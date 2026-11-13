import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'src/app.dart';

void main() {
  // URL propres, sans dièse : /statistiques, /articles/{slug}, /histoires.
  // Le serveur renvoie la même page HTML pour toute route inconnue (voir
  // backend/public/.htaccess), ce qui rend ces adresses rechargeables.
  usePathUrlStrategy();

  runApp(const IvoirepediaApp());
}
