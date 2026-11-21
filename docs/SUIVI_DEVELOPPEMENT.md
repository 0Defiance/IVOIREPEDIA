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

### 13 novembre 2026 (séance 15) — Pluviométrie et « Histoire incroyable »

**Motif (demande du titulaire)** : rendre la page statistique « plus réaliste et non simpliste, avec une simple courbe », ajouter des statistiques pluviométriques, et ouvrir une section « Histoire incroyable » sur la Côte d'Ivoire.

**Fait — climatologie**
- Nouvelle source : la réanalyse **ERA5** (service Copernicus Climate Change, diffusée par Open-Meteo, licence CC BY 4.0), interrogeé par un script reproductible `database/data/fetch-climate-normals.py`, qui agrège le journalier en normales mensuelles et cumuls annuels. Période de référence **1991-2020**, six villes (Abidjan, Bouaké, Korhogo, San-Pédro, Yamoussoukro, Man). Instantané figé dans `database/data/climate-normals.json` : **72 normales mensuelles** et **180 cumuls annuels**.
- Trois tables : `climate_cities`, `climate_months` (pluie, jours de pluie, température) et `climate_years`. Importées par `country:sync-statistics`, y compris en mode `--offline` : le déploiement ne dépend d'aucun appel réseau.
- `GET /api/v1/statistics` expose désormais `data.climate` : période, source et licence, puis par ville les douze mois et les trente années.

**Fait — graphiques**
- La vignette « courbe » des cartes de chiffres clés est remplacée par un vrai graphique à axes (`YearLineChart`) : grille, graduations compactes (k/M/Md), années repères, aire dégradée et point final.
- Nouvelle section **Pluviométrie** : sélecteur de ville, cumul annuel, mois le plus arrosé, années les plus sèches et les plus arrosées, **barres mensuelles** (le mois le plus arrosé est mis en avant et étiquetté) avec la **courbe de température** en surimpression, puis la courbe des cumuls annuels 1991-2020. Deux villes à 1 400 mm n'ont pas la même saison : les barres le montrent, une moyenne annuelle le cache.

**Fait — Histoire incroyable**
- Table `history_stories`, commande `history:sync-stories`, endpoint `GET /api/v1/history` (cache 6 h) et page Flutter `/histoires`, atteignable depuis l'entrée « Histoire incroyable » de la barre latérale.
- **Sept récits** courts, chacun adossé à un document : Grand-Bassam capitale abandonnée (UNESCO, 2012), la Comoé (UNESCO, 1983), Taï et son hippopotame pygmée (UNESCO, 1982), le Zaouli gouro (UNESCO, 2017), l'attiéké (UNESCO, 2024), le cacao premier producteur mondial (FAOSTAT) et Abidjan, 6 321 017 habitants (RGPH 2021). Chaque récit se déplie sur place et affiche sa source, son éditeur, son année et son URL.

**Vérifié**
- `pint --test` : 75 fichiers conformes ; `phpstan` : aucune erreur ; **21 tests PHP** verts, dont trois nouveaux : import de la climatologie sans réseau (6 villes, 12 mois, 30 ans, licence CC BY 4.0), exposition de `data.climate` (juin = mois le plus arrosé à Abidjan), et import/API des récits (ordre, source, idempotence).
- `flutter analyze` : aucune remarque ; **14 tests Flutter** verts, dont la section pluviométrie (chips de villes, cumul annuel, mois le plus arrosé), l'accès à « Histoire incroyable » depuis la barre latérale et le dépliage d'un récit avec sa source.
- Données contrôlées : Abidjan 1 851,5 mm/an (juin 253 mm, août 85 mm), Korhogo 1 057,7 mm/an, Man 1 511,4 mm/an — ordres de grandeur conformes au climat ivoirien.

**Limite assumée** : ERA5 est une réanalyse sur grille (~9 km) ; elle lisse les extrêmes locaux et sous-estime les cumuls des stations côtières (Abidjan ~1 850 mm contre ~2 000 mm en station). La page le dit explicitement, et la source est citée avec sa licence.

---

### 13 novembre 2026 (séance 16) — Quatre récits d'histoire plus anciens

**Motif (demande du titulaire)** : ajouter des récits d'histoire plus anciens — royaumes akan, Samory Touré, migrations baoulé — « en vérifiant chaque source avant publication ».

**Méthode** : aucune source n'a été reprise d'un souvenir ou d'un site de vulgarisation. Chaque récit a été rattaché à un document daté, puis son URL a été contrôlée en HTTP (code 200) avant publication.

**Fait — quatre récits, quatre documents**
- **Abengourou et les Agni Ndénian (1701-1870)** — Silué, Diabaté & Diabagaté, *Origines et mise en place des Agni Ndénian à Abengourou (1701-1870)*, AKIRI 4 (2), 2026, via AJOL. Foyer Aowin fondé par Ano Assoman après les conflits avec le Denkyira, migration conduite par Ahi Abayé (Konvi Andé, Afewa, Zaranou), installation le long de la Comoé, fondation d'Abengourou par Mian Kouadio au XIXe siècle.
- **La traversée du Comoé et le nom baoulé (XVIIIe siècle)** — Amenan Larissa Diby, *Reliques d'une tradition : Abla Pokou et le peuple baoulé*, Akofena. L'exode est daté du XVIIIe siècle, le sacrifice de l'enfant unique est présenté comme le récit transmis par la tradition orale, et le nom « baoulé » comme « l'enfant est mort ».
- **Le Sanvi et la balahinma Manlan Ahua (1843-1898)** — recension par l'Académie des sciences d'outre-mer de la thèse d'Henriette Dagri Diabaté, *Le Sanvi : un royaume Akan, 1701-1901* (CERAP-IRD-Karthala, 2013). Traité de 1843 avec la France, protectorat, mort d'Amun Ndufu en 1885, rôle de la balahinma jusqu'à sa mort en 1898.
- **La capture de Samory Touré à Guélémou (29 septembre 1898)** — recension dans la *Revue historique des armées* (no 271, 2013) de l'ouvrage de Julie d'Andurain, *La capture de Samory (1898)*. Colonne de deux cents tirailleurs du capitaine Henri Gouraud, capture au petit matin sans un coup de feu, reddition des chefs et des quelque 1 800 sofas, déportation au Gabon.

**Choix éditorial** : chaque récit reste strictement dans ce que dit son document. Là où la tradition orale est la source — Pokou, le sens du nom baoulé —, le texte l'écrit comme telle au lieu de la présenter comme un fait établi. Les récits sont ordonnés du plus ancien au plus récent et précédent désormais Grand-Bassam dans la page.

**Vérifié**
- Les quatre URL répondent en 200 (AJOL, Akofena, Académie des sciences d'outre-mer, OpenEdition) ; Akofena redirige vers sa variante avec barre oblique finale, c'est celle qui est enregistrée.
- `pint --test` : 75 fichiers conformes ; `phpstan` : aucune erreur ; **26 tests PHP** verts (+5) : import des quatre récits anciens avec leur URL exacte, contrôle que chaque récit publié porte une source `https`, un titre et une année, ordre de l'API et position de Grand-Bassam.
- Aucun changement Flutter : la page `/histoires` lit l'API et affiche les récits dans l'ordre reçu, les quatre nouveaux apparaissent sans modification de code.

**Limite assumée** : les dates de la migration baoulé varient selon les auteurs (XVIIIe siècle ; installation située entre 1730 et 1760 par l'*Encyclopaedia Universalis*) ; le récit retient la formulation large de la source citée plutôt qu'une date précise non vérifiée.

---

### 13 novembre 2026 (séance 17) — Le site à la racine, avec des adresses propres

**Motif (signalement du titulaire)** : le site n'était accessible que sous `https://ivoirepedia.alwaysdata.net/site/#/statistiques` — un sous-dossier et un dièse qui ne font pas une adresse de site professionnelle.

**Fait — adresses**
- `usePathUrlStrategy()` dans `app/lib/main.dart` remplace la stratégie `#/` : les adresses deviennent `/statistiques`, `/histoires`, `/articles/{slug}`, `/categories/{slug}`, `/recherche?q=…`. Elles se partagent et se rechargent telles quelles.
- `articleUrl()` et `kSiteUrl` (`app/lib/src/article_export.dart`) pointent désormais vers la racine, sans dièse : les liens copiés, le presse-papiers et le PDF citent `https://ivoirepedia.alwaysdata.net/articles/{slug}`.

**Fait — service à la racine**
- Le build est produit avec `--base-href=/` et déployé dans `backend/public/`, la racine du document, à côté de `index.php`.
- `backend/public/.htaccess` répartit les requêtes : `/api`, `/admin`, `/livewire`, `/sanctum` à Laravel ; fichier ou dossier réel servi directement (assets, CanvasKit, polices) ; toute autre adresse reçoit `index.html`, ce qui rend les routes Flutter rechargeables.
- Les anciennes adresses `/site/...` sont redirigées en 301 vers la racine, pour ne pas casser les liens déjà partagés. L'ancien dossier `site/` est supprimé au déploiement.
- `app/web/.htaccess` est supprimé : ses règles (brotli, cache) sont reprises dans `backend/public/.htaccess`, seule source de vérité pour la racine. Un `.htaccess` livré avec le build aurait écrasé les règles Laravel et cassé l'API.

**Vérifié**
- `flutter analyze` : aucune remarque ; **15 tests Flutter** verts (+1 : `articleUrl()` renvoie une adresse sans dièse).
- En ligne : `/` renvoie le HTML du bootstrap, `/statistiques` et `/histoires` répondent `200` avec le même document, `/api/v1/history` et `/api/v1/statistics` restent en `200`, les assets et `main.dart.js` sont servis depuis la racine.
- Navigateur, adresse directe `https://ivoirepedia.alwaysdata.net/statistiques` : la page se rend (graphiques, pluviométrie) et appelle `/api/v1/statistics` en `200`, sans erreur console ; `https://ivoirepedia.alwaysdata.net/histoires` charge `/api/v1/history` en `200`. Capture `docs/captures/statistiques.png` refaite depuis cette adresse (elle datait d'un build antérieur au correctif d'unités).

**Limite assumée** : le rendu reste côté client (R-09) ; les crawlers voient un HTML unique pour toutes les routes. Un prérendu statique par route reste au backlog V1.

---

### 13 novembre 2026 (séance 18) — Frise, fiches de lieux, partage et confort de lecture

**Motif (demande du titulaire)** : intégrer les fonctionnalités de la liste de recherche — frise chronologique, fiches géographiques, partage, recherche instantanée, favoris, réglages de lecture, sommaire suivi, notes cliquables.

**Fait — côté API**
- `GET /api/v1/timeline` : la frise n'a pas de contenu propre, elle est construite à partir des récits datés (`history_stories.year`, nouvelle colonne alimentée par `history:sync-stories`). Ajouter un récit daté ajoute un jalon.
- `GET /api/v1/places` et `/places/{slug}` : districts, régions et villes du RGPH 2021, une fiche rassemblant les niveaux qui partagent un slug (Abidjan est district, pas ville), avec climat (rapprochement des noms normalisés : « BOUAKE » côté recensement, « Bouaké » côté climatologie) et articles liés par titre ou chapeau.
- `GET /api/v1/search/suggest?q=` : six titres au maximum, à partir de deux caractères, pour la recherche instantanée.

**Fait — côté application**
- **Frise du temps** (`/chronologie`) : jalons groupés par siècle, année, période et accroche ; chaque ligne ouvre le récit correspondant (`/histoires?recit=slug`, que la page des récits déplie à l'arrivée).
- **Villes et régions** (`/lieux`, `/lieux/{slug}`) : annuaire filtrable, fiche avec population, hommes, femmes, ménages, taille moyenne, climat et articles liés ; les lignes de la page statistique mènent désormais à ces fiches.
- **Partage** : WhatsApp, X, Facebook, LinkedIn et copie du lien sous le titre ; liens profonds par section (`/articles/{slug}#ancre`), l'ancre étant calculée depuis le titre.
- **Recherche instantanée** : suggestions sous le champ pendant la frappe et historique des huit dernières recherches, effaçable.
- **Ma bibliothèque** (`/ma-bibliotheque`) : favoris et lectures récentes dans le stockage du navigateur, sans compte ; bouton « Garder » sur chaque article.
- **Confort de lecture** : thème papier / sépia / nuit, taille du texte de 85 à 150 %, mode lecture seule qui masque le menu et le pied de page ; réglages conservés sur l'appareil. Le thème s'applique à l'en-tête, à la colonne, à la feuille et au corps de l'article.
- **Sommaire suivi** : colonne de gauche collante sur grand écran, la section en cours de lecture s'allume ; le sommaire reste après le chapeau sur mobile.
- **Notes cliquables** : un `[1]` dans le texte ouvre la référence 1, chaque référence offre un retour au texte, et un bouton copie le lien de la section.

**Vérifié**
- `pest` : **31 tests** verts (+5 : frise ordonnée et sourcée, annuaire, fiche de lieu multi-niveaux avec climat, 404, suggestions sans brouillon) ; `pint --test` : 80 fichiers conformes ; `phpstan` : aucune erreur.
- `flutter analyze` : aucune remarque ; **20 tests Flutter** verts, dont 5 nouveaux : frise atteinte depuis la barre latérale, annuaire → fiche avec climat, suggestions de recherche, article avec références et favori, URL de partage sans dièse avec ancre.

**Limites assumées**
- Le mode nuit est un thème de lecture (interface, feuille et texte) : les cartes de données de la page statistique gardent leur papier clair, par choix de lisibilité des graphiques.
- Les articles n'utilisent pas encore d'appels de note `[n]` dans leur texte : le mécanisme est en place et testé, il s'activera à la première note rédigée.
- Le rendu reste côté client : les nouvelles pages ne sont pas prérendues (R-09).

---

## Séance 19 — 13 novembre 2026 · Des chiffres à jour, et ce qu'ils font dans le temps

**Demande**
- Utiliser les données statistiques les plus récentes possibles, et afficher à côté de chaque statistique la moyenne annuelle (croissance ou décroissance).

**Constat après vérification**
- L'instantané de la Banque mondiale était déjà le plus récent publié : séries annuelles **1990-2025**, dernière publication du 11 novembre 2026 (vérifié à l'API le 13). Il n'existe donc pas de chiffre 2026 officiel : 2025 est la dernière année disponible.
- En revanche l'affichage ne disait pas la fraîcheur des séries, et une valeur seule (RGPH 2021, « 6 321 017 habitants ») ne dit pas si la population monte ou baisse.

**Fait — côté API**
- Chaque indicateur porte `trend` : fenêtre des cinq dernières années, variation absolue par an, taux de croissance composé par an, sens (`hausse`, `baisse`, `stable`) et libellé prêt à afficher (« +2,5 % par an (2020-2025) »). Pour un indicateur déjà en pourcentage, la variation s'exprime en **points par an** : un taux de croissance d'un taux n'a pas de sens.
- `meta.data_through` (dernière année publiée), `meta.census_year` et `meta.census_note` : le recensement de 2021 est présenté comme le dernier publié, pas comme un chiffre périmé.
- `data.census.growth` : croissance démographique nationale la plus récente, avec sa source.
- `GET /api/v1/places/{slug}` gagne `estimate` : population extrapolée pour 2026 à partir du RGPH 2021 et de la croissance nationale, avec la méthode et la mention « estimation, pas un recensement ». Aucun chiffre officiel n'est inventé.

**Fait — côté application**
- Page statistique : bandeau « Séries annuelles à jour jusqu'en 2025 · recensement : RGPH 2021 », croissance annuelle dans le panneau du recensement, et sous chaque indicateur (cartes de tête comme tableaux par thème) son évolution annuelle moyenne, flèche verte à la hausse, orange à la baisse.
- Fiche de lieu : la population du RGPH 2021 est suivie de « ≈ N habitants en 2026 », de la méthode (« RGPH 2021 extrapolé avec la croissance nationale de 2,4 % par an (2025) ») et de la réserve sur son statut d'estimation.
- Courbes : chaque graphique porte sa période. Les grandes courbes affichent l'année de début, l'année médiane et l'année de fin (les deux bornes plus marquées), et les vignettes des tableaux affichent leur année de début et de fin sous la courbe : une courbe se lit désormais sans remonter au libellé de l'indicateur.
- La page gagne une vignette par indicateur dans les tableaux, en 88 px, pour laisser la place aux deux années sans écraser la valeur.

**Vérifié**
- `pest` : **33 tests** verts (+2 : évolution annuelle et croissance du recensement, extrapolation 2026 non présentée comme officielle) ; `pint --test` : 80 fichiers conformes ; `phpstan` : aucune erreur.
- `flutter analyze` : aucune remarque ; **22 tests Flutter** verts (+2 : évolution annuelle par indicateur, années de début et de fin des vignettes).

**Limites assumées**
- L'extrapolation 2026 utilise la croissance **nationale** : elle ne capture ni la dynamique propre d'Abidjan ni une éventuelle baisse locale, et ne remplace pas un recensement.
- La climatologie reste une normale 1991-2020 : c'est la période de référence publiée, pas une donnée périmée.

---

## Séance 20 — 13 novembre 2026 · Une vraie une

**Demande**
- La page d'accueil paraissait trop simple et vide : en faire une entrée qui donne envie, sans ajouter de dépendance ni de backend.

**Fait — côté application**
- **Bande d'ouverture** : filet aux trois couleurs du drapeau, titre « La Côte d'Ivoire, documentée. », la promesse éditoriale, puis les compteurs (articles, domaines, période couverte par la frise, régions et districts) et trois portes d'entrée — la frise, les villes et régions, les chiffres du pays.
- **Quatre chiffres clés** en cartes cliquables : population (avec son évolution annuelle), territoires du RGPH, jalons historiques avec leur période, articles publiés. Chaque carte mène à la page qui la détaille.
- **À la une** : l'article du jour devient une carte éditoriale (domaine en capitale, titre large, date de publication, chapô, filet tissé).
- **Aujourd'hui dans l'histoire** : chaque jour de l'année détermine un jalon différent (index du jour dans la frise), affiché avec son année et « il y a N ans ». Aucune requête supplémentaire, aucun hasard serveur.
- **La frise en un coup d'œil** : les jalons défilent horizontalement, avec leur siècle, et mènent au récit ; lien vers la frise complète.
- **Reprendre la lecture** : dans la colonne latérale, le dernier article lu (mémoire de l'appareil), avec sa date et un lien pour continuer.
- La frise et les statistiques sont chargées **à part** : si l'une des deux API échoue, la une reste complète sans elles.

**Vérifié**
- `flutter analyze` : aucune remarque ; **22 tests Flutter** verts, dont le test d'accueil enrichi : titre d'ouverture, chiffre de population avec son évolution, jalon du jour, frise et récits affichés.
- Aucun changement backend : `pest`, `pint` et `phpstan` n'ont pas été relancés (aucun fichier PHP touché).

**Limites assumées**
- Pas de carte géographique ni de photos : aucune géométrie ni image n'est fournie par les données actuelles.
- Le jalon du jour est le même pour tous les visiteurs du jour, mais il n'est pas « historique » au sens d'une date exacte : la frise ne porte que des années.

---

## Séance 21 — 13 novembre 2026 · Des articles, pas des notices

**Demande**
- Les textes publiés étaient trop courts : l'article Abidjan se lisait en trois paragraphes.

**Constat**
- Les 51 articles du contenu public venaient d'un seeder de démonstration, avec deux ou trois sections de deux phrases. La structure (Delta Quill, sommaires, références) était prête, le fond manquait.

**Fait**
- Les articles de territoires sont réécrits en articles de fond : **Abidjan** (dix sections : site et lagune, capitale économique, dix communes, ponts, port, métropole ouest-africaine, culture, défis environnementaux), et autour d'elle **Yamoussoukro**, **Bouaké**, **San-Pédro**, **Korhogo**, **Man**, **Grand-Bassam**, **Le Bandama**, **Le port d'Abidjan**.
- Chaque texte appuie ses affirmations sur ce que l'on sait du pays sans inventer de chiffre : les effectifs cités sont ceux du RGPH 2021 déjà en base (6 321 017 à Abidjan, 832 371 à Bouaké, 440 926 à Korhogo, 390 654 à San-Pédro, 241 969 à Man, 124 567 à Grand-Bassam, 422 072 pour le district de Yamoussoukro).
- Les infobox des villes portent désormais leur population et son année, au lieu d'un champ vide.
- Références conservées (INS RGPH 2021, UNESCO pour Grand-Bassam, etc.) : aucune source inventée.

**Vérifié**
- `pest` : **34 tests** verts (+1 : Abidjan dépasse 650 mots et 7 sections, Bouaké et Korhogo dépassent 300 mots, la population de Bouaké est en infobox) ; `pint --test` : 80 fichiers conformes ; `phpstan` : aucune erreur.
- Aucun changement Flutter : `flutter analyze` et `flutter test` ne sont pas relancés.

**Reste**
- Les 42 autres articles (personnalités, institutions, langues, culture, patrimoine, économie) gardent leur format court : ils demanderont le même travail, sujet par sujet.

---

## Séance 22 — 13 novembre 2026 · Une voix ivoirienne, des faits précis

**Demande**
- Les textes doivent sentir la Côte d'Ivoire — sans vulgarité — et dire des choses précises plutôt que des généralités.

**Fait**
- Les neuf articles de territoires sont réécrits une seconde fois, avec un ancrage local assumé : « chercher la vie » à Abidjan, les gbakas et les woro-woros, le garba et l'allocodrome, les maquis, le zouglou né dans les campus de Yopougon, le « Vieux » pour Houphouët-Boigny, l'harmattan à Korhogo, le « Bassam » des habitués, les caïmans des lacs de Yamoussoukro.
- Les détails remplacent les formules creuses : les dix communes d'Abidjan avec leurs quartiers (Angré, Deux-Plateaux, Riviera, Siporex, Niangon, Toits Rouges, Anonkoua-Kouté, Boribana, Anoumabo), la Cité administrative et la cathédrale Saint-Paul, les trois ponts et leurs dates, les navettes lagunaires, les CHU de Treichville, Cocody et Yopougon, les universités Félix Houphouët-Boigny et Nangui Abrogoua, les stades Félix Houphouët-Boigny et d'Ebimpé, la CAN remportée en février 2024.
- Les séries démographiques de la fiche sont reprises : 6 321 017 habitants, 3 210 983 hommes, 3 110 034 femmes, 1 414 136 ménages, 4,5 personnes par ménage, 2 140 km², soit près de 3 000 habitants au kilomètre carré.
- Même travail sur les autres fiches : le marché Gouro et les gares routières d'Adjamé, les filatures et égrenage de Bouaké, Taï et Monogaga pour San-Pédro, le Poro et les toiles de Korhogo, la région des Dix-Huit Montagnes et les ponts de lianes à Man, le musée national du Costume à Grand-Bassam, Kossou et Taabo pour le Bandama.

**Vérifié**
- `pest` : 34 tests verts, dont le test de longueur (Abidjan > 650 mots, 7 sections au moins) ; `pint` : 80 fichiers conformes ; `phpstan` : aucune erreur.
- Aucun changement Flutter.

**Limites**
- Les précisions ajoutées restent des faits établis et vérifiables ; aucun chiffre nouveau n'a été inventé, et les effectifs viennent tous du RGPH 2021 déjà en base.
- Les 42 autres articles gardent leur format court.

---

## Séance 23 — 13 novembre 2026 · Les 42 articles restants passent en forme longue

**Demande**
- Traiter le reste du corpus avec la même exigence : voix ivoirienne, faits précis, pas de notices.

**Fait — trois lots, 42 articles**
- **Histoire et personnalités (13)** : indépendance du 7 août 1960, marche des femmes du 24 décembre 1949 et Marie Koré, Samory Touré et sa capture à Guélémou en 1898, royaume de Kong, coup d'État du 24 décembre 1999, crise 2002-2011 (Marcoussis, Ouagadougou, 11 avril 2011), Houphouët-Boigny, Bédié, Gbagbo, Ouattara, Guéï, Drogba, Alpha Blondy.
- **Institutions et langues (12)** : constitution de 2016 (vice-présidence, Sénat, mandat de cinq ans renouvelable une fois), présidence, Assemblée nationale (255 députés), Sénat (99 membres, deux tiers élus), Conseil constitutionnel ; akan, baoulé, dioula, sénoufo, bété, dan, nouchi.
- **Culture, patrimoine, économie (17)** : zaouli (UNESCO 2017), goli, kedjenou, coupé-décalé, zouglou, Ahmadou Kourouma (Renaudot 2000), attiéké ; basilique de Yamoussoukro, Banco, Taï (UNESCO 1982), Comoé (1983), mont Nimba ; cacao, anacarde, franc CFA, BRVM, hévéa.

**Vérifié**
- `pest` : **34 tests** verts, dont un nouveau garde-fou collectif : **aucun article ne descend sous 150 mots ni sous trois sections** (le test liste les contrevenants et échoue s'il en trouve). `pint --test` : 80 fichiers conformes ; `phpstan` : aucune erreur.
- Contenu reseedé en production après déploiement.

**Limites**
- Les faits restent des faits établis, formulés prudemment quand une date ou un chiffre prête à débat ; aucun chiffre n'a été inventé pour « faire précis ».
- Les articles de personnalités vivantes restent descriptifs et neutres : pas de jugement politique.

---

## Séance 24 — 14 novembre 2026 · Références par article et données 2025-2026

**Demande**
- Ajouter des références précises à chaque article, approfondir les dix sujets phares, et ne plus s'appuyer seulement sur le RGPH 2021 : chercher les données les plus récentes.

**Sources récentes retenues (vérifiées en ligne)**
- **ANStat, *Chiffres clés de la Côte d'Ivoire 2025*** (juillet 2025) : population 32,8 millions, croissance démographique 2,73 %, densité 100,8 hab/km², 52,5 % d'urbains, PIB 48 294 milliards FCFA en 2023, PIB/habitant 1,56 million FCFA.
- **Gouvernement / Trésor / BAD** : croissance 6,5 % en 2025 ; PIB par habitant 3 188,6 USD en 2025 ; inflation 0,1 % en 2025 (3,5 % en 2024) ; déficit budgétaire ramené à 3,0 % du PIB ; dette 55,6 % du PIB fin 2025 (FMI).
- **FMI, revues 2026** : croissance attendue à 6,0 % en 2026, inflation 3,3 %, réserves régionales supérieures à huit mois d'importations.
- **ANStat, comptes nationaux T1 2026** : PIB +4,7 % en glissement annuel.
- **Présidentielle du 25 octobre 2025** : Alassane Ouattara 89,77 % (3 759 030 voix), participation 50,10 %, résultats définitifs proclamés le 4 novembre 2025 par le Conseil constitutionnel présidé par Chantal Nanaba Camara, première femme à ce poste ; Laurent Gbagbo et Tidjane Thiam écartés du scrutin.
- **Cacao** : prix bord champ 2026-2027 fixé à 1 200 FCFA/kg (café 1 300 FCFA), campagne principale du 1er septembre au 28/29 février, campagne intermédiaire du 1er mars au 31 août.
- **Métro d'Abidjan** : ligne 1 de 37,4 km et 18 stations, 540 000 passagers/jour visés, 66 % d'avancement en novembre 2026, viaduc sur la lagune Ébrié achevé à l'été 2026, mise en service annoncée pour début 2029, plus de 2 000 emplois ivoiriens.

**Fait**
- **Références** : les 51 articles du corpus ont désormais au moins une source (46 articles en ont reçu, Abidjan en a deux de plus). Les références pointent vers l'ANStat, le Gouvernement, le Conseil constitutionnel, la CEI, la BCEAO, le Conseil du café-cacao, l'UNESCO, le FMI, la CPI, le port d'Abidjan, la BRVM, l'OIPR et Wikipédia pour les entrées encyclopédiques.
- **Appels de note** : les faits sourcés portent des appels `[n]` cliquables dans le texte, qui renvoient à la référence correspondante (mécanisme déjà présent dans le rendu Delta).
- **Dix sujets approfondis** (environ 500 à 700 mots, 6 à 8 sections) : Félix Houphouët-Boigny, indépendance de 1960, Constitution de 2016, crise de 2002-2011, Laurent Gbagbo, Alassane Ouattara, Yamoussoukro, cacao, franc CFA, plus une nouvelle section « Le métro, chantier du siècle » dans Abidjan.
- **Faits mis à jour** : résultats de la présidentielle 2025, quatrième mandat, gouvernement remanié début 2026, prix du cacao 2026-2027, avancement du métro, croissance et inflation 2025-2026.

**Vérifié**
- `pest` : **34 tests** verts (226 assertions), dont deux garde-fous : aucun article sous 150 mots ou trois sections, et **chaque article a au moins une référence, chaque appel `[n]` pointant vers une référence existante**. `pint --test` : 80 fichiers conformes ; `phpstan` : aucune erreur.
- Contenu reseedé en production, puis contrôle via l'API.

**Limites**
- Les données de population par ville restent celles du RGPH 2021 : aucune estimation communale récente et fiable n'a été trouvée pour Abidjan, Bouaké ou Korhogo.
- Quelques sources (Wikipédia) servent d'entrée encyclopédique et non de source primaire ; les chiffres sensibles renvoient aux institutions.
- Les articles approfondis restent des synthèses de 500 à 700 mots, pas des dossiers de plusieurs milliers de mots.

---

## Séance 25 — 14 novembre 2026 · La bibliothèque des sources

**Demande**
- Une page qui liste toutes les sources de la plateforme, classées par institution.

**Fait**
- **API** : `GET /api/v1/sources` (`SourcesController`) agrège les références des articles publiés, les dédoublonne par éditeur + titre + adresse, puis les regroupe par institution. Réponse : `data` (nom, nombre de références, références avec année, URL et articles citants) et `meta` (institutions, références, mentions, articles). En-tête `Cache-Control: public, max-age=1800`.
- **Page Flutter** : `/sources` (« D'où viennent nos informations »), route ajoutée à `router.dart`, entrée de menu **« Charte et sources »** de la colonne de navigation (elle ouvrait jusqu'ici un message « à venir »). Compteurs en tête (institutions, références distinctes, articles sourcés), une carte par institution, chaque référence affichant son année, un bouton d'ouverture externe et la liste cliquable des articles qui la citent.
- **Modèles** : `app/lib/src/models/sources.dart` (`SourceLibrary`, `SourceInstitution`, `SourceReference`, `SourceArticleLink`), méthode `fetchSources()` sur `IvoirepediaApi` et `HttpIvoirepediaApi`.

**Vérifié**
- Backend : `pest` **35 tests** verts (1 126 assertions), dont `tests/Feature/SourcesTest.php` (structure, tri par nombre de références, présence de l'ANStat, chaque référence rattachée à un article publié) ; `pint --test` 82 fichiers conformes ; `phpstan` aucune erreur.
- App : `flutter analyze` propre, `flutter test` **25 tests** verts, dont `test/sources_page_test.dart` (affichage par institution, compteurs, navigation vers un article depuis une référence).
- En production : l'API et la page sont servies sur le domaine.

**Reste**
- La page n'affiche pas encore de filtre par domaine ni de recherche dans les sources ; le volume actuel (une centaine de références) ne le justifie pas.

---

## Séance 26 — 14 novembre 2026 · Un appel de note ouvre sa fiche source

**Demande**
- Faire pointer chaque appel `[n]` d'un article vers la fiche correspondante de la bibliothèque des sources.

**Fait**
- **Identifiant partagé** : `ArticleReference::sourceKey()` calcule une empreinte stable (sha1 tronqué de `éditeur|titre|url`), utilisée à la fois par `ArticleResource` (`source_id` sur chaque référence d'article) et par `SourcesController` (`id` sur chaque fiche). C'est ce qui relie un `[n]` à la bonne fiche sans table intermédiaire.
- **Article** : `_openReference(n)` remplace `_scrollToReference` comme gestionnaire des appels de note. Il cherche la référence de position `n`, puis navigue vers `/sources?ref=<source_id>` ; si le routeur n'est pas disponible (page isolée en test), il retombe sur le défilement local. La liste « Notes et références » reçoit en plus un bouton **« Voir la fiche dans la bibliothèque des sources »** par référence identifiée.
- **Page des sources** : `SourcesPage(highlight: …)` reçoit le paramètre `ref`, met en évidence la fiche (filet orange, fond ambré, mention « Référence ouverte depuis un article ») et y fait défiler automatiquement la page.
- **Modèles** : `ArticleReference.sourceId` et `SourceReference.id`.

**Vérifié**
- Backend : `pest` **36 tests** verts (1 135 assertions), dont un test d'alignement qui vérifie que chaque `source_id` d'un article existe bien dans `/api/v1/sources` ; `pint --test` 82 fichiers conformes ; `phpstan` aucune erreur.
- App : `flutter analyze` propre, `flutter test` **27 tests** verts, dont la navigation effective d'un appel de note vers `/sources?ref=…` et la mise en évidence de la fiche demandée.

**Limite**
- Le clic sur le numéro en exposant n'est pas couvert par un test de widget (le `TextSpan` n'expose pas de cible facile à `find.text`) : le test passe par le bouton équivalent de la liste des références, qui appelle le même gestionnaire.

---

## Séance 27 — 15 novembre 2026 · Refonte visuelle : un fond de tissu ivoirien

**Demande**
- Garder la colonne de navigation de gauche telle quelle, et refaire le reste : plus ivoirien, plus ludique pour apprendre, professionnel, avec un vrai fond et des motifs.

**Fait**
- **Fond du site** (`ui/widgets/backdrop.dart`, exporté par `ivorian_patterns.dart`) : composition statique en cinq couches — lavis orange/vert aux deux angles, treillis de losanges baoulés, quatre rosaces de pagne aux angles, lisière tissée sur les deux bords (blocs orange, or, vert), frise Korhogo en bas (triangles et cercles gravés), grain de papier. Opacités entre 2 % et 7 % : les motifs se lisent sans concurrencer le texte, et rien n'est chargé comme image. Le fond animé précédent est remplacé par ce fond fixe, plus calme et moins coûteux à peindre.
- **Ouverture de l'accueil** : panneau de tissu peint à droite (losanges et rosace, légende « Motifs baoulé et Korhogo »), badge « Encyclopédie libre · Côte d'Ivoire », titre et promesse à gauche, filet tricolore conservé en haut, ombre douce et coins arrondis à 16 px. Le panneau disparaît sous 820 px de large.
- **Nouvelle section « Trois parcours pour apprendre »** : les trois domaines les plus fournis, numérotés 01 à 03, avec leur symbole, le nombre d'articles à lire et un appel « Commencer » vers la catégorie. C'est l'entrée guidée pour un lecteur qui ne sait pas par où commencer.
- **Domaines en tuiles** : chaque domaine a désormais un symbole et une couleur (livre pour l'histoire, globe pour la géographie, note pour la culture, balance pour les institutions, etc.), avec son nombre d'articles et un chevron ; survol qui souligne la tuile.
- **Titres de section** : le simple filet est remplacé par un motif à trois losanges suivi du filet, pour un rythme visuel constant.
- **Inchangé** : la colonne de gauche (La maison, Histoire, Mon espace, Écrire ensemble), la colonne de droite de l'accueil (Reprendre la lecture, Article au hasard, Contribuer), le sommaire d'article à droite et la barre de lecture.

**Vérifié**
- `flutter analyze` propre ; `flutter test` **27 tests** verts, dont un nouveau contrôle de la section « Trois parcours pour apprendre » sur l'accueil, et le test « grand écran » qui couvre le panneau de tissu.
- Build web de production reconstruit et redéployé ; la page d'accueil répond 200 avec le nouveau bundle.

**Limites**
- Le rendu n'a pas été relu à l'œil dans un navigateur : les tests et l'analyse garantissent la structure, pas l'équilibre visuel. Ajustements probables après une première visite (taille du panneau, densité du fond).
- Les polices restent Inter : pas de fonte d'affichage ajoutée, pour ne pas alourdir le chargement.

---

## Séance 28 — 16 novembre 2026 · La direction visuelle gagne les pages intérieures

**Demande**
- Étendre la direction de l'accueil (motifs, tuiles, filets à losanges, cartes arrondies) aux pages encore sobres : catégories, statistiques, lieux, frise, recherche. Colonne de gauche et sommaire d'article inchangés.

**Fait**
- **Composants partagés** (`ui/widgets/page_parts.dart`) : `PageHeader` (pastille de domaine, titre, chapeau, filet à losanges), `DiamondRule` (trois losanges + trait), `SectionHeading` (titre + compteur + filet), `MotifCard` (papier, filet, ombre douce, liseré d'accent optionnel). Les cinq pages les utilisent, ce qui garantit un rythme identique sans dupliquer les styles.
- **Catégories** : en-tête `PageHeader` « DOMAINE », description en tête de page, chaque article devient une carte arrondie, les sous-titres passent au filet à losanges.
- **Lieux** : en-tête unifié, chaque district/région/ville devient une ligne-carte (bordure au survol), sections coiffées du filet à losanges avec leur compteur.
- **Frise** : en-tête unifié, en-têtes d'époques avec losanges, chaque jalon devient une carte arrondie qui s'éclaire au survol.
- **Recherche** : en-tête unifié avec un chapeau expliquant la frappe instantanée, résultats en cartes arrondies au lieu de simples filets.
- **Statistiques** : en-tête `PageHeader` en orange, en-têtes de thème avec losanges verts.
- **Inchangé** : colonne de navigation de gauche, sommaire d'article à droite, barre de lecture, colonne de droite de l'accueil.

**Vérifié**
- `flutter analyze` propre ; `flutter test` **27 tests** verts (catégories, frise, lieux, recherche et statistiques sont déjà couvertes par la suite existante).
- Build web de production reconstruit et redéployé.

**Limites**
- Toujours pas de relecture visuelle dans un navigateur : la structure et les tests passent, l'équilibre des espacements reste à valider à l'œil.
- Les cartes de statistiques gardent leur rayon de 10 px (les indicateurs sont denses) ; seuls les en-têtes et les listes adoptent 12–14 px.

---

## Séance 29 — 16 novembre 2026 · Des images sourcées plutôt que des motifs inventés

**Demande**
- Retirer les motifs « baoulé » et « Korhogo » dessinés en code.
- Proposer un article au hasard pris dans toute la base, depuis l'accueil.
- Remplacer les motifs fictifs par des images et des motifs réels, sourcés, et donner une illustration à chaque article.

**Fait**
- **Motifs retirés** : `ui/widgets/backdrop.dart` ne garde que le lavis orange/vert et un grain de papier ; le treillis de losanges, les rosaces, la lisière tissée et la frise Korhogo ont disparu. Sur l'accueil, le panneau « motifs baoulé et Korhogo » est remplacé par la photographie de l'article de la une, avec son titre et son crédit.
- **Article au hasard** : route `GET /api/v1/articles/random` (tirage `inRandomOrder()` sur les seuls articles publiés, 404 si la base est vide), `fetchRandomArticle()` côté Flutter, et le bouton « Tirer un article » de la colonne de droite l'utilise désormais. Le tirage porte sur les 51 articles, plus seulement sur la page déjà chargée.
- **Illustrations** : `database/data/article-images.php` réunit **51 images**, une par article, toutes issues de Wikimedia Commons — image de tête de l'article Wikipédia francophone quand elle existe, sinon une photographie du sujet. Chaque entrée porte l'URL, le texte alternatif, l'auteur, la licence et la page de description.
- **Base et API** : migration `add_cover_image_credit_to_articles` (`cover_image_credit`, `cover_image_license`, `cover_image_source_url`), modèle et `ArticleSummaryResource` complétés ; commande `articles:attach-images` (idempotente, `--dry-run`) qui applique le jeu de données.
- **Application** : `ui/widgets/article_image.dart` avec `ArticleFigure` (grande image + mention « Photo : auteur — licence » cliquable vers Commons) et `ArticleThumb` (vignette de liste). La une, la page article, la catégorie et la recherche affichent les images.
- **Outils** : `database/data/fetch-article-images.py` retrouve les images de tête et leurs licences ; `build-article-images.py` régénère le fichier de données à partir de la sélection relue à la main.

**Vérifié**
- `flutter analyze` propre ; `flutter test` **28 tests** verts (dont « Tirer un article » ouvre bien l'article tiré par le serveur).
- `pint --test` : 86 fichiers conformes ; `phpstan` : aucune erreur ; `pest` : **41 tests**, 1 157 assertions (dont 5 pour les illustrations et le hasard).
- `php artisan articles:attach-images` : 51 articles illustrés en local ; les URL pointent vers `thumb.wikimedia.org` et répondent en 200.

**Limites**
- Les illustrations sont des photographies de Commons, pas des images produites pour IVOIREPEDIA : la mention de licence est obligatoire et affichée, mais certaines montrent un lieu voisin ou un objet de musée plutôt qu'une scène ivoirienne précise (l'anacardier vient d'Inde, le cacaoyer d'une ferme ghanéenne).
- Quatre fiches Commons ont un champ auteur illisible ou dupliqué ; la mention affichée est corrigée à la main dans `build-article-images.py` (`CREDIT_FIX`).
- Pas de vérification visuelle en navigateur après le passage aux photographies.

---

## Séance 30 — 17 novembre 2026 · Le pagne documenté revient, et une couverture au lancement

**Demande**
- Remettre en arrière-plan les motifs culturels ivoiriens, mais réels et documentés, de façon dynamique et interactive (les motifs « baoulé » et « Korhogo » dessinés en code avaient été retirés à la séance 29 parce qu'ils étaient inventés).
- Remplacer l'écran de chargement du site par une couverture présentant IVOIREPEDIA en image, affichée quelques secondes pendant le chargement.

**Fait**
- **Le décor est un pagne, pas un ornement** (`ui/widgets/backdrop.dart`) : la structure vient du **pagne tissé**, en bandes de 10 à 15 cm cousues bord à bord avec leur couture (UNESCO, savoir-faire du tissage du pagne, ICH 01949). Les motifs posés dessus sont ceux du répertoire documenté : **losanges** du pagne baoulé à centre en réserve d'indigo (dossier IG « pagne baoulé », OAPI 2023), **frises à degrés** et **zigzag du léopard** hérités du Fila, **arêtes de poisson** du textile de Korhogo. Chaque maille reçoit l'un des quatre motifs de façon stable, sur une trame de fils horizontaux.
- **Dynamique et interactif** : la bande dérive en 80 s, la nappe glisse en parallaxe de quelques pixels à l'opposé du pointeur, et les mailles proches du pointeur s'éclaircissent de 5,5 % à 13 % d'opacité. La position du pointeur passe par une `ValueNotifier` : seul le peintre se reconstruit, jamais le site. Le mouvement s'arrête si la plateforme demande de réduire les animations.
- **Couverture de lancement** : l'image fournie (1376 × 768) est enregistrée en `app/assets/images/couverture.webp`, déclarée dans `pubspec.yaml`, et copiée en `app/web/cover.webp` pour être disponible **avant** le moteur Flutter. `web/index.html` remplace le spinner par cette image plein cadre (`object-fit: cover`), avec le filet orange → or → vert qui balaie le bas et le message d'attente qui n'apparaît qu'au-delà de 12 s. Côté application, `ui/cover.dart` (`LaunchCover`, `CoverSheet`) reprend la même image pendant 2,2 s puis l'efface en fondu de 520 ms ; la couche est ignorée des gestes dès qu'elle s'efface.
- **Point d'entrée** : la couverture s'installe dans `main.dart`, autour de `IvoirepediaApp` : elle s'affiche à chaque lancement du site, sans route ni réglage à activer, et ne s'intercale pas dans la navigation.

**Vérifié**
- `flutter analyze` propre ; `flutter test` **31 tests** verts, dont trois nouveaux : « le pagne est peint derrière le contenu », « les motifs réagissent au pointeur » (position, éclaircissement de la maille, retour au repos) et « la couverture s'affiche au lancement puis se retire ».
- Le test de la couverture a révélé un défaut réel : un `Stack` posé au-dessus du `Directionality` de `MaterialApp` lève une assertion. Les deux piles de `cover.dart` portent désormais un alignement explicite.
- Back-end non modifié : `composer test`, `pint` et `phpstan` ne sont pas relancés pour cette séance.

**Limites**
- Aucune relecture visuelle : le fond animé, l'éclaircissement sous le pointeur et le fondu de la couverture n'ont pas été vus dans un navigateur.
- Le coût de repeint du fond n'a pas été mesuré sur un grand écran ; si le rendu saccade, la piste est de réduire le nombre de mailles ou de figer la dérive.
- L'image de couverture est une illustration fournie par le propriétaire du site ; elle contient déjà son propre bandeau de motifs, qui se superpose visuellement au fond de la page d'accueil.

---

## Séance 31 — 17 novembre 2026 · Couverture adaptable et accueil plus vivant, publiés à la racine

**Demande**
- Mettre les changements en production sur `ivoirepedia.alwaysdata.net`.
- Vérifier la couverture sur téléphone : elle ne doit pas rogner le titre ; adapter l'affichage aux écrans étroits.
- Travailler directement en production plutôt que sur un serveur local, et rendre le site plus professionnel, interactif, complet, innovant et ludique.

**Fait**
- **Couverture adaptable** : en portrait (`largeur / hauteur < 0,8`), l'image passe en `BoxFit.contain` — le grand titre de l'illustration reste entier — et la même image, atténuée à 22 %, remplit l'écran derrière elle, ce qui évite de grandes bandes vides. En paysage, elle garde `BoxFit.cover`. La même règle est appliquée à l'écran de chargement HTML via `@media (max-aspect-ratio: 4/5)` (fond `cover.webp` sous une voile ivoire, image en `contain`).
- **Accueil plus vivant** (modifications déjà présentes dans l'arbre de travail, vérifiées et conservées) : l'illustration de la une devient cliquable, s'agrandit doucement au survol et porte un badge « À LA UNE » ; le tirage au hasard devient une carte verte pleine ; les cartes de l'accueil (portes d'entrée, parcours, cartes partagées) se soulèvent et prennent une ombre au survol ; le panneau photo s'élargit à 336 px et le bouton « Lire l'article » remplace le simple lien.
- **Publication directe en production** : build `flutter build web --release --base-href=/ --dart-define=API_BASE_URL=/api/v1`, puis envoi des seuls fichiers du build dans `~/ivoirepedia/backend/public` — `index.php`, `.htaccess`, `storage/` et les autres fichiers Laravel sont préservés. Aucun serveur `127.0.0.1` n'a été démarré pour cette livraison.

**Vérifié**
- `flutter analyze` : aucune remarque ; **33 tests Flutter** verts, dont deux nouveaux sur la couverture (« la couverture entière tient dans l'écran portrait » en 390 × 844, « la couverture recadre en format paysage » en 1280 × 800).
- Correctif trouvé par l'analyse : `offset: const Offset(0, _hover ? 10 : 6)` dans `_PathCard` — une constante ne peut pas dépendre de `_hover` ; `const` retiré.
- Build release terminé sans erreur (bundle `main.dart.js` de 3,7 Mo, CanvasKit 37 Mo).
- En ligne : `/` sert le nouveau `index.html`, `/cover.webp` et l'asset Flutter `assets/assets/images/couverture.webp` répondent `200` en `image/webp` (142 090 o), `/main.dart.js` `200` (3,87 Mo), `/api/v1/health` et `/api/v1/articles?limit=1` `200`, `/statistiques` et `/articles/abidjan` `200`. `index.php` et `.htaccess` de Laravel intacts après extraction.
- **Portrait vérifié en production** (390 × 844, onglet incognito) : `matchMedia('(max-aspect-ratio: 4/5)')` vrai, `object-fit: contain` appliqué, image rendue sur 390 × 218 px centrée, fond `cover.webp` présent sous la voile — le titre « IVOIREPEDIA : L'Encyclopédie de la Côte d'Ivoire » est entièrement lisible. Capture `docs/captures/couverture-telephone-portrait.png` ; aucune erreur console dans l'onglet de contrôle.

**Limites**
- La vérification téléphone est faite au navigateur en 390 × 844 (règle CSS et capture), pas sur un appareil physique : le rendu exact sur un iPhone/Android reste à confirmer sur un vrai écran.
- L'image de couverture est en 1376 × 768 : en portrait elle occupe une bande horizontale centrée, avec de larges marges ivoire. Pour un plein écran vertical, il faudrait une variante portrait de l'illustration.
- Le back-end n'est pas modifié : `pest`, `pint` et `phpstan` ne sont pas relancés.

---

## Séance 32 — 17 novembre 2026 · Un accueil plus vivant, lisible sur téléphone, publié en production

**Demande**
- Rendre le site plus professionnel, plus interactif, plus attractif, plus ludique et plus responsif, en travaillant directement sur `ivoirepedia.alwaysdata.net`.

**Fait**
- **Échelle mobile de l'ouverture** : sous 640 px, le titre passe de 40 à 32 px, le chapeau de 15,5 à 14,5 px et les marges de 26 à 18 px. Le premier écran d'un téléphone tient désormais le titre, le chapeau et les trois portes d'entrée sans allonger la page inutilement.
- **En-tête robuste** : sous 620 px, la devise disparaît de la marque et celle-ci occupe la place restante dans un `FittedBox` : elle se réduit si le texte est agrandi (réglage « Confort de lecture ») au lieu de pousser les commandes hors de l'écran. `IvoireLogo` reçoit un paramètre `tagline`.
- **Cartes de chiffres** : deux colonnes dès 470 px (au lieu de 560) et soulèvement bordé de la couleur du thème au survol, comme les autres cartes de la maison.
- **« Le défi du jour »** (`_DailyChallenge`, accueil) : trois années proposées pour situer un jalon de la frise, correction immédiate (« Bien vu » / « Pas cette fois »), puis lien « Lire le récit ». **Aucun fait n'est inventé** : le jalon et les années leurres viennent de `/api/v1/timeline`, déjà sourcé. Le jalon est choisi ailleurs que celui d'« Aujourd'hui dans l'histoire », dont la réponse est affichée juste au-dessus. Le badge est un `?` typographique, sans dépendance à la police d'icônes.
- **Liens de section** : sous 440 px, le lien annexe (« Voir la frise complète ») passe sous le titre au lieu de comprimer celui-ci sur deux lignes.
- **Navigation** : l'entrée « Article au hasard » de la colonne de gauche tire maintenant un article du serveur (elle annonçait auparavant une fonction à venir).
- **Pages intérieures** : `PageHeader` réduit son titre à 26 px sous 520 px.
- **Cache des polices d'icônes** (`backend/public/.htaccess`) : Flutter réduit `MaterialIcons-Regular.otf` aux seules icônes utilisées à chaque build. La règle `max-age=86400` servait donc pendant un jour une police sans les glyphes ajoutés depuis la visite précédente — une icône nouvelle s'affichait vide. Les deux polices d'icônes (13 ko) passent en `no-cache` ; les polices de texte et CanvasKit gardent leur cache d'un jour.

**Vérifié**
- `flutter analyze` : aucune remarque ; **36 tests Flutter** verts (+3) : le défi corrige la réponse choisie, l'entrée « Article au hasard » ouvre bien un article, et l'accueil se rend en 390 × 844 sans débordement.
- Le test téléphone a trouvé **deux débordements réels** : l'en-tête (marque large) et la pastille de l'ouverture. Corrigés par la marque repliable, la devise masquée et la pastille en `Flexible`. Le troisième passage ne signale plus aucune exception.
- Build release (bundle `main.dart.js` 3 879 441 o) envoyé dans `~/ivoirepedia/backend/public` ; `index.php`, `.htaccess` et `storage/` préservés.
- En ligne : `/` `200`, `/main.dart.js` `200` (taille identique au build local), `/api/v1/health` `200`, `/statistiques` `200` ; la police d'icônes est servie en `cache-control: no-cache` (12 168 o, nouveaux glyphes).
- **Rendu contrôlé en production** en 390 × 844 : titre sur deux lignes, en-tête sans débordement, badge « ? » visible, défi du jour avec ses trois années, liens de section sous le titre, icône « article au hasard » rendue. Captures : `docs/captures/accueil-telephone-2026-11-17.png`, `defi-du-jour.png`, `accueil-hasard-telephone.png`, `accueil-tablette.png`. Aucune erreur console (seul l'avertissement Noto préexistant sur les caractères absents d'Inter).

**Limites**
- Le clic sur une année du défi est couvert par le test widget, pas par un vrai clic dans le navigateur : les événements de pointeur synthétiques ne sont pas reçus par le moteur Flutter. Le rendu de la correction n'a donc pas été vu en production.
- La capture du panneau de prévisualisation est plus étroite que la fenêtre demandée en 1280 px : le rendu grand écran n'a été vérifié qu'en partie, et par les tests (800 et 1280 px).
- `docs/captures/couverture-telephone.png` (séance 31) reste non versionné.

---

## Séance 33 — 17 novembre 2026 · Nouvelle marque et accueil de type portail

**Demande**
- Remplacer l'icône de l'onglet par l'emblème fourni (le « I » à tête d'éléphant) et le titre de l'onglet par « Ivoirepedia, l'encyclopédie libre de la Côte d'Ivoire », désormais devise du site.
- Remplacer le logo principal (médaillon drapeau + « IVOIREPEDIA ») par les visuels fournis, et intégrer chaque image selon sa nature et sa fonction.
- Faire vivre les motifs culturels et les images de la maison de façon professionnelle et interactive, fond compris.
- Retirer les tics visuels de « site généré » (pastille « ENCYCLOPÉDIE LIBRE · CÔTE D'IVOIRE », cartes à liseré, chiffres 01-02-03) et rapprocher l'accueil d'un portail encyclopédique, sans copier Wikipédia.

**Fait — marque**
- Trois fichiers dérivés des visuels du propriétaire, détourés sur fond transparent : `marque.webp` (emblème), `logo-mot.webp` (mot-symbole) et `logo.webp` (signature complète emblème + nom + devise). Les anciens `assets/images/couverture.webp` et `web/cover.webp` — une illustration qui portait l'ancienne marque et un sous-titre anglais — sont retirés.
- `brand.dart` : `kTagline` fixe la devise ; `IvoireMark` et `IvoireLogo` affichent les images. L'en-tête combine emblème, mot-symbole et devise ; sous 620 px la devise se replie et seule la marque reste.
- `web/index.html` : titre d'onglet exact, description française, `theme-color` ivoire, favicon 64 px, apple-touch-icon 180 px et écran de chargement avec la signature sur une trame de pagne en CSS.
- `web/manifest.json` : nom, description, couleurs et icônes PWA mis à jour ; `favicon.ico` (16/32/48) et `favicon.png` régénérés depuis l'emblème, y compris dans `backend/public/` où l'ancien favicon Flutter restait servi.
- Devise reprise dans le titre `MaterialApp`, le pied de page, la couverture, l'export PDF et la mention de bas d'article.
- `PageKicker` : les pastilles arrondies deviennent un court filet et un libellé, sur toutes les pages intérieures.

**Fait — accueil**
- `_Masthead` : signature complète, phrase de présentation, compteurs, puis barre « Portails » listant les huit domaines avec leur nombre d'articles.
- Titres de section : libellé et filet fin, sans losanges ni cartes à liseré. L'article du jour passe en pleine largeur (photo sourcée avec son crédit, titre, chapô), « Aujourd'hui dans l'histoire » devient une liste, le défi garde sa correction immédiate mais sur papier blanc, la frise reste une bande à faire défiler.
- Colonne de droite : les chiffres forment une liste de définitions, l'article au hasard un encart discret, puis la reprise de lecture et « Contribuer ».
- « Portails thématiques » remplace les trois cartes de parcours et les tuiles colorées ; la page reste un portail, pas une page de vente.
- Fond : l'emblème veille en bas à droite (5 %, dérive très lente) derrière le pagne documenté et réactif au pointeur ; il reste décoratif et ne passe jamais devant le texte.
- Couverture : la signature se pose sur le pagne peint, à la place de l'ancienne illustration.

**Vérifié**
- `flutter analyze` : aucune remarque ; `flutter test` : **37 tests** verts (+1 : titre de l'application = devise, présence de l'emblème, du mot-symbole et de l'emblème de fond) ; les tests de couverture sont adaptés à la nouvelle composition.
- Build release (`main.dart.js` 3 863 580 o) envoyé dans `~/ivoirepedia/backend/public` ; `index.php`, `.htaccess` et `storage/` préservés.
- En ligne : `/` 200, `/favicon.png` 200 (7 881 o), `/logo.png` 200, `/manifest.json` 200, les trois images `assets/assets/images/*.webp` 200, `/main.dart.js` 200, `/api/v1/health` 200.
- Titre de l'onglet vérifié dans le navigateur : « Ivoirepedia, l'encyclopédie libre de la Côte d'Ivoire ».
- Rendu contrôlé en 1280×900 : en-tête avec emblème, mot-symbole et devise ; manchette centrée ; barre des portails ; article du jour avec photo et crédit ; sections à filet ; chiffres et article au hasard dans la colonne de droite. En 390×844 : marque réduite sans débordement, portails sur trois lignes, article du jour lisible. Captures `docs/captures/accueil-marque-2026-11-17.png` et `accueil-marque-telephone-2026-11-17.png`.

**Limites**
- La couverture n'a pas été photographiée en production : elle dure 2,2 s et la fenêtre de prévisualisation n'était pas dessinée au bon moment. Son rendu est couvert par les tests de widgets, pas par une capture.
- Les survols et le clic du défi sont couverts par les tests de widgets, pas par une interaction réelle dans le navigateur.
- Les logos sont des images bitmap issues des visuels fournis (1600 px de large) : ils restent nets aux tailles du site, mais une version vectorielle serait préférable pour l'impression et les très grands écrans.
- Aucun appareil physique n'a été testé.

## Séance 34 — 18 novembre 2026 · Chargement allégé, frise sur un axe et marque nette la nuit

**Demande**
- Le site mettait trop de temps à s'afficher : revoir le chargement.
- Supprimer la section « défi du jour ».
- Revoir l'affichage de la frise sur la page principale.
- Corriger le halo clair de la marque en thème nuit et sépia.
- Vérifier en production la couverture de lancement sur téléphone et grand écran : entière et nette.

**Fait — chargement**
- Cause principale trouvée en production : `canvaskit.wasm` (7,28 Mo) était servi **sans compression**, Apache ne compressant pas `application/wasm` par défaut. `.htaccess` compresse désormais explicitement wasm, javascript, json, css, html et svg. Mesures : wasm 2 923 814 o en 1,9 s (contre 7 284 602 o en 66 s), `main.dart.js` 860 029 o en 1,3 s.
- Le paquet `pdf` passe en **import différé** : ses 969 ko ne sont plus chargés au démarrage. `main.dart.js` descend de 3 863 580 à 2 900 442 o ; le bouton « Télécharger en PDF » charge le module à la demande. Les fonctions de texte (presse-papiers, sections) vivent maintenant dans `article_text.dart`, hors du module différé.
- Accueil : les quatre appels API (domaines, articles, frise, chiffres) partent ensemble au lieu de s'enchaîner.
- Écran de chargement HTML : signature en WebP (26 350 o au lieu de 263 624 o) avec repli PNG, disparition en 260 ms, surveillance toutes les 100 ms.
- Couverture Flutter : 800 ms au lieu de 2,2 s, et le décompte part de la **première image peinte** (avant, sur connexion lente, il expirait pendant le chargement du moteur et la couverture n'était jamais vue). Images en `FilterQuality.high`.
- Fond animé : la dérive du pagne n'est repeinte que 12 fois par seconde (1,3 px/s, mouvement inchangé à l'œil) au lieu de 60.

**Fait — accueil**
- « Le défi du jour » et ses composants sont supprimés, avec son test.
- Frise : plus de cartes à liseré. Chaque jalon est posé sur un axe continu — année, époque, point, filet — et le titre se lit dessous ; la bande se fait défiler, la hauteur suit l'agrandissement du texte. Un test vérifie qu'un jalon ouvre son récit.

**Fait — marque**
- Les trois visuels sont retaillés depuis les originaux : le halo crème (la planche du sticker) est retiré par remplissage depuis les bords, les trous de lettres nettoyés, les bords désempourprés. L'emblème garde ses ivoires intérieurs ; le mot-symbole est livré sans la devise gravée, désormais écrite en texte et donc lisible dans les trois thèmes.
- En nuit et sépia, la marque se pose sur le papier sans auréole claire. Captures `docs/captures/accueil-nuit-prod-2026-11-18.png` et `accueil-sepia-prod-2026-11-18.png`.

**Vérifié**
- `flutter analyze` : aucune remarque ; `flutter test` : **37 tests** verts (défi retiré, frise testée, couverture adaptée).
- Build release (`main.dart.js` 2 900 442 o + `main.dart.js_1.part.js` 969 149 o) déployé dans `~/ivoirepedia/backend/public`.
- En production : `/` 200 compressé (2 186 o), `/main.dart.js` 860 029 o compressés en 1,3 s, `/canvaskit/canvaskit.wasm` 2 923 814 o compressés en 1,9 s, `/logo.webp` 26 350 o.
- Écran de lancement contrôlé en production en 390×844 et en grand écran : signature entière, centrée, nette (captures `couverture-telephone-2026-11-18.png` et `couverture-large-2026-11-18.png`).
- Thèmes nuit et sépia contrôlés en production : en-tête et feuille suivent le thème, la marque n'a plus de halo crème.
- Frise contrôlée en production : années 1701, 1730, 1843, 1893 sur l'axe, titres lisibles ; « Le défi du jour » absent (capture `accueil-frise-prod-2026-11-18.png`).

**Limites**
- La couche Flutter de la couverture (800 ms) n'a pas pu être photographiée : entre l'écran HTML et la capture, la fenêtre d'automatisation est trop lente. Les captures montrent l'écran de lancement HTML, qui porte la même signature ; la couverture Flutter est couverte par les tests de widgets (390×844 et 1280×800, `BoxFit.contain`, hauteur ≤ 240 px).
- En thème nuit, la devise gravée dans l'image de signature reste peu contrastée ; dans la manchette elle demeure lisible et l'en-tête affiche la devise en texte du thème. Une variante « nuit » de la signature serait la prochaine amélioration.
- Les logos restent bitmap ; aucun appareil physique n'a été testé.

---

## Séance 35 — 18 novembre 2026 · Nouvelle marque servie, onglet fiable, comptes de lecteurs

**Demande**
- Remplacer les visuels de la marque par les trois nouvelles images fournies.
- L'icône de l'onglet ne s'affiche pas toujours selon le navigateur : corriger.
- Remettre en place « Créer un compte » et « Se connecter ».
- Réfléchir à la mise en place du tableau de bord d'administration.

**Fait — marque**
- `tools/build_brand_assets.py` régénère les trois dérivés depuis les originaux : détourage par diffusion depuis les bords (seuil 22 pour le fond, 6 + test de couronne pour les creux enfermés), ce qui conserve l'ivoire de l'éléphant et les pages du livre. L'ombre portée est ôtée en coupant sous la dernière ligne colorée, puis en effaçant les gris neutres : plus aucun halo clair en thème nuit ou sépia.
- Assets : `marque.webp` (893 × 880, 130 ko), `logo-mot.webp` (1 230 × 150), `logo.webp` (1 200 × 282) pour l'application, et les mêmes en `web/` pour l'écran de lancement.
- Couverture : la signature est contenue par la largeur (`min(maxWidth − 56, 760)` × `min(maxHeight × 0,34, 240)`) et posée en `BoxFit.contain` : elle ne déborde plus des écrans étroits.

**Fait — onglet**
- `favicon.ico` porte quatre tailles (16/32/48/64) ; `favicon.png` (32 px), `icons/Icon-32|64|180|192|512.png` et deux variantes *maskable* complètent le jeu. Fond papier opaque et coins arrondis : l'emblème se détache aussi sur la barre d'onglets sombre.
- **Deux causes réelles du défaut signalé** : la balise `apple-touch-icon` et le lien `manifest.json` étaient **relatifs** — depuis une adresse profonde (`/articles/…`), ils pointaient vers `/articles/icons/…` et vers `/manifest.json` absent ; ils sont désormais absolus. Et l'ancien favicon restait en cache : les liens portent `?v=2`, y compris l'ICO.
- `backend/public/.htaccess` applique le cache d'un jour aux `.ico`, comme aux PNG et WebP.

**Fait — comptes de lecteurs**
- API : table `api_tokens` (empreinte SHA-256, 60 jours), middleware `AuthenticateApiToken` (en-tête `Bearer`, 401 `UNAUTHENTICATED`, 403 `ACCOUNT_SUSPENDED`), routes `POST /auth/register`, `POST /auth/login`, `GET /auth/me`, `POST /auth/logout`. Inscription limitée à 5 essais par minute, connexion à 10 ; le rôle créé est toujours `READER`.
- Application : `AuthStore` + `AuthScope`, jeton conservé dans le stockage du navigateur et vérifié au démarrage (une session expirée retombe sur la lecture en visiteur) ; écran `AuthPage` commun à `/connexion` et `/inscription` ; bandeau avec « Se connecter » / « Créer un compte » au large, icône de compte et feuille de déconnexion en dessous de 1 120 px ; entrées correspondantes dans le tiroir.
- Quatre tests de parcours avec un serveur d'authentification en mémoire : connexion, création de compte, mot de passe refusé, déconnexion.

**Fait — en-tête (régression trouvée par les tests)**
- L'ajout des liens de compte faisait déborder la rangée d'en-tête de 40 px vers 800 px de large. Sous 1 000 px, le tiroir porte déjà « Confort de lecture » et « Ma bibliothèque » : l'en-tête les lui laisse et garde la recherche et le compte.

**Réflexion — tableau de bord**
- `docs/DASHBOARD_ADMIN.md` : périmètre (écrire et publier, administrer, voir l'état du contenu), choix d'un panneau serveur sur `/admin` plutôt que des écrans Flutter, matrice des rôles READER → ADMIN, formulaires (essentiel, corps Delta, infobox, sources, couverture, médias), versions, journal éditorial, tableau de bord qualité, authentification par session séparée des jetons d'API, découpage en cinq phases (20 à 26 jours) et questions ouvertes. **Aucune ligne de code : c'est une note de cadrage.**

**Vérifié**
- `flutter analyze` : aucune remarque. `flutter test` : **41 tests** verts (+4).
- Backend : `php artisan test` **47 tests, 1 203 assertions** ; `pint --test` propre ; `phpstan` sans erreur (deux corrections : import inutilisé et `@property-read User|null` sur `ApiToken`, qui rendait le test de nullité inutile aux yeux de l'analyseur).
- Les tests ont aussi attrapé trois défauts réels de la séance : le débordement d'en-tête, deux libellés ambigus (« Se connecter », « Se déconnecter » existent aussi dans le tiroir) et l'absence d'`AuthScope` dans les tests qui montent une page seule.
- Build release (`main.dart.js` 3 001 722 o, `main.dart.js_1.part.js` 969 149 o ; compilation 248 s). L'envoi s'est fait par `tar` sur SSH — `rsync` n'existe pas sur le poste — en laissant CanvasKit en place (37 Mo inchangés) et sans toucher à `index.php`, `.htaccess` ni `storage/`.
- Serveur passé à `19e10f5` (`git pull --ff-only` après `git checkout -- backend/public/.htaccess`) ; migration `2026_11_18_000001_create_api_tokens_table` jouée en 40 ms ; caches de routes et de configuration vidés.
- En production : `/` 200, `/favicon.ico?v=2` 200 en `image/vnd.microsoft.icon` (18 523 o, quatre tailles), `/favicon.png?v=2` 2 888 o, `/icons/Icon-32.png` 2 888 o, `/icons/apple-touch-icon.png?v=2` 47 244 o, `/manifest.json` 200, `/main.dart.js` 3 001 722 o, `/logo.webp` 200, `/assets/assets/images/marque.webp` 200 (130 166 o). Depuis l'adresse profonde `/articles/abidjan`, les six liens d'icônes et de manifeste sont les mêmes, en absolu.
- API en production : `/auth/me` sans jeton → 401 `UNAUTHENTICATED` ; `/auth/login` avec un mauvais mot de passe → 422 `INVALID_CREDENTIALS` ; `/auth/register` vide → 422 avec les messages français champ par champ ; `/health` 200.

**Limites**
- La devise gravée dans l'image de signature reste peu contrastée en thème nuit ; l'en-tête affiche la devise en texte du thème.
- Les logos restent bitmap ; aucun appareil physique n'a été testé, ni les navigateurs de bureau un par un (le jeu d'icônes est vérifié par les fichiers servis, pas par chaque moteur).
- Le tableau de bord n'est pas commencé : la note de cadrage propose un ordre, elle n'engage rien.

---

## Séance 36 — 19 novembre 2026 · Socle du panneau éditorial et mot de passe oublié

**Demande**
- Ouvrir la phase 0 du panneau d'administration décrite dans `docs/DASHBOARD_ADMIN.md` : rôles, policies, machine à états testée.
- Rendre le panneau utilisable au quotidien : connexion, tableau de bord, articles, transitions, comptes.
- Qu'un compte perdu se retrouve sans intervention serveur, depuis l'application comme depuis le panneau.

**Fait — phase 0, le socle invisible**
- `App\Enums\UserRole` (READER, CONTRIBUTOR, EDITOR, ADMIN) et cast `role` sur `User` ; `UserFactory` gagne `contributor()`, `editor()`, `admin()`, `suspended()`.
- `App\Enums\ArticleStatus` complété par `label()` et `tone()` : les huit statuts du workflow ont leur libellé et leur pastille.
- `App\Enums\EditorialActionType` : une valeur par action, avec `forAction()` pour que le journal ne contienne jamais de chaîne libre.
- `App\Services\Workflow` : table des transitions (`submit`, `start_review`, `request_revision`, `approve`, `publish`, `archive`, `restore`, `delete`) avec `authorOnly`, `notAuthor` et `commentRequired`. Les refus lèvent `WorkflowException` (`FORBIDDEN`, `INVALID_TRANSITION`, `COMMENT_REQUIRED`, `INCOMPLETE`, `SOURCES_REQUIRED`, `ALT_REQUIRED`), et `actionsFor()` construit les boutons sans devenir la règle.
- `App\Services\ArticleService` : seule porte d'écriture du statut — transaction, `lockForUpdate`, garde de publication (titre, résumé, au moins une source, texte alternatif de couverture), version de jalon (`submit`, `publish`, jamais une sauvegarde) et ligne `editorial_actions`.
- `ArticlePolicy` / `UserPolicy` : lecture, écriture, transition, suppression, changement de rôle, suspension ; un ADMIN ne peut pas se retirer ses droits.
- Relecture par l'auteur ouverte en phase solo (`ALLOW_SELF_REVIEW`, `backend/config/ivoirepedia.php`), à fermer à l'arrivée du premier éditeur : la règle reste appliquée par le workflow, pas par l'écran.

**Fait — panneau `/admin`**
- Routes serveur (`routes/web.php`) et session par cookie, distincte des jetons de l'API : `guest` pour la connexion, `auth` + `editorial` pour le reste, `redirectGuestsTo(route('admin.login'))`, et `/` renvoie vers `/admin`.
- `EnsureEditorialAccess` ouvre le panneau à CONTRIBUTOR et au-dessus ; un READER est refusé.
- Vues Blade maison, sans Filament : `layout`, `auth.login`, `dashboard`, `articles.index|show|form`, `users.index`. Un CONTRIBUTOR ne voit que ses articles, un EDITOR la file de relecture, la gestion des comptes est réservée à l'ADMIN.
- `ArticleController` (index, create, store, show, edit, update, transition), `UserController` (rôle, suspension avec révocation des jetons, réactivation), `DashboardController` (file de relecture et compteurs).
- `ArticleRequest`, `TransitionRequest`, `LoginRequest` : validation en français, corps Delta saisi en JSON.
- `Article` gagne `versions()`, `actions()` et `plainText()` (aperçu sans publier le JSON).

**Fait — mot de passe oublié**
- API : `POST /api/v1/auth/forgot-password` (5 essais/minute) et `POST /api/v1/auth/reset-password` (10/minute) ; `PasswordResetService` (jeton à usage unique, valable une heure), `ResetPasswordNotification` dont le lien pointe sur `{SITE_URL}/mot-de-passe-oublie?token=…&email=…`. La réponse ne dit jamais si l'adresse existe ; un lien mort lève `ResetLinkException`.
- Application : `AuthApi.requestPasswordReset` / `resetPassword` et `AuthStore` qui relaie le message du serveur ; écran `PasswordResetPage` sur `/mot-de-passe-oublie` — la même adresse porte les deux étapes, puisque c'est exactement ce que le courriel envoie — et lien « Mot de passe oublié ? » sous le champ du mot de passe à la connexion. Le panneau renvoie sur le même écran.
- Le reset n'ouvre pas de session : on revient à `/connexion` avec le nouveau mot de passe.

**Vérifié**
- `flutter analyze` : aucune remarque. `flutter test` : **44 tests** verts (+3 : demande sans révéler le compte, lien reçu → nouveau mot de passe → connexion, lien brûlé → refus → nouvelle demande).
- Backend : `composer test` **93 tests, 1 376 assertions** (+46 tests) ; `pint --test` propre après `composer format` (4 fichiers) ; `phpstan` sans erreur sur 60 fichiers.
- Les tests ont attrapé un vrai défaut dans le parcours écrit cette séance : le faux serveur n'émet un jeton qu'après une demande, donc le test suit maintenant le lien après l'avoir demandé, comme un lecteur.

**Limites**
- Aucune vérification en navigateur : ni `/admin` ni l'écran de réinitialisation n'ont été ouverts à la main, seuls les tests et l'analyse couvrent le code.
- Le courriel part par `MAIL_MAILER=log` tant que la clé SMTP n'est pas fournie : le lien est écrit dans les journaux, pas envoyé.
- Le panneau livre les phases 0 et 1 ; formulaire complet (sources, médias), éditeur visuel et file de relecture riche restent aux phases 2 et 3.

---

## Séance 37 — 19 novembre 2026 · Référentiels, sources multiples et journal

**Demande**
- Continuer le panneau : combler ce qui manquait encore par rapport à `docs/DASHBOARD_ADMIN.md`.

**Fait — référentiels**
- `CategoryController` et `TagController` : listes, création, renommage, suppression ; `CategoryRequest` et `TagRequest` valident nom, description, position et catégorie mère (une catégorie ne peut pas être sa propre mère).
- Le slug découle du nom ; il ne bouge plus dès qu'un article utilise la catégorie, et une catégorie qui porte des articles refuse la suppression — les adresses publiques restent valides.
- Nouvelle permission `manage-references` (Gate : EDITOR et ADMIN) : un contributeur reçoit 403. Deux entrées de navigation, « Catégories » et « Étiquettes ».

**Fait — formulaire article**
- Sources multiples : lignes ajoutées et retirées sans quitter la page (gabarits HTML, numérotation des appels dans l'ordre saisi) ; les sources sont remplacées à l'enregistrement, comme le journal le laisse attendre.
- Infobox : paires libellé/valeur, lignes incomplètes ignorées, stockage `libellé => valeur` — le format déjà lu par la fiche publique.
- Étiquettes : cases à cocher sur le référentiel, `sync` du pivot `article_tag`.
- Le test de création passe désormais `references`, qui remplace les anciens champs `reference_title` / `reference_publisher`.

**Fait — lecture**
- Liste d'articles : filtres catégorie, auteur (éditeurs seulement), « sans source », « sans image » ; colonnes sources et image.
- Fiche article : infobox, étiquettes, empreinte SHA-256 tronquée par version, et comparaison « dernier jalon ↔ contenu courant » sur le titre, le résumé et le corps.
- Journal éditorial global `/admin/journal` : filtres par type et par acteur ; un contributeur ne voit que les actions de ses propres articles.

**Vérifié**
- `composer test` : **103 tests, 1 428 assertions** (+10) ; `pint --test` propre ; `phpstan` sans erreur sur 65 fichiers.
- `php artisan route:list --path=admin` : 24 routes, dont 9 nouvelles.
- Aucun fichier Flutter touché : les 44 tests de la séance 36 restent la référence pour l'application.

**Limites**
- Toujours aucune vérification au navigateur : les gabarits ne sont couverts que par les tests HTTP (statut et contenu), pas par un rendu réel, et l'ajout de lignes en JavaScript n'est exercé par aucun test.
- Dépôt des médias, éditeur visuel du Delta, 2FA, édition des contenus sourcés et export restent ouverts (phases 3 et 4).

---

## Séance 38 — 19 novembre 2026 · Accueil réorganisé comme une page de portail

**Demande**
- Refaire la page d'accueil : une vraie page d'encyclopédie, bien remplie, à l'image de la Côte d'Ivoire, avec plusieurs sections.

**Fait — le plan de la page**
- Manchette conservée (signature, devise, compteurs, barre des portails).
- Nouveau **sommaire** en tête : rubriques numérotées et cliquables (`Scrollable.ensureVisible`) — c'est lui qui fait lire la page comme un portail et non comme un fil.
- Les **portails thématiques** remontent juste après le sommaire : cartes avec médaillon à initiale, description et nombre d'articles, au lieu d'une simple liste en fin de page.

**Fait — entrées de contenu**
- Article du jour, « Aujourd'hui dans l'histoire » et frise : conservés.
- **Explorer les régions** (nouveau) : les huit régions les plus peuplées du recensement, avec effectif, année du RGPH et entrée vers `/lieux`.
- **Dernières publications** (nouveau) : grille de fiches avec vignette, catégorie, type et résumé.
- **Récits et mémoire** (nouveau) : trois récits avec période, chapeau et source citée.
- Colonne de droite : chiffres du pays, article au hasard, **bibliothèque des sources** (références, institutions, appels de source), reprise de lecture, contribuer.
- Pied de page : **Explorer l'encyclopédie** (six entrées : chronologie, lieux, chiffres, récits, sources, bibliothèque) et **Ce que garantit IVOIREPEDIA** (la charte en quatre engagements).

**Fait — données**
- `_HomeData` charge en parallèle catégories, articles, frise, statistiques, récits et bibliothèque ; les quatre derniers restent facultatifs : une panne n'emporte pas la « une ».
- Aucun faux contenu : une rubrique sans donnée ne s'affiche pas, et son entrée de sommaire disparaît avec elle.

**Vérifié**
- `flutter analyze` : aucune remarque. `flutter test` : **44 tests** verts.
- Trois assertions de `widget_test.dart` ont été mises à jour, pas affaiblies : le sommaire reprend les titres des rubriques, donc « Article du jour », « Aujourd'hui dans l'histoire » et « La frise en un coup d'œil » apparaissent deux fois ; les tests vérifient désormais ce nombre exact.
- Le test téléphone (390 px) a attrapé un débordement de 77 px sur les liens du sommaire : libellés repliés avec ellipse.

**Limites**
- Toujours aucune vérification visuelle : la page n'a été rendue par aucun navigateur, seuls les tests de widgets la dessinent.
- Trois rubriques restent à écrire faute de donnée : « image du jour » (médias), « index alphabétique » (index des titres), « articles demandés » (propositions des lecteurs). Elles attendent respectivement le dépôt des médias, la recherche plein texte et les signalements.

---

## Séance 39 — 19 novembre 2026 · Liens de l'accueil vérifiés

**Demande**
- Corriger le lien des cartes de région, retirer un paramètre inutilisé, et vérifier par un test que le sommaire fait bien défiler la page.

**Fait**
- Une carte de région ouvre désormais sa fiche `/lieux/:slug` quand le recensement lui connaît un slug ; sinon elle mène à l'annuaire `/lieux`, au lieu de toujours renvoyer à l'annuaire. C'est la règle déjà suivie par le tableau des régions des statistiques.
- `_SourceLibraryBox` ne reçoit plus `institutions` : le paramètre n'était pas lu, le nombre d'institutions venant déjà de `SourceLibrary.institutionCount`.
- La fixture du recensement porte maintenant deux régions : Haut-Sassandra avec son slug `haut-sassandra` (celui de la vraie réponse de l'API) et Folon sans slug, pour représenter une région que l'annuaire ne dessert pas.
- Deux tests de widgets : le sommaire fait défiler jusqu'à sa rubrique (voir ci-dessus), et une carte de région ouvre `/lieux/:slug` quand le recensement connaît le slug, `/lieux` sinon.

**Vérifié**
- `flutter analyze` : aucune remarque. `flutter test` : **46 tests** verts (+2).
- Aucun fichier backend touché : la suite Laravel de la séance 37 reste la référence (103 tests).

**Mise en ligne**
- Les quatre commits locaux en attente (panneau éditorial, référentiels, accueil, liens de l'accueil) sont poussés : `origin/main` est à `c4e5f70`.
- Serveur : `git pull --ff-only` de `57e5bdc` à `c4e5f70`, `composer install --no-dev --optimize-autoloader`, `php artisan migrate --force` (« Nothing to migrate », le schéma était déjà à jour), puis `config:cache`, `route:cache` et `view:cache`.
- Site Flutter reconstruit (`flutter build web --release --base-href=/ --dart-define=API_BASE_URL=/api/v1`, `main.dart.js` de 3 027 454 octets) et extrait à la racine de `backend/public` ; `index.php`, `.htaccess` et `storage` sont restés en place, et un `main.dart.js_1.part.js` résiduel a été supprimé.
- Contrôles en production : `/api/v1/health` répond `{"status":"ok"…}`, `/statistiques` et `/admin/connexion` répondent 200, la page d'accueil affiche le nouveau sommaire à sept rubriques et les portails.

**Limites**
- Le premier chargement reste lent (bundle de 3 Mo servi par l'hébergement mutualisé, vignettes Wikimedia à 5–10 s pièce) : mesuré à ~0,6 s pour le premier rendu et ~3 s pour `main.dart.js` après déploiement, mais une visite froide peut dépasser la minute. Un navigateur qui a l'ancien service worker en cache peut rester sur l'ancienne version : recharger sans cache.
- Le panneau `/admin` n'a été vérifié que par sa page de connexion : aucun identifiant de production n'a été saisi, donc le parcours éditorial en ligne reste à essayer.

---

## Séance 40 — 19 novembre 2026 · Série « Villes de Côte d'Ivoire »

**Demande**
- Intégrer une série d'articles détaillés sur les villes de Côte d'Ivoire.

**Fait — périmètre**
- Les 40 villes du répertoire public (`/lieux/:slug`, effectifs du RGPH 2021). Six avaient déjà leur article (Bouaké, Grand-Bassam, Korhogo, Man, San-Pédro, Yamoussoukro) ; les **34 autres** reçoivent une fiche, du chef-lieu de région (Daloa, Gagnoa, Soubré…) à la ville moyenne (Katiola, Toumodi, Sikensi).
- Ce périmètre est celui que l'application sait déjà relier : chaque ville a une page `/lieux/:slug` alimentée par le recensement. Les ~200 communes du pays restent à couvrir.

**Fait — contenu**
- `backend/database/data/cities.php` : les données éditoriales, séparées du code du seeder — nom, effectif communal 2021, chapeau et 8 à 10 blocs (situation, histoire, économie, vie locale, démographie).
- `backend/database/seeders/CityArticleSeeder.php` : publie chaque fiche en catégorie « Géographie », type Territoire, étiquette « Ville », infobox `CITY` + population + année du recensement, et une référence au document officiel du RGPH 2021 (ANStat) — la source dont viennent les effectifs cités.
- Non destructif : il ne crée que les fiches absentes et ne touche jamais à un article existant, même relancé. Enregistré dans `DatabaseSeeder`, il peut aussi être lancé seul (`php artisan db:seed --class=CityArticleSeeder`).
- Incident corrigé : le premier passage en production écrivait à l'aveugle et a écrasé l'article **Grand-Bassam** déjà publié. La fiche d'origine a été restaurée depuis `PublicContentSeeder` (texte, étiquettes, référence UNESCO) et un test verrouille désormais la règle : un article existant sur la même ville reste intact.
- Rien d'inventé : les chiffres sont ceux du recensement ; l'histoire et l'économie restent générales plutôt que précises au hasard, et les épisodes sensibles (Duékoué et la crise de 2010-2011, le Sanwi) sont formulés avec prudence.

**Vérifié**
- `composer test` : **108 tests, 1 560 assertions** (+5 : une fiche publiée pour chaque ville du répertoire, infobox/source/étiquette de Daloa, idempotence, article existant jamais réécrit, lecture d'une fiche par l'API publique).
- `pint --test` propre après `composer format` ; `phpstan` sans erreur.
- Aucun fichier Flutter touché : les 46 tests de l'application restent la référence.

**Mise en ligne**
- Serveur : `git pull --ff-only`, `composer install --no-dev`, `php artisan db:seed --class=CityArticleSeeder --force`, puis `config:cache` et `route:cache`.
- Le site compte **85 articles publiés** (51 + 34) ; `/api/v1/articles/katiola`, `/daloa`, `/grand-bassam` répondent 200. La fiche d'origine de Grand-Bassam a été restaurée en base à partir de `PublicContentSeeder`, et le seeder corrigé n'écrit plus que des fiches absentes.

**Limites**
- Fiches de synthèse : ni relief, ni quartiers, ni équipements ville par ville, et aucune image de couverture (le panneau ne gère pas encore les crédits d'image).
- Aucune relecture éditoriale humaine avant publication : à faire avant l'ouverture publique.

---

## Séance 41 — 19 novembre 2026 · Fiches de villes complètes et illustrées

**Demande**
- Vérifier en production que les 34 fiches s'ouvrent une par une et que les liens depuis `/lieux` mènent à la bonne ville, puis corriger ce qui restait : pas de relief, de quartiers ni d'équipements, aucune image de couverture.

**Vérifié en production (état de départ)**
- 34 fiches sur 34 : `/api/v1/articles/:slug`, `/api/v1/places/:slug` et la page `/articles/:slug` répondent 200 ; aucune fiche vide, aucun 404.
- Liens : `/lieux` ouvre `/lieux/:slug`, et la fiche de lieu retrouve son article par titre ou chapô (`LIKE` insensible aux accents : « Soubre » → Soubré, « Duekoue » → Duékoué) puis l'affiche sous « Articles liés ».
- Manques confirmés : 8 blocs par fiche, aucun paragraphe de relief, de quartier ou d'équipement ; aucune couverture.

**Fait — contenu**
- `database/data/cities-details.php` (nouveau) : deux sections par ville, « Relief et climat » et « Quartiers et équipements » — relief, climat, quartiers, marché et équipements, sans chiffre inventé. Le seeder les fusionne aux blocs de `cities.php` (chaque fiche passe de 8 à 14 blocs).
- Quand un détail local n'est pas vérifiable, la section décrit l'organisation générale (un chef-lieu, un marché central, un centre de santé de référence) plutôt que d'inventer un chiffre.

**Fait — images**
- `build-article-images.py` étendu à 24 villes : fichier, auteur, licence et page source relus un par un sur Wikimedia Commons, puis écrits dans `article-images.php` (75 entrées, 24 couvertures de villes). Les 24 URL répondent 200.
- `articles:attach-images` pose l'adresse, le texte alternatif, le crédit, la licence et la page source. Pour la photo de Danané, l'auteur n'est pas nommé : le crédit reprend la mention de la notice Commons, « Bibliothèque nationale de France » (domaine public). Le panneau éditorial gagne les champs **Licence** et **Page source de l'image** (le crédit existait déjà) : l'attribution survit désormais à une modification depuis `/admin`.

**Fait — série éditoriale**
- Migration `add_series_to_articles` : colonne `series` (nullable, indexée). `CityArticleSeeder` marque ses fiches `series = 'villes'` ; il crée les fiches absentes et rafraîchit **seulement** celles de la série. Un article écrit à la main (Grand-Bassam) n'est jamais réécrit, et la date de publication d'origine est conservée lors d'un rafraîchissement.

**Vérifié**
- `composer test` : **112 tests, 1 638 assertions** (+4 : sections détaillées présentes sur les 34 fiches, rafraîchissement limité à la série sans changer la date de publication, reprise d'une fiche antérieure à la colonne, crédit/licence/page source enregistrés depuis le panneau).
- `pint --test` propre après `composer format` ; `phpstan` sans erreur.
- Aucun fichier Flutter touché : les 46 tests de l'application restent la référence.

**Mise en ligne**
- Serveur : `git pull --ff-only`, `php artisan migrate --force`, puis la reprise en deux temps : `CITY_SEEDER_ADOPT=1 php artisan db:seed --class=CityArticleSeeder --force` marque et rafraîchit les 34 fiches créées avant la colonne `series`, et les passages suivants n'ont plus besoin de la variable. Enfin `php artisan articles:attach-images`, `config:cache` et `route:cache`.

**Limites**
- Dix villes n'ont aucune photo libre réutilisable sur Commons (Agnibilékrou, Bloléquin, Bonon, Buyo, Lakota, Méagui, Oumé, Séguéla, Sinfra, Tengréla) : pas de carte ni de portrait à la place, la fiche reste sans image jusqu'à une photo sous licence libre.
- Les sections restent générales là où aucune source ne documente le détail local ; la relecture éditoriale humaine avant ouverture publique reste à faire.

---

## Séance 42 — 19 novembre 2026 · Rafraîchissement non destructif de la série

**Demande**
- Le seeder des villes écrasait le travail éditorial : il supprimait les références ajoutées depuis `/admin` et annulait les modifications d'une fiche de la série. Rendre le rafraîchissement non destructif, l'outiller de tests, puis le relire d'un œil neuf.

**Le défaut**
- `attachCensusReference` (ancien bloc du seeder) appelait `$article->references()->delete()` avant d'ajouter la source du recensement : toute source ajoutée depuis le panneau disparaissait au passage suivant.
- `fill([...])` réécrivait titre, chapô, contenu et infobox à chaque exécution : une fiche retravaillée dans `/admin` redevenait la fiche machine.
- `tags()->sync([...])` retirait les étiquettes éditoriales au profit de la seule étiquette « ville ».

**Fait**
- Colonne `articles.series_state` (JSON) : le seeder y range l'empreinte SHA-256 de chaque champ qu'il écrit (titre, chapô, contenu, infobox). Au passage suivant, un champ n'est réécrit que si la base contient encore la valeur machine ; sinon la valeur présente est conservée.
- Fiche sans empreinte (créée avant le suivi) : rien n'est remplacé — si son contenu diffère de la série, il est conservé, l'empreinte est posée et la fiche est signalée en fin d'exécution (« Contenu différent de la série, conservé et désormais protégé : … »). Pour reprendre la version de la série, on vide `series_state` de cette fiche.
- Seule l'adoption explicite (`CITY_SEEDER_ADOPT=1`) écrit le contenu de la série sur une fiche qui n'en vient pas : c'est une décision humaine, pas un effet de bord.
- Les empreintes sont calculées sur une forme canonique (clés triées) : MySQL réordonne les objets JSON, l'empreinte relue reste donc celle de la valeur écrite.
- Références : la source du recensement est ajoutée si elle manque, à la position suivante, sans plus rien supprimer.
- Étiquettes : `syncWithoutDetaching` — l'étiquette « ville » s'ajoute, les étiquettes de la rédaction restent.
- Aucune écriture inutile : une fiche déjà à jour ne voit plus son `updated_at` bouger.
- Même défaut, même correction pour les illustrations : `articles:attach-images` réécrivait une couverture choisie dans `/admin`. Elle conserve désormais une image différente du jeu de données et la liste en fin d'exécution ; `--force` reprend explicitement le jeu de données.

**Vérifié**
- `composer test` : **118 tests, 1 657 assertions** ; les six nouveaux cas couvrent la source ajoutée depuis le panneau (deux passages), la fiche modifiée via `PUT /admin/articles/{id}` puis reseedée deux fois, l'étiquette éditoriale conservée, la fiche antérieure au suivi dont le contenu diffère (conservée, signalée en sortie, puis toujours protégée), l'absence d'écriture inutile (`updated_at` inchangé sur une fiche à jour), et la couverture choisie à la main conservée puis reprise avec `--force`.
- `pint --test` propre, `phpstan` sans erreur ; aucun fichier Flutter touché.

**Mise en ligne**
- `git pull --ff-only`, `php artisan migrate --force`, un passage du seeder (les fiches déjà en base reçoivent leur `series_state` sans que rien d'éditorial ne soit perdu), puis `config:cache` et `route:cache`.

**Reste**
- Les 34 fiches n'ont pas encore d'empreintes en production : le premier passage après déploiement ne remplace aucun contenu, il enregistre les empreintes et signale les fiches qui diffèrent de la série.
- Un champ ne peut pas être « repris » par la série après une modification humaine sans effacer l'empreinte à la main (`series_state` à `null`) : c'est le prix de la protection, et le message d'avertissement le rappelle.

---

## Séance 43 — 19 novembre 2026 · Pages de confiance et formulaire de contact

**Demande**
- Les quatre liens du pied de page (« À propos », « Charte », « Contact », « Confidentialité ») ouvraient un dialogue « pas encore disponible ». Créer les pages réelles, avec tests et documentation.

**Fait — site**
- `app/lib/src/ui/trust_pages.dart` : quatre pages de contenu réel, servies par le routeur aux adresses `/a-propos`, `/charte`, `/contact`, `/confidentialite`.
  - **À propos** : ce que le site contient, comment il travaille (une source par information, images libres créditées), la licence CC BY-SA 4.0 des textes, et les liens vers la charte, le contact et les sources.
  - **Charte** : six règles — une information/une source, rien d'inventé, images libres créditées, corrections visibles, neutralité et respect des personnes, licence ouverte.
  - **Contact** : formulaire (nom et adresse facultatifs, message obligatoire de 20 à 4 000 caractères), état d'envoi, confirmation, message d'erreur lisible tiré de la réponse 422.
  - **Confidentialité** : favoris, lectures et réglages restent dans le stockage local ; compte facultatif (adresse + mot de passe haché), message de contact, journaux techniques ; ni publicité, ni traqueur, ni revente.
- Le pied de page utilise désormais `wikiGo` vers ces adresses : plus aucun lien mort de ce côté. La page ne promet rien que le code ne tient pas (pas de relecture humaine annoncée, pas d'adresse électronique inventée).

**Fait — API et panneau**
- `contact_messages` (migration, modèle `ContactMessage`, enum `ContactMessageStatus`) et `POST /api/v1/contact` : validation par `ContactRequest` (longueurs, adresse, piège à robots `website`), plafond `throttle:5,1`, réponse `201` avec l'identifiant et le statut, adresse normalisée en minuscules.
- `/admin/messages` : file des messages à traiter, lien « Traités (n) » pour les consulter, bouton « Marquer comme traité » (statut + horodatage, rien n'est supprimé). Entrée « Messages » dans la navigation ; accès réservé aux rôles qui révisent (403 pour un contributeur, redirection vers la connexion pour un visiteur).
- `docs/DASHBOARD_ADMIN.md` : §4.7 décrit l'écran, le tableau des permissions gagne « Traiter les messages de contact ».

**Vérifié**
- `composer test` : **129 tests, 1 706 assertions** (6 tests d'API de contact — création, sans nom ni adresse, message court, adresse invalide, piège à robots, plafond à 5 envois ; 5 tests du panneau — liste, séparation traité/à traiter, marquage, refus au contributeur, redirection du visiteur).
- `flutter analyze` propre ; `flutter test` : **51 tests** (5 nouveaux : les quatre liens du pied de page ouvrent les pages réelles, la charte énonce ses règles, la confidentialité décrit le stockage local, le formulaire envoie puis confirme, le formulaire refuse un message trop court).

**Mise en ligne**
- `git pull --ff-only`, `php artisan migrate --force`, reconstruction de l'application Flutter (`flutter build web`) pour que les nouvelles pages soient servies, puis `config:cache` et `route:cache`.

**Reste**
- Aucune adresse de contact publique n'est affichée : le formulaire est le seul canal, faute d'adresse vérifiée à publier.
- Les messages ne déclenchent pas de courriel : un éditeur doit ouvrir `/admin/messages` (Mailjet est encore en `log`).
- Les liens « Créer un article », « Discussion », « Modifier une section » et les étiquettes restent, eux, non implémentés.

---

## Séance 44 — 19 novembre 2026 · Pré-rendu des articles, partage et sitemap

**Demande**
- Enchaîner sur l’étape 2 : rendre les articles lisibles en HTML côté serveur, fournir des cartes de partage (Open Graph) et un `sitemap.xml`, avec tests et documentation.

**Le défaut**
- Toutes les adresses non fichiers recevaient `index.html`, l’application Flutter dessinée en canvas : un moteur de recherche ou un aperçu WhatsApp/X/Facebook ne trouvait ni titre, ni texte, ni image. `/sitemap.xml` n’existait pas et `robots.txt` n’indiquait aucun plan du site.

**Fait**
- `App\Support\DeltaHtml` : rendu serveur du Delta Quill, sans jamais stocker de HTML. Le texte est échappé avant d’être enveloppé dans nos balises ; les blocs suivent la lecture Flutter (chapeau, titres, listes, citations). Les titres reçoivent l’ancre de `sectionAnchor` (`Histoire ancienne` → `histoire-ancienne`) et les appels `[n]` deviennent des liens vers `#reference-n`.
- `GET /articles/{slug}` (`ArticlePageController`, vues `site/article`, `site/missing` et `site/layout`) : titre, chapô, couverture créditée, sommaire, contenu, notes et références, catégories et licence CC BY-SA 4.0. Un article non publié, programmé ou inconnu renvoie une page 404 en HTML.
- Métadonnées de partage : `og:type=article`, `og:title`, `og:description`, `og:url`, `og:image` (couverture absolue) et `og:image:alt`, `article:published_time`, `article:modified_time`, `article:section`, `article:tag`, `twitter:card` (`summary_large_image` avec couverture, `summary` sinon), lien canonique et `lang="fr"`.
- `GET /sitemap.xml` : pages fixes, catégories contenant au moins un article publié, articles publiés (`lastmod` = date de publication) et fiches de lieux du recensement, sans doublon. `robots.txt` pointe désormais vers le sitemap.
- `public/.htaccess` : `/articles/{slug}` et `/sitemap.xml` sont traités par Laravel ; tout le reste continue de recevoir l’application Flutter. Les liens internes et la navigation client ne changent pas : au moment de cette livraison, un chargement direct (partage, rechargement, crawler) recevait le HTML pré-rendu — la séance 45 rétablit l’application pour les visiteurs et réserve ce HTML aux robots.
- Défaut découvert en production : l’ancienne redirection `^site/?(.*)$` (adresses `/site/...`) lisait `/sitemap.xml` comme `/site` + `map.xml` et le renvoyait en 301 vers `/map.xml`. La règle exige désormais la barre (`^site(?:/(.*))?$`) ; `/site/...` continue de rediriger, `/sitemap.xml` atteint Laravel.
- `docs/DEPLOIEMENT.md` : procédure et vérifications de la page pré-rendue et du sitemap ; `IVOIREPEDIA_CONTEXT.md` §17 : R-09 passe de « SEO limité » à « SEO partiellement limité ».

**Vérifié**
- `composer test` : **136 tests, 1 755 assertions**. Sept nouveaux cas : contenu et ancre de section avec appel de note, Open Graph/canonique/couverture, échappement d’un `<script>` inséré dans le contenu, listes et citations, 404 pour brouillon/programmé/inconnu, sitemap complet et XML valide, exclusion des articles programmés et du panneau.
- `composer format:check` et `composer analyse` propres ; aucune modification Flutter (les 51 tests de l’application restent verts, la navigation interne n’a pas bougé).

**Mise en ligne**
- `git pull --ff-only`, `php artisan config:cache && route:cache && view:cache` ; aucun build Flutter n’est nécessaire.
- Vérifications sur la production : page article en `200` avec ses balises `og:*` et son texte dans le source, `sitemap.xml` en `application/xml`, `robots.txt` annonçant le sitemap, et toujours `200` sur l’accueil et les autres routes de l’application.

**Reste**
- Seules les pages d’articles sont pré-rendues : accueil, catégories, lieux, statistiques et sources restent rendus par Flutter (R-09 partiellement levé).
- Pas encore de données structurées JSON-LD (`Article`) ni de sitemap d’images : le partage et l’indexation reposent sur Open Graph et le HTML.
- `robots.txt` fige l’adresse de production ; un changement de domaine exige de le mettre à jour.

---

## Séance 45 — 19 novembre 2026 · Une seule charte pour la page article

**Demande**
- Signalement après la séance 44 : la page `/articles/daloa` ouverte directement n’a pas le design de l’application, alors que le même article ouvert depuis l’accueil l’a. Deux rendus pour une seule adresse, et une page pré-rendue qui ne suit pas la charte graphique.

**Le défaut**
- La navigation depuis l’accueil reste dans Flutter : aucun appel serveur, donc l’écran de lecture habituel. Un accès direct ou un rechargement passait par Laravel et affichait la page HTML simplifiée ajoutée pour le SEO et le partage. La palette était proche, mais la typographie, la mise en page et les commandes de l’article différaient.

**Fait**
- `ArticlePageController` distingue désormais les clients :
  - un navigateur reçoit `site/shell` — la coquille Flutter (`flutter_bootstrap.js`, écran de lancement, icônes) avec le titre, la description, l’Open Graph et la canonique de l’article dans le `<head>` ; l’application reprend ensuite la main et affiche sa page de lecture, identique à celle atteinte depuis l’accueil ;
  - un robot (moteur de recherche, aperçu WhatsApp/X/Facebook/LinkedIn, etc.) ou un client qui demande `?html=1` reçoit `site/article`, le HTML complet sans JavaScript.
- Un article inconnu suit la même règle : page 404 HTML pour les robots, coquille Flutter en 404 pour les visiteurs (l’application affiche son propre écran « page inexistante »).
- Les balises de partage sont factorisées dans `site/partials/social.blade.php`, utilisé par les deux rendus : elles ne peuvent plus diverger.
- Aucun changement Flutter : la page de lecture, ses onglets et ses commandes restent celles de l’application.

**Vérifié**
- `composer test` : **139 tests, 1 766 assertions**. Trois nouveaux cas : un navigateur reçoit la coquille Flutter avec les métadonnées de l’article, `?html=1` renvoie le HTML complet, et un article inconnu renvoie une coquille en 404 pour un visiteur. Les tests du pré-rendu existants passent avec un User-Agent de robot.
- `composer format:check` et `composer analyse` propres ; vérification en production à l’URL directe (application affichée) et avec un User-Agent Googlebot (HTML complet).

**Reste**
- La version `?html=1` reste une page de lecture simplifiée, volontairement sans les commandes de l’application ; elle sert de repli sans JavaScript et de contenu aux robots.
- Les autres pages (accueil, catégories, lieux) n’ont toujours pas de version pré-rendue.

---

## Séance 46 — 19 novembre 2026 · Coquille issue du build déployé, partage en bas d’article

**Demande**
- La séance 45 avait recopié le document Flutter dans un second fichier (`site/shell.blade.php`) : la moindre évolution de `app/web/index.html` (écran de lancement, icônes, manifeste) pouvait diverger de l’application. La coquille doit partir du `public/index.html` déployé, avec un repli local pour les tests.
- Le bloc de partage (WhatsApp, X, Facebook, LinkedIn, copier le lien) se trouvait sous le titre de l’article : il doit être en bas, une fois la lecture finie.

**Fait — coquille**
- `App\Support\FlutterShell` remplace `site/shell.blade.php`, supprimé : le document vient de `public/index.html` (build déployé), sinon de `app/web/index.html` (source versionnée), sinon d’une page de repli sans Flutter (`site/shell-fallback`). La variable de build `$FLUTTER_BASE_HREF` est remplacée par `/`.
- Seules les métadonnées sont modifiées : `<title>` et `meta description` remplacés, canonique et Open Graph (`site/partials/shell-head`) insérés dans le `<head>`, `<noscript>` (`site/partials/shell-noscript`) avant `</body>`. Le reste du document déployé est laissé intact — écran de lancement, icônes, manifeste et script de démarrage ne sont plus écrits à la main côté Laravel.
- `ArticlePageController` instancie `FlutterShell` pour les deux rendus (article trouvé et 404).

**Fait — partage**
- `article_page.dart` : `ShareBar` retiré du haut de page et posé en bas du contenu de lecture, après les catégories et sous un filet ; le message « Lien copié. » passe par le `ScaffoldMessenger` de la page. Le commentaire de `share_bar.dart` décrit le nouvel emplacement.

**Vérifié**
- `composer test` : **141 tests, 1 783 assertions**. Deux nouveaux cas dans `tests/Feature/Site/FlutterShellTest.php` : le document déployé est repris tel quel (marqueur du build conservé, base `/`, titre, description, canonique et Open Graph injectés, `noscript` juste avant `</body>`) ; sans document disponible, une page de repli est rendue sans `flutter_bootstrap.js`.
- `composer format:check` et `composer analyse` propres.
- `flutter analyze` propre ; `flutter test` : **52 tests**, dont un nouveau qui vérifie que « Partager : » se trouve plus bas que les catégories dans la page de lecture.

**Mise en ligne**
- `flutter build web --release --base-href=/ --dart-define=API_BASE_URL=/api/v1`, envoi du build dans `backend/public/`, `git pull --ff-only` en SSH, `composer install --no-dev`, `migrate --force`, puis `config:cache`, `route:cache` et `view:cache`. La base n’avait aucune migration en attente.
- Vérifié en production : `/articles/daloa` répond `200` avec `<base href="/">`, `<title>Daloa — IVOIREPEDIA</title>`, `og:title` et le repli `?html=1`, l’accueil répond `200` ; en bas de l’article, après les catégories, on voit « Partager : WhatsApp, X, Facebook, LinkedIn, Copier le lien » (capture `screenshot-partage-bas-article.png`).

**Reste**
- Les autres pages (accueil, catégories, lieux) n’ont toujours pas de version pré-rendue ; les suites SEO proposées (JSON-LD `Article`, sitemap d’images, image Open Graph par défaut) ne sont pas commencées.

---

## Séance 47 — 19 novembre 2026 · Données structurées JSON-LD, doc de déploiement corrigée

**Demande**
- Corriger `docs/DEPLOIEMENT.md`, qui décrivait un `app/web/.htaccess` recopié dans le build alors qu'il n'existe pas.
- Publier chaque article en données structurées JSON-LD, avec tests et documentation.

**Fait — déploiement**
- §5 : le build Flutter ne contient aucun `.htaccess` ; `backend/public/.htaccess`, versionné, reste la seule source de vérité pour la racine et l'extraction du `tar` ne le touche pas. La vérification devient « le `.htaccess` du dépôt est toujours là », et non « le fichier du build a été extrait ».
- §3 : la commande d'envoi n'efface plus un dossier `public/site` qui n'existe pas ; le build s'extrait directement dans `backend/public/`, à côté d'`index.php`.

**Fait — JSON-LD**
- `site/partials/json-ld.blade.php` : bloc `application/ld+json` de type `Article` — `headline`, `description`, `url`, `mainEntityOfPage`, `inLanguage` (`fr-CI`), `isAccessibleForFree`, licence CC BY-SA 4.0, image de couverture, `datePublished`/`dateModified`, `articleSection`, `keywords` (étiquettes), `author` (`Person` quand l'auteur est connu, sinon l'organisation) et `publisher` Organization IVOIREPEDIA avec son logo. Les champs vides sont omis plutôt qu'envoyés vides.
- Le bloc est inclus dans les deux rendus — `site/article` (robots et `?html=1`) et `site/partials/shell-head` (coquille Flutter) — pour que le même article porte les mêmes données quel que soit le client. Une page 404 n'en émet aucun : rien ne déclare un article qui n'existe pas.
- Encodage `JSON_HEX_TAG`, `JSON_HEX_AMP`, `JSON_HEX_APOS` et `JSON_HEX_QUOT` : un titre contenant `</script>` ne peut pas fermer le bloc ni injecter de balise.

**Vérifié**
- `composer test` : **144 tests, 1 823 assertions**. Trois nouveaux cas : les mêmes données pour un robot et pour un visiteur (type, titre, URL, langue, image, étiquettes, auteur, éditeur, logo, dates), aucun JSON-LD sur une page inconnue, et un titre `</script><script>alert(1)</script>` qui reste du texte dans un bloc toujours analysable.
- `composer format:check` et `composer analyse` propres ; aucun fichier Flutter touché, les 52 tests de l'application restent valables sans modification.

**Mise en ligne**
- `git pull --ff-only` en SSH (`4d5cfcc` → `4b966c4`), puis `config:cache`, `route:cache` et `view:cache` ; aucun build Flutter, aucune migration.
- Vérifié sur `/articles/daloa` : `200` pour Googlebot comme pour un navigateur, un seul bloc `application/ld+json` de chaque côté, données identiques (titre, description, URL, langue, licence, image, dates, section, étiquette, auteur, éditeur et logo) ; pour le visiteur, la coquille charge toujours `flutter_bootstrap.js`. Une page inconnue reste `404` sans aucun bloc.

**Reste**
- `author` porte le nom du compte qui a publié (« Administrateur IVOIREPEDIA ») : une personne réelle ou une signature éditoriale demanderait une décision de contenu.
- Pas de `BreadcrumbList` ni de `WebSite` (recherche interne), et toujours pas de sitemap d'images.

---

## Séance 48 — 19 novembre 2026 · Nouvelle marque, statistiques d’article, confirmation de copie

**Demande**
- Intégrer les nouveaux visuels de la marque (emblème et signature) chacun à sa place.
- Afficher, dans la page de chaque article, les statistiques qui le concernent.
- Faire réagir le bouton « copier » d'une section : il confirme la copie, puis reprend sa place.

**Fait — marque**
- `tools/build_brand_assets.py` part des visuels fournis (déjà détourés, canal alpha) : `cutout()` ne sert plus que pour une source revenue sur fond clair. Emblème `marque.webp` (1 010 × 880), mot-symbole `logo-mot.webp` (1 074 × 150) découpé dans la signature, signature `logo.webp` (1 200 × 298) pour la couverture, la manchette et le pied de page.
- Icônes refaites sur le nouvel emblème : `square_icon()` ajuste désormais la marque sur sa plus grande dimension, sinon un emblème plus large que haut débordait du carré.
- Le script écrit aussi `backend/public/logo.png` (l'URL que cite le JSON-LD `publisher.logo`), `favicon.png` et `favicon.ico` : la racine du site a ses replis même sans build Flutter.
- `app/web/index.html` : hauteur du PNG de lancement corrigée (298 px au lieu de 282) pour la nouvelle signature ; `cover.dart` porte la même mesure en commentaire.

**Fait — statistiques d’article**
- Encart « Statistiques » dans la colonne de droite de l'article (et après le chapeau sur téléphone) : mots, sections, notes et références, temps de lecture, étiquettes, date de publication et dernière modification.
- Tout se calcule à partir du contenu déjà chargé (`articleWordCount`, `articleSections`, `references`), sans requête supplémentaire. `ArticleDetail` lit maintenant `updated_at`, ce qui distingue la publication de la modification.

**Fait — confirmation de copie**
- Le lien « copier » d'un titre de section devient « copié » en vert pendant 1,6 s, puis reprend son libellé. La largeur est réservée pour que « modifier » ne saute pas, et le minuteur est annulé au retrait du widget.

**Vérifié**
- `flutter analyze` : aucun problème. `flutter test` : **54 tests au vert**. Deux tests ajoutés dans `app/test/article_page_test.dart` : statistiques attendues (22 mots, 2 sections, 1 référence, 6 min, « 2 novembre 2026 ») et confirmation de copie qui s'efface. Ces tests ont d'abord révélé un doublon de libellé (« Notes et références » affiché à la fois dans l'encart et comme titre de section), corrigé en « Références » dans l'encart.
- Aucun fichier du backend modifié hormis des images ; ses tests restent valables sans nouvelle exécution.

**Reste**
- Rien n'est déployé : les visuels, les statistiques et la confirmation partiront avec le prochain build Flutter.
- Les trois variantes de signature reçues sont proches : la plus lisible au petit format a été retenue ; remplacer `LOCKUP` dans le script suffit pour en essayer une autre.

---

## Séance 49 — 20 novembre 2026 · Anciennes images en production et chargement lent

**Demande**
- Sur d'autres navigateurs, le site affiche encore les anciennes images et met trop de temps à charger.

**Constaté (mesuré, pas supposé)**
- Les nouveaux visuels n'avaient jamais été déployés : le build Flutter en production datait du 19 novembre 19 h 16, et le serveur Git en était resté à `4b966c4`. Le `/logo.png` servi pesait 253 061 o (ancien) contre 393 303 o (nouveau), empreintes différentes.
- Le premier chargement télécharge ~10 Mo : `main.dart.js` (3 047 876 o, 904 206 o avec gzip — la compression du serveur fonctionne, vérifiée par `content-encoding: gzip`), son différé `main.dart.js_1.part.js` (~970 ko) et `canvaskit.wasm` (7 284 602 o). Le chemin mesuré vers l'hébergeur plafonne autour de 20 ko/s avec ~2 s de latence par requête (contre ~90 ko/s vers un grand site), d'où des minutes d'attente au premier passage.
- Optimisation PNG sans effet (`393 303 o` avant comme après) : le fichier est déjà optimisé, on garde les visuels tels quels.

**Fait**
- `backend/tests/Feature/Site/PublicAssetsTest.php` : le logo cité par le JSON-LD du `publisher` (`/logo.png`) et les favicons de la coquille doivent exister dans `public/`, non vides, au bon type MIME.
- Serveur : `git pull --ff-only` jusqu'à `971cd82` (il a fallu écarter le `logo.png` déployé non suivi qui bloquait la fusion), `config:cache`, `route:cache`, `view:cache`.
- Reconstruction `flutter build web --release --base-href=/ --dart-define=API_BASE_URL=/api/v1` (353,8 s) puis transfert vers `~/ivoirepedia/backend/public`. Piège : sous Git Bash, `--base-href=/` exige `MSYS_NO_PATHCONV=1`, sinon la barre oblique est convertie en chemin Windows et le build refuse de partir.

**Vérifié**
- `composer test` (filtre `PublicAssetsTest`) : 2 tests au vert ; `format:check` : PASS (150 fichiers) ; `analyse` : aucune erreur.
- Production après déploiement : `/logo.png` servi avec la même empreinte que le nouveau fichier, `index.html` régénéré, `/articles/daloa` en 200 en 0,8 s.
- Les navigateurs qui gardaient l'ancien build basculent au nouveau au prochain passage (le service worker se met à jour) ; en cas d'image figée, un rechargement forcé suffit.

**Reste**
- Le premier chargement reste lourd par construction (moteur CanvasKit de ~7 Mo + ~4 Mo de JavaScript, gzip déjà actif) : sur une connexion lente, il faut s'attendre à plusieurs dizaines de secondes la première fois, puis le cache (service worker + `max-age`) prend le relais. Aucune piste simple restante côté dépôt sans changer de moteur de rendu.

---

## Séance 50 — 20 novembre 2026 · Préchargement du JavaScript critique

**Demande**
- Ajouter les liens `preload` du JS critique (et `preconnect` vers l'API) dans `app/web/index.html`.

**Fait**
- `app/web/index.html` : `<link rel="preload" as="script">` pour `flutter_bootstrap.js` et `main.dart.js`, en chemins relatifs pour suivre la même base que le chargeur. Le navigateur les découvre dès la lecture de l'en-tête — environ un aller-retour (~2 s sur le chemin mesuré) gagné avant le premier octet utile.
- Pas de `preconnect` vers l'API : elle est servie par la même origine (`/api/v1`), la connexion est déjà ouverte, un `preconnect` serait sans effet. Un `preconnect` absolu figerait en plus le domaine de production dans la coquille.
- `app/test/web_shell_test.dart` : la coquille doit contenir les deux `preload` et aucun `preconnect`.

**Vérifié**
- `flutter analyze` : aucun problème. `flutter test` : **55 tests au vert** (54 + 1 nouveau).
- `composer test` : **146 tests au vert** ; `format:check` : PASS (150 fichiers) ; `analyse` : aucune erreur (backend inchangé, contrôles reconduits avant commit).
- Production après redéploiement : `index.html` servi contient les deux `preload`.

**Reste**
- Pistes suivantes (séance 49) : brotli précompressé au déploiement, puis audit `--analyze-size` et imports différés.

---

## Séance 51 — 20 novembre 2026 · Page de chargement vivante et brotli précompressé

**Demande**
- Rendre la page de chargement plus attractive, plus compréhensible et plus interactive.
- Mettre en place le brotli précompressé au déploiement (JS et wasm), avec mesures avant/après.

**Fait — chargement**
- `app/web/index.html` : trois pastilles d'étapes pilotées par des événements réels (connexion → moteur → encyclopédie), phrase de statut lisible par les lecteurs d'écran, compteur de secondes réellement écoulées après 10 s, et bouton « Recharger la page » en cas de lenteur ou d'échec du chargeur (`onerror`). Le voile se retire toujours à la première image peinte, et `prefers-reduced-motion` coupe les animations.
- `app/test/web_shell_test.dart` : la coquille doit contenir les étapes, le statut, le compteur, le bouton et les signaux `onload`/`onerror`.

**Fait — brotli**
- `tools/precompress_web.py` : écrit `<fichier>.br` (qualité 11) à côté de chaque `.js`/`.wasm` du build, en ignorant les sorties à jour et celles qui gonfleraient. Piège : l'option `--squash` du CLI fait échouer la compression sur sortie standard — la comparaison de taille est faite en Python.
- `backend/public/.htaccess` : quand le navigateur annonce `br` et que la variante existe, c'est elle qui part, avec `Content-Encoding: br`, le type d'origine et la même politique de cache. Le brotli dynamique reste coupé.
- `backend/tests/Feature/Site/BrotliPrecompressionTest.php` : fige la négociation (JS + wasm, encodage, types, cache). Correction au passage : les motifs `.htaccess` sont échappés (`\.js\.br`), le test les attend désormais tels quels.
- `docs/DEPLOIEMENT.md` : l'étape de précompression rejoint la procédure de publication du site.

**Mesuré**
- Avant (gzip serveur) : `main.dart.js` 3 050 672 o → 904 206 o en 44,4 s ; `canvaskit.wasm` 7 284 602 o → 2 923 814 o en 24,2 s.
- Après (fichiers `.br` qualité 11) : `main.dart.js` → 693 361 o (−23 % contre gzip) ; `canvaskit.wasm` → 1 055 638 o (−64 %) ; total du build 33 316 218 o → 10 061 012 o (−69,8 %). Aller-retour vérifié par décompression (`cmp` identique).

**Vérifié**
- `flutter analyze` : aucun problème. `flutter test` : **55 tests au vert**.
- `composer test` : **147 tests au vert** ; `format:check` : PASS (151 fichiers) ; `analyse` : aucune erreur.
- Production après redéploiement : `main.dart.js` servi en `content-encoding: br` avec le poids du fichier `.br`, page de chargement avec étapes et bouton.

**Reste**
- Piste suivante (séance 49) : audit `--analyze-size` et imports différés pour réduire le JS initial lui-même.

---

## Séance 52 — 20 novembre 2026 · Audit du poids du JS initial : rien de plus à différer

**Demande**
- Lancer l'audit `--analyze-size`, trouver les dépendances lourdes du JS initial et mettre celles des écrans rares en imports différés.

**Méthode**
- `flutter build web --analyze-size` n'existe plus sous Flutter 3.47 (option inconnue, sortie 64). Audit remplacé par trois preuves directes : graphe des imports tiers de `app/lib`, contenu comparé de `main.dart.js` et de son différé, et lecture de `flutter_bootstrap.js` pour l'origine du moteur.

**Constaté**
- Les seules dépendances tierces lourdes sont `pdf` + `file_saver` (export PDF de l'article), et elles sont **déjà en import différé** (`article_page.dart` fait `loadLibrary()` au clic) : les marqueurs du moteur PDF (`Helvetica`, `DCTDecode`) sont absents de `main.dart.js` (3 050 672 o) et présents uniquement dans `main.dart.js_1.part.js` (969 714 o), qui ne part qu'au clic « Télécharger en PDF ».
- Le reste du JS initial n'importe que le framework, `go_router`, `url_launcher`, `shared_preferences` et `http` : aucune autre bibliothèque tierce à sortir du chemin critique. Différer un écran ne déplacerait que du code applicatif, pour un aller-retour supplémentaire et zéro économie réelle — c'est donc écarté.
- Le moteur ne vient pas du serveur : `flutter_bootstrap.js` choisit `https://www.gstatic.com/flutter-canvaskit` par défaut (option CDN active). Les 7 Mo de wasm mesurés en séance 49 correspondaient à des requêtes directes, pas au parcours réel des navigateurs, qui profitent du CDN Google et de son cache partagé.
- `intl` est déclaré dans `pubspec.yaml` mais jamais importé : poids nul (élagué à la compilation), simple note de ménage, sans effet mesurable.

**Décision**
- Aucun changement de code : il n'y a rien à différer de plus, et inventer un différé serait nuisible. Cette séance est donc documentation seule, sans redéploiement (le build en production est déjà le bon).

**Vérifié**
- Preuves relues dans le build déployé (`grep` des marqueurs des deux côtés de la séparation, URL gstatic dans le chargeur). Suites au vert de la séance 51 sur un code inchangé depuis : `flutter test` 55/55, `composer test` 147/147.

**Reste**
- Réduire le JS initial lui-même exigerait un régime (retirer du framework ou du code applicatif), pas un différé : hors périmètre du chargement sans changer de moteur.

---

## Séance 53 — 20 novembre 2026 · Le brotli à la volée recompressait les `.br` : site bloqué, correctif déployé

**Signalement**
- Depuis la séance 51, le site met beaucoup plus de temps à charger, au point de rester bloqué sur l'écran de chargement (panneau « Le moteur tarde à arriver », compteur au-delà de 20 s, bouton de rechargement), alors que les vérifications `curl` semblaient vertes.

**Constaté (navigateur réel, onglet partagé)**
- Dans un vrai navigateur, `main.dart.js` (677 ko transférés) n'est jamais exécuté : `SyntaxError: Invalid or unexpected token`, puis avertissement « preloaded but not used ». L'écran reste donc affiché indéfiniment : ce n'était pas un ralentissement, c'était un blocage total.
- Reproduction avec des en-têtes de navigateur (`Accept-Encoding: gzip, deflate, br, zstd`) : le corps décompressé une fois en brotli pèse 693 361 o, soit exactement la variante `.br` elle-même — le serveur servait du **brotli de brotli** (`content-encoding: br` unique, corps doublement compressé, `curl` avec `Accept-Encoding: br` seul ne le révélait pas).
- Cause : après la réécriture vers `main.dart.js.br`, l'adresse finit en `.br`, le motif d'exclusion `no-brotli` (qui ne vise que `.js`/`.wasm`/…) ne correspond plus, et le brotli dynamique d'Apache recompresse la variante déjà compressée. Le `SetEnvIfNoCase` s'évalue sur l'adresse réécrite, pas sur l'originale.

**Décision**
- `.htaccess` : exclusion explicite des `.br` de toute compression à la volée, côté brotli (`no-brotli`) comme côté gzip (`no-gzip`, par précaution). Aucun changement applicatif, aucun rebuild Flutter : le correctif est une configuration serveur.
- Test ajouté (`BrotliPrecompressionTest`) : fige les deux exclusions, dans le style des tests existants qui relisent le `.htaccess`.

**Vérifié**
- `composer test` : 148 verts ; `format:check` PASS (151 fichiers) ; `analyse` OK.
- Après déploiement (simple `git pull` serveur, effet immédiat) : re-téléchargement avec en-têtes navigateur → décompression = 3 050 672 o de JavaScript valide ; rechargement dans l'onglet → l'écran de chargement défile (Connexion → Moteur de lecture → Encyclopédie) puis l'application s'affiche.
- À noter pour la suite : `logo.webp` pèse 153 ko pour l'écran de chargement — acceptable mais perfectible si l'on veut gratter la première seconde.

---

## Séance 54 — 20 novembre 2026 · Logo de chargement allégé et contrôle post-déploiement navigateur

**Demandé**
- Alléger le `logo.webp` de l'écran de chargement (153 ko mesurés en séance 53) et ajouter un contrôle post-déploiement avec des en-têtes de navigateur réels, pour ne plus jamais revivre le faux-vert `curl` de la séance 53.

**Constaté (mesures)**
- Le logo fait 156 610 o à cause du canal alpha : à qualité égale, l'aplatir sur le papier du thème (`#FBF9F4`, fond uni de l'écran) divise le poids par cinq ; réduire la largeur ou la qualité ne gagne que 13 à 41 %.
- Le PNG de repli (393 ko) ne part presque jamais (navigateurs sans WebP) : laissé tel quel, tout comme le logo JSON-LD.

**Décision**
- `tools/build_brand_assets.py` : le WebP du chargeur est aplati sur le papier, qualité 80, mêmes dimensions (1200 px, net en rétina) ; le PNG et les autres visuels gardent leur transparence. Résultat : 156 610 → 29 824 o (−81 %), visuel identique vérifié à l'œil.
- `tools/verify_deploy.py` (nouveau) : rejoue le parcours réel après chaque déploiement — page + `main.dart.js` + différé PDF + `canvaskit.wasm` + logo, avec `Accept-Encoding: gzip, deflate, br, zstd` ; chaque réponse `br` est décompressée et comparée octet à octet à la variante `identity`. Sortie 1 au premier écart. Sa logique de détection est prouvée sur un double-brotli synthétique (693 361 o décodés contre 3 050 672 attendus → écart signalé).
- `docs/DEPLOIEMENT.md` : le contrôle devient obligatoire (§5, après l'envoi) et rejoint le tableau du §6.

**Vérifié**
- `flutter analyze` propre, `flutter test` 56 verts (dont « le logo de chargement reste léger », budget 60 ko + repli PNG présent) ; `composer test` 149 verts (dont le contrat du script), `format:check` PASS (152 fichiers), `analyse` OK.
- Script en direct avant déploiement du logo : tout `OK` sauf le logo encore à 156 610 o — la mesure avant/après est faite par le script lui-même.
- Déploiement : logo copié à la racine servie (+ `git pull` serveur pour le reste), nouveau passage du script tout `OK` avec le logo à 29 824 o, et capture de l'écran de chargement avec le nouveau logo.

---

## Séance 55 — 20 novembre 2026 · Corrections de sources sur les articles de fond

**Demandé**
- Compléter les articles avec des sources officielles plus larges et corriger les affirmations non vérifiées.

**Constaté et corrigé** (`PublicContentSeeder.php`)
- Président de la République : le mode d'élection était faux (« un seul tour, majorité relative »). Remplacé par le scrutin à deux tours et la majorité absolue des suffrages exprimés (Constitution 2016, titre III).
- Sénat et Conseil constitutionnel : composition réécrite d'après la Constitution 2016 et senat.ci.
- Anacarde : « premier producteur mondial », chiffres 2024–2025 et taux de transformation locale d'après bilan.gouv.ci.
- Port d'Abidjan : TC1 et TC2 (inauguré le 2 décembre 2022), trafic 2020–2025 d'après les publications du port et du ministère des Transports ; affirmations non sourcées retirées.
- Assemblée nationale : année de fondation (1959) et date des dernières élections (2021) retirées faute de source ; paragraphes sur le Parlement tirés de la Constitution 2016 (titre IV).

**Vérifié**
- `composer test` 149 verts (1869 assertions), `format:check` PASS après Pint sur le seul fichier modifié, `analyse` OK.

**Reste à faire**
- Articles minces (BRVM, parc national de Taï), 34 fiches de villes sans référence, 11 histoires, références de `article-enrichment.php`.

---

## Séance 56 — 21 novembre 2026 · Fiches de villes : neutralisation des affirmations non sourcées

**Demandé**
- Relire les 34 fiches de `database/data/cities.php` une par une et retirer les affirmations descriptives sans source.

**Fait**
- Chaque fiche ne garde que la position dans le pays, le statut administratif (chef-lieu de région ou de département), l'effectif RGPH 2021 et la répartition non détaillée.
- Retirés : histoire, peuplement et groupes de population, cultures et économie, pratiques culturelles, distances et durées de trajet, surnoms, chiffres du barrage de Soubré et de Buyo.
- Les sections « Relief et climat » et « Quartiers et équipements » restent fournies par `cities-details.php`, déjà neutres.

**Sources retenues**
- Effectifs : RGPH 2021, ANStat — <https://plan.gouv.ci/uploads/publications/RGPH2021-RESULTATS-GLOBAUX-VF.pdf>.
- Chefs-lieux de régions et de départements : décret n° 2011-263 du 28 septembre 2011 portant organisation du territoire national, annexe — <http://lexterra.ci/data/domaine/coll_terr/CT2/2011-09-28%20D2011-263%20D%C3%A9coupage%20r%C3%A9gional%20&%20districts.pdf>.
- Rattachement des localités aux régions et départements : répertoires des localités du RGPH 2021 par région — <https://rp2021.anstat.ci/>.

**Vérifié**
- `composer test` 149 verts (1869 assertions), `format:check` PASS (152 fichiers), `analyse` OK ; `pint` appliqué au seul fichier modifié.

**Reste à faire**
- Sourcer, si le propriétaire les vérifie, les éléments historiques et économiques retirés : histoire cacaoyère de Daloa, royaume sanwi d'Aboisso, poterie de Katiola, barrage de Buyo.
- Vérifier la position géographique des 34 villes sur les cartes administratives de l'ANStat (`rp2021.anstat.ci`), seule partie descriptive conservée sans référence explicite.

---

## Séance 57 — 21 novembre 2026 · Fiches de villes : géographie restaurée et formulations variées

**Demandé**
- Rétablir la géographie vérifiable des 34 fiches à partir des répertoires et cartes administratives, garder le neutre seulement là où rien n'est sourcé, varier les formulations.

**Fait**
- Chaque fiche nomme la région, son chef-lieu et la liste de ses départements, puis le statut de la ville (chef-lieu régional ou départemental), d'après l'annexe du décret n° 2011-263.
- Les intitulés et les tournures varient d'une fiche à l'autre (Situation, Géographie, Position, Statut administratif, Administration, Un chef-lieu de région) ; plus de gabarit unique.
- Méagui, Bonon : le statut de chef-lieu n'est pas affirmé, le décret de 2011 ne les retenant pas ; la fiche signale qu'une source à jour manque.
- Tonkpi, Marahoué, Nawa, Bélier : seuls les départements figurant au décret sont cités (pas de Sipilou, Bonon ou Djékanou ajoutés après 2011).

**Sources**
- Statuts et départements : décret n° 2011-263 du 28 septembre 2011, annexe — <http://lexterra.ci/data/domaine/coll_terr/CT2/2011-09-28%20D2011-263%20D%C3%A9coupage%20r%C3%A9gional%20&%20districts.pdf>.
- Effectifs communaux : RGPH 2021, ANStat — <https://plan.gouv.ci/uploads/publications/RGPH2021-RESULTATS-GLOBAUX-VF.pdf>.
- Contrôle des sous-préfectures : répertoires des localités RGPH 2021 (Tchologo, Agnéby-Tiassa) — <https://rp2021.anstat.ci/>.

**Limite de fraîcheur, assumée**
- 2021 reste le dernier dénombrement communal officiel. L'ANStat publie une estimation nationale à 32,8 millions d'habitants en 2025 (`Chiffres_Cles_CIV_2025.pdf`) et des projections 2022-2041 par département et sous-préfecture dans les 21 monographies régionales, mais aucune série communale récente n'est publiée : les fiches ne convertissent donc pas ces projections en chiffres de ville.
- Les répertoires `rp2021.anstat.ci` et l'API de l'ANStat renvoient 403 aux requêtes automatisées ; les monographies restent consultables une par une.

**Vérifié**
- `php -l` OK, `pint` appliqué puis `--test` OK, `CityArticlesTest` + `EnrichArticlesTest` 17 verts (241 assertions), `composer test` 149 verts, `format:check` PASS, `analyse` OK.

**Reste à faire**
- Récupérer une par une les 21 monographies pour porter les projections 2024-2025 au niveau du département et de la sous-préfecture, si le propriétaire accepte cette échelle.

---

## Séance 58 — 21 novembre 2026 · Fiches de villes : projections 2024-2025 et listes de départements à jour

**Demandé**
- Récupérer une par une les 21 monographies régionales de l'ANStat et ajouter, pour chaque ville, la projection 2024 et 2025 du département et de la sous-préfecture, en précisant qu'il s'agit d'une projection.
- Uniformiser les listes de départements : Taabo était cité alors que Bonon, Sipilou, Djékanou et Méagui avaient été écartés.

**Fait**
- Les 21 monographies ont été téléchargées depuis le site de l'ANStat et lues page par page (tableau 11.1, chapitre « Projections démographiques »).
- 32 fiches sur 34 portent désormais deux couples de chiffres : département puis sous-préfecture, pour 2024 et 2025. La sous-préfecture est présentée comme l'échelon qui englobe la commune, jamais comme un décompte de la ville, et le mot « projection » figure dans chaque paragraphe.
- Les tournures varient d'une fiche à l'autre (les projections donnent, dans ses projections, la projection place, pour 2024 et 2025, le département compterait, même exercice pour, même logique pour).
- Listes de départements alignées sur l'état actuel : Nawa à quatre (Soubré, Guéyo, Méagui, Buyo), Guémon à quatre (Duékoué, Bangolo, Facobly, Kouibly), Marahoué à cinq (Bouaflé, Sinfra, Zuénoula, Bonon, Gohitafla), Tonkpi à cinq (Man, Biankouma, Danané, Zouan-Hounien, Sipilou), Cavally à quatre (Guiglo, Bloléquin, Toulépleu, Taï), Bélier à quatre (Toumodi, Didiévi, Tiébissou, Djékanou).
- Méagui et Bonon ne sont plus décrites comme de simples sous-préfectures : les monographies les comptent parmi les départements de leur région.
- L'en-tête du fichier de données ne dit plus que les projections ne sont pas déclinées ; il rappelle qu'elles ne sont pas des dénombrements.

**Sources**
- Projections 2022-2041 par département et sous-préfecture : monographies régionales ANStat (RGPH 2021), chapitre 11, tableau 11.1 — <https://www.anstat.ci/publications-regionales>.
- Listes de départements : mêmes monographies, chapitre 1.
- Effectifs communaux : RGPH 2021, ANStat — <https://plan.gouv.ci/uploads/publications/RGPH2021-RESULTATS-GLOBAUX-VF.pdf>.

**Limite**
- La monographie de la Cavally est inaccessible : le fichier `File_val_indicateur_20260821150909_c2f00655b318d47b.pdf` renvoie 404 sur le site de l'ANStat, alors que sa fiche de publication est en ligne. Guiglo et Bloléquin ne portent donc que la projection régionale 2025 (806 262 habitants), sans détail par département ni par sous-préfecture.
- Le site renvoie 403 aux requêtes automatisées sans en-tête de navigateur ; les PDF ont été récupérés avec un profil de navigateur et lus hors ligne (les tableaux en paysage exigent une extraction par colonnes).

**Vérifié**
- `php -l` OK, `pint` appliqué puis `--test` OK, `CityArticlesTest` + `EnrichArticlesTest` 17 verts (241 assertions), `composer test` 149 verts (1 869 assertions), `format:check` PASS, `analyse` OK (0 erreur).
- Contrôle de structure : 34 fiches, 8 blocs chacune, donc 14 opérations après fusion avec `cities-details.php`.

**Reste à faire**
- Reprendre la Cavally dès que l'ANStat republie son PDF, pour aligner Guiglo et Bloléquin sur les autres fiches.

---

## Séance 59 — 21 novembre 2026 · Contrôle des tableaux en paysage et seconde tentative sur la Cavally

**Demandé**
- Relancer la récupération de la monographie de la Cavally pour compléter Guiglo et Bloléquin (département et sous-préfecture, 2024-2025).
- Vérifier dans les PDF d'origine les chiffres de Sikensi, de la Bagoué et du Bélier, reconstitués à partir des tableaux en paysage.

**Fait**
- Les trois monographies ont été relues en local : `pdftotext -table` pour les pages droites, puis extraction par coordonnées (pdf.js, axes remis à l'horizontale) pour les pages en paysage, qui portent deux tableaux superposés.
- Sikensi : département 134 650 (2024) puis 137 490 (2025) ; sous-préfecture 97 078 puis 99 074. Conforme aux fiches.
- Bagoué : département de Boundiali 218 634 puis 225 553, sous-préfecture 102 413 puis 105 602 ; département de Tengréla 157 031 puis 162 034, sous-préfecture 102 069 puis 105 320. Conforme aux fiches.
- Bélier : département de Toumodi 180 562 puis 184 413, sous-préfecture 94 749 puis 98 665. Conforme aux fiches.
- Contrôles arithmétiques dans les mêmes tableaux : chaque sous-préfecture retenue vérifie hommes + femmes = total, et la somme des départements redonne le total régional (Agnéby-Tiassa 2025 : 421 771 + 137 490 + 303 679 + 84 086 = 947 026 ; Bagoué 2025 : 225 553 + 162 034 + 199 360 = 586 947 ; Bélier 2024 : 180 562 + 124 434 + 100 451 + 39 810 = 445 257 ; Guémon 2024 : 296 034 + 458 538 + 158 429 + 103 809 = 1 016 810).
- Cavally : nouvelle tentative infructueuse. Le fichier `File_val_indicateur_20260821150909_c2f00655b318d47b.pdf` répond toujours 404, en HTTPS comme en HTTP, avec ou sans `www`, en variantes de casse, avec paramètre de cache et via les routes `publication/download`, `publication/file`, `publication/getFile`. Les quatre identifiants de fiche renvoyés par la recherche paginée pointent tous vers la même publication, et le site n'en connaît qu'une (« MONOGRAPHIE DE LA REGION DU CAVALLY », 18/08/2026). Aucun miroir trouvé ; l'archive Internet est injoignable depuis le poste.

**Conséquence**
- Aucune fiche n'est modifiée par cette séance : les 32 valeurs déjà publiées sont confirmées, et Guiglo comme Bloléquin restent à l'échelle régionale (806 262 habitants projetés en 2025) faute de tableau accessible.

**Vérifié**
- `php -l` OK, `composer test` 149 verts, `format:check` PASS, `analyse` 0 erreur.

---

## Séance 60 — 21 novembre 2026 · Projections 2024-2025 dans les six grands articles de villes

**Demandé**
- Étendre les projections 2024-2025 du département et de la sous-préfecture aux six articles déjà publiés dans `PublicContentSeeder` (Abidjan, Yamoussoukro, Bouaké, Korhogo, Man, San-Pédro), pour homogénéiser la série.
- Reformuler la phrase des fiches Guiglo et Bloléquin sur la Cavally pour qu'elle ne passe pas pour un choix éditorial.

**Fait**
- Six monographies supplémentaires ont été récupérées (Gbêkê, Poro, Tonkpi, San-Pédro, District autonome d'Abidjan, District autonome de Yamoussoukro) et lues au chapitre 11, tableau 11.1.
- Abidjan : district, qui forme le département, 6 865 306 habitants en 2024 puis 7 047 425 en 2025 ; les quatre sous-préfectures de la couronne (Anyama, Bingerville, Brofodoumé, Songon) réunies passent de 765 578 à 785 921 habitants. Le paragraphe précise que la ville-centre n'est pas isolée dans ces totaux, et la phrase qui annonçait « trois sous-préfectures » a été corrigée en quatre.
- Yamoussoukro : département 395 260 puis 402 596 ; sous-préfecture 360 828 puis 367 466.
- Bouaké : département 984 724 puis 1 001 707 ; sous-préfecture 879 084 puis 894 082.
- Korhogo : département 826 192 puis 852 647 ; sous-préfecture 487 298 puis 502 527.
- Man : département 501 118 puis 514 024 ; sous-préfecture 262 278 puis 268 807.
- San-Pédro : département 850 481 puis 870 575 ; sous-préfecture 420 326 puis 430 038. La phrase de clôture qui disait les perspectives « non détaillées, faute de source » a été retirée, puisqu'elles le sont désormais.
- Guiglo et Bloléquin : la phrase ne parle plus d'un détail « non repris ici » mais indique que seules les projections régionales sont publiées à ce jour pour la Cavally (806 262 habitants en 2025), le détail départemental et de sous-préfecture n'étant pas disponible.

**Sources**
- Monographies régionales ANStat (RGPH 2021), chapitre 11, tableau 11.1 — <https://www.anstat.ci/publications-regionales>.

**Vérifié**
- Contrôle de cohérence dans les tableaux : pour l'Abidjan, la somme des quatre sous-préfectures redonne 724 517 habitants en 2022, contre 724 518 cités par le commentaire de la monographie ; pour le Gbêkê, Bouaké 879 084 + Bounda, Brobo, Djebonoua et Mamini = 984 724 ; pour le Tonkpi, Man 262 278 + Podiaguiné et les autres sous-préfectures = 501 118.
- `php -l` OK sur les deux fichiers, `pint` appliqué puis `--test` OK, `composer test` 149 verts (1 869 assertions), `format:check` PASS, `analyse` 0 erreur.

---

## Séance 61 — 21 novembre 2026 · Monographies régionales en références des six grands articles

**Demandé**
- Ajouter la monographie régionale ANStat correspondante dans les références des six grands articles, pour que leurs projections 2024-2025 soient sourcées comme les chiffres du RGPH 2021.

**Fait**
- Chacun des six articles porte maintenant, dans son tableau `references`, une entrée `REPORT` d'auteur « ANStat (ex-INS) », d'éditeur « ANStat », avec le lien direct vers le PDF de sa monographie :
  - Abidjan — *Monographie du District autonome d'Abidjan — projections démographiques 2022-2041* (`File_val_indicateur1781527276.pdf`) ;
  - Yamoussoukro — *Monographie du District autonome de Yamoussoukro…* (`File_val_indicateur1767023430.pdf`) ;
  - Bouaké — *Monographie de la région du Gbêkê…* (`File_val_indicateur1767188731.pdf`) ;
  - Korhogo — *Monographie de la région du Poro…* (`File_val_indicateur1767628940.pdf`) ;
  - Man — *Monographie de la région du Tonkpi…* (`File_val_indicateur1767631604.pdf`) ;
  - San-Pédro — *Monographie de la région de San-Pédro…* (`File_val_indicateur1767630675.pdf`).
- Le champ `year` reste `null` : aucune des six monographies ne porte de date d'édition lisible (couvertures muettes), et l'horizon des tableaux (2022-2041) ne permet pas de la déduire. Les fiches de ville gardent leur référence unique au RGPH, inchangées.

**Vérifié**
- Les six URL répondent en HTTP 200 et leur `Content-Length` correspond exactement au PDF lu en séance 60 (17 895 379 ; 8 592 221 ; 12 514 542 ; 10 592 705 ; 10 027 135 ; 11 241 496 octets), donc la référence pointe bien sur le document dont sont tirées les projections.
- Répartition contrôlée dans le seeder : Abidjan et Yamoussoukro passent à quatre références, Bouaké, Korhogo, Man et San-Pédro à trois ; chaque URL de monographie n'apparaît que dans son article.
- `php -l` OK, `pint` appliqué puis `--test` OK, `composer test` 149 verts (1 927 assertions), `format:check` PASS, `analyse` 0 erreur.

**Reste**
- Rien sur ce point. La monographie de la Cavally demeure inaccessible (404), ce qui bloque toujours les projections départementales de Guiglo et Bloléquin.

---

## Blocages

**Aucun blocage.** L'API répond en HTTPS sur le compte dédié.

**Mailjet** n'est pas bloquant : `MAIL_MAILER=log` jusqu'à réception de la clé SMTP.

**Historique Git** : les commits antérieurs à la séance 5 contiennent les hôtes et noms de bases de l'ancien compte. La réécriture (`git filter-repo` + `push --force`) n'a pas été faite : destructive, elle attend une décision explicite.

---

## Travail restant détaillé

Voir le backlog ordonné dans `IVOIREPEDIA_CONTEXT.md` §14 (Sprint 0 à Sprint 5, puis V1).
