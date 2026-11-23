import 'package:flutter_test/flutter_test.dart';
import 'package:ivoirepedia/src/ui/widgets/article_image.dart';

void main() {
  group('coverWidthFor', () {
    test('un palier servi par Wikimedia est choisi', () {
      expect(coverWidthFor(96), 250);
      expect(coverWidthFor(500), 500);
      expect(coverWidthFor(960), 960);
      expect(coverWidthFor(1280), 1280);
    });

    test('au-delà du plus grand palier, on reste au plus grand palier', () {
      expect(coverWidthFor(4000), 1280);
    });
  });

  group('sizedCoverUrl', () {
    test('une variante plus large que la cible est réduite au palier visé', () {
      const url =
          'https://thumb.wikimedia.org/wikipedia/commons/thumb/f/ff/'
          'Rue_de_Korhogo.jpg/1280px-Rue_de_Korhogo.jpg';

      expect(
        sizedCoverUrl(url, 960),
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/f/ff/'
        'Rue_de_Korhogo.jpg/960px-Rue_de_Korhogo.jpg',
      );
    });

    test('une variante déjà plus petite que la cible est conservée', () {
      const url =
          'https://thumb.wikimedia.org/wikipedia/commons/thumb/8/84/'
          'Les_cascades_de_Man.jpg/500px-Les_cascades_de_Man.jpg';

      expect(sizedCoverUrl(url, 960), url);
    });

    test('une URL d’origine est réécrite en URL de vignette', () {
      const url =
          'https://upload.wikimedia.org/wikipedia/commons/d/d5/Cizaouli.jpg';

      expect(
        sizedCoverUrl(url, 960),
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d5/'
        'Cizaouli.jpg/960px-Cizaouli.jpg',
      );
    });

    test('une URL d’origine conserve les caractères encodés du nom', () {
      const url =
          'https://upload.wikimedia.org/wikipedia/commons/d/d3/'
          'Entr%C3%A9e_du_palais.jpg';

      expect(
        sizedCoverUrl(url, 500),
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d3/'
        'Entr%C3%A9e_du_palais.jpg/500px-Entr%C3%A9e_du_palais.jpg',
      );
    });

    test('une URL étrangère à Wikimedia est laissée intacte', () {
      const url = 'https://example.test/zaouli.jpg';

      expect(sizedCoverUrl(url, 960), url);
    });

    test('une chaîne vide reste vide', () {
      expect(sizedCoverUrl('', 960), '');
    });

    test('la largeur d’origine empêche l’agrandissement (zaouli)', () {
      const url =
          'https://upload.wikimedia.org/wikipedia/commons/d/d5/Cizaouli.jpg';

      // 681 px d'origine : demander 960 px rendrait l'original, pas la
      // variante agrandie qui pesait 312 Ko contre 127 Ko.
      expect(sizedCoverUrl(url, 960, originalWidth: 681), url);
    });

    test('une variante plus grande que l’original revient à l’original', () {
      const url =
          'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d5/'
          'Cizaouli.jpg/960px-Cizaouli.jpg';

      expect(
        sizedCoverUrl(url, 960, originalWidth: 681),
        'https://upload.wikimedia.org/wikipedia/commons/d/d5/Cizaouli.jpg',
      );
    });

    test('un grand original garde la variante 960 px', () {
      const url =
          'https://thumb.wikimedia.org/wikipedia/commons/thumb/f/ff/'
          'Rue_de_Korhogo.jpg/1280px-Rue_de_Korhogo.jpg';

      expect(
        sizedCoverUrl(url, 960, originalWidth: 4624),
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/f/ff/'
        'Rue_de_Korhogo.jpg/960px-Rue_de_Korhogo.jpg',
      );
    });
  });
}
