import 'package:flutter/material.dart';

/// Racine de l'application IVOIREPEDIA.
///
/// Les routes seront enregistrées ici (go_router) au Sprint 4 —
/// cf. CONTEXT §14. À ce stade (Sprint 0), un seul écran d'accueil.
class IvoirepediaApp extends StatelessWidget {
  const IvoirepediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IVOIREPEDIA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

/// Écran d'accueil — « hello world » du Sprint 0 : prouve que le site
/// Flutter s'affiche. Le contenu réel (recherche, articles) vient au Sprint 4.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IVOIREPEDIA')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'IVOIREPEDIA',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Encyclopédie Inclusive Ivoirienne'),
          ],
        ),
      ),
    );
  }
}
