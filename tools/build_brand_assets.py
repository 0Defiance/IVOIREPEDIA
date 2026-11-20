"""Dérive les visuels de la marque IVOIREPEDIA depuis les originaux fournis.

Les sources sont fournies par le propriétaire du site : la dernière version
est déjà détourée (canal alpha), le script se contente alors de la recadrer.
Si une source revient sur fond crème (ou blanc), `cutout()` la détoure par
diffusion depuis les bords. Le script écrit ensuite les fichiers utilisés par
l'application Flutter, l'écran de chargement HTML et les icônes d'onglet.

Utilisation (depuis la racine du dépôt) :

    python tools/build_brand_assets.py

Les originaux sont lus dans `.cloud-attachments/` ; ils ne sont pas versionnés.
"""

from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
ATTACHMENTS = ROOT / ".cloud-attachments"
IMAGES = ROOT / "app" / "assets" / "images"
WEB = ROOT / "app" / "web"
ICONS = WEB / "icons"

EMBLEM = ATTACHMENTS / "454640e5327be3e58ffe4cd789506c13da159cc794a3316add712ab669a3b25b.webp"
LOCKUP = ATTACHMENTS / "3ec145ef3cfa4d8fe552cbe8cffc0286be1f1b0f454bd8974f37417949e15243.webp"

# Racine servie en production : les fichiers de repli de l'écran de
# chargement y vivent aussi, JSON-LD (`publisher.logo`) compris.
INSTANCE = ROOT / "backend" / "public"

# Fond des icônes : le papier ivoire du site, opaque, pour que la marque reste
# lisible sur un onglet clair comme sur un onglet sombre.
PAPER = (251, 249, 244, 255)


def cutout(
    image: Image.Image,
    pages_from: int = 0,
    tolerance: int = 22,
    hole_tolerance: int = 6,
    min_hole: int = 60,
) -> Image.Image:
    """Rend transparent le fond clair, y compris l'ombre portée.

    Deux seuils, parce que le fond et l'ivoire se ressemblent :

    * la diffusion depuis les bords retire le fond clair ; l'ombre douce
      posée sous le livre est écartée en coupant l'image sous la dernière
      ligne colorée de la marque (le trait de la couverture) ;
    * les creux restés enfermés dans la marque (entre les oreilles, sous la
      trompe, contres des lettres) n'acceptent qu'un blanc presque pur (6),
      sinon l'ivoire de l'éléphant — enfermé lui aussi — partirait avec eux.
      Les pages du livre, situées sous `pages_from`, sont préservées.
    """
    rgb = image.convert("RGB")

    # L'ombre portée est un gris neutre : elle n'a aucune couleur saturée.
    # On coupe donc sous la dernière ligne colorée de la marque, ce qui la
    # retire sans toucher aux pages blanches du livre.
    probe = np.asarray(rgb).astype(int)
    coloured = (probe.max(axis=2) - probe.min(axis=2)) > 40
    rows = np.flatnonzero(coloured.sum(axis=1) > 8)
    if rows.size:
        rgb = rgb.crop((0, 0, rgb.width, min(rgb.height, int(rows[-1]) + 2)))

    array = np.asarray(rgb).astype(int)
    corners = np.array(
        [array[0, 0], array[0, -1], array[-1, 0], array[-1, -1]]
    )
    background = np.median(corners, axis=0)
    distance = np.abs(array - background).max(axis=2)

    # 0 = couleur de fond, 255 = sujet. `.copy()` rend l'image inscriptible :
    # Pillow refuse silencieusement de remplir une image issue de `fromarray`,
    # qui partage son tampon.
    binary = Image.fromarray(((distance > tolerance) * 255).astype(np.uint8), "L").copy()
    ImageDraw.floodfill(binary, (0, 0), 128, thresh=0)
    transparent = np.asarray(binary) == 128

    transparent |= _enclosed_holes(
        distance <= hole_tolerance,
        distance=distance,
        pages_from=pages_from,
        min_area=min_hole,
    )

    # Il reste, juste sous la couverture, la ligne claire de l'ombre : un gris
    # neutre. On l'efface dans la bande basse, où seuls le vert et l'orange de
    # la couverture sont colorés et doivent donc rester opaques.
    if pages_from:
        saturation = array.max(axis=2) - array.min(axis=2)
        band = np.zeros_like(transparent)
        band[max(0, transparent.shape[0] - 24) :, :] = True
        transparent |= band & (saturation < 12)

    alpha = np.where(transparent, 0, 255).astype(np.uint8)
    mask = Image.fromarray(alpha, "L")

    # Un pixel de retrait puis un flou léger : le liseré crème des bords ne
    # survit pas, et la découpe reste douce (pas d'escalier).
    mask = mask.filter(ImageFilter.MinFilter(3))
    mask = mask.filter(ImageFilter.GaussianBlur(0.8))

    result = rgb.convert("RGBA")
    result.putalpha(mask)
    return result


def _enclosed_holes(
    candidates: np.ndarray,
    distance: np.ndarray,
    pages_from: int,
    min_area: int = 60,
    ring_threshold: float = 60,
) -> np.ndarray:
    """Composantes de fond restées enfermées dans la marque.

    Un creux de fond est cerné par le trait sombre de la marque : la couronne
    de pixels qui l'entoure s'éloigne nettement du papier. Un reflet d'ivoire
    est cerné d'ivoire, donc proche du papier : il reste opaque. C'est ce que
    mesure `ring_threshold`. `pages_from` protège en plus le bas de l'image,
    où les pages du livre doivent rester blanches.
    """
    from collections import deque

    height, width = candidates.shape
    seen = np.zeros_like(candidates)
    holes = np.zeros_like(candidates)

    for seed_y, seed_x in np.argwhere(candidates):
        if seen[seed_y, seed_x]:
            continue

        queue = deque([(int(seed_y), int(seed_x))])
        seen[seed_y, seed_x] = True
        component: list[tuple[int, int]] = []

        while queue:
            y, x = queue.popleft()
            component.append((y, x))
            for next_y, next_x in ((y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)):
                if (
                    0 <= next_y < height
                    and 0 <= next_x < width
                    and candidates[next_y, next_x]
                    and not seen[next_y, next_x]
                ):
                    seen[next_y, next_x] = True
                    queue.append((next_y, next_x))

        if len(component) < min_area:
            continue

        ys, xs = zip(*component)
        lowest = max(ys)
        if pages_from and lowest >= pages_from:
            continue

        # Couronne de quatre pixels autour du creux : elle porte le trait de
        # la marque s'il s'agit d'un trou, de l'ivoire s'il s'agit d'un reflet.
        top, left = min(ys), min(xs)
        shape = (max(ys) - top + 1, max(xs) - left + 1)
        patch = np.zeros(shape, dtype=np.uint8)
        patch[np.array(ys) - top, np.array(xs) - left] = 255
        grown = np.asarray(
            Image.fromarray(patch, "L").filter(ImageFilter.MaxFilter(9))
        )
        ring = (grown > 0) & (patch == 0)
        if ring.any() and distance[top : top + shape[0], left : left + shape[1]][ring].mean() < ring_threshold:
            continue

        holes[list(ys), list(xs)] = True

    return holes


def transparent(image: Image.Image) -> bool:
    """Vrai si l'image arrive déjà détourée (fond alpha à zéro)."""
    alpha = np.asarray(image.convert("RGBA"))[..., 3]
    return bool((alpha == 0).any())


def trim(image: Image.Image, pad: int = 0) -> Image.Image:
    """Recadre sur le sujet, avec une marge optionnelle."""
    box = image.getchannel("A").point(lambda value: 255 if value > 8 else 0).getbbox()
    if box is None:
        return image

    left, top, right, bottom = box
    return image.crop(
        (
            max(0, left - pad),
            max(0, top - pad),
            min(image.width, right + pad),
            min(image.height, bottom + pad),
        )
    )


def resize(image: Image.Image, *, height: int | None = None, width: int | None = None) -> Image.Image:
    if height is not None:
        width = round(image.width * height / image.height)
    assert width is not None
    return image.resize((width, height or round(image.height * width / image.width)), Image.LANCZOS)


def save_webp(image: Image.Image, path: Path, quality: int = 90) -> None:
    image.save(path, "WEBP", quality=quality, method=6)
    print(f"{path.relative_to(ROOT)}  {image.width}×{image.height}  {path.stat().st_size:,} o")


def square_icon(
    emblem: Image.Image,
    size: int,
    fill: float,
    rounded: bool = True,
) -> Image.Image:
    """Emblème centré sur un carré de papier ; `fill` est sa part de la hauteur.

    Le carré est arrondi pour l'onglet (la marque ne flotte pas dans un coin
    blanc), mais plein pour la variante « maskable », qui doit couvrir tout
    le gabarit Android.
    """
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)
    if rounded:
        draw.rounded_rectangle(
            (0, 0, size - 1, size - 1), radius=round(size * 0.2), fill=PAPER
        )
    else:
        draw.rectangle((0, 0, size, size), fill=PAPER)

    # Le gabarit est un carré : c'est la plus grande dimension de l'emblème
    # qui le remplit, sinon une marque large déborderait de l'icône.
    target = round(size * fill)
    scaled = resize(emblem, width=target)
    if scaled.height > target:
        scaled = resize(emblem, height=target)
    canvas.alpha_composite(
        scaled,
        ((size - scaled.width) // 2, (size - scaled.height) // 2),
    )
    return canvas


def main() -> None:
    for directory in (IMAGES, ICONS):
        directory.mkdir(parents=True, exist_ok=True)

    emblem_source = Image.open(EMBLEM).convert("RGBA")
    lockup_source = Image.open(LOCKUP).convert("RGBA")

    # Emblème : le visuel seul, sans le fond. La source est déjà détourée ;
    # `cutout()` ne sert que si elle revient sur fond clair.
    emblem = trim(
        emblem_source if transparent(emblem_source) else cutout(emblem_source, pages_from=800)
    )
    save_webp(resize(emblem, height=880), IMAGES / "marque.webp")

    # Mot-symbole : la ligne « IVOIREPEDIA » de la signature horizontale,
    # détachée de son emblème, de son filet et de sa devise (bande y 155-282).
    wordmark = trim(lockup_source.crop((600, 150, 1570, 290)), pad=2)
    save_webp(resize(wordmark, height=150), IMAGES / "logo-mot.webp")

    # Signature complète : emblème + nom + devise, pour la couverture, la
    # manchette et l'écran de chargement. Le papier du thème prend le relais
    # là où le fond est transparent.
    lockup = trim(
        lockup_source if transparent(lockup_source) else cutout(lockup_source, pages_from=330)
    )
    save_webp(resize(lockup, width=1200), IMAGES / "logo.webp")

    # Écran de chargement HTML : la même signature, WebP puis PNG de repli.
    loader = resize(lockup, width=1200)
    save_webp(loader, WEB / "logo.webp", quality=88)
    loader.save(WEB / "logo.png", optimize=True)
    print(f"app/web/logo.png  {loader.width}×{loader.height}  {(WEB / 'logo.png').stat().st_size:,} o")

    # Icônes d'onglet et de bureau : carré opaque, marges généreuses pour que
    # la marque ne soit pas rognée par les navigateurs.
    icon = square_icon(emblem, 512, 0.9)
    for size in (512, 192, 180, 64, 32):
        icon.resize((size, size), Image.LANCZOS).save(ICONS / f"Icon-{size}.png", optimize=True)
    icon.resize((180, 180), Image.LANCZOS).save(ICONS / "apple-touch-icon.png", optimize=True)

    # Variante « maskable » : la zone sûre d'Android est un cercle de 80 %.
    maskable = square_icon(emblem, 512, 0.62, rounded=False)
    for size in (512, 192):
        maskable.resize((size, size), Image.LANCZOS).save(
            ICONS / f"Icon-maskable-{size}.png", optimize=True
        )

    # favicon.png (32 px, affichage net dans l'onglet) et favicon.ico
    # multi-tailles, que les navigateurs demandent d'eux-mêmes à la racine.
    icon.resize((32, 32), Image.LANCZOS).save(WEB / "favicon.png", optimize=True)
    icon.resize((64, 64), Image.LANCZOS).save(
        WEB / "favicon.ico",
        format="ICO",
        sizes=[(16, 16), (32, 32), (48, 48), (64, 64)],
    )
    print(f"app/web/favicon.ico  {(WEB / 'favicon.ico').stat().st_size:,} o")

    # Replis côté serveur : la racine du site sert aussi l'emblème (JSON-LD
    # `publisher.logo`) et les icônes même sans build Flutter.
    INSTANCE.mkdir(parents=True, exist_ok=True)
    loader.save(INSTANCE / "logo.png", optimize=True)
    icon.resize((32, 32), Image.LANCZOS).save(INSTANCE / "favicon.png", optimize=True)
    icon.resize((64, 64), Image.LANCZOS).save(
        INSTANCE / "favicon.ico",
        format="ICO",
        sizes=[(16, 16), (32, 32), (48, 48), (64, 64)],
    )
    print(f"backend/public/logo.png  {(INSTANCE / 'logo.png').stat().st_size:,} o")

    # Contrôle visuel : la marque posée sur papier clair, sépia et nuit.
    for name, colour in (
        ("paper", (251, 249, 244)),
        ("night", (24, 28, 26)),
    ):
        sheet = Image.new("RGB", (900, 420), colour)
        mark = resize(emblem, height=340)
        sheet.paste(mark, ((900 - mark.width) // 2, (420 - mark.height) // 2), mark)
        sheet.save(ATTACHMENTS / f"preview-{name}.png")
        small = Image.new("RGB", (240, 240), colour)
        tiny = icon.resize((96, 96), Image.LANCZOS)
        small.paste(tiny, ((240 - 96) // 2, (240 - 96) // 2), tiny)
        small.save(ATTACHMENTS / f"preview-icon-{name}.png")

        # La signature complète, dans sa taille d'en-tête, sur le même fond.
        header = Image.new("RGB", (620, 150), colour)
        signature = resize(lockup, height=72)
        header.paste(signature, (20, (150 - signature.height) // 2), signature)
        header.save(ATTACHMENTS / f"preview-lockup-{name}.png")


if __name__ == "__main__":
    main()
