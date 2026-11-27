import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api.dart' show apiBaseUrl;
import '../auth.dart';

/// Message honnête pour les commandes dont le backend viendra plus tard :
/// plutôt qu'un lien mort, on explique que la fonction arrive.
void wikiNotImplemented(BuildContext context, String label) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          '« $label » sera activé avec les fonctionnalités à venir.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
}

/// Navigation interne (le routeur gère les URLs propres).
void wikiGo(BuildContext context, String path) => context.go(path);

/// Formulaire de rédaction du panneau éditorial.
///
/// Il vit hors du SPA : le panneau garde sa propre session (cookie), alors que
/// l'application ne détient qu'un jeton d'API. On y va donc par l'adresse du
/// site, pas par le routeur interne.
const String editorialFormPath = '/admin/articles/nouveau';

/// Adresse du formulaire éditorial, sur la même origine que l'API.
///
/// En production l'API est servie sous `/api/v1` par le site lui-même ; en
/// développement elle répond sur le port 8000. Une racine relative est résolue
/// contre l'adresse de la page.
Uri editorialFormUri({String baseUrl = apiBaseUrl, Uri? origin}) {
  final api = Uri.parse(baseUrl);
  final site = api.hasScheme && api.hasAuthority ? api : (origin ?? Uri.base);

  return site.resolve(editorialFormPath);
}

/// Ouvre une adresse du site dans l'onglet courant : le lecteur ne quitte pas
/// le site, il change de page comme avec un lien ordinaire.
Future<bool> openSiteInSameTab(Uri url) async {
  try {
    return await launchUrl(url, webOnlyWindowName: '_self');
  } catch (_) {
    return false;
  }
}

/// Ouvreur des pages du site, remplaçable en test comme `ivoireMotionEnabled`
/// : un test de widget lit ainsi l'adresse visée sans navigateur.
Future<bool> Function(Uri url) openSiteTab = openSiteInSameTab;

/// « Créer un article » : le formulaire éditorial pour l'équipe de rédaction,
/// la page de connexion pour un visiteur, et un mot clair pour un lecteur.
///
/// Le panneau n'ouvre ses portes qu'aux CONTRIBUTOR et au-dessus : envoyer un
/// compte de lecteur à `/admin/articles/nouveau` ne le mènerait qu'à un 403.
Future<void> wikiOpenEditorialForm(BuildContext context) async {
  final store = AuthScope.of(context);

  if (!store.signedIn) {
    wikiGo(context, '/connexion');

    return;
  }

  if (!(store.user?.canContribute ?? false)) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Écrire est réservé à l’équipe éditoriale. Demandez le statut de '
            'contributeur depuis la page Contact.',
          ),
          duration: Duration(seconds: 4),
        ),
      );

    return;
  }

  final opened = await openSiteTab(editorialFormUri());

  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Le formulaire n’a pas pu s’ouvrir.'),
          duration: Duration(seconds: 3),
        ),
      );
  }
}
