import 'package:flutter_test/flutter_test.dart';

import 'package:ivoirepedia/src/app.dart';

void main() {
  testWidgets('affiche l’écran d’accueil IVOIREPEDIA', (tester) async {
    await tester.pumpWidget(const IvoirepediaApp());

    expect(find.text('IVOIREPEDIA'), findsWidgets);
    expect(find.text('Encyclopédie Inclusive Ivoirienne'), findsOneWidget);
  });
}
