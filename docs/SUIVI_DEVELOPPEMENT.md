# Suivi de développement — IVOIREPEDIA

> Journal technique étape par étape : **ce qui est fait, vérifié, bloqué et restant.**
> Chaque séance de travail ajoute une entrée datée.
> Règle : ce journal, le dépôt local et le dépôt distant restent **au même niveau d'information**.

**Version** : 1.8 · **Dernière mise à jour** : 4 novembre 2026

**État en une phrase** : **IVOIREPEDIA est en ligne** sur son compte Alwaysdata dédié — Sprint 0 terminé, backend déployé (Laravel 13.39.0, PHP 8.4.27), le **site est lisible en ligne** (`https://ivoirepedia.alwaysdata.net/site/`) et branché sur l'API (`/api/v1/articles`, `/categories`, `/search`). Restent le contenu éditorial, l'authentification (Sprint 1) et l'éditeur (Sprint 2).

---

## Chronologie

### 2 novembre 2026 — Mise en place du dépôt et de la documentation de cadrage

**Fait**
- Dépôt GitHub `0Defiance/IVOIREPEDIA` initialisé (licence MIT) et cloné en local.
- Structure du dépôt :
  - `README.md` — page d'accueil : présentation, table « Où est quoi », règle de parité local/distant, ordre de lecture ;
  - `IVOIREPEDIA_CONTEXT.md` — **source de vérité opérationnelle** (sections 0 à 19 : stack MVP, ADR-001→008, modèle de données Prisma, workflow éditorial, RBAC, contrat d'API, backlog en sprints, conventions, instructions IA) ;
  - `docs/IVOIREPEDIA_Document_de_Contextualisation.md` — vision complète du produit (statuts ✅ 🟡 ❓) ;
  - `docs/` — documents source PDF (cahier des charges, stack technique phase 1 locale, stack technique phase 2 production) ;
  - `AGENTS.md` — règle de travail : définition de « fait » (accessible / testable / vérifié-committé-poussé) ;
  - `docs/SUIVI_DEVELOPPEMENT.md` — ce journal ;
  - `.gitignore` (secrets, build Node.js) et `.gitattributes` (fins de ligne LF).
- Première séance committée et poussée sur `origin/main`.

**Vérifié**
- `git status` propre après commit ; `git log` et `origin/main` au même niveau.
- Les deux documents de contexte sont lisibles depuis le README.

**Point d'attention (divergence signalée)**
- Les deux documents de cadrage décrivaient des stacks différentes : le **CONTEXT** (MVP : Next.js + Prisma + PostgreSQL, monolithe) et le **document de contextualisation** (horizon plus large : NestJS + PostGIS + Meilisearch, monorepo, 🟡 hypothèses). Règle en vigueur : **`IVOIREPEDIA_CONTEXT.md` fait foi** en cas de contradiction (CONTEXT §2). Le document de contextualisation reste la référence pour la vision produit (langues, sources orales, géo, hors-ligne).
  - *Corrigé en séance 2 (ci-dessous) : le CONTEXT a été aligné sur la stack retenue (Flutter + Laravel + MySQL), et la stack du document de contextualisation est désormais explicitement supplantée par une bannière ⚠️.*

**Reste (ordre prioritaire)**
1. **Sprint 0 — Fondations** (CONTEXT §14) : créer `backend/` (Laravel) et `app/` (Flutter) ; base `ivoirepedia` via phpMyAdmin + `.env.example` ; migrations + seeders ; scripts Composer (Pest/Pint/Larastan) + `flutter analyze`/`flutter test` ; CI GitHub Actions ; `docs/INSTALLATION.md` avec versions constatées ; déploiement « hello world ».
   - Critère de sortie : un nouvel arrivant suit CONTEXT §7 et obtient l'app Flutter **et** l'API en local ; la CI est verte.
2. Puis Sprint 1 — Authentification (EF-AUTH-01→05).
3. Questions ouvertes à traiter au fil de l'eau : éditeur riche Flutter à confirmer (Q8), licence du code (Q1), licence du contenu (Q2), nom de domaine / emails (Q3).

### 2 novembre 2026 (séance 2) — Adaptation de la stack (Flutter + Laravel)

**Fait**
- Décision : **adopter Flutter + Laravel + MySQL**, même objectif multiplateforme (web d'abord, Android ensuite) — au lieu de Next.js + Prisma + PostgreSQL.
- `IVOIREPEDIA_CONTEXT.md` passé en **v1.1** : Flutter (`app/`) + Laravel (`backend/`, API `/api/v1` + Filament) + MySQL/XAMPP/phpMyAdmin + Sanctum + Pest/flutter_test.
  - ADR-001→008 réécrits ; §5 stack ; §6 arborescence `app/` + `backend/` ; §7 installation XAMPP (ports 8000/8082/3306) ; §8 schéma converti en **MySQL** (DDL, tables `article_tag` et `article_references` pivot/mot réservé, `position` au lieu de `order`) ; §8.3 infobox en règles `FormRequest` ; §9 workflow traduit en **PHP** (`app/Services/Workflow.php`) ; §11 contrat `/api/v1` + table d'erreurs 422 ; §13 sécurité adaptée (Eloquent, disque local) ; §14 backlog Sprint 0 réécrit ; §15.4 CI 2 jobs ; §17 risques R-05/R-08/R-09 (SPA → SEO limité) ; Q8/Q9 ajoutées.
- `README.md` (v1.1) : tableau de stack validée + prochaine étape Sprint 0 adaptée ; bannière ⚠️ ajoutée en tête du document de contextualisation (sa stack NestJS/PostGIS est supplantée, vision produit inchangée).
- `AGENTS.md` : chemins Flutter/Filament/Pest, commandes `composer test/format:check/analyse` + `flutter analyze/test`.
- `.gitignore` (`app/`, `backend/`) et `.gitattributes` (`.dart`, `.php` au lieu de `.ts`).
- Cohérence vérifiée avec les PDFs du dépôt : Phase 1 (XAMPP + Laravel + MySQL) et Phase 2 (API `/api/v1` + Sanctum, VPS Nginx) — seuls les PDFs confirment déjà Laravel ; l'interface Blade/PWA est remplacée par Flutter (divergence D9 documentée).

**Vérifié**
- Recherche grep sur les fichiers de cadrage actifs (`IVOIREPEDIA_CONTEXT.md`, `README.md`, `AGENTS.md`, `.gitignore`, `.gitattributes`) : plus aucune occurrence de Next.js / Prisma / PostgreSQL / Auth.js / Vitest / pnpm. Seules subsistent les mentions volontaires (divergence D9, historique v1.0→v1.1 du CONTEXT), l'historique des séances antérieures de ce journal, et le document de contextualisation (source verbatim, couvert par la bannière ⚠️).
- Parité local ↔ distant : commit poussé sur `origin/main` dans la même séance.

**Reste**
1. Sprint 0 — Fondations (ci-dessus), avec les versions réellement constatées à figer dans `docs/INSTALLATION.md`.
2. Confirmer l'éditeur riche Flutter (`flutter_quill` ou alternative) avant le Sprint 2 (Q8).
3. Les PDFs EII ne sont pas réécrits : ils restent la référence pour la base/API/production ; l'écart interface (Blade/PWA → Flutter) est tracé en CONTEXT D9.

---

### 3 novembre 2026 (séance 3) — Sprint 0 réalisé, puis bascule vers Alwaysdata + Mailjet

**Fait**
- **Sprint 0 côté backend** : Laravel 13.39.0 installé, `composer.json` aligné sur le socle retenu (Pest 4, Larastan 3, Pint, scripts `test` / `analyse` / `format` / `format:check`), `phpstan.neon` niveau 5.
  - 10 migrations fidèles au schéma §8.2 : `users` (+ `verification_tokens`, `sessions`), `categories`, `articles`, `article_versions`, `tags`, `article_tag`, `article_references`, `media`, `editorial_actions`.
  - Seeders `CategorySeeder` (8 catégories) et `DevAdminSeeder` (`admin@ivoirepedia.test`, refusé en production).
  - `app/Models/User.php` adapté (UUID, `password_hash`, `role`), `GET /api/v1/health` déclarée dans `routes/api.php` et câblée via `bootstrap/app.php`.
- **Sprint 0 côté app** : Flutter 3.47.7 / Dart 3.13.5 ; l'écran compteur de `flutter create` est remplacé par `app/lib/src/app.dart` (écran d'accueil IVOIREPEDIA) avec son test widget.
- **CI** : `.github/workflows/ci.yml`, deux jobs (backend PHP 8.3, Flutter 3.47.7), mêmes commandes que `AGENTS.md` §3.
- **Changement de cap demandé** : abandon des tests et du MySQL local ; l'hébergement **Alwaysdata** et les emails **Mailjet** sont retenus. Le compte Alwaysdata d'un autre projet est d'abord réutilisé avec des ressources IVOIREPEDIA séparées (abandonné en séance 5).
  - `IVOIREPEDIA_CONTEXT.md` v1.2 : **ADR-002 révisé** (base hébergée, dev et production), **ADR-008 réécrit** (Alwaysdata mutualisé dès le développement, VPS+Nginx abandonné), **ADR-009 ajouté** (Mailjet SMTP). §5, §7, §7.5, R-10, Q3 et Q9 mis à jour.
  - `backend/.env.example` : `DB_HOST` sur l'hôte MySQL de l'hébergement, deux bases (dev/prod), SMTP Mailjet (port 587, `MAIL_SCHEME=null`).
  - `docs/INSTALLATION.md` créé (poste de travail, base distante, versions constatées) et `docs/DEPLOIEMENT.md` créé (panneau Alwaysdata, premier déploiement, Mailjet, vérifications, pièges) — faits vérifiés dans la documentation officielle des deux services.

**Vérifié**
- `cd backend && composer test` → 3 tests / 4 assertions, vert.
- `composer format:check` → 38 fichiers conformes ; `composer analyse` → « No errors » (niveau 5).
- `php artisan migrate:fresh --seed` → 10 migrations + `CategorySeeder` + `DevAdminSeeder` sans erreur.
- `php artisan serve` + `curl /api/v1/health` → `200` avec `{"status":"ok","service":"ivoirepedia-api","version":"v1"}`.
- `cd app && flutter analyze` → « No issues found! » ; `flutter test` → écran d'accueil, 1 test vert.
- **Accessibilité du compte d'hébergement** (sondes réseau, sans mot de passe) : SSH `:22` et MySQL `:3306` ouverts, le domaine du compte répond en `200`, `https://ivoirepedia.alwaysdata.net` → aucun site. Authentification SSH par clé refusée avant dépôt de la clé dans le panneau.

**Reste**
1. **Panneau Alwaysdata** (actions humaines, cf. `docs/DEPLOIEMENT.md` §2) : PHP 8.3 au niveau du compte, créer les deux bases + utilisateur MySQL dédié, déposer la clé publique de déploiement `.deploy/ivoirepedia_ed25519.pub` (générée le 3 nov. 2026, exclue de Git) dans `Accès distant > SSH`, créer le site PHP pointant sur `~/ivoirepedia/backend/public`, valider l'expéditeur Mailjet et générer la clé SMTP.
2. Renseigner `backend/.env` (DB_*, MAIL_*) puis `php artisan migrate --seed` sur la base de dev distante.
3. Déployer le backend et vérifier `https://ivoirepedia.alwaysdata.net/api/v1/health` en ligne.
4. Test d'envoi Mailjet (`Mail::raw` en tinker).
5. Puis Sprint 1 — Authentification (EF-AUTH-01→05).

---

### 3 novembre 2026 (séance 4) — Compte partagé branché, backend déployé

**Fait**
- Compte Alwaysdata d'un autre projet confirmé et réutilisé, avec des ressources IVOIREPEDIA séparées.
- **Clé de déploiement dédiée** générée dans `.deploy/ivoirepedia_ed25519` (ed25519, sans phrase de passe, exclue par `.gitignore`), clé publique déposée dans `Accès distant > SSH`. L'accès SSH fonctionne en `BatchMode`, sans mot de passe.
- Bases créées par le titulaire du compte : une base de production et une base de développement, utilisateur MySQL unique avec tous droits sur les deux.
- **Déploiement du backend** : `git clone` dans `~/ivoirepedia` (commit `b23ab6e`), `backend/.env` de production copié par `scp` depuis `.deploy/env.production`, `composer install --no-dev --optimize-autoloader`, `php artisan key:generate --force`, `php artisan storage:link`, `php artisan migrate --seed --force`.
- Base de **développement** migrée et seedée depuis le poste de travail (connexion MySQL distante validée, ~20 s au total).
- Guides corrigés avec les valeurs réelles, la procédure de clé, le piège du domaine `.net`/`.com` et la section phpMyAdmin.

**Vérifié**
- `ssh -i .deploy/ivoirepedia_ed25519 <compte>@ssh-<compte>.alwaysdata.net` → connecté, **PHP 8.4.27** en CLI, Composer en `/usr/bin/composer`.
- `php artisan migrate --seed --force` sur la base de production → 9 tables + `CategorySeeder` en ~85 ms ; `DevAdminSeeder` correctement ignoré en production.
- `php artisan route:list --path=api` sur le serveur → `GET|HEAD api/v1/health`, `routes/api.php:12`.
- Le domaine du compte répond `200` ; `https://ivoirepedia.alwaysdata.net` → absent (site non créé).

**Reste (abandonné en séance 5)**
- Créer le site PHP dans le panneau : l'adresse `ivoirepedia.alwaysdata.net` y est **refusée** (« le domaine alwaysdata.net ne vous appartient pas ») car le compte ne possède qu'une seule adresse gratuite, déjà occupée.

---

### 3 novembre 2026 (séance 5) — Virage : compte d'hébergement dédié, séparation totale

**Décision (titulaire du projet)** : abandon du compte d'hébergement partagé. IVOIREPEDIA aura **son propre compte Alwaysdata**, créé par le titulaire, avec son site, ses bases, son utilisateur MySQL et son phpMyAdmin. Motif : sur un compte partagé, l'unique adresse gratuite est déjà prise et le panneau refuse toute adresse dérivée — le blocage était structurel, pas une erreur de saisie.

**Fait**
- **Purge des références à l'autre projet** dans tout le dépôt (compte, hôtes `ssh-*`/`mysql-*`, noms de bases, utilisateur MySQL, comparaisons, lien vers son dépôt) : `README.md`, `AGENTS.md`, `IVOIREPEDIA_CONTEXT.md`, `docs/INSTALLATION.md`, `docs/DEPLOIEMENT.md`, `docs/SUIVI_DEVELOPPEMENT.md`, `backend/.env.example`.
- `docs/DEPLOIEMENT.md` **réécrit en v2.0** pour un compte dédié : §1 « un compte dédié, sans partage » remplace la table de partage, adresse `ivoirepedia.alwaysdata.net` (l'adresse gratuite du compte), bases `ivoirepedia_prod`/`ivoirepedia_dev` (le panneau préfixe par le nom du compte), utilisateur `ivoirepedia_app`, §2.5 phpMyAdmin par compte, piège du domaine reformulé.
- `backend/.env.example` : hôtes et bases du compte dédié.
- `IVOIREPEDIA_CONTEXT.md` **v1.3** : ADR-002 et ADR-008 alignés (compte dédié), §5 et §7 mis à jour, historique complété.
- `README.md` **v1.3** et section stack : compte dédié.

**Vérifié**
- Recherche du nom de l'ancien compte dans tout le dépôt (hors `.git`, `vendor`, `node_modules`) → **aucune occurrence** dans les fichiers versionnés.

**Reste**
1. ~~Créer le compte Alwaysdata~~ — **fait** : compte `ivoirepedia` (courriel `my.fat.inc@gmail.com`). Résolution DNS vérifiée le 3 nov. 2026 : `ivoirepedia.alwaysdata.net` (185.31.40.30), `ssh-ivoirepedia.alwaysdata.net` (185.31.41.84), `mysql-ivoirepedia.alwaysdata.net` (185.31.41.43). Nouvelle clé de déploiement générée dans `.deploy/ivoirepedia_ed25519` (empreinte `ivoirepedia-deploy`) ; accès SSH en attente du dépôt de la clé publique dans le panneau.
---

### 3 novembre 2026 (séance 6) — Mise en ligne sur le compte dédié

**Fait**
- Compte `ivoirepedia` configuré : bases `ivoirepedia_prod` et `ivoirepedia_dev`, utilisateur MySQL `ivoirepedia_app` (tous droits sur les deux), clé publique de déploiement autorisée dans `Accès distant > SSH`.
- Serveur : `git clone` dans `~/ivoirepedia` (commit `fcb6eab`), `composer install --no-dev --optimize-autoloader` (56 paquets), `backend/.env` de production copié depuis `.deploy/env.production`, `php artisan key:generate --force`, `php artisan storage:link`, droits sur `storage` et `bootstrap/cache`.
- Base de production : `php artisan migrate --seed --force` → 10 migrations, 9 tables métier (17 avec les tables techniques), `CategorySeeder` (8 catégories) ; `DevAdminSeeder` correctement ignoré.
- **Administrateur de production** créé par un script bootstrapé : `my.fat.inc@gmail.com`, rôle `ADMIN`, mot de passe provisoire communiqué au titulaire — **à changer**.
- Site PHP créé dans `Web > Sites` : adresse `ivoirepedia.alwaysdata.net`, répertoire `ivoirepedia/backend/public`.
- Base de **développement** migrée et seedée depuis le poste de travail (`ivoirepedia_dev`, admin de dev `admin@ivoirepedia.test`).

**Vérifié**
- `curl https://ivoirepedia.alwaysdata.net/api/v1/health` → `HTTP 200`, `application/json`, `{"status":"ok","service":"ivoirepedia-api","version":"v1"}` (~0,8 s).
- Certificat TLS : `CN=*.alwaysdata.net`, Let's Encrypt, valide jusqu'au 14 décembre 2026.
- `mysql-ivoirepedia.alwaysdata.net:3306` atteint depuis le serveur **et** depuis le poste (migrations exécutées des deux côtés).
- `php artisan about` sur le serveur : Laravel 13.39.0 · PHP 8.4.27 · Composer 2.9.8 · `APP_ENV=production`, `APP_DEBUG=off`.

**Reste**
1. **Mailjet** : valider l'expéditeur, générer la clé SMTP, passer `MAIL_MAILER=smtp` dans `~/ivoirepedia/backend/.env`, tester un envoi (§4 de `docs/DEPLOIEMENT.md`). Aujourd'hui `MAIL_MAILER=log`.
2. **Tâche planifiée** : `php artisan schedule:run` chaque minute (`Advanced > Tâches planifiées`).
3. **Rotation des secrets** : le mot de passe MySQL et celui de l'administrateur ont circulé dans la conversation. À changer : panneau `Bases de données > MySQL` puis `DB_PASSWORD` dans `backend/.env` (local) et `~/ivoirepedia/backend/.env` (serveur) ; pour l'admin, dès que l'écran de connexion existera (Sprint 1).
4. **Ancien compte** : supprimer les bases IVOIREPEDIA (prod et dev) et l'utilisateur MySQL qui y était dédié, pour que son phpMyAdmin ne montre plus que les bases de l'autre projet.
5. **Côté autre projet** : renommer `soutrali_bd` en `soutrali_prod`, créer `soutrali_dev` (export/import phpMyAdmin), puis supprimer l'ancienne base une fois le site basculé.

---

---

### 3 novembre 2026 (séance 7) — Le site prend vie : lecture publique de bout en bout

**Fait — backend (Sprint 4, partie lecture)**
- `App\Enums\ArticleStatus` (workflow §9.1) et `App\Enums\ArticleType` (`BIOGRAPHY`, `REGION`, `INSTITUTION`, `TOPIC`).
- Modèles `Category`, `Article` (scopes `published`, `inCategory`, `taggedWith`, `matching`), `Tag`, `ArticleReference`, avec annotations `@property` pour Larastan.
- Endpoints publics : `GET /api/v1/categories` (arbre + compteurs d'articles publiés), `GET /api/v1/articles` (`category`, `tag`, `q`, `page`, `limit` ≤ 20), `GET /api/v1/articles/{slug}` (contenu Delta, infobox, tags, références), `GET /api/v1/search` (limitée à 60 req/min).
- Règles de visibilité **côté serveur** : un article non publié ou programmé renvoie `404` avec l'enveloppe d'erreur du CONTEXT §11.2.
- `PublicContentSeeder` : 11 articles de démonstration (Abidjan, Yamoussoukro, Houphouët-Boigny, Constitution 2016, Akan, baoulé, attiéké, Banco, basilique, marche de 1949, cacao), 12 étiquettes, références institutionnelles ; toutes les catégories couvertes.

**Fait — application Flutter**
- Identité : marque vectorielle `IvoireMark` (défense d'ivoire, orange/vert/or) et thème Material 3 `buildIvoireTheme()` (ivoire, encre, orange, vert, or). Le dépôt ne contenant aucun logo binaire, la marque est dessinée en code.
- `IvoirepediaApi` (contrat) + `HttpIvoirepediaApi` (client HTTP, `API_BASE_URL`, défaut `http://localhost:8000/api/v1`) + `ApiScope` pour l'injection ; les tests fournissent une API en mémoire.
- `go_router` : `/`, `/categories/{slug}`, `/articles/{slug}`, `/recherche?q=` — URLs propres et partageables.
- Écrans : accueil (héros, domaines, derniers articles), catégorie (avec « Charger plus »), article (fil d'Ariane, infobox, contenu Delta, étiquettes, références), recherche. Rendu Delta maison : aucun HTML, donc aucune injection possible.
- Mise en page responsive (une colonne < 760 px, grilles au-delà) et en-tête/pied de page communs.

**Vérifié**
- `cd backend && composer test` → **11 tests / 32 assertions** verts, dont 8 tests HTTP de lecture publique (visibilité, pagination plafonnée, 404, recherche).
- `composer format:check` → 53 fichiers conformes ; `composer analyse` → « No errors ».
- `cd app && flutter analyze` → « No issues found! » ; `flutter test` → **3 tests** verts (accueil, article avec infobox et références, 404).
- **En ligne** : `GET /api/v1/articles?limit=3` → `200`, 11 articles au total ; `/api/v1/articles/abidjan` → `200`, 11 opérations Delta + infobox ; `/api/v1/categories` → 8 catégories avec compteurs.
- Site Flutter publié sous `https://ivoirepedia.alwaysdata.net/site/` : build web (`--base-href=/site/`, `API_BASE_URL=/api/v1`), puis vérification navigateur — `main.dart.js`, `flutter_bootstrap.js` et les trois appels API répondent `200`, aucune erreur console.

**Reste**
1. **Contenu éditorial** : les 11 articles sont des textes de démonstration ; l'ouverture publique exige 30 articles de qualité (CONTEXT §14, Sprint 5).
2. **Sprint 1 (authentification)** : inscription, vérification email, connexion Sanctum, `GET /me`.
3. **Sprints 2-3** : éditeur `flutter_quill`, `Workflow.php` et tests de transitions.
4. **SEO** : le site est une SPA servie en `#/…` (limitation R-09) ; métadonnées statiques par défaut dans `web/index.html` à compléter.
5. Mailjet, tâche planifiée et rotation des secrets (voir séance 6).

---

---

### 3 novembre 2026 (séance 8) — Refonte visuelle : une vraie page d'encyclopédie

**Motif (demande du titulaire)** : la première version était trop minimaliste ; la vue doit s'approcher de Wikipédia. Les commandes dont le backend n'existe pas encore restent visibles mais répondent honnêtement (« sera activé avec les fonctionnalités à venir ») au lieu d'être des liens morts.

**Fait**
- Nouvelle palette d'encyclopédie (fond blanc, encre `#202122`, liens `#3366CC`, filets gris) et **titres en serif** (Georgia, repli Times/serif), corps sans-serif 15 px — la hiérarchie visuelle d'une page imprimée.
- Marque redessinée : **globe** à méridiens et parallèles (orange/vert du drapeau) + « IVOIREPEDIA » en serif + devise « L'encyclopédie ivoirienne libre ».
- Ossature : bandeau avec recherche globale et liens de compte, **colonne de navigation** (Navigation / Contribuer / Outils, tiroir sous 1000 px), pied de page licence CC BY-SA.
- **Page d'accueil** façon « une » : bandeau de bienvenue chiffré (articles, domaines), **Article du jour**, **Le saviez-vous ?**, **Explorer par domaine**, colonne d'outils (article au hasard, contribuer).
- **Page article** : onglets `Article · Discussion · Lire · Modifier · Voir l'historique`, titre serif avec filet, mention « Dernière modification le … », **Sommaire** numéroté généré depuis les titres du contenu, sections avec lien « modifier », **infobox encadrée** (en-tête surligné, libellés en gras), **Notes et références**, barre **Catégories**, encart « À propos de cet article ».
- **Page catégorie** : « Catégorie : … » avec onglets, sous-catégories et liste de pages commentées, chargement progressif.
- **Recherche** : résultats comptés (« Résultats 1 à N sur N »), titre en lien, métadonnées et résumé.

**Vérifié**
- `flutter analyze` → « No issues found! » ; `flutter test` → **3 tests** verts (accueil refondu, article avec sommaire/infobox/références, 404).
- Correctif de mise en page : le bandeau débordait de 51 px à 800 px de large (test) ; seuils revus (recherche ≥ 720 px, liens de compte ≥ 1040 px, menu toujours accessible).
- Build web reconstruit et republié sous `/site/` ; rechargement vérifié dans le navigateur : `main.dart.js`, `/api/v1/categories` et `/api/v1/articles` en `200`, aucune erreur console.

**Reste**
1. Brancher les commandes affichées : connexion/inscription (Sprint 1), modification (Sprint 2), discussion et historique (Sprint 3).
2. Contenu éditorial réel et 30 articles de qualité avant ouverture publique.
3. Sommaire cliquable (ancres de section) — le sommaire est pour l'instant indicatif.

---

---

### 3 novembre 2026 (séance 9) — Identité ivoirienne et fond animé

**Motif (demande du titulaire)** : la refonte précédente ressemblait trop à Wikipédia ; il faut une **touche ivoirienne** et un site **plus vivant**, avec un fond qui bouge et des motifs liés à la Côte d'Ivoire.

**Fait**
- **Palette** réancrée sur le pays : ivoire chaud, sable, terre cuite, pourpre, orange et vert du drapeau, or des tissus. Les liens passent du bleu encyclopédique au **vert forêt** ; l'orange porte l'accent éditorial.
- **Typographie** : une ligne de « kicker » (domaine · type) en capitales terre cuite au-dessus des titres, titre serif, puis un **filet tissé orange → or → vert** (`WeaveRule`).
- **Bande kente animée** en haut de page : blocs de couleurs irréguliers et trame tissée, peints en code, défilement lent.
- **Onglets en pastilles** (vert plein pour l'onglet actif) au lieu des boîtes grises ; colonne de navigation sur fond sable avec titres terre cuite, puces losange et encart « l'encyclopédie cite ses sources ».
- **Fond animé** (`IvorianBackdrop`) : lavis orange → vert et **champ de motifs de pagne** (losanges baoulé, cercles de Korhogo, chevrons, sabliers, croix, spirales) qui dérive très lentement. Tout est `CustomPainter`, **aucune image binaire** dans le dépôt.
- **Vie maîtrisée** : cadence du fond limitée à **20 images/s** (le déplacement est de quelques pixels par seconde), apparition douce du contenu à l'ouverture d'une page, respect de la préférence système « réduire les animations ».
- Le bandeau n'affiche plus le menu à côté de la colonne de navigation sur grand écran (seuil 1000 px cohérent avec l'affichage de la colonne).

**Vérifié**
- `flutter analyze` → « No issues found! » ; `flutter test` → **3 tests** verts. Les tests désactivent le mouvement (`ivoireMotionEnabled = false`) pour que `pumpAndSettle` se stabilise ; l'animation est donc vérifiée en ligne, pas en test unitaire.
- Site republié sous `/site/` ; accueil rechargé : `main.dart.js`, `/api/v1/categories`, `/api/v1/articles` en `200`, aucune erreur console ; route `#/articles/abidjan` rechargée : `/api/v1/articles/abidjan` en `200`, aucune erreur console.

**Reste**
1. Contrôler le rendu sur mobile réel (le fond animé est le poste de coût principal).
2. Brancher les commandes affichées (compte, modification, discussion, historique).
3. Sommaire cliquable et partage social (image d'aperçu aux couleurs ivoiriennes).

---

---

### 4 novembre 2026 (séance 10) — Réactivité, police unique et contenus élargis

**Motif (demande du titulaire)** : « plus réactif et plus interactif », « les couleurs de la Côte d'Ivoire », « une police uniforme », « un visuel professionnel », et « seeder beaucoup de données à condition qu'elles soient correctes ».

**Fait — interface**
- **Police unique** : Inter (400/600/700) embarquée dans `app/assets/fonts`, déclarée dans `pubspec.yaml`. Les titres, le corps, les libellés et la navigation partagent désormais la même famille ; les anciens titres serif ont disparu (`serifStyle` → `titleStyle`).
- **Palette drapeau** : vert `#0E7B45` pour l'action, orange `#F07C00` pour l'accent, neutres chauds pour les surfaces ; médaillon de marque aux trois bandes verticales.
- **Réactivité** : liens avec soulignement et changement de teinte au survol, cartes qui se soulèvent, boutons qui s'enfoncent à l'appui, onglets animés, barre de progression de lecture sous le bandeau, bandeau qui prend une ombre au défilement, transitions de page en fondu, squelettes de chargement à la place des roues.
- **Interactions réelles** : sommaire **cliquable** (défilement vers la section), bouton « Copier le lien », article au hasard fonctionnel, recherche **au fil de la frappe** avec délai de 280 ms, URL synchronisée, suggestions et état vide.
- Onglets Discussion / Modifier / Voir l'historique : panneaux explicatifs au lieu de liens morts.

**Fait — contenus**
- `PublicContentSeeder` passe de **10 à 51 articles**, 33 étiquettes et 9 références, répartis sur les huit domaines : géographie (Bouaké, San-Pédro, Korhogo, Man, Bandama), histoire (indépendance 1960, coup d'État de 1999, crise 2002-2011, Samory Touré, royaume de Kong), personnalités (Bédié, Gbagbo, Ouattara, Guéï, Drogba, Alpha Blondy, Kourouma), institutions (président, Assemblée nationale, Sénat, Conseil constitutionnel), langues (dioula, sénoufo, bété, dan, nouchi), culture (zaouli, goli, kedjenou, coupé-décalé, zouglou), patrimoine (Grand-Bassam, Taï, Comoé, Nimba), économie (anacarde, port d'Abidjan, franc CFA, BRVM, hévéa).
- **Règle de prudence appliquée** : faits établis uniquement, formulations prudentes quand une date ou un chiffre est discuté (pas de chiffres de population inventés, pas de résultats électoraux récents), et une référence réelle pour les articles sensibles (UNESCO, Journal officiel, INS).

**Vérifié**
- `flutter analyze` → « No issues found! » ; `flutter test` → **5 tests** verts, dont deux nouveaux sur la recherche (`search_page_test.dart` : terme passé dans l'URL, relance après la frappe).
- Backend : `composer test` → **11 tests / 32 assertions**, `format:check` 53 fichiers, `analyse` « No errors ». Base locale et base de production re-seedées : **51 articles**.
- En ligne : `/site/` charge `main.dart.js`, les trois fontes Inter (400/600/700) et `/api/v1/...` en `200`, sans erreur console ; lien profond `#/articles/bouake` et `#/recherche?q=cacao` vérifiés (requêtes `articles/bouake` et `search?q=cacao` en `200`).
- Correctif d'exploitation : la page racine du site renvoyait `500` (clé `APP_KEY` absente de l'environnement de production) ; clé régénérée, `/` répond `200`.

**Reste**
1. Faire relire les 51 articles par un historien ou un éditeur avant toute ouverture publique (les textes sont sourcés mais restent de démonstration).
2. Enrichir encore : préhistoire, religions, éducation, santé, transports, médias, gastronomie régionale.
3. Vérifier le rendu du survol sur un vrai mobile (pas de souris) et l'accessibilité clavier du sommaire.

---

### 4 novembre 2026 (séance 11) — Corps d'article lisible, présentation encyclopédique

**Motif (demande du titulaire)** : « le contenu (body) est trop IA (vibecode) ; je veux une présentation qui ressemble un tout petit peu à Wikipédia sans que cela ne saute aux yeux, plus professionnelle et créative ».

**Fait**
- **Bogue de mise en forme corrigé** : dans `DeltaContent`, les attributs d'un titre (`{"header": 2}`) étaient reportés sur le paragraphe suivant, qui s'affichait donc en gros titre avec un lien « modifier ». La boucle de lecture des op Delta ne réapplique plus les attributs au segment vide qui suit un saut de ligne.
- **Hiérarchie sobre** : un seul niveau de titre visible (21 px, semi-gras, filet fin), sous-titres 16,5 px, lien « modifier » réduit à 11,5 px en gris ; deux niveaux suffisent, plus de pastilles ni de grands aplats.
- **Texte d'abord** : chapeau en 16,5 px / interligne 1,8, corps en 15,5 px / interligne 1,75, colonne limitée à 720 px pour une longueur de ligne lisible ; listes à puces et numérotées alignées, citations en retrait avec filet vertical.
- **Ordre de lecture** : le sommaire passe **après le chapeau** ; sur petit écran l'infobox passe elle aussi après l'introduction (auparavant elle occupait tout le premier écran).
- **Onglets plats** : la barre d'onglets quitte les pastilles pour un soulignement vert du titre actif, sur une seule ligne défilante ; le reste des repères (bandeau, barre latérale) est inchangé.
- **Repères resserrés** : titre 30 px, filet simple à la place du dégradé, métadonnées allégées (la mention « Un article de IVOIREPEDIA » disparaît sur mobile), espacements des références et des catégories réduits.
- **Même langage sur les autres pages** : l'accueil abandonne l'encadré dégradé, les cartes à en-tête vert et les pastilles pour une introduction en chapeau suivie de sections séparées par un filet fin ; les domaines deviennent une liste de liens avec leur nombre d'articles, en deux colonnes sur grand écran. La recherche remplace ses suggestions en pastilles par une ligne de liens et ses résultats encadrés par une liste de lignes séparées d'un filet. La page de catégorie remplace le filet tricolore par un trait simple.

**Vérifié**
- `flutter analyze` → « No issues found! » ; `flutter test` → **7 tests** verts, dont un nouveau qui vérifie qu'un paragraphe suivant un titre reste un paragraphe (15,5 px, graisse 400) et qu'il n'y a qu'un lien « modifier » par titre, et un second qui rend l'accueil en 1280 × 1000 pour couvrir la disposition à deux colonnes.
- Rendus contrôlés dans le navigateur, en 1280 px et en 420 px, sur `#/articles/felix-houphouet-boigny`, `#/articles/abidjan`, l'accueil, `#/recherche` et `#/categories/histoire` ; captures dans `docs/captures/`. Un « → » isolé s'affichant en carré (glyphe absent d'Inter), le lien de l'accueil s'en tient au texte.
- Build `flutter build web --release --base-href=/site/` redéployé sur Alwaysdata ; API et fontes toujours en `200`, aucune erreur console.

**Reste**
1. Faire relire les 51 articles par un historien ou un éditeur avant toute ouverture publique.
2. Enrichir encore : préhistoire, religions, éducation, santé, transports, médias, gastronomie régionale.
3. Compléter les références des articles qui n'en ont pas encore.

---

### 4 novembre 2026 (séance 12) — Copier et télécharger un article

**Motif (demande du titulaire)** : pouvoir copier un article, y compris section par section, et le télécharger en PDF.

**Fait**
- **Un seul texte source** : `app/lib/src/article_export.dart` lit le contenu Delta une fois (`articleBlocks`) et en tire le texte du presse-papiers comme celui du PDF. Le rendu à l'écran garde son propre lecteur, mais les trois sorties décrivent les mêmes blocs (chapeau, titres, listes, citations).
- **Copier l'article** : bouton dans la ligne de métadonnées. Le presse-papiers reçoit le titre, le corps mis à plat, les références numérotées, les catégories, puis la source (`https://ivoirepedia.alwaysdata.net/site/#/articles/{slug}`) et la licence CC BY-SA 4.0.
- **Copier une section** : chaque titre de section porte désormais, à côté de « modifier », un lien « copier » qui ne prend que cette section — son titre, ses paragraphes, puis la source.
- **Télécharger en PDF** : `pdf` construit un A4 (`MultiPage`) avec la police Inter embarquée — nécessaire car Latin-1 ne couvre ni l'apostrophe courbe ni le tiret cadratin —, un chapeau de métadonnées, le corps, les références, les catégories et une notice de licence, avec la source et la pagination en pied de page. `file_saver` déclenche le téléchargement du navigateur sous `{slug}.pdf`.
- **Lien de partage corrigé** : le bouton « Copier le lien » produisait une adresse sans `/site/` (donc inexistante) ; l'URL est maintenant construite par `articleUrl()`.

**Vérifié**
- `flutter analyze` → « No issues found! » ; `flutter test` → **9 tests** verts, dont deux nouveaux : la copie de l'article complet puis d'une seule section (presse-papiers intercepté, contenu et provenance vérifiés), et la génération du PDF avec les vraies polices Inter (en-tête `%PDF-`, taille non triviale).
- Boutons visibles et actionnés dans le navigateur sur `#/articles/abidjan` : « Copier l'article » affiche « Article copié : titre, texte et références. »

**Reste**
1. Vérifier le téléchargement PDF dans Chrome, Firefox et Safari (le déclenchement du téléchargement par le navigateur ne se prête pas au test automatisé).
2. Faire relire les 51 articles par un historien ou un éditeur avant toute ouverture publique.
3. Enrichir encore : préhistoire, religions, éducation, santé, transports, médias, gastronomie régionale.

---

### 11 novembre 2026 (séance 13) — Répertoire des sources documentaires

**Motif (demande du titulaire)** : « J'ai besoin d'un puits d'informations divers » — recenser toutes les plateformes où trouver des informations pour l'encyclopédie, au-delà de Wikipédia : sites du gouvernement, institutions, statistiques, archives, presse, recherche.

**Fait**
- **`docs/SOURCES_INFORMATION.md`** : répertoire en dix-huit sections — encyclopédies et bases générales ; exécutif et ministères ivoiriens ; Parlement, justice, élections, opérateurs et collectivités ; statistiques internationales ; cartographie, toponymie et climat ; patrimoine, archives et musées ; recherche et thèses ; presse et audiovisuel ; droit et jurisprudence ; langues ; sport ; économie et entreprises ; organisations internationales — puis un guide « par où commencer selon le sujet », huit règles de sourçage, les angles morts assumés et le journal de vérification.
- **Vérification, pas compilation** : 176 adresses testées par requête HTTP le 11 novembre 2026, avec code de statut et redirection suivie. Les réponses 403 sont distinguées des sites morts — la Présidence et le portail du Gouvernement refusent les robots mais ont été ouvertes dans un navigateur pour le confirmer ; les échecs réels (502 du BNETD, 503 de JORCI, certificat expiré de `www.sgg.gouv.ci`) sont datés plutôt que masqués.
- **Écartés après test** : `ccja.ci`, `cge.ci`, `justice.gouv.ci`, `interieur.gouv.ci`, `sports.gouv.ci`, `rti.ci` (502), `olympics.com`, Our World in Data (pas de page pays), Human Rights Watch (page pays introuvable). `coursupreme.ci` reste cité comme site historique, avec la mise en garde sur le découpage Cour de cassation / Conseil d'État.
- **Ce que le répertoire ajoute au projet** : la distinction entre accès libre et droit de réutilisation, la règle du millésime pour tout chiffre, la nécessité de recouper le politique, et l'indication des gisements réellement exploitables pour les images (Commons, Met Open Access) contre ceux qui exigent un accord (presse, musées).
- **`IVOIREPEDIA_CONTEXT.md`** : le répertoire entre au §2 comme document de référence ; historique du document en version 1.4.

**Vérifié**
- 322 lignes, aucune adresse laissée sans statut ; les liens les plus critiques ont été rouverts individuellement (Présidence, Gouvernement, SGG, ANStat, GeoNames, Banque mondiale).
- Aucun code applicatif modifié : `flutter analyze` et `flutter test` restent ceux de la séance 12 (neuf tests verts).

**Reste**
1. Porter les sources les plus utiles dans la page « Charte et sources » de l'application, pour que les contributeurs les trouvent sans lire un fichier Markdown.
2. Constituer une bibliographie ivoirienne de référence (ouvrages imprimés) : le répertoire recense des plateformes, pas encore les titres.
3. Faire relire les 51 articles par un historien ou un éditeur avant toute ouverture publique.

---

### 11 novembre 2026 (séance 14) — Statistiques nationales et articles enrichis

**Motif (demande du titulaire)** : compléter les informations déjà en base à l'aide du répertoire de sources, et créer une fonctionnalité statistique sur la Côte d'Ivoire, « le plus exhaustif possible ».

**Fait**
- **Recensement exploité à la source** : le PDF officiel du RGPH 2021 (ministère de l'Économie, du Plan et du Développement, 22 juillet 2022) a été téléchargé, son texte extrait en colonnes (`pdftotext -table`), puis réassemblé par un script qui recolle les séparateurs de milliers et valide chaque ligne par l'identité `total = hommes + femmes`. Résultat figé dans `backend/database/data/rgph-2021.json` : population nationale **29 389 150**, 14 districts, 31 régions, 40 villes avec ménages et taille moyenne — licence et URL du document comprises.
- **Trois tables** : `country_indicators` (valeur, année, organisme, licence), `country_indicator_points` (série annuelle), `census_divisions` (districts, régions, villes). Aucune route d'écriture : l'API ne fait que lire.
- **Commande `country:sync-statistics`** : importe le recensement, puis les séries de la Banque mondiale (51 indicateurs WDI, 1990-2025) soit par le réseau, soit depuis l'instantané `database/data/worldbank-civ.json` (`--from-file`, licence CC BY 4.0) ; `--offline` n'importe que le recensement. **55 indicateurs et 1 500 points** en base.
- **API `GET /api/v1/statistics`** : indicateurs groupés en six thèmes (démographie, économie, société et travail, santé, éducation, énergie et environnement), chiffres clés, bloc recensement, divisions administratives ; cache de six heures.
- **Page Flutter `/statistiques`**, atteignable depuis la barre latérale : population résidente du RGPH, cartes de chiffres clés avec courbe de tendance, tableaux par thème (valeur, année, source), barres de population des districts, des régions et des vingt plus grandes villes, puis les sources et licences. Aucune bibliothèque de graphiques ajoutée : la courbe est un `CustomPainter` de quelques lignes, cohérent avec la sobriété du site.
- **Articles enrichis** : commande `articles:enrich-sources` sur un jeu de données vérifiées (`database/data/article-enrichment.php`). **22 articles examinés, 5 infobox complétées** (Yamoussoukro 422 072, Bouaké 832 371, Korhogo 440 926, Man 241 969, San-Pédro 390 654) et **24 références ajoutées** (fiches UNESCO du patrimoine mondial — Comoé 227, Taï 195, Grand-Bassam 1322 —, éléments du patrimoine immatériel — Zaouli 01255, attiéké 02086 —, sites institutionnels, FAOSTAT, BRVM, port d'Abidjan, UCDP). La référence historique pointant vers `ins.ci` est remplacée par le PDF officiel du RGPH.

**Vérifié**
- `phpstan` niveau 5 : aucune erreur ; `pint --test` : 65 fichiers conformes ; **16 tests PHP** verts, dont deux nouveaux fichiers : l'API statistique (structure, format français « 31 934 230 habitants », source et série) et l'import hors ligne du recensement (29 389 150, 6 321 017 pour Abidjan, 832 371 pour Bouaké, 31 régions, 14 districts) ; l'enrichissement (infobox, références, idempotence, référence éditoriale préservée).
- `flutter analyze` : aucune remarque ; **10 tests Flutter** verts, dont la page statistique atteinte en cliquant « Statistiques » dans la barre latérale, avec vérification de la population du recensement, d'un indicateur et des divisions.
- API contrôlée en local puis en production : 80 ko de JSON, en-tête `32 711 547 habitants` (2025), PIB 99,8 milliards USD, 14 districts / 31 régions / 40 villes ; `GET /api/v1/articles/bouake` renvoie l'infobox `CITY` 832 371 (2021) et la référence RGPH.
- Base de production migrée, peuplée (55 indicateurs, 1 500 points, 85 divisions) et articles enrichis (22 examinés, 5 infobox, 24 références) ; build web redéployé (bundle de 3,5 Mo contenant la route `/statistiques`).
- Rendu de la page contrôlé dans le navigateur en production après l'incident du 12 novembre (capture : `docs/captures/statistiques.png`).

**Incident du 12 novembre — page blanche en production**

Signalement : `https://ivoirepedia.alwaysdata.net/site/#/statistiques` n'affichait qu'une page blanche. Diagnostic : le navigateur ne recevait jamais `main.dart.js` en entier. Mesures au `curl` et dans la page : Apache d'Alwaysdata compressait les fichiers à la volée en **Brotli**, ce qui ramenait le débit du bundle à 6 ko/s (733 ko en 120 s) ; la connexion était coupée vers 40 s, le script ne s'exécutait donc pas et Flutter ne créait jamais sa vue (aucune requête à l'API, aucun `flutter-view`). Un test du même fichier en gzip donnait 29 ko/s, d'où la cause.

Correctifs livrés :
- `app/web/.htaccess` (copié dans le build) désactive Brotli pour `js`, `wasm`, `json` et les polices ; gzip reste actif et sert le bundle en ~28 s au lieu de 120 s.
- `app/web/index.html` affiche un écran de chargement (« Chargement de l'encyclopédie… ») qui disparaît dès que la vue Flutter existe, signale la lenteur au bout de 12 s et propose de recharger au bout de 90 s : plus de page blanche muette.
- En-têtes de cache : `no-cache` pour le code et les manifestes (déploiement visible immédiatement), un jour pour CanvasKit et les polices (plusieurs mégaoctets stables).
- Un test de non-régression rend la page avec la **charge réelle** de l'API, enregistrée dans `app/test/support/statistics_payload.json` : 11 tests Flutter verts.

Leçon à retenir pour les prochains déploiements : la compression à la volée du serveur fait partie du chemin critique d'une application Flutter web ; à vérifier en même temps que le code.

**Reste**
1. Références pour les articles qui n'en ont pas encore de vérifiable : biographies (Kourouma, Gbagbo, Guéi, Samory Touré), langues (Glottolog à identifier), culture populaire (zouglou, coupé-décalé, goli, kedjenou) — mieux vaut pas de référence qu'une référence décorative.
2. Comparer les séries de la Banque mondiale aux publications de l'ANStat quand elles divergent (population estimée contre recensement) et l'expliquer dans les articles.
3. Ajouter les données du RGPH 2014 pour une série intercensitaire complète.

---

## Blocages

**Aucun blocage.** L'API répond en HTTPS sur le compte dédié.

**Mailjet** n'est pas bloquant : `MAIL_MAILER=log` jusqu'à réception de la clé SMTP.

**Historique Git** : les commits antérieurs à la séance 5 contiennent les hôtes et noms de bases de l'ancien compte. La réécriture (`git filter-repo` + `push --force`) n'a pas été faite : destructive, elle attend une décision explicite.

---

## Travail restant détaillé

Voir le backlog ordonné dans `IVOIREPEDIA_CONTEXT.md` §14 (Sprint 0 à Sprint 5, puis V1).
