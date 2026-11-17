#!/usr/bin/env python3
"""Construit `article-images.php` : une illustration sourcée par article.

La sélection ci-dessous est faite à la main à partir des candidats renvoyés
par `fetch-article-images.py` : image de tête de l'article Wikipédia quand
elle existe, sinon une photographie Commons du sujet ou du lieu concerné.
Chaque entrée garde le fichier d'origine, sa page de description, sa licence
et son auteur, pour que la mention affichée sous l'image soit vérifiable.

Usage : python database/data/build-article-images.py
"""

import json
import os
import urllib.parse
import urllib.request

COMMONS = "https://commons.wikimedia.org/w/api.php"
UA = "Ivoirepedia/1.0 (encyclopedie libre; contact: ivoirepedia@alwaysdata.net)"

# slug -> (fichier Commons, texte alternatif)
CHOICES = {
    "abidjan": ("Abidjan Plateau.png", "Le quartier du Plateau et ses tours, cœur des affaires d'Abidjan."),
    "ahmadou-kourouma": ("Ahmadou Kourouma-FIG 2000 (3).jpeg", "L'écrivain Ahmadou Kourouma au Festival international de géographie de 2000."),
    "alassane-ouattara": ("Alassane Ouattara UNESCO 09-2011.jpg", "Alassane Ouattara en 2011, à l'Unesco."),
    "alpha-blondy": ("Alpha Blondy 013 Tilburg.jpg", "Alpha Blondy en concert à Tilburg."),
    "assemblee-nationale": ("Le Plateau depuis le Pont ADO – Abidjan.jpg", "Le Plateau, quartier des institutions à Abidjan, vu depuis le pont Alassane-Ouattara."),
    "attieke": ("Plat attiéké.jpg", "Une assiette d'attiéké servie avec du poisson et des tomates."),
    "basilique-notre-dame-de-la-paix": ("Basilique Notre-Dame de la Paix Yamoussoukro.jpg", "La basilique Notre-Dame-de-la-Paix de Yamoussoukro et ses colonnades."),
    "bouake": ("Bouaké Collage.jpg", "Vues de Bouaké."),
    "conseil-constitutionnel": ("PlateauSudAbidjanApril2016.JPG", "Immeubles du Plateau, à Abidjan, où siègent les institutions de la République."),
    "constitution-ivoirienne-de-2016": ("Drapeau ivoirien sur le rocher des amoureux, une plage de San-Pédro 01.jpg", "Le drapeau ivoirien flottant sur la plage du rocher des amoureux, à San-Pédro."),
    "coup-d-etat-de-1999": ("Robert Guéï 2.jpg", "Le général Robert Guéï, chef de l'État ivoirien de décembre 1999 à octobre 2000."),
    "crise-politique-de-2002-2011": ("CemaFn.jpg", "Le général Soumaïla Bakayoko, chef d'état-major des Forces nouvelles de Côte d'Ivoire."),
    "didier-drogba": ("Didier Drogba (2019) (cropped2).jpg", "Didier Drogba en 2019."),
    "felix-houphouet-boigny": ("Félix Houphouët-Boigny 1962-07-16.jpg", "Félix Houphouët-Boigny en 1962."),
    "grand-bassam": ("Entrée du palais royal de Grand-Bassam.jpg", "L'entrée du palais royal de Grand-Bassam."),
    "henri-konan-bedie": ("Henri Konan Bédié (P001954018AH).jpg", "Henri Konan Bédié."),
    "independance-de-la-cote-d-ivoire": ("Félix Houphouët-Boigny in 1958.jpg", "Félix Houphouët-Boigny en 1958, deux ans avant l'indépendance du pays."),
    "korhogo": ("Rue de Korhogo.jpg", "Une rue de Korhogo."),
    "l-anacarde": ("Cashew nut tree Anacardium occidentale with unripe cashew apples and nuts at Goa DSCF0333 (8).JPG", "Un anacardier portant des noix de cajou encore vertes."),
    "l-hevea": ("Rubber tapping 3.jpg", "Saignée d'un hévéa : le latex coule dans un godet."),
    "la-brvm": ("BRVM.jpg", "Le siège de la Bourse régionale des valeurs mobilières à Abidjan."),
    "laurent-gbagbo": ("Laurent Gbagbo 2022 (cropped).jpg", "Laurent Gbagbo en 2022."),
    "le-bandama": ("Bandama1.JPG", "Le Bandama et ses rives."),
    "le-baoule": ("Brooklyn Museum 61.3 Male Figure Waka Sran (5).jpg", "Figure masculine waka sran attribuée aux Baoulé, conservée au Brooklyn Museum."),
    "le-bete": ("Brooklyn Museum 56.6.96 Standing Female Figure (2).jpg", "Figure féminine attribuée aux Bété, conservée au Brooklyn Museum."),
    "le-cacao-en-cote-d-ivoire": ("Cocoa tree with pods.jpg", "Un cacaoyer et ses cabosses."),
    "le-coupe-decale": ("TAM SIR et la team Paya au FEMUA en 2024 à Abidjan 17.jpg", "Le groupe TAM SIR et la team Paya sur scène au FEMUA 2024, à Abidjan."),
    "le-dan": ("Pagne traditionnel Yacouba en pays Yacouba.JPG", "Un pagne traditionnel yacouba."),
    "le-dioula": ("Mariage dioula 03.jpg", "Une cérémonie de mariage dioula."),
    "le-franc-cfa": ("Mille francs CFA.jpg", "Billets de mille francs CFA."),
    "le-goli": ("Goli Dance Mask, Cote d'Ivoire, Baule people, 1950s, wood - Chazen Museum of Art - DSC01757.JPG", "Masque de danse goli baoulé conservé au Chazen Museum of Art."),
    "le-kedjenou": ("Kedjenou de Poisson.JPG", "Un kedjenou de poisson."),
    "le-nouchi": ("Street of Abidjan.jpg", "Une rue d'Abidjan."),
    "le-port-d-abidjan": ("Abidjan port warehouses Cote d'Ivoire.jpg", "Les entrepôts du port d'Abidjan."),
    "le-senoufo": ("Woman Xenofu.jpg", "Une femme sénoufo."),
    "le-zaouli": ("Cizaouli.jpg", "Un danseur de zaouli."),
    "le-zouglou": ("Percussionnistes Zouglou au Femua 15.jpg", "Des percussionnistes zouglou au FEMUA."),
    "les-akan": ("Abouré people - peuple Abouré 13.jpg", "Des Abouré, un peuple akan de Côte d'Ivoire."),
    "man": ("Les cascades de Man.jpg", "Les cascades de Man."),
    "marche-des-femmes-de-1949": ("Ecriture en dessous de la statue en Hommage à la Marche des Femmes sur Bassam.JPG", "La statue rendant hommage à la marche des femmes de 1949, à Grand-Bassam."),
    "mont-nimba": ("Mount Nimba Strict Nature Reserve-108450.jpg", "Le mont Nimba et sa réserve naturelle."),
    "parc-national-de-la-comoe": ("Comoé national park on the wayto Gaoui.jpg", "Le parc national de la Comoé."),
    "parc-national-de-tai": ("Taï National Park (24148248710).jpg", "Le parc national de Taï."),
    "parc-national-du-banco": ("Forêt du banco ( Côte d'Ivoire ).jpg", "La forêt du Banco, à Abidjan."),
    "president-de-la-republique": ("PalaisPrésidentielAbidjan2016.jpg", "Le palais présidentiel d'Abidjan."),
    "robert-guei": ("Guéï Robert 1.jpg", "Le général Robert Guéï."),
    "royaume-de-kong": ("Kong3.jpg", "La mosquée de Kong."),
    "samory-toure": ("Almamy Samory Touré-2.jpg", "Portrait d'Almamy Samory Touré."),
    "san-pedro": ("San-Pédro pendant la CAN 2023 03.jpg", "San-Pédro pendant la Coupe d'Afrique des nations 2023."),
    "senat": ("Sénat ivoirien de yamoussoukro.jpg", "Le bâtiment du Sénat à Yamoussoukro."),
    "yamoussoukro": ("Yamoussoukro panorama.jpg", "Panorama de Yamoussoukro."),
}


def api(params):
    query = urllib.parse.urlencode(params)
    request = urllib.request.Request(f"{COMMONS}?{query}", headers={"User-Agent": UA})
    with urllib.request.urlopen(request, timeout=40) as response:
        return json.load(response)


# Quelques fiches Commons donnent un champ « auteur » illisible (pseudo en
# écriture khmère, doublon « Unknown authorUnknown author »). La mention
# affichée est corrigée à la main, sans changer la licence ni la source.
CREDIT_FIX = {
    "abidjan": "Wikimedia Commons",
    "laurent-gbagbo": "Auteur inconnu",
    "le-baoule": "Auteur inconnu",
    "le-bete": "Auteur inconnu",
    "independance-de-la-cote-d-ivoire": "Présence Congolaise",
    "samory-toure": "Joker-x",
}


def php_string(value):
    """Chaîne PHP entre apostrophes, échappée comme l'exige pint."""
    return "'" + value.replace("\\", "\\\\").replace("'", "\\'") + "'"


def strip_html(value):
    text, out, inside = value or "", [], False
    for char in text:
        if char == "<":
            inside = True
        elif char == ">":
            inside = False
        elif not inside:
            out.append(char)
    return " ".join("".join(out).split())


def main():
    files = [f"File:{file}" for file, _ in CHOICES.values()]
    meta = {}
    for start in range(0, len(files), 20):
        payload = api({
            "action": "query",
            "format": "json",
            "prop": "imageinfo",
            "iiprop": "url|extmetadata",
            "iiurlwidth": "1280",
            "titles": "|".join(files[start:start + 20]),
        })
        for page in ((payload.get("query") or {}).get("pages") or {}).values():
            info = (page.get("imageinfo") or [{}])[0]
            values = info.get("extmetadata") or {}
            name = (page.get("title") or "").removeprefix("File:").replace(" ", "_")
            meta[name] = {
                "url": (info.get("thumburl") or "").split("?")[0],
                "page": info.get("descriptionurl"),
                "license": strip_html((values.get("LicenseShortName") or {}).get("value")),
                "artist": strip_html((values.get("Artist") or {}).get("value")),
            }

    missing = []
    entries = []
    for slug, (file, alt) in CHOICES.items():
        details = meta.get(file.replace(" ", "_"))
        if not details or not details["url"] or not details["license"]:
            missing.append(slug)
            print(f"!! {slug} : métadonnées incomplètes ({file})")
            continue
        entries.append((slug, details["url"], alt, CREDIT_FIX.get(slug, details["artist"]), details["license"], details["page"]))

    lines = [
        "<?php",
        "",
        "/**",
        " * Illustrations des articles — une image réelle et sourcée par article.",
        " *",
        " * Toutes viennent de Wikimedia Commons : l'image de tête de l'article",
        " * Wikipédia francophone correspondant quand elle existe, sinon une",
        " * photographie du sujet, du lieu ou de l'objet décrit. Chaque entrée",
        " * garde son fichier d'origine, sa page de description, sa licence et son",
        " * auteur, affichés sous l'image dans l'application (ENF-UX-04).",
        " *",
        " * Généré par `database/data/build-article-images.py` à partir d'une",
        " * sélection relue à la main ; ne pas éditer les URL à la main.",
        " */",
        "return [",
        "",
    ]
    for slug, url, alt, artist, license_name, page in entries:
        lines.append(f"    '{slug}' => [")
        lines.append(f"        'url' => '{url}',")
        lines.append(f"        'alt' => {php_string(alt)},")
        lines.append(f"        'credit' => {php_string(artist)},")
        lines.append(f"        'license' => '{license_name}',")
        lines.append(f"        'page' => '{page}',")
        lines.append("    ],")
        lines.append("")
    lines.append("];")

    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "article-images.php")
    with open(path, "w", encoding="utf-8", newline="\n") as handle:
        handle.write("\n".join(lines) + "\n")
    print(f"{len(entries)} entrées écrites dans {path}")
    if missing:
        raise SystemExit(f"entrées incomplètes : {', '.join(missing)}")


if __name__ == "__main__":
    main()
