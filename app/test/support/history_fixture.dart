import 'package:ivoirepedia/src/models/history.dart';

/// Deux récits en mémoire : aucun test ne dépend du réseau ni de la base.
List<HistoryStory> historyFixture() {
  return const [
    HistoryStory(
      slug: 'grand-bassam-capitale-abandonnee',
      title: 'La capitale abandonnée à cause des moustiques',
      period: '1893-1900',
      teaser: 'Première capitale de la Côte d’Ivoire, Grand-Bassam a été '
          'désertée par l’administration coloniale.',
      paragraphs: [
        'Grand-Bassam s’est construite face à l’océan.',
        'Les épidémies de fièvre jaune déciment la population européenne.',
      ],
      figures: [
        HistoryFigure(label: 'Inscription au patrimoine mondial', value: '2012'),
      ],
      source: HistorySource(
        title: 'Ville historique de Grand-Bassam — liste du patrimoine mondial',
        publisher: 'UNESCO',
        year: 2012,
        url: 'https://whc.unesco.org/fr/list/1322',
      ),
    ),
    HistoryStory(
      slug: 'attieke-savoir-faire-feminin',
      title: 'L’attiéké, le manioc fermenté devenu patrimoine de l’humanité',
      period: 'Inscrit en 2024',
      teaser: 'Semoule de manioc fermentée, l’attiéké accompagne les repas '
          'ivoiriens depuis longtemps.',
      paragraphs: ['L’attiéké est une semoule obtenue à partir de manioc.'],
      figures: [
        HistoryFigure(label: 'Inscription UNESCO', value: '2024'),
      ],
      source: HistorySource(
        title: 'Les savoir-faire liés à la fabrication de l’attiéké',
        publisher: 'UNESCO',
        year: 2024,
        url: 'https://ich.unesco.org/fr/RL/les-savoir-faire-lies-a-la-fabrication-de-l-attieke-en-cote-d-ivoire-02086',
      ),
    ),
  ];
}
