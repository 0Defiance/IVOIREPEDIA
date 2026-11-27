import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ivoirepedia/src/app.dart';
import 'package:ivoirepedia/src/auth.dart';
import 'package:ivoirepedia/src/ui/widgets/ivorian_patterns.dart';
import 'package:ivoirepedia/src/ui/wiki_actions.dart';

import 'support/fake_home_api.dart';

/// Comptes en mémoire : ces parcours ne demandent que la connexion et le
/// profil, sans réseau. Le rôle décide de l'accès au formulaire.
class _FakeAuthApi implements AuthApi {
  _FakeAuthApi({this.role = 'EDITOR'});

  final String role;

  AuthUser get user => AuthUser(
    id: 'compte-1',
    name: 'Awa Koné',
    email: 'awa@example.test',
    role: role,
  );

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return AuthSession(user: user, token: 'jeton-de-test');
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

/// L'application ouverte avec le compte donné, déjà connecté.
Future<AuthStore> openSignedIn(WidgetTester tester, String role) async {
  final store = AuthStore(api: _FakeAuthApi(role: role));
  await store.signIn(email: 'awa@example.test', password: 'motdepasse123');

  await tester.pumpWidget(IvoirepediaApp(api: FakeApi(), auth: store));
  await tester.pumpAndSettle();

  return store;
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
      IvoirepediaApp(
        api: FakeApi(),
        auth: AuthStore(api: _FakeAuthApi()),
      ),
    );
    await tester.pumpAndSettle();

    await tapCreateArticle(tester);

    // Sans compte, la promesse tient quand même : on arrive sur la page de
    // connexion de l'application, pas sur un message d'attente.
    expect(find.byKey(const Key('auth-page')), findsOneWidget);
  });

  testWidgets('un compte de contributeur ouvre le formulaire éditorial', (
    tester,
  ) async {
    useWideScreen(tester);

    Uri? opened;
    openSiteTab = (url) async {
      opened = url;

      return true;
    };

    // CONTRIBUTOR est le premier rôle qui écrit : c'est la frontière que le
    // middleware `editorial` du backend applique aussi.
    await openSignedIn(tester, 'CONTRIBUTOR');
    await tapCreateArticle(tester);

    // Le formulaire vit hors du SPA : l'adresse est celle du site, sur la même
    // origine que l'API, et l'application ne change pas de page.
    expect(opened.toString(), 'http://localhost:8000/admin/articles/nouveau');
    expect(find.byKey(const Key('auth-page')), findsNothing);
  });

  testWidgets('un compte de lecteur est prévenu, sans être envoyé au panneau', (
    tester,
  ) async {
    useWideScreen(tester);

    Uri? opened;
    openSiteTab = (url) async {
      opened = url;

      return true;
    };

    await openSignedIn(tester, 'READER');
    await tapCreateArticle(tester);

    // Un lecteur n'a rien à faire dans le panneau : ni formulaire, ni 403.
    expect(opened, isNull);
    expect(find.byKey(const Key('auth-page')), findsNothing);
    expect(
      find.text(
        'Écrire est réservé à l’équipe éditoriale. Demandez le statut de '
        'contributeur depuis la page Contact.',
      ),
      findsOneWidget,
    );
  });
}
