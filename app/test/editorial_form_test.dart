import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ivoirepedia/src/app.dart';
import 'package:ivoirepedia/src/auth.dart';
import 'package:ivoirepedia/src/ui/widgets/ivorian_patterns.dart';
import 'package:ivoirepedia/src/ui/wiki_actions.dart';

import 'support/fake_home_api.dart';

/// Comptes en mémoire : ces parcours ne demandent que la connexion et le
/// profil, sans réseau.
class _FakeAuthApi implements AuthApi {
  static const user = AuthUser(
    id: 'compte-1',
    name: 'Awa Koné',
    email: 'awa@example.test',
    role: 'EDITOR',
  );

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return const AuthSession(user: user, token: 'jeton-de-test');
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) {
    return login(email: email, password: password);
  }

  @override
  Future<AuthUser> me(String token) async => user;

  @override
  Future<void> logout(String token) async {}

  @override
  Future<String> requestPasswordReset({required String email}) async => '';

  @override
  Future<String> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async => '';
}

/// Écran large : la colonne de navigation est dans la page, pas dans le tiroir.
void useWideScreen(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1280, 1000);
  addTearDown(tester.view.reset);
}

/// L'entrée du groupe « Écrire ensemble », ramenée à l'écran comme le ferait
/// un lecteur avant de cliquer.
Future<void> tapCreateArticle(WidgetTester tester) async {
  final entry = find.text('Créer un article').first;
  await tester.ensureVisible(entry);
  await tester.pumpAndSettle();
  await tester.tap(entry);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Pas d'animation de fond : `pumpAndSettle` doit pouvoir se stabiliser.
    ivoireMotionEnabled = false;
  });

  tearDown(() => openSiteTab = openSiteInSameTab);

  testWidgets('« Créer un article » mène à la connexion sans compte', (
    tester,
  ) async {
    useWideScreen(tester);

    await tester.pumpWidget(
      IvoirepediaApp(api: FakeApi(), auth: AuthStore(api: _FakeAuthApi())),
    );
    await tester.pumpAndSettle();

    await tapCreateArticle(tester);

    // Sans compte, la promesse tient quand même : on arrive sur la page de
    // connexion de l'application, pas sur un message d'attente.
    expect(find.byKey(const Key('auth-page')), findsOneWidget);
  });

  testWidgets('un compte connecté ouvre le formulaire éditorial du panneau', (
    tester,
  ) async {
    useWideScreen(tester);

    final store = AuthStore(api: _FakeAuthApi());
    await store.signIn(email: 'awa@example.test', password: 'motdepasse123');

    Uri? opened;
    openSiteTab = (url) async {
      opened = url;

      return true;
    };

    await tester.pumpWidget(IvoirepediaApp(api: FakeApi(), auth: store));
    await tester.pumpAndSettle();

    await tapCreateArticle(tester);

    // Le formulaire vit hors du SPA : l'adresse est celle du site, sur la même
    // origine que l'API, et l'application ne change pas de page.
    expect(opened.toString(), 'http://localhost:8000/admin/articles/nouveau');
    expect(find.byKey(const Key('auth-page')), findsNothing);
  });
}
