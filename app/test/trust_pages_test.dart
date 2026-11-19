import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ivoirepedia/src/app.dart';
import 'package:ivoirepedia/src/ui/widgets/ivorian_patterns.dart';

import 'support/fake_home_api.dart';

/// API en mémoire qui retient les messages du formulaire de contact.
class _ContactApi extends FakeApi {
  final List<Map<String, String?>> sent = [];

  @override
  Future<void> sendContactMessage({
    required String message,
    String? name,
    String? email,
    String? website,
  }) async {
    sent.add({'message': message, 'name': name, 'email': email});
  }
}

void main() {
  setUp(() => ivoireMotionEnabled = false);

  Future<void> openSite(WidgetTester tester, {_ContactApi? api}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1400);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(IvoirepediaApp(api: api ?? _ContactApi()));
    await tester.pumpAndSettle();
  }

  /// Le pied de page est en bas d'une longue page : on y va avant de cliquer.
  Future<void> tapFooter(WidgetTester tester, String label) async {
    final link = find.text(label).last;

    await tester.ensureVisible(link);
    await tester.pumpAndSettle();
    await tester.tap(link);
    await tester.pumpAndSettle();
  }

  testWidgets('les liens du pied de page ouvrent les quatre pages réelles',
      (tester) async {
    await openSite(tester);

    await tapFooter(tester, 'À propos');
    expect(find.text('Une encyclopédie ivoirienne, écrite et sourcée'),
        findsOneWidget);
    expect(find.textContaining('« sera activé »'), findsNothing);

    await tapFooter(tester, 'Charte');
    expect(find.text('Ce que nous nous engageons à faire'), findsOneWidget);

    await tapFooter(tester, 'Contact');
    expect(find.text('Signaler une erreur, proposer une source'),
        findsOneWidget);

    await tapFooter(tester, 'Confidentialité');
    expect(find.text('Ce que le site sait de vous'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('la charte énonce les règles de fond', (tester) async {
    await openSite(tester);
    await tapFooter(tester, 'Charte');

    expect(find.text('1. Une information, une source'), findsOneWidget);
    expect(find.text('3. Des images libres et créditées'), findsOneWidget);
    expect(find.textContaining('CC BY-SA 4.0'), findsWidgets);
    expect(find.textContaining('Rien d’inventé'), findsOneWidget);
  });

  testWidgets('la page confidentialité décrit le stockage local', (tester) async {
    await openSite(tester);
    await tapFooter(tester, 'Confidentialité');

    expect(find.text('Sans compte : rien ne quitte votre navigateur'),
        findsOneWidget);
    expect(find.text('Le formulaire de contact'), findsOneWidget);
    expect(find.text('Vos droits'), findsOneWidget);
  });

  testWidgets('le formulaire envoie un message et confirme', (tester) async {
    final api = _ContactApi();
    await openSite(tester, api: api);
    await tapFooter(tester, 'Contact');

    await tester.enterText(
      find.byKey(const Key('contact-message')),
      'La date de fondation de la ville de Katiola me semble fausse.',
    );
    await tester.enterText(
      find.byKey(const Key('contact-email')),
      'lecteur@example.test',
    );

    final submit = find.byKey(const Key('contact-submit'));
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(api.sent, hasLength(1));
    expect(api.sent.single['message'], contains('Katiola'));
    expect(api.sent.single['email'], 'lecteur@example.test');
    expect(api.sent.single['name'], isNull);
    expect(find.byKey(const Key('contact-confirmation')), findsOneWidget);
  });

  testWidgets('le formulaire refuse un message trop court', (tester) async {
    final api = _ContactApi();
    await openSite(tester, api: api);
    await tapFooter(tester, 'Contact');

    await tester.enterText(find.byKey(const Key('contact-message')), 'Erreur');

    final submit = find.byKey(const Key('contact-submit'));
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(api.sent, isEmpty);
    expect(
      find.text('Décrivez votre demande en quelques mots (20 caractères au moins).'),
      findsOneWidget,
    );
  });
}
