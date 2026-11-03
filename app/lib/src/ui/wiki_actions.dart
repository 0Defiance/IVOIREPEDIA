import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Message honnête pour les commandes dont le backend viendra plus tard :
/// plutôt qu'un lien mort, on explique que la fonction arrive.
void wikiNotImplemented(BuildContext context, String label) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('« $label » sera activé avec les fonctionnalités à venir.'),
        duration: const Duration(seconds: 2),
      ),
    );
}

/// Navigation interne (le routeur gère les URLs propres).
void wikiGo(BuildContext context, String path) => context.go(path);
