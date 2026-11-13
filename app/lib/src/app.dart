import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'api.dart';
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
  const IvoirepediaApp({this.api, super.key});

  final IvoirepediaApi? api;

  @override
  State<IvoirepediaApp> createState() => _IvoirepediaAppState();
}

class _IvoirepediaAppState extends State<IvoirepediaApp> {
  late final IvoirepediaApi _api = widget.api ?? HttpIvoirepediaApi();
  late final GoRouter _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return ApiScope(
      api: _api,
      child: DisplayScope(
        prefs: AppStorage.instance.display,
        child: ValueListenableBuilder<DisplayPrefs>(
          valueListenable: AppStorage.instance.display,
          builder: (context, prefs, _) {
            return MaterialApp.router(
              title: 'IVOIREPEDIA',
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
    );
  }
}
