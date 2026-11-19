import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
  final Map<String, String> _resetTokens = {};
  int _sequence = 0;

  /// Dernière adresse pour laquelle un lien a été demandé, connue ou non.
  String? lastResetRequest;

  static const resetToken = 'jeton-reset-1234567890';

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

  @override
  Future<String> requestPasswordReset({required String email}) async {
    lastResetRequest = email;

    // Le serveur ne dit jamais si le compte existe : il n'émet un jeton que
    // dans ce cas, mais répond la même phrase dans les deux cas.
    if (_accounts.containsKey(email)) {
      _resetTokens[resetToken] = email;
    }

    return 'Si un compte existe avec cette adresse, un lien vient de lui être envoyé.';
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    if (_resetTokens[token] != email) {
      throw const AuthException(
        'Ce lien n’est plus valable. Demandez-en un nouveau.',
      );
    }

    _resetTokens.remove(token);
    _accounts[email] = password;

    return 'Votre mot de passe est changé. Vous pouvez vous connecter.';
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

  testWidgets('le lien « mot de passe oublié » demande un lien sans révéler le compte', (
    tester,
  ) async {
    final api = FakeAuthApi();
    final store = AuthStore(api: api);
    await openSignIn(tester, store);

    await tester.tap(find.byKey(const Key('auth-forgot')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reset-page')), findsOneWidget);
    expect(find.byKey(const Key('reset-password')), findsNothing);

    // Une adresse inconnue reçoit exactement la même confirmation.
    await tester.enterText(
      find.byKey(const Key('reset-email')),
      'inconnu@example.test',
    );
    await tester.tap(find.byKey(const Key('reset-submit')));
    await tester.pumpAndSettle();

    expect(api.lastResetRequest, 'inconnu@example.test');
    expect(find.byKey(const Key('reset-done')), findsOneWidget);
    expect(
      find.text(
        'Si un compte existe avec cette adresse, un lien vient de lui être envoyé.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('un lien reçu permet de choisir un nouveau mot de passe', (
    tester,
  ) async {
    final api = FakeAuthApi();
    final store = AuthStore(api: api);
    await openSignIn(tester, store);

    // Un lien n'existe qu'après une demande : le faux serveur l'émet alors.
    await api.requestPasswordReset(email: 'awa@example.test');

    // Le courriel arrive avec le jeton et l'adresse en paramètres.
    GoRouter.of(tester.element(find.byKey(const Key('auth-page')))).go(
      '/mot-de-passe-oublie?token=${FakeAuthApi.resetToken}'
      '&email=awa%40example.test',
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reset-password')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('reset-password')),
      'nouveaumotdepasse',
    );
    await tester.enterText(
      find.byKey(const Key('reset-confirm')),
      'nouveaumotdepasse',
    );
    await tester.tap(find.byKey(const Key('reset-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reset-done')), findsOneWidget);
    expect(store.signedIn, isFalse);

    await tester.tap(find.byKey(const Key('reset-signin')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('auth-email')),
      'awa@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('auth-password')),
      'nouveaumotdepasse',
    );
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle();

    expect(store.signedIn, isTrue);
    expect(store.user?.email, 'awa@example.test');
  });

  testWidgets('un lien déjà utilisé affiche le refus et permet d’en redemander', (
    tester,
  ) async {
    final store = AuthStore(api: FakeAuthApi());
    await openSignIn(tester, store);

    GoRouter.of(tester.element(find.byKey(const Key('auth-page')))).go(
      '/mot-de-passe-oublie?token=jeton-perime-1234567890'
      '&email=awa%40example.test',
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('reset-password')),
      'nouveaumotdepasse',
    );
    await tester.enterText(
      find.byKey(const Key('reset-confirm')),
      'nouveaumotdepasse',
    );
    await tester.tap(find.byKey(const Key('reset-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reset-error')), findsOneWidget);
    expect(
      find.text('Ce lien n’est plus valable. Demandez-en un nouveau.'),
      findsOneWidget,
    );

    // Le même écran, sans jeton, redevient la demande de lien.
    await tester.tap(find.byKey(const Key('reset-restart')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reset-password')), findsNothing);
    expect(find.byKey(const Key('reset-email')), findsOneWidget);
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
