import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ivoirepedia/src/app.dart';
import 'package:ivoirepedia/src/auth.dart';
import 'package:ivoirepedia/src/ui/widgets/ivorian_patterns.dart';

import 'support/fake_home_api.dart';

/// Serveur d'authentification en mémoire : les parcours sont testés sans
/// réseau, avec les mêmes messages que l'API réelle.
class FakeAuthApi implements AuthApi {
  FakeAuthApi() {
    _accounts['awa@example.test'] = 'motdepasse123';
    _names['awa@example.test'] = 'Awa Koné';
  }

  final Map<String, String> _accounts = {};
  final Map<String, String> _names = {};
  final Map<String, String> _tokens = {};
  int _sequence = 0;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    if (_accounts[email] != password) {
      throw const AuthException('Adresse ou mot de passe incorrect.');
    }

    return _issue(email);
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_accounts.containsKey(email)) {
      throw const AuthException('Un compte existe déjà avec cette adresse.');
    }

    _accounts[email] = password;
    _names[email] = name;

    return _issue(email);
  }

  @override
  Future<AuthUser> me(String token) async {
    final email = _tokens[token];

    if (email == null) {
      throw const AuthException('Connectez-vous pour accéder à cet espace.');
    }

    return _user(email);
  }

  @override
  Future<void> logout(String token) async {
    _tokens.remove(token);
  }

  AuthSession _issue(String email) {
    final token = 'jeton-${++_sequence}';
    _tokens[token] = email;

    return AuthSession(user: _user(email), token: token);
  }

  AuthUser _user(String email) => AuthUser(
        id: email,
        name: _names[email] ?? 'Lecteur',
        email: email,
        role: 'READER',
      );
}

void main() {
  setUp(() {
    // Pas d'animation de fond : `pumpAndSettle` doit pouvoir se stabiliser.
    ivoireMotionEnabled = false;
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> openSignIn(WidgetTester tester, AuthStore store) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1000);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(IvoirepediaApp(api: FakeApi(), auth: store));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('account-signin')));
    await tester.pumpAndSettle();
  }

  testWidgets('la connexion ouvre la session et le bandeau montre le compte', (
    tester,
  ) async {
    final api = FakeAuthApi();
    final store = AuthStore(api: api);
    await openSignIn(tester, store);

    expect(find.byKey(const Key('auth-page')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('auth-email')),
      'awa@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('auth-password')),
      'motdepasse123',
    );
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle();

    // Retour à l'accueil, le compte remplace les liens du bandeau.
    expect(find.byKey(const Key('auth-page')), findsNothing);
    expect(store.signedIn, isTrue);
    expect(store.user?.firstName, 'Awa');
    expect(find.text('Awa'), findsWidgets);

    // Le jeton reste dans le stockage : la session survit au rechargement.
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthStore.tokenKey);
    expect(token, isNotNull);

    final restored = AuthStore(api: api);
    await restored.restore();
    expect(restored.user?.email, 'awa@example.test');
  });

  testWidgets('la création de compte depuis le bandeau ouvre la session', (
    tester,
  ) async {
    final store = AuthStore(api: FakeAuthApi());
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1000);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(IvoirepediaApp(api: FakeApi(), auth: store));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('account-signup')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth-page')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('auth-name')), 'Koffi Yao');
    await tester.enterText(
      find.byKey(const Key('auth-email')),
      'koffi@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('auth-password')),
      'motdepasse123',
    );
    await tester.enterText(
      find.byKey(const Key('auth-confirm')),
      'motdepasse123',
    );
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle();

    expect(store.signedIn, isTrue);
    expect(store.user?.email, 'koffi@example.test');
    expect(store.user?.role, 'READER');
    expect(find.text('Koffi'), findsWidgets);
  });

  testWidgets('un mot de passe refusé affiche le message du serveur', (
    tester,
  ) async {
    final store = AuthStore(api: FakeAuthApi());
    await openSignIn(tester, store);

    await tester.enterText(
      find.byKey(const Key('auth-email')),
      'awa@example.test',
    );
    await tester.enterText(find.byKey(const Key('auth-password')), 'mauvais123');
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle();

    expect(store.signedIn, isFalse);
    expect(find.byKey(const Key('auth-error')), findsOneWidget);
    expect(find.text('Adresse ou mot de passe incorrect.'), findsOneWidget);
  });

  testWidgets('la déconnexion ramène les liens de connexion', (tester) async {
    final store = AuthStore(api: FakeAuthApi());
    await openSignIn(tester, store);

    await tester.enterText(
      find.byKey(const Key('auth-email')),
      'awa@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('auth-password')),
      'motdepasse123',
    );
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Mon compte'));
    await tester.pumpAndSettle();
    // Le menu du compte et la colonne de navigation portent le même libellé :
    // on vise l'entrée du menu déroulant.
    await tester.tap(
      find.descendant(
        of: find.byType(PopupMenuItem<String>),
        matching: find.text('Se déconnecter'),
      ),
    );
    await tester.pumpAndSettle();

    expect(store.signedIn, isFalse);
    expect(find.text('Se connecter'), findsWidgets);
  });
}
