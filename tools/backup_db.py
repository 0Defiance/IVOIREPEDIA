#!/usr/bin/env python3
"""Sauvegarde et restauration de la base et des médias IVOIREPEDIA (Alwaysdata).

Le poste de travail n'a pas de client MySQL (ADR-002) : tout passe par SSH sur le
compte d'hébergement, qui a `mysqldump` et `mysql` et dont le `.env` porte les
identifiants. Le script ne lit jamais ces identifiants côté poste : il demande à
Laravel, sur le serveur, la configuration `database.connections.mysql`, puis la
range dans un fichier d'options `600` à usage unique (`--defaults-extra-file`).

    python ../tools/backup_db.py backup            # dump base + médias, rapatriés
    python ../tools/backup_db.py restore --dump backups/20261128-…/db-….sql.gz \\
        --database ivoirepedia_dev --yes           # essai de restauration
    python ../tools/backup_db.py counts --database ivoirepedia_dev

`backup` laisse `--keep` couples (7 par défaut) dans `~/backups` sur le serveur
et rapatrie la dernière paire dans `backups/` à la racine du dépôt (ignoré par
Git : ce sont des données, pas du code).
"""

from __future__ import annotations

import argparse
import json
import os
import shlex
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
KEY = ROOT / ".deploy" / "ivoirepedia_ed25519"
HOST = "ssh-ivoirepedia.alwaysdata.net"
USER = "ivoirepedia"
REMOTE = "~/ivoirepedia"
BACKEND = f"{REMOTE}/backend"
REMOTE_BACKUPS = "~/backups"
DEFAULTS_FILE = "/tmp/ivp-mysql.cnf"
TABLES = ("articles", "users", "categories", "tags", "article_versions", "editorial_actions")


def die(message: str) -> None:
    print(f"ERREUR : {message}", file=sys.stderr)
    raise SystemExit(1)


def ssh(command: str, stdin: str | None = None, check: bool = True) -> subprocess.CompletedProcess:
    """Exécute une commande sur le compte d'hébergement (clé de déploiement)."""
    if not KEY.exists():
        die(f"clé de déploiement absente : {KEY}")
    args = [
        "ssh",
        "-o",
        "BatchMode=yes",
        "-o",
        "ConnectTimeout=20",
        "-i",
        str(KEY),
        f"{USER}@{HOST}",
        command,
    ]
    result = subprocess.run(args, input=stdin, text=True, capture_output=True)
    if check and result.returncode != 0:
        die(f"commande distante échouée ({result.returncode}) : {command}\n{result.stderr.strip()}")
    return result


def scp(remote: str, local: str) -> None:
    result = subprocess.run(
        ["scp", "-q", "-i", str(KEY), f"{USER}@{HOST}:{remote}", local],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        die(f"copie de {remote} échouée : {result.stderr.strip()}")


def scp_up(local: str, remote: str) -> None:
    result = subprocess.run(
        ["scp", "-q", "-i", str(KEY), local, f"{USER}@{HOST}:{remote}"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        die(f"envoi de {local} échoué : {result.stderr.strip()}")


def db_config() -> dict[str, str]:
    """Configuration MySQL lue par Laravel sur le serveur (jamais affichée)."""
    code = (
        'require "vendor/autoload.php";'
        ' $app = require "bootstrap/app.php";'
        " $app->make(Illuminate\\Contracts\\Console\\Kernel::class)->bootstrap();"
        ' $c = config("database.connections.mysql");'
        " echo json_encode(["
        ' "host" => $c["host"], "port" => $c["port"], "database" => $c["database"],'
        ' "username" => $c["username"], "password" => $c["password"]]);'
    )
    result = ssh(f"cd {BACKEND} && php -r {shlex.quote(code)}")
    try:
        return json.loads(result.stdout.strip())
    except json.JSONDecodeError:
        die("configuration MySQL illisible depuis le serveur")


def quote_option(value: str) -> str:
    """Valeur de fichier d'options MySQL : guillemets et antislashs échappés."""
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'


def write_defaults(config: dict[str, str]) -> None:
    """Écrit le fichier d'options (600) et le supprime en sortie de commande."""
    body = "\n".join(
        [
            "[client]",
            f"host = {quote_option(str(config['host']))}",
            f"port = {config.get('port') or 3306}",
            f"user = {quote_option(str(config['username']))}",
            f"password = {quote_option(str(config['password']))}",
            "",
        ]
    )
    ssh(f"umask 077; cat > {DEFAULTS_FILE}", stdin=body)


def mysql(command: str, database: str, check: bool = True) -> subprocess.CompletedProcess:
    """Commande `mysql` sur la base visée, avec le fichier d'options."""
    sql = shlex.quote(command)
    return ssh(
        f"mysql --defaults-extra-file={DEFAULTS_FILE} --default-character-set=utf8mb4 "
        f"-N -B {shlex.quote(database)} -e {sql}",
        check=check,
    )


def counts(database: str) -> dict[str, int]:
    """Nombre de lignes des tables qui portent le contenu et les comptes."""
    values: dict[str, int] = {}
    for table in TABLES:
        result = mysql(f"SELECT COUNT(*) FROM {table};", database, check=False)
        text = result.stdout.strip()
        if result.returncode == 0 and text.isdigit():
            values[table] = int(text)
    return values


def show_counts(title: str, values: dict[str, int]) -> None:
    print(title)
    for table in TABLES:
        if table in values:
            print(f"  {table:<20} {values[table]:>8}")


def cmd_backup(args: argparse.Namespace) -> int:
    config = db_config()
    database = args.database or config["database"]
    write_defaults(config)

    print(f"Sauvegarde de {database} et des médias sur {HOST}…")
    stamp = time.strftime("%Y%m%d-%H%M%S")
    dump = f"{REMOTE_BACKUPS}/db-{database}-{stamp}.sql.gz"
    media = f"{REMOTE_BACKUPS}/media-{stamp}.tar.gz"
    dump_cmd = (
        f"mysqldump --defaults-extra-file={DEFAULTS_FILE} --single-transaction --quick "
        f"--skip-lock-tables --default-character-set=utf8mb4 {shlex.quote(database)} "
        f"| gzip -9 > {dump}"
    )
    media_cmd = (
        f"tar czf {media} -C {BACKEND} --exclude=storage/logs storage/app"
    )
    prune_cmd = (
        f"ls -1t {REMOTE_BACKUPS}/db-*.sql.gz 2>/dev/null | tail -n +{args.keep + 1} | xargs -r rm -f; "
        f"ls -1t {REMOTE_BACKUPS}/media-*.tar.gz 2>/dev/null | tail -n +{args.keep + 1} | xargs -r rm -f"
    )
    ssh(f"set -e; mkdir -p {REMOTE_BACKUPS}; {dump_cmd}; {media_cmd}; {prune_cmd}; rm -f {DEFAULTS_FILE}")

    sizes = ssh(f"du -h {dump} {media} | cut -f1,2")
    print(sizes.stdout.strip())

    local_dir = ROOT / "backups" / stamp
    local_dir.mkdir(parents=True, exist_ok=True)
    scp(dump, str(local_dir / Path(dump).name))
    scp(media, str(local_dir / Path(media).name))
    print(f"Rapatrié dans {local_dir}")
    print(f"Conservé sur le serveur : {args.keep} dernières paires dans {REMOTE_BACKUPS}")
    return 0


def cmd_restore(args: argparse.Namespace) -> int:
    local = Path(args.dump)
    if not local.exists():
        die(f"dump introuvable : {local}")
    if not args.yes:
        die("restauration destructive : relancer avec --yes après avoir vérifié la base visée")

    config = db_config()
    write_defaults(config)
    before = counts(args.database)
    show_counts(f"Avant restauration — {args.database}", before)

    remote = f"/tmp/ivp-restore-{int(time.time())}.sql.gz"
    print(f"Envoi de {local.name} vers le serveur…")
    scp_up(str(local), remote)
    print(f"Restauration dans {args.database}…")
    ssh(
        f"set -e; zcat {remote} | mysql --defaults-extra-file={DEFAULTS_FILE} "
        f"--default-character-set=utf8mb4 {shlex.quote(args.database)}; rm -f {remote}"
    )

    after = counts(args.database)
    ssh(f"rm -f {DEFAULTS_FILE}")
    if not after:
        die("compteurs illisibles après la restauration : la base ne répond pas")
    show_counts(f"Après restauration — {args.database}", after)
    changed = [name for name in TABLES if before.get(name) != after.get(name)]
    if changed:
        print("Tables dont le compte a changé : " + ", ".join(changed))
    else:
        print("Compteurs identiques avant et après : le dump couvre les mêmes tables.")
    return 0


def cmd_counts(args: argparse.Namespace) -> int:
    config = db_config()
    write_defaults(config)
    show_counts(f"{args.database} ({config['host']})", counts(args.database))
    ssh(f"rm -f {DEFAULTS_FILE}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Sauvegarde et restauration IVOIREPEDIA (Alwaysdata)")
    sub = parser.add_subparsers(dest="command", required=True)

    backup = sub.add_parser("backup", help="dump de la base + archive des médias, rapatriés")
    backup.add_argument("--keep", type=int, default=7, help="paires conservées sur le serveur")
    backup.add_argument(
        "--database", default=None, help="base à sauvegarder (par défaut celle du .env du serveur)"
    )
    backup.set_defaults(func=cmd_backup)

    restore = sub.add_parser("restore", help="réimporte un dump dans une base")
    restore.add_argument("--dump", required=True, help="fichier .sql.gz local")
    restore.add_argument("--database", required=True, help="base cible, ex. ivoirepedia_dev")
    restore.add_argument("--yes", action="store_true", help="confirme l'écrasement de la base cible")
    restore.set_defaults(func=cmd_restore)

    counts_cmd = sub.add_parser("counts", help="compteurs de lignes par table")
    counts_cmd.add_argument("--database", required=True, help="base interrogée")
    counts_cmd.set_defaults(func=cmd_counts)

    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    os.environ.setdefault("PYTHONIOENCODING", "utf-8")
    raise SystemExit(main())
