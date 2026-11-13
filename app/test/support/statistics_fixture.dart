import 'package:ivoirepedia/src/models/statistics.dart';

/// Jeu de statistiques en mémoire : les valeurs reprennent celles du RGPH 2021
/// et de la Banque mondiale, mais aucun test ne dépend du réseau.
StatisticsSnapshot statisticsFixture() {
  const source = StatisticSource(
    name: 'Banque mondiale — WDI',
    url: 'https://data.worldbank.org/country/ci',
    licence: 'CC BY 4.0',
  );

  return StatisticsSnapshot(
    census: const CensusSummary(
      year: 2021,
      population: 29389150,
      households: 5616487,
      averageSize: 5.2,
      womenShare: 47.8,
      growthPercent: 2.4,
      growthYear: 2025,
      source: StatisticSource(
        name: 'ANStat — RGPH 2021',
        url: 'https://plan.gouv.ci/',
        licence: 'Licence Ouverte',
      ),
    ),
    headline: const [
      StatisticIndicator(
        code: 'SP.POP.TOTL',
        label: 'Population totale',
        display: '32 711 547 habitants',
        year: 2025,
        series: [
          StatisticPoint(year: 2023, value: 31165654),
          StatisticPoint(year: 2024, value: 31934230),
          StatisticPoint(year: 2025, value: 32711547),
        ],
        trend: StatisticTrend(
          fromYear: 2020,
          toYear: 2025,
          display: '+2,5 % par an (2020-2025)',
          percentPerYear: 2.49,
          absolutePerYear: 757219.6,
          direction: 'hausse',
        ),
        source: source,
      ),
      StatisticIndicator(
        code: 'NY.GDP.MKTP.CD',
        label: 'Produit intérieur brut',
        display: '87 113 179 149 USD courants',
        year: 2024,
        series: [],
        source: source,
      ),
    ],
    themes: const [
      StatisticTheme(
        code: 'demographie',
        label: 'Démographie',
        indicators: [
          StatisticIndicator(
            code: 'SP.POP.GROW',
            label: 'Croissance démographique',
            display: '2,4 % par an',
            year: 2025,
            series: [],
            source: source,
          ),
          StatisticIndicator(
            code: 'SP.DYN.LE00.IN',
            label: 'Espérance de vie à la naissance',
            display: '62,1 ans',
            year: 2024,
            series: [],
            source: source,
          ),
        ],
      ),
      StatisticTheme(
        code: 'education',
        label: 'Éducation',
        indicators: [
          StatisticIndicator(
            code: 'SE.ADT.LITR.ZS',
            label: 'Alphabétisation des adultes',
            display: '47,2 %',
            year: 2019,
            series: [],
            source: source,
          ),
        ],
      ),
    ],
    districts: const [
      StatisticDivision(
        name: 'Abidjan',
        population: 6321017,
        households: 1414136,
      ),
      StatisticDivision(
        name: 'Yamoussoukro',
        population: 422072,
        households: 82760,
      ),
    ],
    regions: const [
      StatisticDivision(
        name: 'Haut-Sassandra',
        population: 1739697,
        households: 329000,
      ),
    ],
    cities: const [
      StatisticDivision(
        name: 'Bouaké',
        parent: 'Vallée du Bandama',
        population: 832371,
        households: 152187,
        averageSize: 5.4,
      ),
    ],
    climate: const ClimateSnapshot(
      periodStart: 1991,
      periodEnd: 2020,
      source: StatisticSource(
        name: 'Open-Meteo — réanalyse ERA5 (Copernicus)',
        url: 'https://open-meteo.com/en/docs/historical-weather-api',
        licence: 'CC BY 4.0',
      ),
      cities: [
        ClimateCity(
          slug: 'abidjan',
          name: 'Abidjan',
          annualRainMm: 1851.5,
          months: [
            ClimateMonth(month: 1, rainMm: 85.9, rainDays: 17, temperatureC: 26.3),
            ClimateMonth(month: 2, rainMm: 106.7, rainDays: 20, temperatureC: 26.8),
            ClimateMonth(month: 3, rainMm: 149.9, rainDays: 25.1, temperatureC: 27),
            ClimateMonth(month: 4, rainMm: 157.2, rainDays: 25.2, temperatureC: 26.9),
            ClimateMonth(month: 5, rainMm: 237.7, rainDays: 29, temperatureC: 26.2),
            ClimateMonth(month: 6, rainMm: 253.1, rainDays: 27.9, temperatureC: 25.1),
            ClimateMonth(month: 7, rainMm: 145.8, rainDays: 24.8, temperatureC: 24.4),
            ClimateMonth(month: 8, rainMm: 84.7, rainDays: 21.7, temperatureC: 24.1),
            ClimateMonth(month: 9, rainMm: 151, rainDays: 26.6, temperatureC: 24.5),
            ClimateMonth(month: 10, rainMm: 199.2, rainDays: 29.8, temperatureC: 25.1),
            ClimateMonth(month: 11, rainMm: 164.7, rainDays: 27.7, temperatureC: 25.7),
            ClimateMonth(month: 12, rainMm: 115.4, rainDays: 23.2, temperatureC: 26.1),
          ],
          years: [
            ClimateYear(year: 2018, rainMm: 1720.4),
            ClimateYear(year: 2019, rainMm: 2104.9),
            ClimateYear(year: 2020, rainMm: 1691.8),
            ClimateYear(year: 2021, rainMm: 1435.3),
          ],
        ),
        ClimateCity(
          slug: 'korhogo',
          name: 'Korhogo',
          annualRainMm: 1057.7,
          months: [
            ClimateMonth(month: 1, rainMm: 6.1, rainDays: 1.4, temperatureC: 27.4),
          ],
          years: [
            ClimateYear(year: 2019, rainMm: 1053.4),
            ClimateYear(year: 2020, rainMm: 858.1),
            ClimateYear(year: 2021, rainMm: 1100.2),
          ],
        ),
      ],
    ),
    updatedAt: DateTime(2026, 11, 11),
    dataThrough: 2025,
    censusNote:
        'Le RGPH 2021 est le dernier recensement publié : les effectifs de '
        'districts, régions et villes datent du 14 décembre 2021 et ne sont pas '
        'remplacés par des estimations.',
    sources: const ['Banque mondiale — WDI'],
  );
}
