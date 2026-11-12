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
    updatedAt: DateTime(2026, 11, 11),
    sources: const ['Banque mondiale — WDI'],
  );
}
