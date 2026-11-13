import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'src/app.dart';
import 'src/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // URL propres, sans dièse : /statistiques, /articles/{slug}, /histoires.
  // Le serveur renvoie la même page HTML pour toute route inconnue (voir
  // backend/public/.htaccess), ce qui rend ces adresses rechargeables.
  usePathUrlStrategy();

  // Favoris, historique et réglages : lus une fois au démarrage. Un stockage
  // indisponible ne doit pas empêcher l'affichage du site.
  await AppStorage.instance.load();

  runApp(const IvoirepediaApp());
}
