import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'api.dart';
import 'auth.dart';
import 'brand.dart';
import 'router.dart';
import 'storage.dart';
import 'theme.dart';
import 'ui/display_settings.dart';

/// Racine de l'application IVOIREPEDIA.
///
/// L'API est injectable : les tests fournissent une implémentation en mémoire,
/// l'application utilise l'API HTTP (`API_BASE_URL`). Les réglages de confort
/// sont exposés à tout l'arbre via [DisplayScope] : thème de lecture, taille
/// du texte et mode lecture seule s'appliquent immédiatement.
class IvoirepediaApp extends StatefulWidget {
  const IvoirepediaApp({this.api, this.auth, super.key});

  final IvoirepediaApi? api;

  /// Session des lecteurs ; les tests en fournissent une avec un faux serveur.
  final AuthStore? auth;

  @override
  State<IvoirepediaApp> createState() => _IvoirepediaAppState();
}

class _IvoirepediaAppState extends State<IvoirepediaApp> {
  late final IvoirepediaApi _api = widget.api ?? HttpIvoirepediaApi();
  late final AuthStore _auth = widget.auth ?? AuthStore();
  late final GoRouter _router = buildRouter();

  @override
  void initState() {
    super.initState();

    // Le jeton éventuellement conservé est vérifié auprès de l'API : une
    // session expirée retombe proprement sur la lecture en visiteur.
    _auth.restore();
  }

  @override
  void dispose() {
    if (widget.auth == null) {
      _auth.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ApiScope(
      api: _api,
      child: AuthScope(
        store: _auth,
        child: DisplayScope(
          prefs: AppStorage.instance.display,
          child: ValueListenableBuilder<DisplayPrefs>(
            valueListenable: AppStorage.instance.display,
            builder: (context, prefs, _) {
              return MaterialApp.router(
                title: kTagline,
                debugShowCheckedModeBanner: false,
                theme: buildIvoireTheme(),
                routerConfig: _router,
                builder: (context, child) {
                  final media = MediaQuery.of(context);

                  return MediaQuery(
                    data: media.copyWith(
                      textScaler: TextScaler.linear(prefs.textScale),
                    ),
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
