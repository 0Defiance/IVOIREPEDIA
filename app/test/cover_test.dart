import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ivoirepedia/src/ui/cover.dart';

void main() {
  testWidgets('la couverture s’affiche au lancement puis se retire',
      (tester) async {
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
