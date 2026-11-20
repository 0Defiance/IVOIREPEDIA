"""Contrôle post-déploiement avec des en-têtes de navigateur réels.

`curl` avec `Accept-Encoding: br` seul ne déclenche pas les mêmes règles
Apache qu'un vrai navigateur (`gzip, deflate, br, zstd`) : en novembre 2026,
toutes les vérifications `curl` étaient vertes pendant que le site restait
bloqué (brotli de brotli, `SyntaxError`, écran de chargement infini).
Ce script rejoue le parcours réel :

* la page et le JavaScript avec les en-têtes d'un navigateur ;
* si la réponse annonce `br`, décompression puis comparaison octet à octet
  avec la variante non compressée (demandée en `identity`).

Utilisation (depuis la racine du dépôt) :

    python tools/verify_deploy.py [--base-url https://ivoirepedia.alwaysdata.net]

Sortie 0 si tout est bon, 1 sinon. À lancer après chaque déploiement
(`docs/DEPLOIEMENT.md` §6). Exige le CLI `brotli` pour la décompression.
"""

from __future__ import annotations

import shutil
import subprocess
import sys
import time
import urllib.request
from dataclasses import dataclass

BROWSER_UA = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/120.0 Safari/537.36"
)
# Exactement ce qu'envoie un navigateur moderne : c'est cette valeur qui
# déclenchait la double compression, pas `br` seul.
BROWSER_ENCODING = "gzip, deflate, br, zstd"

TIMEOUT = 180


@dataclass
class Failure:
    where: str
    detail: str


def fetch(url: str, accept_encoding: str) -> tuple[int, dict[str, str], bytes, float]:
    request = urllib.request.Request(
        url,
        headers={"User-Agent": BROWSER_UA, "Accept-Encoding": accept_encoding},
    )
    start = time.monotonic()
    with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
        body = response.read()
        headers = {key.lower(): value for key, value in response.headers.items()}
        return response.status, headers, body, time.monotonic() - start


def brotli_decode(data: bytes) -> bytes:
    brotli = shutil.which("brotli")
    if brotli is None:
        raise RuntimeError("le CLI `brotli` est introuvable dans le PATH")
    completed = subprocess.run(
        [brotli, "-d", "-c"], input=data, capture_output=True, timeout=120
    )
    if completed.returncode != 0:
        raise RuntimeError(
            f"brotli -d a échoué : {completed.stderr.decode('utf-8', 'replace')[:200]}"
        )
    return completed.stdout


def decode_body(body: bytes, encoding: str) -> bytes:
    kind = encoding.split(",")[0].strip()
    if kind == "br":
        return brotli_decode(body)
    if kind == "gzip":
        import gzip

        return gzip.decompress(body)
    return body


def check_page(base: str, failures: list[Failure]) -> None:
    status, headers, body, elapsed = fetch(base + "/", BROWSER_ENCODING)
    try:
        text = decode_body(body, headers.get("content-encoding", "aucun"))
    except RuntimeError as error:
        text = b""
        failures.append(Failure("page", str(error)))
    ok = status == 200 and b"flutter_bootstrap.js" in text
    print(f"page  GET /  {status}  {len(body):,} o  {elapsed:.1f} s  {'OK' if ok else 'ÉCHEC'}")
    if not ok:
        failures.append(Failure("page", f"statut {status} ou bootstrap absent"))


def check_asset(base: str, path: str, failures: list[Failure]) -> None:
    url = base + path
    try:
        status, headers, body, elapsed = fetch(url, BROWSER_ENCODING)
    except Exception as error:  # noqa: BLE001 - le script doit tout rapporter
        print(f"asset  GET {path}  ERREUR  {error}")
        failures.append(Failure(path, str(error)))
        return
    encoding = headers.get("content-encoding", "aucun")
    line = f"asset  GET {path}  {status}  {encoding}  {len(body):,} o  {elapsed:.1f} s"
    if status != 200:
        print(line + "  ÉCHEC")
        failures.append(Failure(path, f"statut {status}"))
        return
    if encoding == "br":
        try:
            decoded = brotli_decode(body)
            _, _, plain, _ = fetch(url, "identity")
            if decoded == plain:
                print(line + f"  OK (décompressé : {len(decoded):,} o, identique)")
            else:
                print(line + "  ÉCHEC (double compression ?)")
                failures.append(
                    Failure(
                        path,
                        f"le corps décompressé ({len(decoded):,} o) diffère "
                        f"de l'original ({len(plain):,} o)",
                    )
                )
        except RuntimeError as error:
            print(line + f"  ÉCHEC ({error})")
            failures.append(Failure(path, str(error)))
    else:
        print(line + "  OK (non compressé)")


def main() -> int:
    base = "https://ivoirepedia.alwaysdata.net"
    for index, argument in enumerate(sys.argv[1:]):
        if argument == "--base-url" and index + 2 < len(sys.argv):
            base = sys.argv[index + 2]
    base = base.rstrip("/")

    print(f"Contrôle post-déploiement de {base} (en-têtes navigateur)")
    failures: list[Failure] = []
    check_page(base, failures)
    for path in (
        "/main.dart.js",
        "/main.dart.js_1.part.js",
        "/canvaskit/canvaskit.wasm",
        "/logo.webp",
    ):
        check_asset(base, path, failures)

    if failures:
        print(f"\n{len(failures)} contrôle(s) en échec :")
        for failure in failures:
            print(f"  - {failure.where} : {failure.detail}")
        return 1
    print("\nTout est bon : le navigateur reçoit du code exécutable.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
