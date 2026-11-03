import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'api.dart';
import 'router.dart';
import 'theme.dart';

/// Racine de l'application IVOIREPEDIA.
///
/// L'API est injectable : les tests fournissent une implémentation en mémoire,
/// l'application utilise l'API HTTP (`API_BASE_URL`).
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
      child: MaterialApp.router(
        title: 'IVOIREPEDIA',
        debugShowCheckedModeBanner: false,
        theme: buildIvoireTheme(),
        routerConfig: _router,
      ),
    );
  }
}
