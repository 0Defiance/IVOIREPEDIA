#!/usr/bin/env python3
"""Trouve l'illustration de tête de chaque article sur Wikipédia/Commons.

Choix de méthode : l'image de tête de l'article Wikipédia francophone
correspondant est celle que les contributeurs ont retenue comme
représentative du sujet. Le script récupère son URL, puis la licence et
l'auteur depuis les métadonnées Commons, pour que chaque image publiée par
IVOIREPEDIA porte sa source et sa licence.

Il ne publie rien : il écrit `article-image-candidates.json`, relu et figé à
la main dans `article-images.php`.

Usage : python database/data/fetch-article-images.py
"""

import json
import os
import time
import urllib.parse
import urllib.request

WIKI = "https://fr.wikipedia.org/w/api.php"
COMMONS = "https://commons.wikimedia.org/w/api.php"
UA = "Ivoirepedia/1.0 (encyclopedie libre; contact: ivoirepedia@alwaysdata.net)"

# slug IVOIREPEDIA -> titre de l'article Wikipédia francophone
TITLES = {
    "abidjan": "Abidjan",
    "ahmadou-kourouma": "Ahmadou Kourouma",
    "alassane-ouattara": "Alassane Ouattara",
    "alpha-blondy": "Alpha Blondy",
    "assemblee-nationale": "Assemblée nationale (Côte d'Ivoire)",
    "attieke": "Attiéké",
    "basilique-notre-dame-de-la-paix": "Basilique Notre-Dame-de-la-Paix de Yamoussoukro",
    "bouake": "Bouaké",
    "conseil-constitutionnel": "Conseil constitutionnel (Côte d'Ivoire)",
    "constitution-ivoirienne-de-2016": "Constitution de la Côte d'Ivoire",
    "coup-d-etat-de-1999": "Coup d'État de 1999 en Côte d'Ivoire",
    "crise-politique-de-2002-2011": "Première guerre civile ivoirienne",
    "didier-drogba": "Didier Drogba",
    "felix-houphouet-boigny": "Félix Houphouët-Boigny",
    "grand-bassam": "Grand-Bassam",
    "henri-konan-bedie": "Henri Konan Bédié",
    "independance-de-la-cote-ivoire": "Côte d'Ivoire",
    "korhogo": "Korhogo",
    "l-anacarde": "Anacardier",
    "l-hevea": "Hévéa",
    "la-brvm": "Bourse régionale des valeurs mobilières",
    "laurent-gbagbo": "Laurent Gbagbo",
    "le-bandama": "Bandama",
    "le-baoule": "Baoulés",
    "le-bete": "Bétés",
    "le-cacao-en-cote-d-ivoire": "Cacaoyer",
    "le-coupe-decale": "Coupé-décalé",
    "le-dan": "Dan (peuple)",
    "le-dioula": "Dioula (peuple)",
    "le-franc-cfa": "Franc CFA",
    "le-goli": "Goli (masque)",
    "le-kedjenou": "Kedjenou",
    "le-nouchi": "Nouchi",
    "le-port-d-abidjan": "Port autonome d'Abidjan",
    "le-senoufo": "Sénoufos",
    "le-zaouli": "Zaouli",
    "le-zouglou": "Zouglou",
    "les-akan": "Akans",
    "man": "Man (Côte d'Ivoire)",
    "marche-des-femmes-de-1949": "Marche des femmes de 1949",
    "mont-nimba": "Mont Nimba",
    "parc-national-de-la-comoe": "Parc national de la Comoé",
    "parc-national-de-tai": "Parc national de Taï",
    "parc-national-du-banco": "Parc national du Banco",
    "president-de-la-republique": "Palais présidentiel d'Abidjan",
    "robert-guei": "Robert Guéï",
    "royaume-de-kong": "Kong (Côte d'Ivoire)",
    "samory-toure": "Samory Touré",
    "san-pedro": "San-Pédro (Côte d'Ivoire)",
    "senat": "Sénat (Côte d'Ivoire)",
    "yamoussoukro": "Yamoussoukro",
    # Série « Villes de Côte d'Ivoire » (séance 40 et suivantes).
    "abengourou": "Abengourou",
    "aboisso": "Aboisso",
    "adzope": "Adzopé",
    "agboville": "Agboville",
    "agnibilekrou": "Agnibilékrou",
    "blolequin": "Bloléquin",
    "bondoukou": "Bondoukou",
    "bonon": "Bonon",
    "bouafle": "Bouaflé",
    "bouna": "Bouna",
    "boundiali": "Boundiali",
    "buyo": "Buyo (Côte d'Ivoire)",
    "dabou": "Dabou",
    "daloa": "Daloa",
    "danane": "Danané",
    "daoukro": "Daoukro",
    "divo": "Divo (Côte d'Ivoire)",
    "duekoue": "Duékoué",
    "ferkessedougou": "Ferkessédougou",
    "gagnoa": "Gagnoa",
    "guiglo": "Guiglo",
    "issia": "Issia",
    "katiola": "Katiola",
    "lakota": "Lakota (Côte d'Ivoire)",
    "meagui": "Méagui",
    "oume": "Oumé",
    "seguela": "Séguéla (Côte d'Ivoire)",
    "sikensi": "Sikensi",
    "sinfra": "Sinfra",
    "soubre": "Soubré",
    "tengrela": "Tengréla",
    "toumodi": "Toumodi",
    "vavoua": "Vavoua",
    "zouan-hounien": "Zouan-Hounien",
}


def api(url, params):
    query = urllib.parse.urlencode(params)
    request = urllib.request.Request(f"{url}?{query}", headers={"User-Agent": UA})
    for attempt in range(5):
        try:
            with urllib.request.urlopen(request, timeout=40) as response:
                return json.load(response)
        except urllib.error.HTTPError as error:
            if error.code != 429 or attempt == 4:
                raise
            time.sleep(10 * (attempt + 1))
    raise RuntimeError("API indisponible")


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


def lead_images(titles):
    """Image de tête de chaque page Wikipédia (une requête pour 40 titres)."""
    reverse = {title: slug for slug, title in titles.items()}
    found = {}

    items = list(titles.items())
    for start in range(0, len(items), 40):
        chunk = dict(items[start:start + 40])
        payload = api(WIKI, {
            "action": "query",
            "format": "json",
            "redirects": "1",
            "prop": "pageimages",
            "piprop": "thumbnail|name",
            "pithumbsize": "1280",
            "titles": "|".join(chunk.values()),
        })
        query = payload.get("query") or {}
        normalized = {}
        for entry in query.get("normalized") or []:
            normalized[entry["to"]] = entry["from"]
        redirects = {}
        for entry in query.get("redirects") or []:
            redirects[entry["to"]] = entry["from"]

        for page in (query.get("pages") or {}).values():
            title = page.get("title")
            slug = reverse.get(title)
            # Suit les normalisations et redirections pour retrouver le slug.
            for mapping in (redirects, normalized):
                while title in mapping:
                    title = mapping[title]
                    slug = slug or reverse.get(title)
            slug = slug or reverse.get(title)
            if not slug:
                continue
            thumb = (page.get("thumbnail") or {}).get("source")
            if thumb:
                found[slug] = {"file": page.get("pageimage"), "thumb": thumb}
        time.sleep(1)

    return found


def commons_metadata(files):
    """Licence, auteur et page de description pour chaque fichier."""
    meta = {}
    names = [f"File:{name}" for name in files if name]
    for start in range(0, len(names), 20):
        chunk = names[start:start + 20]
        payload = api(COMMONS, {
            "action": "query",
            "format": "json",
            "prop": "imageinfo",
            "iiprop": "url|extmetadata",
            "iiurlwidth": "1280",
            "titles": "|".join(chunk),
        })
        for page in ((payload.get("query") or {}).get("pages") or {}).values():
            info = (page.get("imageinfo") or [{}])[0]
            values = info.get("extmetadata") or {}
            title = page.get("title", "").removeprefix("File:")
            meta[title] = {
                "page": info.get("descriptionurl"),
                "thumb": (info.get("thumburl") or "").split("?")[0],
                "license": strip_html((values.get("LicenseShortName") or {}).get("value")),
                "artist": strip_html((values.get("Artist") or {}).get("value")),
                "credit": strip_html((values.get("Credit") or {}).get("value")),
            }
        time.sleep(1)
    return meta


def main():
    leads = lead_images(TITLES)
    meta = commons_metadata([item["file"] for item in leads.values()])
    print(f"{len(leads)} images de tête, {len(meta)} fiches Commons")

    result = {}
    for slug in TITLES:
        lead = leads.get(slug)
        if not lead:
            result[slug] = None
            continue
        details = meta.get(lead["file"] or "", {})
        result[slug] = {
            "file": lead["file"],
            "url": details.get("thumb") or lead["thumb"],
            "page": details.get("page"),
            "license": details.get("license"),
            "artist": details.get("artist") or details.get("credit"),
        }

    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "article-image-candidates.json")
    with open(path, "w", encoding="utf-8") as handle:
        json.dump(result, handle, ensure_ascii=False, indent=2)

    missing = [slug for slug, value in result.items() if not value]
    print(f"écrit {path}")
    print(f"sans image ({len(missing)}) : {', '.join(missing)}")


if __name__ == "__main__":
    main()
