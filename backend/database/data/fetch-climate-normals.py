#!/usr/bin/env python3
"""Construit un instantané des normales climatiques de villes ivoiriennes.

Source : Open-Meteo (archive ERA5, Copernicus Climate Change Service), données
sous licence CC BY 4.0. Le script interroge l'archive jour par jour, agrège en
moyennes mensuelles et en totaux annuels, puis écrit un JSON daté que la
commande `country:sync-statistics` importe — comme pour la Banque mondiale, la
base ne dépend donc jamais du réseau au moment du déploiement.

Exemple :
    python backend/database/data/fetch-climate-normals.py --start 1991-01-01 --end 2020-12-31
"""

from __future__ import annotations

import argparse
import json
import pathlib
import urllib.parse
import urllib.request
from collections import defaultdict

# Villes suivies : les quatre grandes villes et deux chefs-lieux de l'intérieur.
CITIES = [
    ("abidjan", "Abidjan", 5.354, -4.008),
    ("bouake", "Bouaké", 7.690, -5.030),
    ("korhogo", "Korhogo", 9.458, -5.629),
    ("san-pedro", "San-Pédro", 4.748, -6.641),
    ("yamoussoukro", "Yamoussoukro", 6.827, -5.290),
    ("man", "Man", 7.412, -7.554),
]

API = "https://archive-api.open-meteo.com/v1/archive"


def fetch(lat: float, lon: float, start: str, end: str) -> dict:
    query = urllib.parse.urlencode(
        {
            "latitude": lat,
            "longitude": lon,
            "start_date": start,
            "end_date": end,
            "daily": "precipitation_sum,temperature_2m_mean",
            "timezone": "Africa/Abidjan",
        }
    )
    request = urllib.request.Request(
        f"{API}?{query}", headers={"User-Agent": "IVOIREPEDIA/1.0 (statistiques)"}
    )

    with urllib.request.urlopen(request, timeout=180) as response:
        return json.loads(response.read().decode("utf-8"))


def summarise(payload: dict) -> tuple[dict[int, dict[str, float]], dict[int, float]]:
    daily = payload["daily"]
    dates = daily["time"]
    rain = daily["precipitation_sum"]
    temp = daily["temperature_2m_mean"]

    monthly_rain: dict[tuple[int, int], float] = defaultdict(float)
    monthly_temp: dict[tuple[int, int], list[float]] = defaultdict(list)
    yearly_rain: dict[int, float] = defaultdict(float)
    yearly_days: dict[tuple[int, int], int] = defaultdict(int)

    for index, day in enumerate(dates):
        year, month = int(day[0:4]), int(day[5:7])
        value = rain[index] or 0.0
        monthly_rain[(year, month)] += value
        yearly_rain[year] += value
        if value >= 1.0:
            yearly_days[(year, month)] += 1
        if temp[index] is not None:
            monthly_temp[(year, month)].append(float(temp[index]))

    months: dict[int, dict[str, float]] = {}
    years: dict[int, float] = {}

    for month in range(1, 13):
        values = [monthly_rain[(year, month)] for year in sorted(yearly_rain)]
        temps = [t for year in sorted(yearly_rain) for t in monthly_temp[(year, month)]]
        days = [yearly_days[(year, month)] for year in sorted(yearly_rain)]

        months[month] = {
            "rain_mm": round(sum(values) / len(values), 1),
            "rain_days": round(sum(days) / len(days), 1),
            "temperature_c": round(sum(temps) / len(temps), 1) if temps else None,
        }

    for year, total in yearly_rain.items():
        years[year] = round(total, 1)

    return months, years


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--start", default="1991-01-01")
    parser.add_argument("--end", default="2020-12-31")
    parser.add_argument(
        "--out",
        default=str(pathlib.Path(__file__).parent / "climate-normals.json"),
    )
    args = parser.parse_args()

    cities = []

    for slug, name, lat, lon in CITIES:
        payload = fetch(lat, lon, args.start, args.end)
        months, years = summarise(payload)
        annual = round(sum(years.values()) / len(years), 1)
        cities.append(
            {
                "slug": slug,
                "name": name,
                "latitude": lat,
                "longitude": lon,
                "annual_rain_mm": annual,
                "months": [
                    {"month": month, **months[month]} for month in range(1, 13)
                ],
                "years": [{"year": year, "rain_mm": total} for year, total in sorted(years.items())],
            }
        )
        print(f"{name}: {annual} mm/an")

    snapshot = {
        "source": {
            "name": "Open-Meteo — réanalyse ERA5 (Copernicus)",
            "url": "https://open-meteo.com/en/docs/historical-weather-api",
            "licence": "CC BY 4.0",
            "dataset": "ERA5-Land / ERA5, service Copernicus Climate Change",
        },
        "period": {"start": args.start, "end": args.end},
        "generated_at": __import__("datetime").date.today().isoformat(),
        "cities": cities,
    }

    path = pathlib.Path(args.out)
    path.write_text(json.dumps(snapshot, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Écrit : {path} ({path.stat().st_size} octets)")


if __name__ == "__main__":
    main()
