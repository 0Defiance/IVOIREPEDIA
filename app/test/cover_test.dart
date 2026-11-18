import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ivoirepedia/src/ui/cover.dart';

void main() {
  testWidgets('la couverture garde la signature entière sur téléphone', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: CoverSheet()));

    final image = tester.widget<Image>(find.byKey(const Key('cover-image')));
    expect(image.fit, BoxFit.contain);
    expect(image.height, lessThanOrEqualTo(260));

    // Le pagne documenté remplit l’écran derrière la signature.
    expect(find.byKey(const Key('cover-backdrop')), findsOneWidget);
    expect(
      find.text('Articles sourcés · Lecture libre · CC BY-SA 4.0'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('la couverture reste contenue sur grand écran', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: CoverSheet()));

    final image = tester.widget<Image>(find.byKey(const Key('cover-image')));
    expect(image.fit, BoxFit.contain);
    expect(image.height, 260);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la couverture s’affiche au lancement puis se retire', (
    tester,
  ) async {
    await tester.pumpWidget(
      const LaunchCover(
        hold: Duration(milliseconds: 80),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text('site'),
        ),
      ),
    );

    expect(find.byType(CoverSheet), findsOneWidget);
    expect(find.text('site'), findsOneWidget);

    // Pendant la couverture, le site est dessous mais ne reçoit pas les gestes.
    final guard = tester.widget<IgnorePointer>(
      find.ancestor(
        of: find.byType(CoverSheet),
        matching: find.byType(IgnorePointer),
      ),
    );
    expect(guard.ignoring, isFalse);

    // Après le temps de chargement, la couverture s'efface en fondu.
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pumpAndSettle();

    expect(find.byType(CoverSheet), findsNothing);
    expect(find.text('site'), findsOneWidget);
  });
}
