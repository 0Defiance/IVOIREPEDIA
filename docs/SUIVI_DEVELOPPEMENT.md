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

## Séance 62 — 21 novembre 2026 · Monographies régionales en références des fiches de villes

**Demandé**
- Ajouter la référence de la monographie régionale ANStat à chacune des fiches de `cities.php` qui utilisent ses projections, pour qu'elles soient sourcées comme les six grands articles, puis lancer les contrôles et commiter.

**Fait**
- Nouveau fichier de données `backend/database/data/cities-monographs.php` : vingt monographies régionales (titre + lien direct vers le PDF) et le rattachement des trente-quatre fiches à leur région, dans la logique des fichiers compagnons déjà utilisés par la série (`cities-details.php`).
- `CityArticleSeeder` ajoute désormais, après la référence du recensement, la monographie de la région de la fiche (`attachMonographReference`), en `REPORT`, auteur « ANStat (ex-INS) », éditeur « ANStat », position 2. L'ajout est idempotent et ne supprime aucune référence existante, y compris celles posées depuis `/admin`.
- Les trente-deux fiches qui portent des projections départementales et de sous-préfecture ont donc deux sources : le RGPH 2021 et la monographie régionale. Guiglo et Bloléquin restent à une source, faute de fichier publié pour la Cavally.
- En-tête de `cities.php` complété d'une phrase sur ce rattachement.

**Vérifié**
- Les trente-trois monographies listées par l'ANStat répondent en HTTP 200 ; seule celle de la Cavally renvoie 404, ce qui est la raison de l'exception Guiglo/Bloléquin.
- Contrôle du contenu dans les PDF téléchargés : le département de Soubré (622 918), celui de Gagnoa (775 499), celui de Divo (613 218) et celui de Bouaflé (321 835) y figurent bien aux dates citées, ce qui confirme que chaque lien pointe sur le document dont la fiche tire ses chiffres.
- Test ajouté dans `CityArticlesTest` : chaque fiche du rattachement porte l'URL de sa monographie, les fiches de la Cavally restent à une source, et la référence Daloa est bien un `REPORT` en position 2. Les trois tests qui figeaient le nombre de références (une seule) passent à deux, et à trois après ajout manuel.
- `php -l` OK sur les trois fichiers touchés, `pint` appliqué (153 fichiers) puis `--test` OK, `composer test` 150 verts (1 998 assertions), `format:check` PASS, `analyse` 0 erreur.

**Reste**
- La monographie de la Cavally (404) empêche toujours de sourcer les projections départementales de Guiglo et Bloléquin.

---

## Séance 63 — 21 novembre 2026 · Une seule table de monographies, et nouvelle tentative sur la Cavally

**Demandé**
- Faire prendre aux six grands articles leurs références de monographie dans `cities-monographs.php`.
- Réessayer de récupérer la monographie de la Cavally par une autre voie, pour compléter Guiglo et Bloléquin.
- Lancer les contrôles à la fin.

**Fait**
- `cities-monographs.php` porte maintenant les cinq monographies qui manquaient (Abidjan, Yamoussoukro, Gbêkê, Poro, San-Pédro) et une table `articles` qui rattache les six grands slugs à leur région.
- `PublicContentSeeder` lit ce fichier et ajoute la monographie de la région à la fin des références de l'article, au lieu de recopier le bloc dans les données du seeder ; les six entrées en dur ont été retirées. Les positions restent les mêmes qu'avant (dernière référence de l'article).
- Les deux seeders puisent donc dans la même table : une monographie a un seul titre et une seule URL dans tout le dépôt.

**Cavally — tentatives de la séance**
- La page de publication de l'ANStat liste toujours la monographie et un bouton « Télécharger », mais le fichier `File_val_indicateur_20260821150909_c2f00655b318d47b.pdf` renvoie 404, y compris sans `www`, en HTTP et depuis le portail `rp2021.anstat.ci`.
- Aucun instantané dans l'archive Wayback pour cette URL, et aucun miroir trouvé pour le nom de fichier exact.
- Le portail `rp2021.anstat.ci` (monographies et répertoires des localités) est protégé par un défi Cloudflare : la page ne se charge pas sans intervention humaine, et les fichiers `wp-content` devinés ne répondent pas.
- Conclusion : le document n'est plus servi par l'ANStat, et Guiglo et Bloléquin restent à une seule référence. Leur texte dit déjà que le détail départemental n'est pas disponible.

**Vérifié**
- Test ajouté dans `EnrichArticlesTest` : les six articles portent, après passage du seeder, la référence `REPORT` dont l'URL et le titre sont exactement ceux de leur région dans `cities-monographs.php`.
- `php -l` OK, `pint` appliqué (153 fichiers) puis `--test` OK, `composer test` 151 verts (2 017 assertions), `format:check` PASS, `analyse` 0 erreur.

**Reste**
- Guiglo et Bloléquin : projections départementales et de sous-préfecture toujours indisponibles, faute de fichier Cavally. À reprendre si l'ANStat republie la monographie.

---

## Séance 64 — 21 novembre 2026 · Refonte de la page d’accueil

**Demandé**
- Améliorer la présentation des sections du site, surtout la page d’accueil, avec un placement plus intelligent et professionnel.

**Fait**
- Nouveau fichier `app/lib/src/ui/home_sections.dart` : bandeau d’ouverture compact (marque, phrase, compteurs, menu unique des portails), sommaire-rail numéroté, mosaïque de une (article principal + deux secondaires), bande « Aujourd’hui dans l’histoire » fusionnée avec la frise, tuiles de régions avec barre de proportion, fil des publications en trois colonnes avec bandeau « Le saviez-vous ? », bande de tous les portails, poste de travail du lecteur (chiffre national, repères, outils).
- `home_page.dart` recomposé autour de ces sections ; les anciennes briques devenues inutiles sont supprimées (manchette centrée, barre de portails, boîte « Sommaire », cartes de régions, cartes d’articles, encart « article au hasard », bloc de chiffres). La page perd la triple redondance des catégories et gagne un écran de contenu.
- Ordre retenu : ouverture → sommaire-rail → une → histoire → régions → fil → récits → domaines → explorer → charte, avec la colonne de droite réduite à quatre blocs hiérarchisés.

**Vérifié**
- `flutter analyze` : aucun problème. `flutter test` : 56 tests verts, dont les tests de la page d’accueil réécrits pour la nouvelle composition (la une, le menu des portails, la bande histoire, le tirage au sort, le rendu téléphone sans débordement).
- Un débordement de 42 px du sommaire-rail sur téléphone a été trouvé par le test puis corrigé (libellés tronqués proprement).

**Reste**
- Le sommaire n’est pas encore « collant » au défilement : l’enveloppe `SiteShell` possède son propre `SingleChildScrollView`, il faudrait la passer en `CustomScrollView` pour épingler la barre. À faire si le besoin se confirme à l’usage.

---

## Séance 65 — 21 novembre 2026 · Chargement de la page d’accueil

**Demandé**
- La page d’accueil met trop de temps à s’afficher ; réduire ce délai.

**Mesuré avant**
- Images de couverture : les neuf articles de la une demandaient tous la variante 1280 px de Wikimedia, soit **3,8 Mo** pour sept fichiers mesurés (dont un PNG de 1,7 Mo). Aucune n’était redimensionnée au décodage.
- Données : la page attendait **tous** les appels (articles, catégories, frise, chiffres, récits, sources) avant de peindre quoi que ce soit, alors que la une suffit à lire.
- API locale : `/statistics` 2,3 s et `/articles` 2,8 s à chaque appel (base MySQL distante, cache `database`). `/health` seul coûte déjà 0,7 s : c’est le plancher de démarrage.

**Fait**
- `widgets/article_image.dart` : les couvertures demandent désormais la largeur réellement affichée, en paliers servis par Wikimedia (**250, 500, 960, 1280** — les largeurs arbitraires répondent 400). Décodage limité par `cacheWidth`. Si une variante manque, `_Cover` se rabat sur l’image d’origine au lieu de laisser un cadre vide.
- `home_page.dart` : chargement en deux temps. La une et les catégories peignent la page ; frise, chiffres, récits et bibliothèque la complètent ensuite, sans bloquer la lecture. Tous les appels partent ensemble : le second temps ne coûte que la requête la plus lente.
- `ArticleController::index` : la liste publique est mise en cache deux minutes, avec une clé de version (`Article::cacheGeneration`) incrémentée à chaque écriture d’article — pas de contenu périmé après publication.
- Cache local passé de `database` à `file` dans `.env` (non versionné) : le cache ne dépend plus de la base distante.

**Résultat mesuré**
- `/articles?limit=9` : 2,76 s → **0,67 s** en cache chaud. `/statistics` : 5,9 s à froid, **0,70 s** ensuite, soit le plancher de démarrage de l’API.
- Images de la une : **3,8 Mo → 0,7 Mo** pour sept fichiers en 500 px, la grande illustration passant à 960 px (1,0 Mo au lieu de 1,7 Mo).

**Vérifié**
- `flutter analyze` : aucun problème. `flutter test` : 56 tests verts.
- `composer test` : 151 tests verts (2 017 assertions) ; `format:check` et `analyse` verts.
- Le rendu réel n’a pas été inspecté dans un navigateur et le délai n’a pas été chronométré à l’écran : les gains ci-dessus sont mesurés sur l’API et sur les fichiers d’images.

---

## Séance 66 — 21 novembre 2026 · Accueil éditorial : manchette chiffrée, cartes et couleurs

**Demandé**
- La présentation issue de la séance 64 est jugée trop minimaliste ; obtenir une page d’accueil plus concrète et plus intéressante.

**Fait**
- Manchette en deux parties : à gauche la marque, le titre « La Côte d’Ivoire, racontée et sourcée », le chapô et les trois compteurs (pages, domaines, sources) ; à droite la carte d’identité du pays sur fond vert profond (population, tendance annuelle, régions, districts, recensement, lien vers les statistiques). La bande tissée ouvre le bloc, un accès unique aux portails le referme.
- La une devient une vraie mosaïque : article principal avec photo pleine largeur, étiquette « À la une » posée sur l’image, étiquette de domaine, signature et bouton d’action ; deux entrées secondaires numérotées, illustrées, encadrées.
- « Aujourd’hui dans l’histoire » passe sur une bande sombre : l’année en or, l’âge du jalon, le récit, puis la frise en cartes sur fond translucide.
- Les régions deviennent un classement : la première carte passe sur fond vert, les suivantes sur des fiches claires, toutes avec rang, effectif et barre de proportion.
- Les portails deviennent des cartes à pictogramme et couleur propres à chaque domaine (histoire, géographie, personnalités, institutions, langues, culture, économie, patrimoine), avec le nombre de pages et la part du corpus.
- Colonne de droite : « Repères nationaux » sur fond sombre (PIB, espérance de vie, alphabétisation, territoires, chronologie, pages publiées) au lieu du seul chiffre de population, déjà présent dans la manchette ; bibliothèque des sources avec son compteur en grand ; encarts réordonnés.
- Toutes les sections reprennent un en-tête commun (filet d’accent orange, titre, filet tissé) ; le fil, les récits, les outils et la charte passent en cartes bordées, avec survol coloré. Les titres, libellés et parcours existants sont conservés (sommaire, ancres, tirages, liens).
- Deuxième passe sur la même séance : l’ouverture devient une **couverture** sur fond vert profond, avec la mosaïque de quatre photos d’articles (domaine et titre sur voile sombre) et une bande de chiffres en pied (population, régions, districts, pages, domaines, sources). Les sections « régions », « récits » et « portails » sont posées sur des bandes teintées (sable, surligné) pour alterner les fonds.
- Le fil ne répète plus les articles de la une : celle-ci garde l’article principal et deux secondaires, le fil prend les suivants, « le saviez-vous » ferme le corpus ; sur un corpus court, les deux sections se rabattent sur ce qui existe.
- Troisième passe : la couverture devient une **photo pleine largeur** (celle de l’article de une), sous un voile qui laisse voir l’image en haut et porter le titre en bas en 44 px ; étiquette « LA UNE », domaine, chapô, bouton plaque d’or, chiffres du pays en encart translucide et mention de licence. Le sommaire de la une passe en trois fiches illustrées numérotées. Répartition sans doublon : couverture = article 1, une = 2 à 4, fil = 5 à 8, « le saviez-vous » = les deux suivants (douze articles chargés au lieu de neuf).

**Vérifié**
- `flutter analyze` : aucun problème. `flutter test` : 56 tests verts, y compris le rendu téléphone 390 px et le grand écran 1280 px (aucun débordement), le sommaire, la frise et les cartes de régions.
- Trois débordements apparus pendant la refonte ont été corrigés : en-tête de la carte pays, pied des cartes de portails, et la phrase de manchette qui porte « L’encyclopédie de la Côte d’Ivoire » (attendu par le test d’accueil).

**Reste**
- Le rendu n’a pas été regardé dans un navigateur : l’aperçu local reste bloqué par le démarrage du serveur Flutter web (voir séance 64), et les tests de widgets rendent avec la police de test, pas avec Inter. À vérifier à l’écran avant une mise en production.
- Les descriptions de domaines sont vides en base : les cartes de portails affichent le nombre de pages et la part du corpus, sans texte inventé. Une description par catégorie permettrait d’enrichir la carte.

---

## Séance 67 — 21 novembre 2026 · Manchette au sommet, en-tête escamotable et une tirée au sort

**Demandé**
- Voir en haut de l’accueil la manchette de marque (signature complète, promesse, nombres d’articles et de domaines, plan des domaines) avant la couverture photo.
- Masquer la barre du site au sommet de l’accueil ; la faire revenir dès qu’on défile, et la garder sur toutes les autres pages.
- Tirer la une au hasard, parmi des articles dont la photo montre un lieu ou une fierté culturelle du pays.

**Fait**
- Nouvelle manchette `HomeMasthead` en tête de l’accueil : signature complète centrée (460 px), promesse en une phrase, ligne « 51 articles · 8 domaines · Chaque article cite ses sources », puis un rail de domaines bordé haut et bas — nom du portail dans sa couleur, nombre de pages en gris, séparateurs verticaux. Les compteurs viennent de l’API ; sur téléphone le rail défile au doigt.
- `SiteShell` reçoit `immersiveHeader` : sur l’accueil, l’en-tête s’efface au sommet et revient en 220 ms dès quatre pixels de défilement ; ailleurs il reste affiché. Le tiroir de navigation reste accessible dès que la barre revient.
- La couverture ne répète plus la marque : la plaque du logo cède la place à « ÉDITION DU 21 NOVEMBRE 2026 » à gauche, l’étiquette « LA UNE » restant à droite.
- Tirage de la visite (`_shuffledForHome`) : les articles illustrés de géographie, patrimoine ou culture sont mélangés, le premier ouvre la couverture, tout le reste est rebattu — la une, le fil et « le saviez-vous » changent à chaque visite sans se répéter. Un corpus sans photo garde l’ordre de l’API (et les tests restent déterministes).
- Vingt articles sont chargés au lieu de douze, pour élargir le tirage de la couverture.

**Vérifié**
- `flutter analyze` : aucun problème. `flutter test` : 56 tests verts ; le test d’accueil vérifie désormais la signature de la manchette et les deux entrées « Portails » (rail de la manchette et menu de la couverture).
- Aperçu local relu à l’écran : au sommet, aucune barre de site et la manchette complète ; après défilement, la barre revient avec logo, recherche et compte ; la couverture affiche une photo de ville tirée au sort (Yamoussoukro sur le contrôle).

**Reste**
- La qualité des photos varie selon les fichiers Wikimedia (ciel voilé sur le panorama de Yamoussoukro) ; le tirage ne peut pas juger la lumière d’une image.
- Le rail des domaines tient sur une ligne en grand écran, mais défile horizontalement en dessous de 1 000 px : la fin de la liste est atteignable au doigt ou à la molette horizontale, sans indice visuel de débordement.

---

## Séance 68 — 21 novembre 2026 · Indice de défilement du rail et couverture privilégiée

**Demandé**
- Signaler le débordement du rail des domaines sur petit écran par un dégradé et un chevron à droite.
- Privilégier pour la couverture les photos les plus larges et nettes (zaouli, Grand-Bassam, Man, Korhogo), puis relancer les contrôles et commiter.

**Fait**
- Le rail de la manchette devient `_MastheadPortalRail` : quand la suite est hors écran, un dégradé partant du sable et un chevron dans une pastille apparaissent à droite ; le chevron avance le rail de 180 px, et l’indice s’efface une fois le dernier portail atteint, pour ne jamais masquer un lien.
- `_coverFavourites` retient quatre photos larges et nettes — `le-zaouli`, `grand-bassam`, `man`, `korhogo`. Le tirage les mélange et en sert une en priorité ; les autres photos de géographie, de patrimoine ou de culture prennent le relais, puis le corpus illustré.
- L’accueil charge tout le corpus publié (première page, puis les suivantes en parallèle) au lieu des seuls vingt derniers articles : sans cela le zaouli (37e) et Grand-Bassam (43e) n’entraient jamais dans le tirage. Une page en panne laisse le tirage sur ce qui est déjà chargé.
- Les parcours d’authentification et du pied de page ont été adaptés à la barre masquée au sommet de l’accueil : ces tests font revenir la barre par un défilement avant de viser le compte ou un lien de pied de page, comme le ferait un lecteur.

**Vérifié**
- `flutter analyze` : aucun problème. `flutter test` : 58 tests verts, dont le nouveau test du rail (chevron et dégradé présents en 390 px, absents en 1280 px) et celui de la couverture (le zaouli, servi en deuxième page, ouvre la une).
- La suite complète a été relancée : douze tests étaient rouges depuis la séance 67 (barre masquée au sommet de l’accueil, jamais retestée sur toute la suite) ; ils repassent tous.

**Reste**
- Le rendu du dégradé et du chevron n’a pas été relu dans un navigateur : à regarder à l’écran avant une mise en production.
- Les photos de couverture préférées sont désignées par leur slug : toute nouvelle photo de premier plan demande d’allonger la liste, faute de dimensions dans l’API.

---

## Séance 69 — 21 novembre 2026 · Seuls les candidats de la couverture sont téléchargés

**Demandé**
- Ne plus télécharger tout le corpus pour choisir la couverture, la page de garde étant déjà signalée comme lente.
- Vérifier le rendu du dégradé et du chevron du rail dans un navigateur, à 390 px.

**Fait**
- `GET /api/v1/articles` accepte `slugs=` (liste séparée par des virgules, validée, plafonnée à 20) : la liste publique renvoie exactement les articles nommés, sans parcourir le corpus.
- L’accueil fait deux petits appels au lieu des trois pages du corpus : les vingt derniers articles, puis les quatre candidats (`?slugs=le-zaouli,grand-bassam,man,korhogo`, 3 Ko en tout). La page de garde ne télécharge donc plus les 51 résumés pour choisir une photo.
- Les faux API des tests acceptent `slugs` ; le test de couverture vérifie qu’une seule requête de slugs part, celle des favoris, et que le zaouli, absent de la première page, ouvre la une.

**Vérifié**
- `flutter analyze` : aucun problème. `flutter test` : 58 tests verts.
- Backend : `php artisan test --filter=PublicReadingTest` — 10 tests verts, dont le filtre par slugs et le refus d’une liste mal formée.
- Navigateur, 390 × 844, application réelle servie par `flutter run -d web-server` sur l’API locale : le rail déborde bien, la fin du libellé s’efface sous le dégradé et le chevron apparaît dans sa pastille. Capture : `screenshot-rail-390.png`.

**Reste**
- Le backend doit être déployé pour que cette version de l’app fonctionne : un serveur qui ignore `?slugs` renvoie la première page, et la couverture retombe alors sur les articles récents, sans erreur.

---

## Séance 70 — 22 novembre 2026 · Couverture en 960 px, refonte de l’accueil et index alphabétique

**Demandé**
- La photo de couverture domine le temps de chargement : demander les photos en plus petit (800 px) et réécrire les URL d’origine en URL de vignette, avec un test sur `sizedCoverUrl`, puis re-mesurer les quatre photos.
- Refonte globale du rendu visuel, sans rien changer de l’identité (palette, Inter, parcours) ; ajouter les fonctionnalités classiques d’une encyclopédie, à partir de ce qui existe déjà.

**Fait**
- `sizedCoverUrl` réécrit : une URL d’origine (`upload.wikimedia.org/…/a/b/Fichier.jpg`) devient une URL de vignette (`thumb.wikimedia.org/…/thumb/a/b/Fichier.jpg/960px-Fichier.jpg`), les caractères encodés du nom étant conservés. Les URL étrangères à Wikimedia et les chaînes vides restent intactes.
- La couverture demande **960 px au lieu de 1280** (image et décodage). Wikimedia répond **400 à 800 px** — vérifié sur les quatre photos le 22/11/2026 : 800 px n’est pas un palier servi (320, 640, 768 et 1024 répondent aussi 400) ; 960 px est le plus petit palier au-dessus, et `Special:FilePath?width=800` y aboutit de la même façon.
- Refonte de l’accueil (parcours, libellés et routes inchangés) : manchette plus lisible (signature agrandie, chapeau en 15,5 px), couverture plus haute et plus arrondie (titre 46 px, crédit photo « Photo : auteur — licence » en pied, comme une encyclopédie), titres de rubriques en 21 px avec filet tissé allongé, cartes à coins 14 px avec ombre au survol, hauteur d’image du fil portée à 148 px, descriptions des portails affichées quand elles existent, rayon des cartes du thème aligné (14 px).
- Nouvelle fonctionnalité d’encyclopédie : **Index de A à Z** (`HomeAlphaIndex`) — vingt-six initiales qui ouvrent `/recherche?q=<lettre>`, comme l’entrée d’une encyclopédie imprimée ; l’entrée « Index de A à Z » rejoint le sommaire de l’accueil et son ancre de défilement.

**Vérifié**
- `flutter analyze` : aucun problème. `flutter test` : **67 tests verts** (8 nouveaux sur `sizedCoverUrl`/`coverWidthFor`, 1 sur l’index A→Z qui ouvre `/recherche?q=K`, dont le rendu 390 px sans débordement).
- Re-mesure des quatre photos à 960 px (en-têtes réels, `curl`) : Korhogo 506 → **288 Ko** (7,1 → 2,1 s), Man 403 → **238 Ko** (3,4 → 1,6 s), Grand-Bassam 259 → **152 Ko** (2,0 → 1,0 s). **Le Zaouli régresse** : 127 → **312 Ko** (2,2 → 1,8 s en temps, mais plus d’octets) — son original ne fait que 681 px de large, Wikimedia agrandit la variante 960 px au lieu de la réduire. Poids moyens : 324 → 247 Ko (−24 %), pire temps : 7,1 → 2,1 s.

**Reste**
- Le Zaouli montre la limite de la réécriture côté client : sans danger de dimensions dans l’API, on ne sait pas si l’original est déjà petit. La correction propre est côté API : servir l’URL de vignette et la largeur d’origine avec chaque résumé.
- Le contrôle visuel dans le navigateur n’a pas abouti : l’onglet n’est pas dessiné tant que la fenêtre Freebuff est réduite (capture impossible). Le rendu 390 px est couvert par les tests de widgets ; il reste à relire à l’écran avant mise en production.
- Les serveurs de vérification restent actifs : `flutter run -d web-server` sur `127.0.0.1:8090`, `php artisan serve` sur `127.0.0.1:8000`.

---

## Séance 71 — 23 novembre 2026 · Bande « Le saviez-vous ? », biographies et vignette du Zaouli

**Demandé**
- Mettre en évidence la section « Le saviez-vous ? ».
- Intégrer les biographies et bibliographies, si possible, des cent personnalités de l’histoire de la Côte d’Ivoire par domaine (politiques, écrivains, sportifs, artistes…).
- Corriger la régression du Zaouli (vignette de 312 Ko servie pour un original de 681 px) en servant la vignette et la largeur d’origine depuis l’API.
- Vérifier l’accueil refondu en capture à 390 px et en desktop.

**Fait**
- **« Le saviez-vous ? » sort du fil** : la bande devient `HomeFactBand`, un bloc autonome (carte dorée, titre de rubrique, filet tissé) placé **juste après la une**, avant « Aujourd’hui dans l’histoire », les régions et le fil, avec sa propre entrée « Le saviez-vous ? » en deuxième position du sommaire et son ancre de défilement. `HomeFeed` ne porte plus les faits.
- **Biographies vérifiées** : `database/data/personalities.php` réunit **38 fiches** (10 politiques, 10 écrivains, 10 sportifs, 8 artistes) avec naissance, repères biographiques, bibliographie ou œuvres quand elles existent et sources citées. `PersonalitiesSeeder` est idempotent, rattache les fiches à la catégorie « personnalités », les tague `biographies-politiciens`, `biographies-ecrivains`, `biographies-sportifs` ou `biographies-artistes`, et les publie par vagues de deux jours pour qu’elles n’écrasent pas la une. La base de développement compte désormais **89 articles publiés, dont 47 biographies**.
- **Le Zaouli servi par l’API** : migration `add_cover_image_width_to_articles` (colonne `cover_image_width`, remplie par backfill : zaouli 681, grand-bassam 3840, man 4424, korhogo 4624) ; `ArticleSummaryResource` sert `cover_image_width` et `cover_image_thumb_url` ; l’app choisit le plus grand palier Wikimedia ≤ min(960, largeur d’origine) — 500 px pour le Zaouli — et `sizedCoverUrl(..., originalWidth:)` ne dépasse jamais l’original. `AttachArticleImages` enregistre la largeur à l’import.
- **Cartes sans photo** : ni la carte verticale du fil (148 px) ni la ligne de « La une » (vignette 112 × 128) n’ouvrent plus un cadre vide avec icône ; une fiche de biographie sans portrait garde son rythme avec un filet dégradé à la couleur de son domaine (3 px).
- **Position corrigée** : la bande était restée sous le fil ; elle passe maintenant **juste après la une**, avant la frise, les régions et le fil, et le sommaire la numérote « 02 Le saviez-vous ? ». Le test d’accueil vérifie l’ordre (bande sous la une, au-dessus du fil) ; le parcours de sommaire à 1280 × 1000 ramène d’abord l’entrée du rail à l’écran, puisqu’elle tombe désormais sur une deuxième ligne.
- **Bandeau d’édition** : en mode étroit, la date est abrégée (`formatDateShort` → « 23 NOV. 2026 ») et la ligne d’édition reçoit toute la largeur restante (le `Spacer` la coupait en deux, « ÉDITION DU 23 N… »).

**Vérifié**
- `GET /api/v1/articles?slugs=le-zaouli` : `cover_image_width: 681` et `cover_image_thumb_url: …/500px-Cizaouli.jpg` ; le navigateur charge le Korhogo en 960 px et le Man en 500 px.
- `flutter analyze` : aucun problème. `flutter test` : **70 tests verts**. `flutter build web --release` : construit.
- Backend : `composer test` **159 tests verts** (2 381 assertions), `composer format:check` 157 fichiers conformes, `composer analyse` aucun problème.
- Navigateur, 390 × 844, bundle release servi par `php -S 127.0.0.1:8090` sur l’API locale : le libellé « ÉDITION DU 23 NOV. 2026 » tient sur une ligne, la couverture Zaouli demande bien `thumb.wikimedia.org/…/500px-Cizaouli.jpg` ; les lignes de biographies de « La une » n’affichent plus de cadre vide. Capture : `screenshot-s71d-390-accueil.png`.
- Bande « Le saviez-vous ? » vue à 390 px : elle s’ouvre immédiatement après la troisième fiche de « La une » (Paco Séry), avec ses deux cartes (Simone Gbagbo, Murielle Ahouré) sourcées « Dans Personnalités ». Capture : `screenshot-s71e-390-saviez-band.png` ; le sommaire porte « 02 Le saviez-vous ? » juste après « 01 La une ».

**Reste**
- Le canevas Flutter ignore la molette de l’outil de prévisualisation (geste synthétique) : les captures plus bas dans la page s’obtiennent en envoyant un `WheelEvent` sur `flt-glass-pane` depuis la console du navigateur.
- Le contrôle desktop n’a pas abouti : la fenêtre du navigateur de prévisualisation ne fait qu’environ 486 px de large, un rendu 1440 px y est rogné. Le rendu 390 px et les 70 tests couvrent le cas étroit ; une capture desktop reste à faire sur une fenêtre plus large.
- Les 38 fiches sont une tranche vérifiée, pas les 400 annoncées : la structure (tags par groupe, bibliographie, sources) permet de monter à 100 par domaine sans changer le code.
- ~~La production sert encore l’ancien bundle~~ : mise en ligne faite le 23 novembre 2026 (séance 72) — migration `cover_image_width` appliquée, bundle et API au niveau du commit `94d58c6`.

---

## Séance 72 — 23 novembre 2026 · Migration `cover_image_width` et mise en ligne

**Demandé**
- Appliquer la migration `cover_image_width` en production, déployer le nouveau bundle, puis vérifier l’accueil et la vignette du Zaouli sur le site en ligne.

**Fait**
- **Serveur** : `git pull --ff-only` dans `~/ivoirepedia` (`c87049c` → `94d58c6`, 25 commits), `composer install --no-dev --optimize-autoloader` (dépendances inchangées depuis `c87049c`), `php artisan migrate --force` → `2026_11_22_000001_add_cover_image_width_to_articles` appliquée en 35 ms, aucune migration « Pending » ; caches `config`, `route` et `view` reconstruits.
- **Bundle** : build de production pris sur un arbre propre au commit `94d58c6` — les reformatages `dart format` non commités ont été mis de côté (`git stash`) puis restaurés après l’envoi, pour ne pas livrer un code absent du dépôt. Commande : `flutter build web --release --base-href=/ --dart-define=API_BASE_URL=/api/v1`, puis `python ../tools/precompress_web.py build/web` (33,3 Mo → 10,1 Mo, 69,8 % de moins) et envoi par `tar` dans `~/ivoirepedia/backend/public`. Le `.htaccess` de Laravel, versionné, est resté en place.

**Vérifié**
- `python ../tools/verify_deploy.py` : page d’accueil `200`, `main.dart.js` et `main.dart.js_1.part.js` servis en `br` et identiques aux originaux après décompression, `canvaskit.wasm` idem, `logo.webp` non compressé — « Tout est bon ».
- API de production : `/api/v1/health` → `{"status":"ok"}` ; `GET /api/v1/articles?slugs=le-zaouli` → `cover_image_width: 681` et `cover_image_thumb_url: …/500px-Cizaouli.jpg`.
- Navigateur, 390 px, onglet incognito sur `https://ivoirepedia.alwaysdata.net/` : aucune erreur CORS (l’app appelle `/api/v1` sur la même origine), 85 articles, couverture « Man » avec sa photo et la mention « Photo : Sahi Tia — CC BY-SA 4.0 », sommaire numéroté « 01 La une · 02 Le saviez-vous ? ». Capture : `screenshot-prod-390-accueil-c.png`.
- Fiche `/articles/le-zaouli` : l’image s’affiche avec sa ligne de crédit. Le navigateur ne demande que l’original `upload.wikimedia.org/…/Cizaouli.jpg` (127 207 o) : la largeur visée (960) dépasse l’original (681), donc `sizedCoverUrl` renvoie le fichier source, plus léger que la vignette de 500 px (144 394 o). Aucune variante 960/1210 px n’est plus demandée. Capture : `screenshot-prod-390-zaouli-b.png`.

**Reste**
- ~~Sur une première visite (cache vide), la photo de couverture s’est peinte une vingtaine de secondes après le reste de la page~~ : mesuré et corrigé en séance 73 (polices préchargées et précompressées).
- Le contrôle desktop et la capture de la bande « Le saviez-vous ? » n’ont été faits qu’en local (séance 71) : la fenêtre de prévisualisation ne dépasse pas ~486 px.

---

## Séance 73 — 23 novembre 2026 · Démarrage à froid et biographies en ligne

**Demandé**
- Appliquer le correctif du démarrage à froid (polices Inter en brotli + préchargement dans `index.html`), mesurer le gain sur une visite à cache vide.
- Publier les biographies en production et vérifier qu’elles sont visibles sur le site.

**Fait**
- **Polices précompressées** : `tools/precompress_web.py` traite aussi les `.ttf` (les `.otf` d’icônes restent dehors, ils font 14 Ko et se revalident à chaque visite) ; `backend/public/.htaccess` réécrit `Inter-*.ttf` vers `…ttf.br` quand le navigateur annonce `br`, avec `Content-Encoding br`, `Content-Type font/ttf` et un jour de cache. Mesure au déploiement : 324 820 + 326 048 + 326 468 o → 122 540 + 126 118 + 126 019 o, soit **977 336 → 374 677 o (954 → 366 Ko)**.
- **Préchargement** : `app/web/index.html` annonce les trois graisses (`<link rel="preload" as="fetch" crossorigin="anonymous" fetchpriority="high">`) avant toute autre chose, pour qu’elles descendent **avec** `main.dart.js` au lieu d’attendre que le moteur les réclame. Sans `crossorigin`, Chrome téléchargeait la police puis la redemandait (« credentials mode does not match ») ; avec, aucune requête en double et aucun avertissement de console.
- **Biographies en production** : `php artisan db:seed --class=PersonalitiesSeeder --force` sur `ivoirepedia_prod` (2,4 s, idempotent). La base passe de **85 à 123 articles publiés**, dont **38 biographies** (10 politiques, 10 écrivains, 10 sportifs, 8 artistes) ; la catégorie « personnalités » compte 47 pages avec celles qui existaient déjà.

**Vérifié**
- **Avant**, cache vide (partition incognito neuve, 390 × 844) : `main.dart.js` 2,6 → 19,6 s (683 Ko br), `canvaskit.wasm` 2,8 → 9,2 s, **polices 20,4 → 27,7 s** (957 Ko non compressés, demandées seulement après le JS), API 28,0 → 31,0 s.
- **Après**, même protocole : polices **0,4 → 2,4 s / 2,4 s / 11,9 s** (122-123 Ko br chacune, démarrées avec le JS), `main.dart.js` 0,4 → 5,2 s, `canvaskit.wasm` 0,6 → 10,4 s, API **13,5 → 18,1 s**. Les polices ne sont plus sur le chemin critique et les premiers appels API partent une quinzaine de secondes plus tôt ; aucune requête de police en double, console propre.
- `python ../tools/verify_deploy.py` : page, `main.dart.js`, `main.dart.js_1.part.js`, `canvaskit.wasm` servis en `br` et identiques aux originaux — « Tout est bon » ; `curl` sur les trois `Inter-*.ttf` : `content-encoding: br`, 122-126 Ko.
- Site : `GET /api/v1/articles?page=1&limit=20` renvoie 123 articles et les vingt plus récents sont des biographies (Ernesto Djédjé, Yaya Touré, Bernard Dadier, Tidjane Thiam, Tiken Jah Fakoly…), donc elles occupent « La une » et le fil ; fiche `ernesto-djedje` : étiquette `biographies-artistes`, infobox complète, 5 blocs de contenu, 1 référence ; la page pré-rendue servie aux robots porte `<title>Ernesto Djédjé — IVOIREPEDIA` et le `<h1>`.
- Captures de production à 390 px : l’accueil annonce **123 pages** et « La une » s’ouvre sur une biographie (« DJ Arafat — Personnalités »), la bande « Le saviez-vous ? » venant juste après. Fichiers : `screenshot-prod-390-bios-2.png` et `screenshot-prod-390-bios-4.png`.

**Reste**
- Le bundle a été construit depuis l’arbre de travail, qui porte encore les reformatages `dart format` non commités de la séance 71 (mise en page seulement, aucun changement de comportement) ; un build depuis un `HEAD` propre reste à faire si l’on veut un artefact strictement identique au dépôt.
- Les 38 fiches restent une tranche : il en faudra 100 par groupe pour tenir la promesse initiale.

---

## Séance 74 — 23 novembre 2026 · Extension des biographies politiques

**Demandé**
- Reprendre l’extension des biographies vers 100 par domaine, en commençant par les politiques, avec la même exigence de sources que les 38 fiches déjà en ligne.
- Publier les nouvelles fiches en production et vérifier qu’elles s’affichent.

**Fait**
- **23 fiches politiques ajoutées** à `database/data/personalities.php` : Guillaume Soro, Pascal Affi N’Guessan, Seydou Diarra, Jeannot Ahoussou-Kouadio, Hamed Bakayoko, Patrick Achi, Robert Beugré Mambé, Kandia Camara, Charles Blé Goudé, Djéni Kobina, Jean Konan Banny, Jean-Baptiste Mockey, Philippe Yacé, Adama Bictogo, Ally Coulibaly, Vagondo Diomandé, Souleymane Diarrassouba, Louis-André Dacoury-Tabley, Aboudramane Sangaré, Maurice Bandaman, Laurent Dona Fologo, Marcel Zadi Kessy et Youssouf Bakayoko. Le groupe politiques passe de **10 à 33 fiches** ; l’ensemble compte **61 biographies** (33 politiques, 10 écrivains, 10 sportifs, 8 artistes).
- Chaque fiche suit le format existant : résumé d’une phrase, deux sections et trois paragraphes, infobox `BIOGRAPHY`, bibliographie. Les dates, lieux et mandats ont été recoupés sur la notice Wikipédia citée ; les sept Premiers ministres citent en plus la liste officielle des anciens chefs de gouvernement de la Primature.
- Aucune figure déjà traitée n’est dupliquée : Henri Konan Bédié, Laurent Gbagbo, Alassane Ouattara et Robert Guéï ont déjà leur article dans `PublicContentSeeder` (slugs `henri-konan-bedie`, `laurent-gbagbo`, `alassane-ouattara`, `robert-guei`), hors série des `biographies-politiciens`.
- Le seeder reste idempotent : relancé, il met à jour les fiches par leur slug sans créer de doublon.
- Documentation du fichier de données mise à jour (tranche politiques 10 → 33, séance 74).

**Vérifié**
- `php -l database/data/personalities.php` : aucune erreur ; compteurs du fichier **33 / 10 / 10 / 8**, **61 slugs uniques**, aucun doublon.
- Backend : `composer test` **159 tests verts (2 588 assertions)**, `composer format:check` **157 fichiers conformes** (une correction Pint `single_quote` sur le fichier de données), `composer analyse` aucun problème.
- App : `flutter analyze` aucun problème, `flutter test` **70 tests verts** (aucun code Flutter modifié).
- Production : `git pull --ff-only` (`8dc1b7c` → `0617dcc`), `php artisan db:seed --class=PersonalitiesSeeder --force` en **893 ms**. L’API passe de **123 à 146 articles publiés** ; la catégorie « personnalités » de **47 à 70 pages** ; le tag `biographies-politiciens` renvoie **33 articles**.
- Fiches servies par l’API avec `type_label: Biographie`, l’étiquette « Biographies : Politiques », leur infobox et 1 à 2 références : `guillaume-soro`, `kandia-camara`, `patrick-achi`, `marcel-zadi-kessy`, `youssouf-bakayoko`.
- Pages pré-rendues : `GET /articles/guillaume-soro`, `/articles/kandia-camara` et `/articles/marcel-zadi-kessy` → **200**, `<title>… — IVOIREPEDIA` avec le nom de la fiche.
- Rendu réel à 390 × 844 sur `https://ivoirepedia.alwaysdata.net/articles/guillaume-soro` : en-tête « Personnalités · Biographie », titre, sommaire à deux entrées et infobox visibles. Capture : `screenshot-prod-390-s74-soro.png`.

**Reste**
- Les politiques sont à **33/100** : les tranches suivantes peuvent puiser dans les ministres, députés, maires et présidents de conseils régionaux déjà catégorisés sur Wikipédia, en gardant la même vérification fiche par fiche.
- Les écrivains (10), sportifs (10) et artistes (8) restent à leur première tranche ; la structure par étiquettes permet de les étendre sans changer le seeder.
- Le build web n’a pas été refait : cette séance ne touche que des données lues par l’API, déjà servies par le bundle en ligne.

---

## Séance 75 — 23 novembre 2026 · Ministres, députés et maires

**Demandé**
- Poursuivre l’extension des biographies politiques (ministres, députés, maires) vers 100, avec la même exigence de sources.
- Publier cette tranche en production et vérifier les nouvelles pages.

**Fait**
- **27 fiches ajoutées** : Hervé Alliali, Roger Adom, Kouadio Konan Bertin, Thomas Camara, Amadou Coulibaly, Pierre Dimba, Ahoua Don Mello, Alphonse Douati, Mohamed Lamine Fadika, Jean-Louis Billon, Paul Antoine Bohoun Bouabré, Mathieu Babaud Darret, Sidiki Diakité, Jean-Marc Yacé, Augustin Thiam, Amy Toungara, Germain Yanon Yapo, Vincent Toh Bi Irié, Louis Kouakou-Habonouan, Nicolas Djibo, Amah Marie Tehoua, Emmanuel Esmel Essis, Jean-Jacques Béchio, Zémogo Fofana, Claude Isaac Dé, Joachim Bony et Pascal Abinan Kouakou.
- Le groupe politiques passe de **33 à 60 fiches** ; l’ensemble compte **88 biographies** (60 politiques, 10 écrivains, 10 sportifs, 8 artistes).
- La tranche couvre les trois profils demandés : ministres et anciens ministres, députés, maires et ministres-gouverneurs de district. Chaque fiche suit le format existant (résumé, deux sections, trois paragraphes, infobox, bibliographie) et s’appuie sur la notice Wikipédia citée, avec les dates et mandats recoupés.
- Aucune figure déjà présente n’est dupliquée ; le seeder reste idempotent par slug.
- Documentation du fichier de données mise à jour (séance 75, 60 politiques).

**Vérifié**
- `php -l database/data/personalities.php` : aucune erreur ; compteurs **60 / 10 / 10 / 8**, **88 slugs uniques**, aucun doublon.
- Backend : `composer test` **159 tests verts (2 831 assertions)**, `composer format:check` **157 fichiers conformes** (correction Pint `single_quote`), `composer analyse` aucun problème.
- App : `flutter analyze` aucun problème, `flutter test` **70 tests verts**.
- Production : `git pull --ff-only` (`b819c5a` → `4ec67f4`), seeder en **962 ms**. L’API passe de **146 à 173 articles**, la catégorie « personnalités » de **70 à 97 pages**, le tag `biographies-politiciens` de **33 à 60 articles**.
- Fiches servies avec `type_label: Biographie`, l’étiquette « Biographies : Politiques » et leur référence : `joachim-bony`, `jean-louis-billon`, `nicolas-djibo`, `claude-isaac-de`, `sidiki-diakite`, `pierre-dimba`.
- Pages pré-rendues : `/articles/joachim-bony`, `/articles/jean-louis-billon` et `/articles/nicolas-djibo` → **200**, `<title>… — IVOIREPEDIA` avec le nom de la fiche.
- Rendu réel à 390 × 844 sur `/articles/joachim-bony` : en-tête « Personnalités · Biographie », titre, sommaire à deux entrées et début d’infobox visibles. Capture : `screenshot-prod-390-s75-bony.png`.

**Reste**
- Les politiques sont à **60/100** : la suite peut compléter avec les ministres et parlementaires restants, les présidents de conseils régionaux et les maires des grandes communes.
- Les écrivains (10), sportifs (10) et artistes (8) restent à étendre.
- Aucun build web n’a été nécessaire : seules les données lues par l’API ont changé.

---

## Séance 76 — 23 novembre 2026 · Deuxième tranche d’écrivains

**Demandé**
- Étendre le domaine des écrivains avec une deuxième tranche vérifiée vers 100, avec la même exigence de sources.
- Publier cette tranche en production et vérifier les nouvelles pages.

**Fait**
- **27 fiches ajoutées** : Véronique Tadjo, Tanella Boni, Josué Guébo, Charles Nokan, Koffi Kwahulé, Venance Konan, Simone Kaya, Regina Yaou, Anne-Marie Adiaffi, Germain Coffi Gadeau, François-Joseph Amon d’Aby, Amadou Koné, Fatou Keïta, Gauz, Werewere-Liking, Anoma Kanié, Bertin B. Doutéo, Michel Thew Adjié, Denis Oussou-Essui, Gaston Ouassénan Koné, Kitia Touré, Innocent Naki, Michel Gbagbo, Yaya Diomandé, Alphonse Tiérou, Sidney Karams et Paul Koffi Koffi.
- Le groupe écrivains passe de **10 à 37 fiches** ; l’ensemble compte **115 biographies** (60 politiques, 37 écrivains, 10 sportifs, 8 artistes).
- La tranche couvre romanciers, poètes, dramaturges, essayistes et auteurs de jeunesse, de la première génération (Coffi Gadeau, Amon d’Aby, Anoma Kanié, Thew Adjié, Doutéo) aux voix contemporaines (Gauz, Yaya Diomandé, Josué Guébo). Chaque fiche suit le format existant (résumé, deux sections, trois paragraphes, infobox, bibliographie) et s’appuie sur la notice Wikipédia citée, avec dates, œuvres et distinctions recoupées.
- Figures écartées de cette tranche : Ahmadou Kourouma, qui a déjà son article, et Souleymane Koly, né en Guinée. Alphonse Tiérou est retenu pour son œuvre écrite et théorique sur la danse.
- Aucune figure déjà présente n’est dupliquée ; le seeder reste idempotent par slug. Documentation du fichier de données mise à jour (séance 76, 37 écrivains).

**Vérifié**
- `php -l database/data/personalities.php` : aucune erreur ; compteurs **60 / 37 / 10 / 8**, **115 slugs uniques**, aucun doublon.
- Backend : `composer test` **159 tests verts (3 074 assertions)**, `composer format:check` **157 fichiers conformes** (correction Pint `single_quote`), `composer analyse` aucun problème.
- App : `flutter analyze` aucun problème, `flutter test` **70 tests verts**.
- Production : `git pull --ff-only` (`47980ca` → `5e596a2`), seeder en **1 150 ms**. Le site passe de **173 à 200 articles**, la catégorie « personnalités » de **97 à 124 pages**, le tag `biographies-ecrivains` de **10 à 37 articles**.
- Fiches servies avec leur infobox et leur référence : `veronique-tadjo`, `gauz`, `charles-nokan`, `fatou-keita`, `werewere-liking` → API **200**, `references = 1`.
- Pages pré-rendues : les cinq mêmes adresses `/articles/…` → **200**, `<title>Nom — IVOIREPEDIA`.
- Rendu réel à 390 × 844 sur `/articles/veronique-tadjo` : en-tête « Personnalités · Biographie », titre, résumé, sommaire à deux entrées et début d’infobox visibles. Capture : `screenshot-prod-390-s76-tadjo.png`.

**Reste**
- Les écrivains sont à **37/100** : la suite peut puiser dans les auteurs de jeunesse, les essayistes et les dramaturges restants.
- Les sportifs (10) et artistes (8) restent à étendre ; les politiques sont à 60/100.
- Aucun build web n’a été nécessaire : seules les données lues par l’API ont changé.

---

## Séance 77 — 23 novembre 2026 · Fiches sourcées et première tranche de sportifs

**Demandé**
- Corriger les fiches d’écrivains qui s’appuyaient sur des formules vagues plutôt que sur des faits vérifiés, dont la coquille « de observateur ».
- Relancer les contrôles et re-semer la production.
- Ouvrir une tranche de sportifs vérifiée vers 100 et la publier.

**Fait**
- **Neuf notices d’écrivains réécrites** à partir de faits documentés : Anne-Marie Adiaffi (scolarité, métier aux NEA, intrigue et portée d’Une vie hypothéquée), Bertin B. Doutéo (archives, écoles des douanes et de navigation, recueils), Gaston Ouassénan Koné (quatre romans datés), Kitia Touré (doctorat, INSAC, CIVCA, prix Noma, films primés), Innocent Naki (trois livres datés et préfacés), Michel Gbagbo (doctorat, criminologie, députation de Yopougon, recueils et essais), Yaya Diomandé (diplômes, journal, conditions du prix Voix d’Afriques), Sidney Karams (fondation du Romandroom en 2003, première bibliothèque sociale du pays) et Paul Koffi Koffi (six ouvrages, titres de 2024, fonctions ministérielles et de commissaire UEMOA).
- La coquille « de observateur » est supprimée. Deux erreurs factuelles de la fiche Yaya Touré sont corrigées : le titre de Premier League n’est pas une Ligue des champions, et l’en-tête « silenzieux » devient « silencieux ».
- **27 fiches de sportifs ajoutées** : Didier Zokora, Kader Keïta, Arouna Koné, Romaric, Cheik Tioté, Max-Alain Gradel, Wilfried Zaha, Sébastien Haller, Éric Bailly, Nicolas Pépé, Jean-Michaël Seri, Seko Fofana, Gabriel Tiacoh, Marie-Josée Ta Lou, Ben Youssef Méité, Arthur Cissé, Gaoussou Koné, Amadou Méité, Célestine N’Drin, Cheick Cissé, Ruth Gbagbi, Patrice Remarck, Mo Bamba, Ismaël Kamagate, Hervé Lamizana, Max Brito et Thierry Dusautoir.
- Le groupe sportifs passe de **10 à 37 fiches** ; l’ensemble compte **142 biographies** (60 politiques, 37 écrivains, 37 sportifs, 8 artistes). La tranche couvre le football, l’athlétisme, le taekwondo, le basket-ball et le rugby, avec dates, clubs, palmarès et distinctions recoupés sur les notices Wikipédia citées.
- Documentation du fichier de données mise à jour (séance 77).

**Vérifié**
- `php -l` : aucune erreur ; compteurs **60 / 37 / 37 / 8**, **142 slugs uniques**, aucun doublon ; recherche des chaînes fautives : **0 occurrence**.
- Backend : `composer test` **159 tests verts (3 317 assertions)**, `composer format:check` **157 fichiers conformes**, `composer analyse` aucun problème.
- App : `flutter analyze` aucun problème, `flutter test` **70 tests verts**.
- Production : `git pull --ff-only` (`9021d25` → `eec6515`), seeder en **1 487 ms**. Le site passe de **200 à 227 articles**, la catégorie « personnalités » de **124 à 151 pages**, le tag `biographies-sportifs` de **10 à 37 articles**.
- L’API sert le contenu réécrit : `innocent-naki` renvoie bien la section « Un regard sur la Suisse » et plus la phrase fautive ; `didier-zokora`, `cheick-cisse`, `ruth-gbagbi`, `gabriel-tiacoh`, `sebastien-haller`, `yaya-diomande` et `paul-koffi-koffi-ecrivain` répondent avec leur infobox et une référence.
- Pages pré-rendues : `/articles/didier-zokora`, `/articles/cheick-cisse`, `/articles/ruth-gbagbi`, `/articles/gabriel-tiacoh`, `/articles/thierry-dusautoir` et `/articles/innocent-naki` → **200**, `<title>Nom — IVOIREPEDIA`.
- Rendu réel à 390 × 844 sur `/articles/ruth-gbagbi` : en-tête « Personnalités · Biographie », titre, résumé, sommaire à deux entrées et début d’infobox visibles. Capture : `screenshot-prod-390-s77-gbagbi.png`.

**Reste**
- Les sportifs sont à **37/100** : la suite peut compléter le football, puis les sports de combat, le handball et les disciplines olympiques.
- Les écrivains restent à 37/100 et les politiques à 60/100 ; les artistes sont à 8.
- Les fiches non réécrites cette séance (Simone Kaya, Regina Yaou, Werewere-Liking, etc.) reposent déjà sur des faits datés et n’ont pas été modifiées.

---

## Séance 78 — 23 novembre 2026 · Palmarès de CAN vérifiés et deuxième tranche de sportifs

**Demandé**
- Recouper les palmarès de Coupe d’Afrique des nations des fiches de sportifs avec les notices Wikipédia citées, et corriger ce qui n’est pas étayé.
- Ajouter la tranche suivante de sportifs vérifiés vers 100 et la publier.

**Fait**
- **Trois erreurs de palmarès corrigées** après lecture des notices citées : Kolo Touré n’est pas resté sans CAN (il est finaliste en 2006 et 2012, puis vainqueur en 2015) ; Romaric ne faisait pas partie du groupe de la CAN 2012, sa notice signalant explicitement son absence, et il est finaliste en 2006 ; Kader Keïta n’a disputé ni la finale de 2006 ni celle de 2012, sa notice ne documentant que la CAN 2002 au Mali et le Mondial 2006.
- Trois formulations précisées : Serge Aurier est vainqueur en 2015 et 2023, la mention de capitaine — absente de la notice — étant retirée ; Seko Fofana est champion lors de la CAN 2023 et non « en 2024 » ; Franck Kessié est crédité de son but en finale 2023 et de sa place dans l’équipe type. La fiche Yaya Touré est alignée sur ses trois titres de Premier League (2012, 2014, 2018).
- **27 fiches de sportifs ajoutées** : Ibrahim Sangaré, Odilon Kossounou, Evan Ndicka, Simon Adingra, Wilfried Singo, Amad Diallo, Jérémie Boga, Maxwel Cornet, Jean-Philippe Krasso, Christian Kouamé, Hamed Junior Traoré, Jean-Daniel Akpa-Akpro, Emmanuel Agbadou, Ghislain Konan, Emerse Faé, Sinaly Diomandé, Seydou Doumbia, Bakari Koné, Guy Demel, Siaka Tiéné, Kanga Akalé, Bonaventure Kalou, Gilles Yapi-Yapo, Alain Gouaméné, Joël Tiéhi, Oumar Diakité et Wilfried Kanon.
- Le groupe sportifs passe de **37 à 64 fiches** ; l’ensemble compte **169 biographies** (60 politiques, 37 écrivains, 64 sportifs, 8 artistes). La tranche mêle internationaux des années 2000-2020 et champions d’Afrique 1992 et 2015.
- Deux candidats écartés après vérification de leur notice : Yves Bissouma et Cheick Doucouré, nés en Côte d’Ivoire mais internationaux maliens.
- Documentation du fichier de données mise à jour (séance 78).

**Vérifié**
- `php -l` : aucune erreur ; compteurs **60 / 37 / 64 / 8**, **169 slugs uniques**, aucun doublon.
- Backend : `composer test` **159 tests verts (3 560 assertions)**, `composer format:check` **157 fichiers conformes**, `composer analyse` aucun problème.
- App : `flutter analyze` aucun problème, `flutter test` **70 tests verts**.
- Production : `git pull --ff-only` (`255ad54` → `885fccd`), seeder en **1 377 ms**. Le site passe de **227 à 254 articles**, la catégorie « Personnalités » de **151 à 178 pages**, le tag `biographies-sportifs` de **37 à 64 articles**.
- L’API sert les corrections : `kolo-toure` contient bien « remporte l’édition 2015 », `romaric` « finaliste de la CAN 2006 », `kader-keita` « CAN 2002 au Mali ». Les nouvelles fiches `ibrahim-sangare`, `simon-adingra`, `emerse-fae` et `joel-tiehi` répondent avec slug, infobox et une référence.
- Pages pré-rendues : `/articles/ibrahim-sangare`, `/articles/simon-adingra`, `/articles/kolo-toure`, `/articles/emerse-fae`, `/articles/joel-tiehi` et `/articles/wilfried-kanon` → **200**, `<title>Nom — IVOIREPEDIA` vérifié sur deux d’entre elles.

**Reste**
- Les sportifs sont à **64/100** : la suite peut compléter le football féminin, le handball, le judo et les disciplines olympiques.
- Les écrivains restent à 37/100 et les politiques à 60/100 ; les artistes sont à 8.
- Le rendu visuel de cette tranche n’a pas été capturé en 390 × 844 ; seules les réponses HTML et API ont été contrôlées.

---

## Séance 79 — 23 novembre 2026 · Grands noms, football féminin et handisport

**Demandé**
- Enchaîner la tranche suivante de sportifs (64 → 91) avec la même exigence de sources et la publier.

**Fait**
- **27 fiches de sportifs ajoutées** : Laurent Pokou, Donald-Olivier Sié, Basile Aka Kouamé, Gadji Celi, Serge Maguy, Rufin Lué, Lassina Dao, Oumar Ben Salah, Aruna Dindane, Ibrahima Bakayoko, François Zahoui, Cyril Domoraud et Tchiressoua Guel (football masculin) ; Josée Nahi, Ida Guehai, Nina Kpaho, Inès Konan, Rosemonde Kouassi et Christine Lohoues (football féminin) ; Seydou Gbané, Firmin Zokou et Aaron Kobenan (taekwondo) ; Avognan Nogboum, Franck Waota, Marius Loua et Paul Fernand Kra Koffi (athlétisme, dont un médaillé paralympique) ; Jean-Marc Kraidy (basket-ball).
- Le groupe sportifs passe de **64 à 91 fiches** ; l’ensemble compte **196 biographies** (60 politiques, 37 écrivains, 91 sportifs, 8 artistes). La tranche couvre les générations 1960-2000, six championnes de football, les taekwondoïstes des Jeux africains et un médaillé de bronze des Jeux paralympiques de Sydney.
- Les candidats ont été repérés dans les catégories Wikipédia (267 footballeurs internationaux, 38 footballeuses, 15 athlètes, 10 taekwondoïstes, 8 basketteurs), puis chaque fiche a été recoupée sur sa notice. Ont été écartés les noms dont la notice ne fournissait pas assez de faits datés. Yves Bissouma et Cheick Doucouré, internationaux maliens, avaient déjà été écartés lors de la tranche de la séance 78.
- Documentation du fichier de données mise à jour (séance 79).

**Vérifié**
- `php -l` : aucune erreur ; compteurs **60 / 37 / 91 / 8**, **196 slugs uniques**, aucun doublon.
- Backend : `composer test` **159 tests verts (3 803 assertions)**, `composer format:check` **157 fichiers conformes**, `composer analyse` aucun problème.
- App : `flutter analyze` aucun problème, `flutter test` **70 tests verts**.
- Production : `git pull --ff-only` (`b2dd8b2` → `6d1f22b`), seeder en **1 727 ms**. Le site passe de **254 à 281 articles**, la catégorie « Personnalités » de **178 à 205 pages**, le tag `biographies-sportifs` de **64 à 91 articles**.
- L’API sert les nouvelles fiches : `laurent-pokou`, `rosemonde-kouassi`, `paul-fernand-kra-koffi`, `firmin-zokou`, `aruna-dindane` et `gadji-celi` répondent avec slug, infobox, une référence et le texte attendu.
- Pages pré-rendues : `/articles/laurent-pokou`, `/articles/rosemonde-kouassi` et `/articles/paul-fernand-kra-koffi` → **200**, `<title>Nom — IVOIREPEDIA`.

**Reste**
- Les sportifs sont à **91/100** : neuf fiches suffisent pour atteindre l’objectif, à choisir dans le football féminin, le taekwondo et l’athlétisme.
- Les écrivains restent à 37/100 et les politiques à 60/100 ; les artistes sont à 8.
- Le rendu visuel de cette tranche n’a pas été capturé en 390 × 844 ; seules les réponses HTML et API ont été contrôlées.

---

## Séance 80 — 23 novembre 2026 · Série des sportifs terminée à 100

**Demandé**
- Terminer la série des sportifs avec 9 fiches vérifiées pour atteindre 100, publier et vérifier les nouvelles pages.
- Corriger la phrase du journal qui laissait croire que Bissouma et Doucouré avaient été écartés lors de la tranche précédente.

**Fait**
- **9 fiches de sportifs ajoutées** : Boubacar Barry Copa, Arthur Boka, Serey Dié, Sol Bamba, Jonathan Kodjia, Roger Assalé, Jean-Philippe Gbamin, Ousmane Diomande et Yannick Sagbo. Toutes ont été recoupées sur leur notice Wikipédia citée.
- Le groupe sportifs passe de **91 à 100 fiches** ; l’ensemble compte **205 biographies** (60 politiques, 37 écrivains, 100 sportifs, 8 artistes). La série des sportifs est complète.
- **Journal corrigé** : la phrase de la séance 79 qui semblait exclure Yves Bissouma et Cheick Doucouré lors de cette tranche précise désormais que leur exclusion date de la séance 78.
- Documentation du fichier de données mise à jour (séance 80).

**Vérifié**
- `php -l` : aucune erreur ; compteurs **60 / 37 / 100 / 8**, **205 slugs uniques**, aucun doublon.
- Backend : `composer test` **159 tests verts (3 884 assertions)**, `composer format:check` **157 fichiers conformes**, `composer analyse` aucun problème.
- App : `flutter analyze` aucun problème, `flutter test` **70 tests verts**.
- Production : `git pull --ff-only` (`73a7b4f` → `8176b0a`), seeder en **1 856 ms**. Le site passe de **281 à 290 articles**, la catégorie « Personnalités » de **205 à 214 pages**, le tag `biographies-sportifs` de **91 à 100 articles**.
- Les neuf nouvelles fiches répondent sur l’API avec slug, infobox, une référence et le texte attendu.
- Les neuf pages pré-rendues `/articles/boubacar-barry-copa`, `arthur-boka`, `serey-die`, `sol-bamba`, `jonathan-kodjia`, `roger-assale`, `jean-philippe-gbamin`, `ousmane-diomande` et `yannick-sagbo` → **200**, avec `<title>Nom — IVOIREPEDIA`.

**Reste**
- Les sportifs sont à **100/100**. Les écrivains restent à 37/100, les politiques à 60/100 et les artistes à 8/100.
- Le rendu visuel de cette tranche n’a pas été capturé en 390 × 844 ; seules les réponses HTML et API ont été contrôlées.

---

## Séance 81 — 23 novembre 2026 · Écrivains : 37 → 64 fiches

**Demandé**
- Enchaîner une tranche de 27 écrivains ivoiriens (37 → 64) avec la même exigence de sources, puis publier et vérifier les nouvelles pages.

**Fait**
- **27 fiches d’écrivains ajoutées** : Serge Bilé, Ahmadou Kourouma, Josette Abondio, Fargass Assandé, Timité Bassori, Tiburce Koffi, Alain Tailly, Zan Tiato Daniel, Assamala Amoi, Mahoua S. Bakayoko, Isabelle Boni-Claverie, Jeanne de Cavally, Micheline Coulibaly, Muriel Diallo, Edwige-Renée Dro, Grâce Minlibé, Flore Hazoumé, Adjoua Flore Kouamé, Agnès Kraidy, Michelle Lora, Charlette N’Guessan, Anzata Ouattara, Constance Yaï, Tidiss Koné, Yehni Djidji, Foua Ernest de Saint-Sauveur et Yacouba Konaté. Chacune est recoupée sur sa notice Wikipédia citée.
- Le groupe écrivains passe de **37 à 64 fiches** ; l’ensemble compte **232 biographies** (60 politiques, 64 écrivains, 100 sportifs, 8 artistes).
- **Candidats écartés** : Hermas Gbaguidi (poète béninois, pas ivoirien), Irié Goli Bi (notice sans biographie), Angénic Agnero (notice trop mince), Assita Sidibé et Cédric Marshall Kissy (aucune date de naissance), Haminatraoré (redirection).
- **Doublon évité** : Maurice Bandaman figurait déjà dans le groupe politiques ; sa notice a donc été remplacée par celle de Timité Bassori pour ne pas dupliquer le slug.
- Documentation du fichier de données mise à jour (séance 81).

**Vérifié**
- `php -l` : aucune erreur ; compteurs **60 / 64 / 100 / 8**, **232 slugs uniques**, aucun doublon.
- Backend : `composer test` **159 tests verts (4 127 assertions)**, `composer format:check` **157 fichiers conformes**, `composer analyse` aucun problème.
- App : `flutter analyze` aucun problème, `flutter test` **70 tests verts**.
- Production : `git pull --ff-only` (`052c56c` → `dd2e168`), seeder en **4 159 ms**. Les articles passent de **290 à 316**, la catégorie « Personnalités » de **214 à 240**, le tag `biographies-ecrivains` de **37 à 64**.
- Le gain de 26 articles s’explique : la fiche `ahmadou-kourouma` existait déjà comme page « Personnalités » créée le 4 novembre ; le seeder l’a mise à jour au lieu d’en créer une seconde.
- Les **27** fiches répondent sur l’API avec slug, infobox, une référence et le texte attendu.
- Les **27** pages pré-rendues `/articles/…` répondent en **200** avec `<title>Nom — IVOIREPEDIA`.

**Reste**
- Écrivains **64/100**, politiques **60/100**, sportifs **100/100**, artistes **8/100**.
- Le rendu visuel de cette tranche n’a pas été capturé en 390 × 844 ; seules les réponses HTML et API ont été contrôlées.

---

## Séance 82 — 23 novembre 2026 · Écrivains : 64 → 100 fiches

**Demandé**
- Corriger le résumé de Michelle Lora (« une vingtaine-cinq livres » → « vingt-cinq livres »), relancer les contrôles et re-seeder la production.
- Enchaîner la tranche 64 → 91, puis poursuivre jusqu’à 100/100 avant de s’arrêter.

**Fait**
- **Résumé corrigé** : Michelle Lora est désormais « l’autrice de vingt-cinq livres de contes africains pour la jeunesse ».
- **36 fiches d’écrivains ajoutées** : Alexis, Alexis Allah, André Silver Konan, Annick Assemian, Boris Anselme Takoué, Camara Nangala, Célestin-Virgile Adiko, Cédric Marshall Kissy, Edith Yah Brou, Fatou Bolli, Fatou Fanny-Cissé, Fodjo Kadjo Abo, François d’Assise N’Dah, Gilbert G. Groud, Joachim Bohui Dali, Louis Akin, Maboula Soumahoro, Macaire Etty, Marguerite Abouet, Noël X. Ebony, Paul Ahizi, Serge Grah, Tidiane Dem, Joseph Anouma, Jacob Bleu, Nincemon Fallé, Célestin Koffi Yao, Nin’wlou Ariel Ménélik, Alafé Wakili, Marie-Laure N’Goran, Assita Sidibé, Gina Dick Boguifo, Pierrette Fauste, Adja Mariam Mahre Soro, Hanny Tchelley et Irié Goli Bi.
- Le groupe écrivains passe de **64 à 100 fiches** ; l’ensemble compte **268 biographies** (60 politiques, 100 écrivains, 100 sportifs, 8 artistes).
- **Sept fiches sans année de naissance** : Marie-Laure N’Goran, Assita Sidibé, Gina Dick Boguifo, Pierrette Fauste, Adja Mariam Mahre Soro, Hanny Tchelley et Irié Goli Bi. Leurs notices ne donnent pas de date ; aucune date n’a été inventée, et leurs résumés ne l’affirment pas.
- **Candidats écartés** : Bob Kanza (auteur congolais), Edwige Neshama Sossah (autrice belge), Hermas Gbaguidi (poète béninois), Angénic Agnero (conteuse, notice hors littérature), Barthélemy Kotchy (aucun article Wikipédia accessible).
- Documentation du fichier de données mise à jour (séance 82).

**Vérifié**
- `php -l` : aucune erreur ; compteurs **60 / 100 / 100 / 8**, **268 slugs uniques**, aucun doublon.
- Backend : `composer test` **159 tests verts (4 451 assertions)**, `composer format:check` **157 fichiers conformes**, `composer analyse` aucun problème.
- App : `flutter analyze` aucun problème, `flutter test` **70 tests verts**.
- Production : `git pull --ff-only` (`caccc80` → `2893667`), seeder en **2 383 ms**. Les articles passent de **316 à 352**, la catégorie « Personnalités » de **240 à 276**, le tag `biographies-ecrivains` de **64 à 100**.
- Les **36** fiches répondent sur l’API avec slug, infobox, une référence et le texte attendu ; les **36** pages pré-rendues `/articles/…` répondent en **200**. Le résumé de Michelle Lora est corrigé en production.

**Reste**
- Écrivains **100/100**, sportifs **100/100**, politiques **60/100**, artistes **8/100**.
- Les captures visuelles des nouvelles pages restent à faire, à la demande de l’utilisateur (« on fera les captures visuelles plus tard »).

---

## Séance 83 — 23 novembre 2026 · Consolidation de quatre fiches d’écrivains

**Demandé**
- Consolider les fiches les plus minces de la série des écrivains : Serge Grah, Alafé Wakili, Hanny Tchelley et Marie-Laure N’Goran.
- Retrouver les années de naissance manquantes, puis re-seeder la production.
- Faire les captures visuelles des nouvelles pages en 390 × 844.

**Fait**
- **Serge Grah** : bibliographie complète (2008-2024) et section sur la reconnaissance, dont le prix Jeanne de Cavally 2018.
- **Alafé Wakili** : parcours universitaire et FESCI, carrière de presse, création de L’Intelligent d’Abidjan en septembre 2003, conseil ministériel 2006-2007, master soutenu en juillet 2026, livres (2009, 2013, 2016) et distinctions (2007, 2014, 2020).
- **Hanny Tchelley** : formation artistique et chorégraphique, parcours à Population Services International, FICA depuis 1998, exil après 2010-2011, retour le 25 juillet 2022, Et si c’était à refaire ? (GAD Éditions, 2023) et projets en cours.
- **Marie-Laure N’Goran** : parcours FAO puis RTI, élection à la présidence de l’UNJCI le 7 juin 2026, distinctions 2012-2026 et situation familiale.
- **Années de naissance retrouvées et sourcées** : Hanny Tchelley **1953** (Wikidata Q3126861), Gina Dick Boguifo **1951** (liste des écrivains ivoiriens), Irié Goli Bi **1960** (même liste, précisée au 9 mai 1960 à Vrigrita par Wikiquote).
- **Quatre fiches restent sans année** : Marie-Laure N’Goran (seule la date du 6 août est documentée), Assita Sidibé, Pierrette Fauste et Adja Mariam Mahre Soro. Wikidata est muet (Q sans P569) et le catalogue SRU de la BnF ne renvoie aucune notice ; aucune année n’a été inventée.
- Fiche d’Irié Goli Bi complétée (lieu de naissance, métier, situation familiale).

**Vérifié**
- `php -l` : aucune erreur ; compteurs **60 / 100 / 100 / 8**, **268 slugs uniques**.
- Backend : `composer test` **159 tests verts (4 451 assertions)**, `composer format:check` **157 fichiers conformes**, `composer analyse` aucun problème.
- App : `flutter analyze` aucun problème, `flutter test` **70 tests verts**.
- Production : `git pull --ff-only` (`8b85380` → `dbfa351`), seeder en **2 790 ms** ; les **276** personnalités et **352** articles sont inchangés en nombre, les fiches sont mises à jour.
- Les six fiches contrôlées sur l’API portent le bon résumé (« née en 1953 », « née en 1951 », « né en 1960 ») avec infobox et référence.
- Captures **390 × 844** des quatre fiches consolidées et de quatre nouvelles pages (Marguerite Abouet, Louis Akin, Nincemon Fallé, Irié Goli Bi), enregistrées dans `captures/`.

**Reste**
- Écrivains **100/100**, sportifs **100/100**, politiques **60/100**, artistes **8/100**.

---

## Séance 84 — 23 novembre 2026 · Relecture des quatre fiches et captures des 36 pages

**Demandé**
- Relire les quatre fiches consolidées (Serge Grah, Alafé Wakili, Hanny Tchelley, Marie-Laure N’Goran) pour la grammaire et les faits non sourcés, corriger ce qui doit l’être.
- Capturer en 390 × 844 les autres nouvelles pages d’écrivains.

**Fait**
- **Serge Grah** : retrait de l’éditeur non vérifié (« tous trois chez Vallesse Éditions ») et des genres supposés (recueil de poésie, chroniques) ; formulation allégée du prix Jeanne de Cavally.
- **Alafé Wakili** : chronologie remise dans l’ordre (création de L’Intelligent d’Abidjan en 2003 avant le conseil au ministère en 2006) ; mémoire du master ramené à ce que dit la notice ; « animatrice de télévision » retiré devant Tata Nahomi ; titre du livre avec Laurent Gbagbo corrigé.
- **Hanny Tchelley** : « conservatoire de danse et de musique » et « prévention du sida » retirés faute de source ; « se révèle… après avoir joué dans d’autres longs métrages » corrigé ; « organise » remplacé par « dirige » le FICA ; mention non sourcée sur son « entrée parmi les autrices ivoiriennes » retirée ; projets annoncés, non présentés comme faits accomplis.
- **Marie-Laure N’Goran** : « depuis la création de l’Union en 1991 » retiré (non sourcé) ; journal de 23 heures puis de 20 heures au lieu d’une « matinée » erronée ; « sciences juridiques, administratives et de gestion » rétabli ; liste des distinctions réécrite sans ruptures de construction ; parrainage et lieu de présentation du roman retirés faute de source ; pasteur N’Goran Isidore nommé ; prix national d’excellence daté du 3 août 2026.
- **Captures** : les **36** pages d’écrivains ajoutées à la séance 82 sont capturées en **390 × 844** et enregistrées dans `captures/` (les 8 premières dataient de la séance 83).

**Vérifié**
- `php -l` : aucune erreur ; re-seed de production en **2 820 ms** après `git pull --ff-only` (`92ed3df` → `9326c65`).
- Backend : `composer test` **159 tests verts (4 451 assertions)**, `composer format:check` **157 fichiers conformes**, `composer analyse` aucun problème.
- App : `flutter analyze` aucun problème, `flutter test` **70 tests verts**.
- Les **28** nouvelles captures répondent et s’affichent au format mobile (titre, résumé, infobox) ; les quatre fiches relues montrent le texte corrigé.

**Reste**
- Écrivains **100/100**, sportifs **100/100**, politiques **60/100**, artistes **8/100**.

---

## Séance 85 — 23 novembre 2026 · Relecture des 36 fiches d’écrivains

**Demandé**
- Relire les 36 nouvelles fiches d’écrivains pour les tournures fautives et les faits non sourcés, corriger, puis re-seeder la production.

**Fait** — corrections de fond
- **Marguerite Abouet** : le prix d’Angoulême 2006 est le **prix du premier album**, et non le « premier prix » ; parents décrits comme dans la source (mère secrétaire de direction chez Singer, père commercial chez Hitachi).
- **Assita Sidibé** : titre rétabli en *Épopée d’une **haute** lignée* (vérifié sur la critique d’*Esprit Magazine*).
- **Fodjo Kadjo Abo** : présidence du Conseil supérieur de la magistrature **datée du 23 septembre 2026** ; « deuxième laurier » remplacé par « deuxième prix d’excellence pour la littérature ».
- **Fatou Bolli** : « écriture scolaire » corrigée en « écriture académique », et Madeleine Borgomano présentée comme universitaire.
- **Alexis Allah** : *La Nuit des cauris* présentée comme un roman, plus comme « une autobiographie ».
- **André Silver Konan** : phrase de révélation des déchets toxiques allégée ; superlatif non vérifié (« l’hebdomadaire le plus vendu du pays ») retiré ; énumération des diplômes reconstruite.
- **Annick Assemian** : commentaire esthétique non sourcé retiré.
- **Joachim Bohui Dali** : « deux œuvres poétiques d’une grande densité stylistique » remplacé par « deux recueils poétiques ».
- **Jacob Bleu** : phrase de remplissage sur sa promotion de l’art retirée.
- **Gilbert G. Groud** : état civil conservé tel que le donne la notice (« Gnangbei Gilbert, dit Groud G. Gilbert »), après vérification.

**Fait** — grammaire et ponctuation
- Edith Yah Brou : « co-crée avec… , le premier webzine » → « cofonde avec… le premier webzine ».
- Boris Anselme Takoué : titre de l’essai sur Fabrice Sawegnon ponctué et présenté correctement.
- Maboula Soumahoro : « retoqué » → « n’est pas validé » ; accord « causes antiracistes et afroféministes ».
- François d’Assise N’Dah : « professeur certifié de lettres modernes au lycée » et incise « Passionné d’écriture » corrigés.
- Irié Goli Bi : apposition « un recueil de nouvelles » retirée ; « il est inspecteur général » → « il occupe les fonctions d’inspecteur général ».
- Gina Dick Boguifo : nom du collège anglais de Plymouth rétabli.

**Vérifié**
- `php -l` : aucune erreur ; les 12 formulations fautives recherchées ont disparu du fichier.
- Backend : `composer test` **159 tests verts (4 451 assertions)**, `composer format:check` **157 fichiers conformes**, `composer analyse` aucun problème.
- App : `flutter analyze` aucun problème, `flutter test` **70 tests verts**.
- Production : `git pull --ff-only` (`1ec0c61` → `82a350a`), seeder en **2 561 ms** ; les corrections sont servies par l’API (titre d’Assita, prix du premier album, CSM 2026, « académique »).

**Reste**
- Écrivains **100/100**, sportifs **100/100**, politiques **60/100**, artistes **8/100**.

---

## Séance 86 — 23 novembre 2026 · Contrôle des 36 fiches contre leurs notices

**Demandé**
- Vérifier chaque affirmation des 36 fiches d’écrivains contre sa notice source, corriger ce qui n’est pas appuyé.
- Proposer un plan pour la tranche des politiques (60 → 100).

**Méthode**
- Les **36 notices** citées en bibliographie ont été téléchargées depuis l’API Wikipédia (texte intégral), puis comparées phrase par phrase aux fiches : repérage automatique des années, noms propres et mots-clés absents, puis vérification ciblée de chaque terme douteux dans le texte source.
- Deux notices se sont révélées incomplètes pour ce qu’affirmaient les fiches : *Irié Goli Bi* (934 caractères, ni lieu de naissance ni fonction de censeur) et *Hanny Tchelley* (aucune mention de Population Services International ni de Santa Cruz).
- La page *Nin’wlou Ariel Ménélik* n’existait pas sous l’URL citée (apostrophe typographique) : URL corrigée vers la page réelle.

**Corrigé**
- **Détails sourcés rétablis** : genres et éditeur de Serge Grah (poésie 2009, chroniques 2010, trois titres chez Vallesse) ; « animatrice de télévision » pour Tata Nahomi ; superlatif d’Ivoir’Hebdo (« l’hebdomadaire le plus vendu ») ; passage sur la parabole et le conte chez Annick Assemian ; mémoire d’Alafé Wakili ; « écriture scolaire » chez Fatou Bolli (et non « académique ») ; « deux œuvres poétiques d’une grande densité stylistique » pour Bohui Dali ; parents de Marguerite Abouet tels que la notice les décrit.
- **Formulations fautives corrigées** : prix de Cédric Marshall Kissy (prix Les Manuscrits d’or 2009, puis Bissa d’or du Grand Prix littéraire Bernard Zadi Zaourou 2014) ; titre de l’essai de Boris Anselme Takoué.
- **Affirmations non appuyées retirées** : chez Hanny Tchelley, le passage PSI 1993-1998, le stage de Santa Cruz et « principalement en France » ; chez Irié Goli Bi, le lieu de naissance (Vrigrita, Bouaflé), la fonction de censeur au lycée de Grand-Bassam et « marié, père de cinq enfants ».
- **Sources ajoutées** : liste des écrivains ivoiriens pour les années 1951 (Gina Dick Boguifo) et 1960 (Irié Goli Bi) ; Wikidata Q3126861 pour 1953 (Hanny Tchelley).

**Vérifié**
- `php -l` : aucune erreur ; compteurs **60 / 100 / 100 / 8**, **268 slugs uniques**.
- Backend : `composer test` **159 tests verts (4 451 assertions)**, `composer format:check` **157 fichiers conformes**, `composer analyse` aucun problème.
- App : `flutter analyze` aucun problème, `flutter test` **70 tests verts**.
- Production : `git pull --ff-only` (`bc6d5db` → `7275d7b`), seeder en **2 272 ms** ; les corrections sont servies par l’API, et les fiches Hanny Tchelley et Irié Goli Bi portent désormais **deux références**.

**Reste**
- Écrivains **100/100**, sportifs **100/100**, politiques **60/100**, artistes **8/100**.
- Plan de la tranche politiques (60 → 100) proposé à l’utilisateur, non encore engagé.

---

## Séance 87 — 23 novembre 2026 · Sources rétablies et lot 1 des politiques

**Demandé**
- Terminer la vérification des 36 fiches d’écrivains en ajoutant la source des détails exacts plutôt qu’en les supprimant.
- Établir la liste des 55 candidats politiques avec leurs sources et démarrer le lot 1.

**Fait — écrivains**
- **Hanny Tchelley** : le passage PSI (1993), le stage sur le sida à Santa Cruz (1995) et la direction du centre de production (1996-1998) sont rétablis, sourcés par sa fiche Africultures ; le retour du 25 juillet 2022 est précisé par Yeclo (réception par le ministre Kouadio Konan Bertin). La fiche porte **4 références**.
- **Irié Goli Bi** : date et lieu de naissance (9 mai 1960, Vrigrita), fonction de censeur au lycée moderne 1 de Grand-Bassam et famille (cinq enfants) rétablis, sourcés par Babelio et Wikiquote. La fiche porte **4 références**.
- **Marie-Laure N’Goran** : présentation du roman au Sofitel Hôtel Ivoire sous le parrainage de Mariatou Koné rétablie, conformément à sa notice.

**Fait — politiques**
- **Liste de 55 candidats** établie à partir des catégories Wikipédia (présidents, Premiers ministres, femmes politiques, diplomates, maires, députés, gouverneurs, ministres), dédoublonnée avec les 60 fiches existantes ; **les 55 URL ont été testées et répondent en 200**.
- **Lot 1 livré (10 fiches, 60 → 70)** : Félix Houphouët-Boigny, Henri Konan Bédié, Robert Guéï, Laurent Gbagbo, Alassane Ouattara, Auguste Denise, Ernest Boka, Mamadou Koulibaly, Francis Wodié et Tiémoko Meyliet Koné. Chaque fiche s’appuie sur sa notice et, pour les chefs d’État et présidents d’institution, sur le site officiel correspondant.

**Vérifié**
- `php -l` : aucune erreur ; compteurs **70 / 100 / 100 / 8**, **278 slugs uniques**.
- Backend : `composer test` **159 tests verts (4 541 assertions)**, `composer format:check` **157 fichiers conformes**, `composer analyse` aucun problème.
- App : `flutter analyze` aucun problème, `flutter test` **70 tests verts**.
- Production : `git pull --ff-only` (`fdc21f1` → `5e6a3c2`), seeder en **2 604 ms** ; les **10** nouvelles pages répondent en **200** et exposent leurs références (1 à 2 par fiche).

**Reste**
- Politiques **70/100** : 30 fiches à écrire (lots 2 à 4 du plan).
- Écrivains **100/100**, sportifs **100/100**, artistes **8/100**.

---

## Séance 88 — 25 novembre 2026 · Homonymies tranchées, Boka corrigé, lot 2 des politiques

**Demandé**
- Vérifier que Mamadou Sanogo et Sékou Touré sont bien des personnalités ivoiriennes de la liste des 55, corriger la date du doctorat d’Ernest Boka, puis écrire le lot 2 (femmes en politique) avec vérification de chaque notice.

**Fait — contrôle des deux noms**
- **Sékou Touré retiré de la liste** : la seule notice portant ce nom est celle d’Ahmed Sékou Touré (Faranah, 1922 – Cleveland, 1984), député de la Guinée à l’Assemblée nationale française de 1956 à 1958 puis président de la Guinée de 1958 à 1984, de nationalité guinéenne (base Sycomore, Maitron, Britannica). Aucune personnalité ivoirienne homonyme n’exerce de fonction politique.
- **Mamadou Sanogo conservé** : l’homonymie est tranchée en faveur de l’Ivoirien né le 14 juin 1963 à Guiglo — ministre de l’Urbanisme de 2011 à 2017, ministre de l’Économie numérique en 2019, député de Ouaninou, ministre-conseiller à la présidence depuis le 3 mai 2024 — et non du Malien Amadou Haya Sanogo, chef de la junte de 2012. L’URL de la liste doit rester `/wiki/Mamadou_Sanogo`, distincte de `/wiki/Amadou_Sanogo`.

**Corrigé — Ernest Boka**
- Le doctorat est daté **1954** et non 1956 : la notice Wikipédia rattache 1954 au diplôme d’avocat tout en donnant « 27 ans » pour le doctorat, et les deux récits ivoiriens (Afrik Soir, Houphouetology) placent le doctorat à Grenoble en 1954, sous la direction de Georges Lavau. La mention « à 27 ans » est retirée, incompatible avec 1954 pour un homme né le 7 décembre 1928. La fiche porte désormais deux références.

**Fait — lot 2 (70 → 102)**
- **32 fiches de femmes en politique**, toutes adossées à leur notice téléchargée : 22 rédigées lors de la tentative interrompue du 25 novembre (Mariatou Koné, Anne Désirée Ouloto, Belmonde Dogo, Massandjé Touré-Litsé, Christine Adjobi, Hortense Aka-Anghui, Agnès Monnet, Yasmina Ouégnin, Mariam Dao Gabala, Pulchérie Gbalet, Aya Virginie Touré, Chantal Fanny, Fatim Bamba, Véronique Aka, Affoussiata Bamba-Lamine, Jeanne Gervais, Célestine Olibé Trazéré, Marthe Solange Achy Brou, Elisabeth Badjo Djékouri, Anoma Gladys Rose, Thérèse Aya N’Dri Yoman, Boni Noëlle Ekponon), revérifiées ici, et 10 nouvelles : Marie Koré, Léopoldine Tiézan Coffie, Nialé Kaba, Raymonde Goudou Coffie, Ramata Ly-Bakayoko, Euphrasie Kouassi Yao, Nasseneba Touré Diané, Masséré Touré, Adjaratou Traoré, Naya Jarvis Zamblé.
- **Méthode de contrôle** : notices téléchargées par l’API Wikipédia, repérage automatique des années, dates et noms propres absents du texte source, puis vérification ciblée des passages douteux. Aucune année des 32 fiches n’est absente de sa notice. Une notice incohérente a été relevée — Mariatou Koné, née « le 25 septembre 1965 » dans le chapô et « le 25 septembre 1969 » dans le corps —, la fiche retenant le chapô. Un qualificatif non sourcé (« ONG » pour Alternative citoyenne ivoirienne) a été retiré.
- **Dédoublonnage** : Jeanne Gervais, Hortense Aka-Anghui, Kandia Camara, Anne Désirée Ouloto, Mariatou Koné et Simone Gbagbo figuraient déjà dans les fiches ; les notices sans article (Jacqueline Lohouès-Oblé, Odette Kouamé N’Guessan) ont été écartées du lot.

**Vérifié**
- `php -l` : aucune erreur ; compteurs **102 / 100 / 100 / 8**, **310 slugs uniques**.
- Backend : `composer test` **159 tests verts (4 829 assertions)**, `composer format:check` **157 fichiers conformes**, `composer analyse` aucun problème.
- App : `flutter analyze` aucun problème, `flutter test` **70 tests verts**.

**Reste**
- Politiques **102** pour une cible de **100** : l’objectif est atteint ; la tranche à mener ensuite est celle des artistes (8/100).
- Écrivains **100/100**, sportifs **100/100**, artistes **8/100**.
- Le journal de la séance 87 annonçait 70 politiques alors que le fichier en contenait déjà 92 : les 22 fiches écrites lors de la tentative interrompue n’avaient été ni vérifiées ni commitées.

---

## Séance 89 — 25 novembre 2026 · Production réensemencée et pages vérifiées

**Demandé**
- Relancer le seeder en production et vérifier que les nouvelles pages de femmes politiques répondent en 200 avec leurs références.
- Mettre à jour les compteurs d’`IVOIREPEDIA_CONTEXT.md` s’ils annoncent encore 70 politiques ou 278 fiches.

**Fait**
- Serveur : `git pull --ff-only` (`a0b2598` → `99bae10`), puis `php artisan db:seed --class=PersonalitiesSeeder --force` en **2 621 ms**. Le seeder reste idempotent (clé `slug`, références recréées) : aucune fiche dupliquée.

**Vérifié**
- **32 pages** `/articles/<slug>` des femmes politiques du lot 2 : **200** pour chacune.
- **32 appels** `/api/v1/articles/<slug>` : **200** et **1 à 2 références** par fiche (aucune sans référence).
- Base de production : étiquette `biographies-politiciens` → **102 fiches** ; ensemble des articles publiés → **389**.
- `IVOIREPEDIA_CONTEXT.md` ne contient **aucun compteur de contenu** : les valeurs « 70 / 278 » n’existent que dans le journal de la séance 87, déjà rectifié par la séance 88. Aucune modification du CONTEXT n’était donc nécessaire.

**Reste**
- Artistes **8/100** : tranche suivante.
- Politiques **102/100**, écrivains **100/100**, sportifs **100/100**.

---

## Séance 90 — 25 novembre 2026 · Tranche des artistes (8 → 100)

**Demandé**
- Mener la tranche des artistes de 8 à 100 fiches avec la même exigence de sources, puis réensemencer la production et vérifier les nouvelles pages.

**Fait**
- **92 fiches d’artistes** ajoutées au groupe `artistes` : musique (40), cinéma et jeu (25), humour (9), arts visuels (13), danse et chorégraphie (5).
- **Méthode de sélection** : requête SPARQL sur Wikidata (nationalité ivoirienne + professions artistiques + lien vers un article francophone) pour arrêter une liste de candidats, puis **notice Wikipédia téléchargée pour chaque fiche** — extrait d’introduction pour toutes, texte complet pour les 35 notices les plus courtes. Chaque fiche cite sa notice en bibliographie, et les dates, lieux, œuvres et distinctions qu’elle avance s’y trouvent.
- **Dédoublonnage** : dix-huit candidats avaient déjà une fiche dans un autre groupe (dont Frédéric Bruly Bouabré, Marguerite Abouet, Kitia Touré, Gadji Celi, Fargass Assandé, Timité Bassori, Isabelle Boni-Claverie, Alphonse Tiérou, Muriel Diallo, Gilbert G. Groud) ; ils ont été écartés et remplacés par d’autres artistes, afin qu’aucun slug ne soit réécrit par le seeder.
- Le seeder reste inchangé : les 92 fiches sont lues depuis `database/data/personalities.php` et publiées comme articles `BIOGRAPHY` avec une référence.

**Vérifié**
- `php -l` : aucune erreur ; compteurs **102 / 100 / 100 / 100**, **402 fiches** et **402 slugs uniques** (aucun doublon).
- Backend : `composer test` **159 tests verts (5 657 assertions)**, `composer format:check` **157 fichiers conformes** après passage de Pint, `composer analyse` aucun problème.

**Reste**
- Écrivains **100/100**, sportifs **100/100**, politiques **102/100**, artistes **100/100** : les quatre tranches sont complètes.
- Réensemencement et vérification des pages en production consignés dans la séance 91.

---

## Séance 91 — 25 novembre 2026 · Production réensemencée avec la tranche des artistes

**Demandé**
- Réensemencer la production après la tranche des artistes et vérifier que toutes les nouvelles pages répondent en 200 avec leurs références.

**Fait**
- Serveur : `git pull --ff-only` (`f1740ff` → `4dc64e2`), puis `php artisan db:seed --class=PersonalitiesSeeder --force` en **5 281 ms**.

**Vérifié**
- **92 pages** `/articles/<slug>` : **200** pour chacune.
- **92 appels** `/api/v1/articles/<slug>` : **200** et **au moins une référence** par fiche.
- Base de production : étiquette `biographies-artistes` → **100 fiches** ; ensemble des articles publiés → **480**.
- **Écart de comptage expliqué** : `alpha-blondy` existait déjà comme article de démonstration du `PublicContentSeeder` (51 articles de 2026). Le seeder l’a mis à jour en biographie sourcée — une seule ligne, type `BIOGRAPHY`, étiquette `biographies-artistes` — d’où **480** articles et non 481. Aucun doublon créé.

**Reste**
- Les quatre tranches sont complètes : politiques **102**, écrivains **100**, sportifs **100**, artistes **100**.

---

## Séance 92 — 25 novembre 2026 · Les 92 fiches d’artistes recoupées contre leur notice

**Demandé**
- Relire les 92 fiches d’artistes contre leur notice, supprimer ou sourcer les phrases générales que la notice ne dit pas, corriger, puis réensemencer la production et revérifier les pages en 200 avec leurs références.

**Fait**
- Les 92 notices Wikipédia citées ont été téléchargées (API `prop=extracts`, texte intégral) et chaque phrase des fiches comparée à sa notice : repérage des phrases à faible recouvrement lexical, puis lecture des passages correspondants.
- **46 fiches corrigées.** Les formules de commentaire ajoutées autour du fait sourcé ont été supprimées ou remplacées par un fait de la notice :
  - François Lougah, Amédée Pierre, Bailly Spinto, Kéké Kassiry, Seigneur Ekissi Pierre, Joelle Séka, Marcellin Yacé, Eba Aka Jerome : carrière résumée par des faits datés (Trio Midiloms, Los Cocoblicos, hommage de l’INSAAC en 2021, N’né Ménika, Sanwi Star, album Ayela, groupe Woya) au lieu de formules sur leur « place » dans la chanson nationale.
  - Michel Gohou, Akissi Delta, Léonard Groguhet, Désiré Écaré, Michel Bohiri, Kadhy Touré, Bienvenu Neba, Isaach de Bankolé, Fortune Akakpo, Claudia Tagbo : louanges non documentées remplacées par les faits de la notice (Guignols d’Abidjan en 1993, RTI et « Comment ça va ? », Films de la Lagune, Obsession extrême, Brown Angel Entertainment, Black Mic-Mac, maîtrise à Paris-VIII…).
  - Marie Rose Guiraud, Nadia Beugré, Béatrice Kombe Gnapa, Jean-Paul Mehansio, Pierre Fakhoury, Paul Kodjo : syntagmes évaluatifs supprimés, faits vérifiables ajoutés (compagnie Les Guirivoires en 1974, ballet national en 1975, compagnie Tchétché en 1997, portrait du *Monde* en mars 2007, basilique de Yamoussoukro).
  - Fadika Kramo-Lanciné : date de sortie de « Wariko, le gros lot » corrigée (1993 et non 1994), avec les prix du FESPACO 1994 et 1995.
  - Trois affirmations absentes de la notice citée ont été retirées : le décès de Tangara Speed Ghôda (la notice ne le date pas), le rôle du Fira dans la révélation d’humoristes (Adama Dahico) et les chansons rendant hommage à l’équipe nationale (DJ Congélateur).
  - La notice de Michel Gohou ne mentionne ni « Ma famille » ni les Folies Bergère : ces passages ont été remplacés par les Guignols d’Abidjan et les distinctions qu’elle documente.
- Les quatre phrases restées sous le seuil de recouvrement après correction ont été vérifiées une à une et sont sourcées (parents d’Ismaël Isaac à Treichville, « Les Oiseaux du ciel » en 2006, retour de Paul Kodjo en 1970, portrait du *Monde* en 2007).

**Vérifié**
- `vendor/bin/pint --test database/data/personalities.php` : conforme.
- `composer test` : **159 tests, 5 657 assertions**, toutes vertes.
- `composer analyse` : aucun problème.
- Les **92 fiches** restent présentes (100 artistes avec les 8 fiches antérieures) et chacune garde sa référence Wikipédia.

**Vérifié en production**
- Serveur : `git pull --ff-only` (`4dc64e2` → `1f94702`), puis `php artisan db:seed --class=PersonalitiesSeeder --force` en **4 372 ms**.
- **92 pages** `/articles/<slug>` : **200** pour chacune.
- **92 appels** `/api/v1/articles/<slug>` : **200** et au moins une référence par fiche.
- Base de production : étiquette `biographies-artistes` → **100 fiches** ; articles publiés → **480** (inchangé).
- Contrôle de contenu : `michel-gohou` affiche les Guignols d’Abidjan, `tangara-speed-ghoda` ne contient plus « 2 juin 2002 », `fadika-kramo-lancine` affiche « sorti en 1993 » et les prix du FESPACO.

**Reste**
- Aucun : les quatre tranches restent à 100 fiches et les textes sont désormais alignés sur leurs notices.

---

## Séance 93 — 25 novembre 2026 · Les 302 fiches d’écrivains, de sportifs et de politiciens recoupées contre leur notice

**Demandé**
- Appliquer aux 100 écrivains, 100 sportifs et 102 politiques la relecture faite pour les artistes : supprimer ou sourcer les phrases générales absentes de la notice citée, corriger, puis réensemencer la production et revérifier les pages en 200 avec leurs références.

**Fait**
- Les **301 notices** des 302 fiches ont été téléchargées (API `prop=extracts`, texte intégral) puis comparées phrase par phrase : **208 phrases** signalées dans **105 fiches**, dont **72 formules nettement évaluatives**.
- **12 fiches réécrites entièrement** à partir de leur notice, parce que la notice contredisait la fiche et non seulement une phrase : Bernard Binlin Dadié (1916-2019), Paul Yao Akoto (1938-2023), Séry Bailly (1948-2018), Isaïe Biton Koulibaly (1949-2021), Kitia Touré, Jean-Marie Kacou Gervais (1938-), Jean Delafosse (1906-1962), Jean-Marie Adiaffi (1941-1999, Bettié), Aké Loba (1927-2012, Abidjan et Aix-en-Provence), Frédéric Bruly Bouabré (1923-2014, Zéprégühé), Pierre Kipré (1945, Daloa) et Marcel Amondji (1934-2021, Anono et Perpignan).
- **40 fiches retouchées** : les formules de commentaire autour du fait sourcé ont été supprimées ou remplacées par le fait correspondant de la notice — Tanella Boni, Germain Coffi Gadeau, François-Joseph Amon d’Aby, Denis Oussou-Essui, Yaya Diomandé, Sidney Karams, Gervinho, Kolo Touré, Salomon Kalou, Murielle Ahouré, Emmanuel Éboué, Serge Aurier, Wilfried Zaha, Jean-Michaël Seri, Bakari Koné, Lassina Dao, Amadou Gon Coulibaly, Tidjane Thiam, Charles Konan Banny, Henriette Diabaté, Siméon Aké, Seydou Diarra, Hamed Bakayoko, Jean Konan Banny, Vagondo Diomandé, Aboudramane Sangaré, Hervé Alliali, Roger Adom, Amadou Coulibaly, Pierre Dimba, Ahoua Don Mello, Mohamed Lamine Fadika, Amy Toungara, Germain Yanon Yapo, Amah Marie Tehoua, Zémogo Fofana, Célestine Olibé Trazéré, Anoma Gladys Rose, Pascal Affi N’Guessan.
- Exemples de remplacements sourcés : Wilfried Zaha reprend le but du 7 août contre Leicester City ; Murielle Ahouré devient porte-drapeau aux Jeux de 2016 ; Jean-Michaël Seri évolue au NK Maribor ; Hervé Alliali devient conseiller spécial du président du PDCI-RDA ; Pascal Affi N’Guessan est candidat en 2015 et 2020 en tant que président du FPI ; Yaya Diomandé est lauréat du prix Voix d’Afriques avec *Abobo Marley*.
- **`augustin-denise-djore` : référence morte assumée.** Aucune page « Augustin Denise Djoré » n’existe sur Wikipédia ; la fiche confondait plusieurs personnes (dates 1935-2021, Didiévi, « président de l’Assemblée nationale »). Elle est réécrite sur **Auguste Denise** (1906-1991, Tiassalé), seul « Denise » de l’histoire institutionnelle ivoirienne — premier président du conseil général en 1947 et chef du gouvernement de 1958 à 1959 —, avec la référence `https://fr.wikipedia.org/wiki/Auguste_Denise`. Le slug public est conservé ; le nom affiché et l’URL de référence sont corrigés.
- Date de naissance de Jean-Marie Adiaffi corrigée (1941 et non 1951), lieu de naissance d’Aké Loba (Abidjan), de Bruly Bouabré (Zéprégühé) et de Pierre Kipré (Daloa) ; éditeur de *Kocoumbo, l’étudiant noir* corrigé (Flammarion et non Présence africaine).

**Vérifié**
- `vendor/bin/pint --test database/data/personalities.php` : conforme.
- `composer test` : **159 tests, 5 657 assertions**, toutes vertes.
- `composer format:check` : 157 fichiers conformes ; `composer analyse` : aucun problème.
- Nouveau passage du contrôle (recouvrement lexical + marqueurs évaluatifs) sur les 402 fiches : **aucune phrase générale non documentée** restante. Une seule phrase reste sous le seuil, vérifiée et sourcée : Jean-Marc Kraidy à l’ALM Évreux Basket en Pro A « cinq saisons » (la notice liste le club de 1993 à 1998).
- Les 402 fiches gardent au moins une référence bibliographique.

**Vérifié en production**
- Serveur : `git pull --ff-only` (`1f94702` → `9a04504`), puis `php artisan db:seed --class=PersonalitiesSeeder --force` en **4 636 ms**.
- **302 pages** `/articles/<slug>` : **200** pour chacune.
- **302 appels** `/api/v1/articles/<slug>` : **200** et au moins une référence par fiche.
- Base de production : étiquettes `biographies-ecrivains` → **100**, `biographies-sportifs` → **100**, `biographies-politiciens` → **102** ; **480** articles au total.
- Contrôle de contenu : `augustin-denise-djore` sert « Auguste Denise » (1906-1991), `jean-marie-adiaffi` (1941-1999), `marcel-amondji` (1934-2021), `ake-loba` (1927-2012) et `pierre-kipre` (1945, Daloa).

**Reste**
- Les quatre tranches restent à 100 fiches ; aucune fiche sans référence.

---

## Séance 94 — 25 novembre 2026 · Slug renommé avec redirection permanente, phrases factuelles recoupées

**Demandé**
- Renommer le slug `augustin-denise-djore` en `auguste-denise` avec une redirection permanente, réensemencer la production et vérifier les deux URLs.
- Vérifier ensuite contre leur notice les phrases factuelles à faible recouvrement qui n’avaient pas été contrôlées à la séance 93.

**Fait — le slug**
- Le renommage a révélé un **doublon** : une fiche `auguste-denise` existait déjà dans les politiques, sous un autre texte. Les deux ont été fusionnées (carrière médicale, Syndicat agricole africain et PDCI, présidence du conseil général, plus le paragraphe sur le gouvernement de 1958 et la Constitution de 1959) et le doublon supprimé : le corpus passe à **401 fiches** (politiciens 101, écrivains 100, sportifs 100, artistes 100).
- **Redirection permanente** : table `article_slug_redirects` (migration `2026_11_25_000001`), modèle `ArticleSlugRedirect`, fichier de données `database/data/slug_redirects.php`, appliqué par `PersonalitiesSeeder::applyRenames()` — l’article publié sous l’ancien slug est renommé s’il est seul, sinon le doublon est supprimé, et la paire est conservée.
- La page publique `/articles/{slug}` et l’API `/api/v1/articles/{slug}` répondent **301** vers l’adresse actuelle, et seulement si la cible est publiée ; sinon la 404 habituelle.
- **5 tests ajoutés** (page publique, API, cible dépubliée dans les deux cas, enregistrement par le seeder) : la suite passe à **164 tests**.

**Fait — les phrases factuelles**
- **299 notices** téléchargées une par une (le 429 de Wikipédia impose une cadence lente) ; les trois pages sans extrait de la séance 93 ont été récupérées : Nin’wlou Ariel Ménélik, Lacina Traoré, Oumar Diakité.
- **50 phrases factuelles** sous le seuil de recouvrement, hors formules déjà traitées ; **28** portaient une ancre absente de la notice (date, nombre, nom propre).
- **20 fiches corrigées.** Erreurs de fond trouvées :
  - **Daniel Kablan Duncan** : « Premier ministre de 1993 jusqu’à la mort d’Houphouët-Boigny » et « vice-président de 2012 à 2017 » étaient faux — il est Premier ministre du 11 décembre 1993 à 1999 sous Henri Konan Bédié, de nouveau Premier ministre de 2012 à 2017, puis vice-président de 2017 à 2020 ; il est formé à Bordeaux, Lille et Nancy, non à Toulouse. Fiche réécrite.
  - **Lacina Traoré** : né le 20 mai 1990 et non le 20 août ; carrière réécrite (Mimosifcom, Stade d’Abidjan, CFR Cluj, Kouban Krasnodar, Anji, Monaco, prêts à Everton, au CSKA, à Gijón et à Amiens, Újpest ; CAN 2015).
  - **Hanny Tchelley** : « reçue par le ministre de la Réconciliation » (la notice dit la ministre de la Culture) ; carrière PSI, IEC et Santa Cruz retirée.
  - **Irié Goli Bi** : « professeur de lettres modernes, censeur au lycée moderne 1 de Grand-Bassam » retiré.
  - **Yaya Diomandé** : diplômes et journal en ligne retirés ; le roman est décrit depuis sa propre référence bibliographique.
  - **Anne-Marie Adiaffi** : détails du roman (55 ans, 15 ans, famille agni, fuite à Abidjan) ramenés à la notice.
  - **Siméon Aké** : dates corrigées (ambassadeur auprès des Nations unies de 1966 à 1977, ministre des Affaires étrangères de 1977 à 1990).
  - Treize autres retouches : Charles Konan Banny, Pascal Affi N’Guessan, Adama Bictogo, Pierre Dimba, Jean-Marc Yacé, Yanon Yapo, Alphonse Douati, Paul Koffi Koffi, Germain Coffi Gadeau, Emmanuel Éboué, Alain Gouaméné, Wilfried Kanon, Yannick Sagbo.

**Vérifié**
- `vendor/bin/pint` : conforme ; `composer test` : **164 tests, 5 659 assertions** ; `composer format:check` : 160 fichiers ; `composer analyse` : aucun problème.
- Après correction, **4 phrases** restent sous le seuil : écarts de notation vérifiés un à un — FPI pour « Front populaire ivoirien » (Dacoury-Tabley), CAN pour « Coupe d’Afrique des nations » (Ndicka, Krasso), « formé » pour les diplômes de Genève (Youssouf Bakayoko).

**Vérifié en production**
- Serveur : `git pull --ff-only` (`ae3d44a` → `b845e22`), `php artisan migrate --force` (table des redirections créée en 21 ms), seeder en **3 878 ms**, caches `config`, `route` et `view` reconstruits.
- `/articles/augustin-denise-djore` → **301** vers `/articles/auguste-denise` ; `/articles/auguste-denise` → **200**. API : `/api/v1/articles/augustin-denise-djore` → **301**, `/api/v1/articles/auguste-denise` → **200** avec sa référence.
- **301 pages** et **301 appels API** en 200, avec au moins une référence par fiche.
- Base de production : **100** écrivains, **100** sportifs, **101** politiques, **479** articles, **1** redirection.

**Reste**
- Toute fusion de fiche ultérieure devra être déclarée dans `database/data/slug_redirects.php` pour conserver l’ancienne adresse.

---

## Séance 95 — 25 novembre 2026 · Référence Abobo Marley vérifiée, phrases factuelles relues une à une

**Fait — la référence de *yaya-diomande***
- La référence « Abobo Marley, roman, JC Lattès, 2020 » est **confirmée** : parution le **16 septembre 2020** aux éditions **JC Lattès**, ISBN **9782709667845** (pages du livre chez Hachette et chez JC Lattès, Page des Libraires, dépêche RFI du 16 septembre 2020).
- L’URL générique `https://www.jclattes.fr` est remplacée par la page du livre : `https://www.editions-jclattes.fr/livre/abobo-marley-9782709667845/`.
- Le synopsis de l’éditeur (« Moussa est “balanceur” sur un gbaka… entre Abobo et Adjamé ») justifie la phrase de la fiche, qui est conservée.

**Fait — relecture phrase par phrase**
- Les 299 notices ont été téléchargées de nouveau (les trois pages sans extrait récupérées avec leur titre exact). Après le scan : **51** phrases sous le seuil de recouvrement, dont **46** dont toutes les ancres figurent dans la notice — ce sont celles relues une à une, avec le passage de notice correspondant affiché à côté.
- **21 fiches retouchées, dont une réécrite.** Les phrases qui déformaient la notice :
  - **Guillaume Soro** : « prend ses distances avec la majorité et fonde son propre mouvement politique » n’est pas dans la notice — remplacé par sa démission de la présidence de l’Assemblée, le 8 février 2019.
  - **Robert Beugré Mambé** : « conduit plusieurs grands chantiers d’infrastructures de la capitale économique » remplacé par son poste au BCET (1977-1985) ; la fin de phrase sur le gouvernement formé en 2023, absente de la notice, est retirée.
  - **Bernard Dadié** : le résumé de *Climbié* (scolarité entre école villageoise et grands établissements) cède la place à la notice : premier roman qualifié d’autobiographique — ce que l’auteur refuse —, qui expose l’acculturation par la langue française imposée par la colonisation.
  - **Bernard Zadi Zaourou** : fiche réécrite. Les trois phrases de commentaire littéraire (« à la fois élu et conteur », « une langue poétique qui parle au village comme à la ville », « la poésie et l’engagement public se répondent ») ne venaient pas de la notice ; elles sont remplacées par ses fonctions, sa maîtrise de stylistique (1970), son poste d’assistant à l’université d’Abidjan et *Les Sofas suivi de L’Œil* (1967).
  - **Wilfried Bony** : « CAN 2015 victorieuse… en pivot et en point d’appui de l’attaque » remplacé par la notice (international depuis 2010, Coupe du monde 2014, quatre CAN).
  - **Michel Gbagbo** : « élu député de Yopougon en mars 2021 » corrigé en candidature sur une liste de six sièges partagés entre l’EDS et le PDCI.
  - **Youssouf Bakayoko** : la mention de la crise post-électorale, absente de la notice, est retirée ; **Seydou Diarra** : « décembre 2005 » ramené à 2005 ; **Simone Kaya** : le commentaire sur sa « place particulière » est retiré.
  - Retouches plus courtes : Kandia Camara, Jean-Baptiste Mockey, Thomas Camara, Amah Marie Tehoua, Jean-Marc Yacé, Augustin Thiam (deux phrases), Josué Guébo, Sidney Karams, Franck Kessié, Laurent Pokou, Donald-Olivier Sié, Roger Assalé, Pierre Dimba.

**Vérifié**
- `composer test` : **164 tests, 5 659 assertions** ; `composer format:check` : 160 fichiers conformes ; `composer analyse` : aucun problème ; `php -l` sur `database/data/personalities.php`.
- Après correction, **25 phrases** restent sous le seuil, dont **20** conservées après relecture (écart de formulation, contenu fidèle) et **5** à ancres absentes qui étaient déjà des écarts de notation (« élections de 2007 », « Front populaire ivoirien », « Coupe d’Afrique des nations », diplômes de Genève).

**Reste**
- Les phrases conservées restent au-dessous du seuil de recouvrement : un futur passage pourra les reformuler si le seuil de contrôle est abaissé.

---

## Séance 96 — 25 novembre 2026 · Les vingt dernières phrases ramenées au seuil

**Fait**
- Les **20 phrases** restées sous le seuil de recouvrement (toutes leurs ancres présentes dans la notice) ont été reformulées dans les mots de la notice, sans changer le fait rapporté. **21 remplacements sur 20 fiches.**
- Reformulations qui apportent une information au lieu d’un commentaire :
  - **Charles Konan Banny** : « jusqu’aux élections de 2007 » (élection qui n’a pas eu lieu cette année-là) → « Il quitte la tête du gouvernement le 29 mars 2007. »
  - **Jeannot Ahoussou-Kouadio** : « commence sa carrière dans le droit » → « Avocat d’affaires de profession, il est membre de longue date du PDCI-RDA. »
  - **Jean Konan Banny** : mention du « lendemain de l’indépendance » et de la présidence Houphouët-Boigny → « Nommé le 3 janvier 1961 ministre de la Défense du premier gouvernement Houphouët-Boigny, il occupe ce poste de 1961 à 1963 et de 1981 à 1990. »
  - **Souleymane Diarrassouba** : la phrase de synthèse sur « près d’une décennie de politique industrielle » cède la place à « En janvier 2026, il est nommé ministre du Plan et du Développement dans le gouvernement Beugré Mambé II. »
  - **Hervé Alliali** : « siège à l’Assemblée tout en participant à la vie municipale » → « Hervé Alliali est intégré à la Commission sécurité-défense de l’Assemblée nationale de Côte d’Ivoire. »
  - **Paul Antoine Bohoun Bouabré** : « pendant la crise politico-militaire » → « Le 15 août 2002, le ministère de l’Économie et des Finances devient un ministère d’État ; il demeure à ce poste jusqu’au 28 décembre 2005. »
  - **Vincent Toh Bi Irié** : « se consacrer à la politique » → son passage de sous-préfet de Tiémé (région d’Odienné).
  - **Louis Kouakou-Habonouan**, **Pierre Kipré**, **Germain Coffi Gadeau**, **Gaston Ouassénan Koné**, **Micheline Coulibaly**, **Camara Nangala**, **Fatou Fanny-Cissé**, **Didier Zokora**, **Alain Gouaméné**, **Rufin Lué**, **Christine Lohoues**, **Serey Dié**, **Ousmane Diomande** : formulations reprises de la notice (« député à l’Assemblée nationale de décembre 2011 à décembre 2016 », « travaux d’historien », « élu membre du bureau politique lors du congrès de 1947 », « Son poste de prédilection était milieu défensif », etc.).

**Vérifié**
- Nouveau scan après correction : **5 phrases** sous le seuil, **toutes à ancre absente** — FPI pour « Front populaire ivoirien » (Dacoury-Tabley), « CAN » (Ndicka, Krasso), « Formé » (Youssouf Bakayoko) et les noms du roman de Yaya Diomandé, qui viennent de sa propre référence et non de Wikipédia. **Aucune phrase à ancres présentes ne reste sous le seuil.**
- `composer test` : **164 tests, 5 659 assertions** ; `composer format:check` : 160 fichiers ; `composer analyse` : aucun problème ; `php -l` sur le fichier de données.
- Rentabilisé au passage : la phrase fautive de Charles Konan Banny (« élections de 2007 ») est corrigée.

**Reste**
- Les 5 phrases à ancre absente restent hors seuil : ce sont des écarts de notation (acronyme, dénomination officielle), pas des erreurs de contenu.

---

## Séance 97 — 25 novembre 2026 · Le seuil de recouvrement passe en test

**Fait**
- Nouveau test `backend/tests/Feature/PersonalitiesNoticeCoverageTest.php` : il **rejoue le seeder** puis parcourt les biographies, en mesurant pour chaque phrase la part de ses mots présents dans la notice. Il échoue dès qu’une phrase descend sous **0,55** alors que toutes ses ancres (années, nombres, noms propres) figurent dans la notice. Les formules évaluatives déjà écartées par l’audit restent hors champ, comme dans le scan des séances 94 à 96.
- Les notices ne sont pas versionnées : la fixture `backend/tests/Fixtures/notice_tokens.php` (0,76 Mo) ne contient que les **jetons distincts** des 301 notices relevées le 25 novembre 2026. Elle se régénère avec `php tests/Fixtures/build_notice_tokens.php <dossier des notices>` (`build_notice_tokens.php`, versionné).
- Deux détails corrigés en écrivant le test : les **titres de section** du Delta Quill (`attributes.header`) sont exclus du texte comparé, sinon ils se collent à la phrase suivante ; et l’extraction des ancres numériques ne découpe plus « 2007 » en « 200 ».

**Vérifié**
- Garde-fou éprouvé par mutation : une phrase de remplacement à **0,25** fait échouer le test en nommant la fiche, le ratio et la phrase ; le rétablissement de la phrase d’origine le rend vert.
- `composer test` : **165 tests, 5 662 assertions** ; `composer format:check` : 163 fichiers ; `composer analyse` : aucun problème. La fixture se régénère à l’identique (aucun diff).

**Reste**
- Le test ne couvre que les fiches dont la notice figure dans la fixture ; une fiche ajoutée sans notice n’est pas contrôlée avant la prochaine régénération.

---

## Séance 98 — 25 novembre 2026 · Les cent fiches d’artistes entrent dans le contrôle

**Fait — les notices manquantes**
- Les **100 fiches d’artistes** n’avaient pas de notice : elles sont toutes récupérées (téléchargement séquentiel, 0,6 s entre requêtes). Deux ont demandé une reprise : **Alpha Blondy** après un délai d’attente, et **A’Salfo** dont le titre exact est « A'salfo » — la requête sur « Salif Traoré » renvoyait une page d’homonymie.
- Fixture régénérée : **401 notices, 0,99 Mo**. Le test vérifie désormais **exactement 401 fiches** couvertes (`expect($checked)->toBe(401)`), et non plus un plancher à 290.

**Fait — les phrases signalées**
- Le contrôle étendu a signalé **12 phrases sur 6 fiches** (Ernesto Djédjé, Meiway, Magic System, Nayanka Bell, Aïcha Koné, Paco Séry). Toutes ont été réécrites dans les mots de la notice, et le scan repasse à **0**.
- La lecture des notices a révélé des **erreurs de fond** dans ces fiches, corrigées au passage :
  - **Nayanka Bell** était donnée **née en 1967 à Toulepleu et morte à Paris en 2020** : la notice la fait naître en **1963 à Agboville** (Aka Louise de Marillac), et la presse ivoirienne la suit encore en activité en 2020. La fiche reprend sa carrière réelle (choriste à la RTI en 1981, deuxième album à Paris en 1984, Lions d’Or et Africa Music Award en 1994).
  - **Aïcha Koné** était donnée **née en 1959 à Kayes, de naissance malienne** : la notice la fait naître le **21 mai 1957 à Abidjan**, originaire de Gbon (département de Boundiali), chantant en sénoufo et en dioula. Sa carrière est reprise depuis la notice (choriste à l’ORTI sous Boncana Maïga, premier 45-tours *Denikeleni* en 1979, Kundé d’honneur en 2008).
  - **Paco Séry** était donné **né à Treichville** et accompagnant « Youssou N’Dour, Fela Kuti » : la notice le fait naître le **1er mai 1956 à Divo** et cite Eddy Louiss, Monty Alexander, Jaco Pastorius, le groupe Sixun, Dee Dee Bridgewater et Manu Dibango.
  - **Meiway** était donné **né à Grand-Bassam** et surnommé « le Champignon » : la notice donne le **17 mars 1962 à Abidjan**, le vrai nom Frédéric Désiré Patrice Ehui et les surnoms « le professeur Awôlôwôh » et « le génie de Kpalèzo » ; Grand-Bassam est sa ville de citoyenneté d’honneur.
  - **Ernesto Djédjé** : la phrase sur les chansons « mêlant langues du pays, guitare et humour » cède la place au « Tohourou », rythme bété à l’origine du ziglibithy, et à sa descendance (zouglou en 1990, coupé-décalé en 2003).
  - **Magic System** : les succès sont listés depuis la notice (Un gaou à Oran, Bouger bouger, Magic in the Air).

**Vérifié**
- `composer test` : **165 tests, 5 661 assertions** ; `composer format:check` : 163 fichiers ; `composer analyse` : aucun problème ; scan de recouvrement : **0 phrase** sous le seuil avec toutes ses ancres dans la notice.

**Reste**
- Les notices des artistes restent des ébauches Wikipédia pour certaines : le contrôle porte sur le recouvrement, pas sur la complétude biographique.

---

## Séance 99 — 25 novembre 2026 · Plus aucune exemption pour les formules évaluatives

**Fait**
- L’exemption des phrases à **marqueur évaluatif** (« reste », « figure », « considéré », « légende »…) est **supprimée** du test : toutes les phrases de plus de 40 caractères sont désormais comparées à leur notice, y compris celles qui ne portent aucune ancre (dates, nombres, noms propres).
- Effet mesuré : **3 phrases** seulement restaient sous le seuil — la liste d’exemptions masquait donc peu de choses, mais elle masquait précisément les affirmations non sourcées :
  - **Jean-Marc Kraidy** (0,50) : « où il reste cinq saisons » remplacé par « De 1993 à 1998, il joue à l’ALM Évreux Basket, en Pro A. »
  - **Tiken Jah Fakoly** (0,17) : « Il reste une voix écoutée dans toute l’Afrique francophone » supprimé. La notice contredit aussi l’exil : il est **exilé au Mali** en 2003 à la suite de menaces de mort (et non « d’abord au Burkina Faso puis en France ») ; la fiche ajoute l’ouverture de son studio à Bamako en 2006.
  - **DJ Arafat** (0,43) : le commentaire sur les « deuils nationaux de la décennie » cède la place aux faits de la notice (scènes d’hystérie à l’annonce de la mort, funérailles du 30 au 31 août 2019). Au passage, le vrai nom (**Ange Didier Houon**, et non Ange Huessan Kouadio) et le lieu de naissance (**Cocody**, et non Yopougon) sont corrigés.
- Garde-fou revérifié : réintroduire « Il reste une voix écoutée dans toute l’Afrique francophone » fait échouer le test en la citant à 0,17.

**Vérifié**
- `composer test` : **165 tests, 5 661 assertions** ; `composer format:check` : 163 fichiers ; `composer analyse` : aucun problème ; environ **2 570 phrases** passent désormais au contrôle, sans exemption.

**Reste**
- Le seuil de 0,55 reste une mesure lexicale : une phrase peut le dépasser tout en ajoutant une nuance que la notice ne porte pas. La relecture humaine garde sa place.

---

## Séance 100 — 25 novembre 2026 · Phrases courtes contrôlées et ponctuation surveillée

**Fait**
- Le **plancher de 40 caractères** est supprimé : toute phrase est comparée à sa notice, y compris les plus courtes — c’est là que passait une affirmation brève comme « Elle est morte en 2020 » sur la fiche Nayanka Bell, réécrite en séance 98.
- Deux phrases courtes étaient encore dessous et sont corrigées, avec la notice à l’appui :
  - **Seydou Diarra** (0,25) : « Son second mandat s’achève en 2005. » → « En 2005, il est remplacé par Charles Konan Banny. » (titre et phrase de la notice : « De nouveau Premier ministre (2003-2005) », « en 2005, Seydou Diarra est remplacé par Charles Konan Banny »).
  - **Tiken Jah Fakoly** (0,00) : « Il se réclame du panafricanisme. » — la notice ne prononce pas une fois le mot — remplacé par « D’autres chansons évoquent la corruption et l’exploitation de la population par les hommes politiques. » Le résumé perd aussi la formule fautive « chante la justice et la panafricanisme » au profit de « évoque les injustices que subit la population africaine ».
- **Garde-fou de ponctuation** dans le même test : `personalitiesPunctuationPatterns()` vérifie le résumé et chaque paragraphe et fait échouer le test sur un **double point**, un **espace avant une virgule ou un point**, ou des **espaces multiples** — les trois défauts que laissaient mes scripts de réécriture. L’espace avant `;`, `:` ou `?` reste autorisé : c’est la typographie française.
- Les deux `..` laissés par les passes de cette séance ont été corrigés avant commit.

**Vérifié**
- Garde-fous éprouvés par mutation, puis restaurés : une phrase de 31 caractères (« Il orchestre un putsch en 2005. ») fait échouer le test à 0,33 ; un `..` ajouté à Seydou Diarra fait échouer le test avec `seydou-diarra : double point`.
- `composer test` : **165 tests, 5 662 assertions** ; `composer format:check` : 163 fichiers ; `composer analyse` : aucun problème. Environ **2 570 phrases** contrôlées, courtes comprises.

**Reste**
- Une phrase courte faite uniquement de mots présents dans la notice peut encore passer sous le seuil (mesure lexicale) : la relecture humaine reste le dernier filet.

---

## Séance 101 — 25 novembre 2026 · Garde-fou de ponctuation étendu aux titres

**Fait**
- Le garde-fou de ponctuation couvre désormais aussi les **titres de section** (blocs `h2`) : `noticeCoverageHeadings()` extrait les `insert` porteurs de `attributes.header` et les passe aux trois mêmes motifs (double point, espace avant virgule ou point, espaces multiples). Un défaut est signalé avec sa localisation : `slug (titre 2) : double point`.
- Aucun titre du corpus n’était défectueux : le test est passé au vert dès l’extension, sans correction de contenu. `personalities.php` n’a donc pas été modifié et la production n’a pas été re-seedée.

**Vérifié**
- Garde-fou éprouvé par mutation, puis restauré : `['h2', 'L’exil ..']` sur la fiche Tiken Jah Fakoly fait échouer le test avec `tiken-jah-fakoly (titre 2) : double point` et `tiken-jah-fakoly (titre 2) : espace avant virgule ou point` ; le titre restauré, le test repasse au vert.
- `composer test` : **165 tests, 5 662 assertions** ; `composer format:check` : 163 fichiers ; `composer analyse` : aucun problème.

**Reste**
- Les titres ne sont contrôlés que sur la ponctuation, pas sur le recouvrement : ce sont des libellés de section, souvent absents de la notice.

---

## Séance 102 — 25 novembre 2026 · Angles morts : les faits que le score ne voit pas

**Fait**
- Audit des angles morts, en trois passes hors test (scripts dans `backend/.tmp-audit3/`) :
  1. **Phrase contre phrase** : pour chaque phrase courte portant une ancre, comparaison avec la phrase de la notice qui contient cette ancre — 54 suspects sur 1 246 phrases, revus un par un.
  2. **Lieux de naissance** cités et absents de la notice : 6.
  3. **Années de naissance et de mort** des fiches absentes de la notice : 21.
- Le score de recouvrement élevé ne prouve rien : il suffit que les mots existent quelque part dans la notice. Cas typiques corrigés :
  - **DJ Arafat** : « animateur de soirées » et « phrases chocs » n'existent pas dans la notice ; remplacés par le producteur Roland le Binguiste, le début de carrière en 2003, « Hommage à Jonathan », Goudron Noir et les deux prix des Kora Awards 2012. Le résumé perd « animateur » et la formule « a marqué le pays par son énergie et ses phrases ».
  - **Simone Gbagbo** : « à la tête de son propre parti » n'est dit nulle part — remplacé par sa demande d'amnistie du 11 août 2020 pour son époux.
  - **Gervinho** : « Moyen-Orient » — la notice le mène en Chine, en Italie et en Turquie.
  - **Tidjane Thiam** : il dirige le Crédit suisse depuis **juillet 2015**, pas 2009 (le résumé disait 2009-2020) ; il est ministre du Plan et du **Développement**, pas du Budget.
  - **Decothey** : « originaire d'Abidjan » et « né à Abidjan » ne sont pas dans la notice.
  - **Aboudia** : la notice donne le 21 octobre 1983, pas Abengourou.
  - **Irié Goli Bi** et **Jean-Paul Mehansio** : la notice ne donne ni date ni lieu de naissance ; Babelio ne confirme que le département de Bouaflé pour le premier. Dates et lieux retirés, fiches rendues sans année.
  - **Nayanka Bell** : la notice la dit **née en 1963 à Agboville** et ne la fait pas mourir — les métadonnées disaient 1967, Toulepleu, morte en 2020 à Paris. Métadonnées corrigées, décès supprimé (la fausse mort ne subsistait plus que là).
  - **Aïcha Koné** : née en **1957** à Abidjan (métadonnées : 1959, Kayes au Mali).
  - **Laurent Dona Fologo** : **Péguékaha**, orthographe de la notice.

**Vérifié**
- `composer test` : **165 tests, 5 662 assertions** ; `composer format:check` : 163 fichiers ; `composer analyse` : aucun problème ; test de recouvrement vert après correction. Les pages des fiches corrigées répondent en 200 et servent les nouveaux textes.

**Reste**
- Le contrôle reste lexical : il attrape les faits fabriqués quand leurs mots manquent, pas quand ils sont composés de mots présents (le « Il meurt en 2005 » construit avec des mots de la notice passe).

---

## Séance 103 — 25 novembre 2026 · Dates de naissance tranchées sur l'article complet

**Fait**
- Vérification sur l'**article Wikipédia complet** (API `prop=extracts`, texte intégral) des dix-huit fiches dont une date avait été retirée ou restait douteuse. Comparaison des tailles : les notices locales et les extraits complets sont **identiques** — les fichiers n'étaient pas tronqués, seulement dépourvus d'infobox.
- Aucun article ne donne d'année de naissance pour : **Irié Goli Bi** (seul le département de Bouaflé, via Babelio), **Jean-Paul Mehansio**, **Cédric Marshall Kissy**, **Gina Dick Boguifo**, **Hanny Tchelley**, **Antoinette Konan**, **Chantal Taïba**, **Papa Ministre**, **Naky Sy Savane**, **Philippe Lacôte**, **Adama Dahico**, **Claudie Titty-Dimbeng**, **Gbizié Troupa Bruno**, **Victor Guéi**, **Angéline Nadié**, **Josiane Yapo**. Les retraits d'Irié Goli Bi et Mehansio sont donc **confirmés** ; la même règle a été appliquée aux seize autres (année retirée du texte et des métadonnées, lieu conservé quand l'article le donne).
- **Soum Bill** : l'article dit « au début des années 1970 », pas 1972 ; le texte garde la formulation prudente, la métadonnée passe à vide.
- **Tangara Speed Ghôda** : l'article complet ne dit **nulle part** qu'il est mort — la seule mention funêbre concerne son père — et n'emploie pas 2002. Le décès de 2002 est donc **retiré** (métadonnées et résumé « (1962-2002) » → « né en 1962 »), faute de source.
- Bilan des trois contrôles automatiques : plus **aucune année de naissance ou de mort** de fiche absente de sa notice, et un seul lieu signalé — **Tiburce Koffi**, où la notice écrit « bouake » sans accent face au « Bouaké » exact de la fiche (faux positif).

**Vérifié**
- `composer test` : **165 tests, 5 662 assertions** ; `composer format:check` : 163 fichiers ; `composer analyse` : aucun problème ; test de recouvrement vert. Production re-seedée, les fiches corrigées répondent en 200 et servent les textes sans année.

**Reste**
- Les fiches sans année de naissance s'affichent sans année : si une source tierce (Babelio, Africultures, presse) documente une date, elle peut être rétablie avec sa référence propre, conformément à la règle de fidélité.
- Le contrôle automatique des années compare la métadonnée au texte de la notice ; il ne peut pas détecter une année juste lexicalement mais mal associée à un événement (cas Thiam, corrigé à la main).

---

## Séance 104 — 25 novembre 2026 · Années de naissance rétablies avec leur source

**Fait**
- Recherche de source explicite pour chaque année retirée en séance 103, puis vérification de la page elle-même (citation lue, pas de reprise d'un résumé). **Onze années rétablies**, chacune avec sa propre référence ajoutée à la bibliographie de la fiche :
  - **Irié Goli Bi, 1960** — facilitateur didactique de *Le Testament* (FP Éditions, 2023) : « est né en 1960 à Vrigrita ».
  - **Jean-Paul Mehansio, 11 décembre 1986 à Bangolo** — *Jeune Afrique*, 4 novembre 2016.
  - **Cédric Marshall Kissy, 1988 à Grand-Bassam** — notice Takam Tikou / BnF, 25 juillet 2019.
  - **Antoinette Konan, 1961 à Béoumi** — Qobuz (Music Story) : la source donne **1961**, et non 1960 comme la fiche l'affirmait avant le retrait.
  - **Papa Ministre, 26 juin 1979** — Qobuz (Music Story).
  - **Adama Dahico, 10 mai 1968 à Adjamé** — Africultures.
  - **Claudie Titty Dimbeng, 1968 à Abidjan** — galerie LouiSimone Guirandou (et son CV PDF).
  - **Soum Bill, 2 novembre 1972 à Aboisso** — Universal Music France : le texte ne dit plus « au début des années 1970 ».
  - **Angéline Nadié, 1968** — 24 News Agency, 19 juillet 2021 (« Née en 1968, morte le 17 juillet 2021 »).
  - **Naky Sy Savané, 1970** — Wikipédia anglophone (l'article s'appuie sur Wikidata).
  - **Philippe Lacôte, 1969** — IFFR ; **réserve** : l'African Film Festival indique 1971. L'année 1969 est celle de deux sources (IFFR, Africultures), la contradiction est signalée ici.
- **Six fiches restent sans année**, faute de source explicite : Gina Dick Boguifo, Hanny Tchelley, Chantal Taïba (Jeune Afrique ne donne que « 17 ans en 1982 »), Gbizié Troupa Bruno, Victor Guéi, Josiane Yapo.

**Vérifié**
- Chaque source a été ouverte et sa phrase relue avant rétablissement. `composer test` : **165 tests, 5 662 assertions** ; `composer format:check` : 163 fichiers ; `composer analyse` : aucun problème ; test de recouvrement vert (les phrases citant ces années ont des ancres absentes de la notice, elles ne déclenchent donc pas de faux positif). Production re-seedée.

**Reste**
- Trois références sont de qualité inégale et signalées comme telles : Naky Sy Savané (Wikipédia anglophone), Angéline Nadié (petit média en ligne), Philippe Lacôte (deux sources contre une). À remplacer si une source institutionnelle apparaît.

---

## Séance 105 — 25 novembre 2026 · Les références faibles tranchées

**Fait**
- **Angéline Nadié** : la référence est remplacée par **Linfodrome** (23 juillet 2021, Philip Kla), qui écrit noir sur blanc « née le 1er janvier 1968 et morte le 17 juillet 2021 ». Année 1968 conservée, petit média remplacé par un quotidien ivoirien.
- **Naky Sy Savané** : aucune source institutionnelle ni de presse de référence ne donne l'année. Le seul document qui l'affirme (1970) est une **fiche d'agence de casting** (Séquence Sud / Filmmakers), pas une source. Année **retirée**, ainsi que la référence Wikipédia anglophone ajoutée en séance 104.
- **Philippe Lacôte** : contradiction non arbitrée. Le **dossier de presse officiel du Festival de Cannes** (*Run*, 2014) écrit « Né en 1971 à Abidjan » ; l'IFFR et Africultures disaient 1969. Faute de source qui tranche, l'année est **retirée** et la référence IFFR supprimée.
- **Les six fiches sans année** ont été recherchées à nouveau, sans succès :
  - **Gina Dick Boguifo** : BnF/Takam Tikou et Éditions Éburnie ne donnent que « née et vit en Côte d'Ivoire » ; l'annuaire *A Celebration of Women Writers* la date par « fl. 1993 ».
  - **Hanny Tchelley** : sa notice Wikipédia porte « Date de naissance non renseignée » ; Africultures et le SPLA ne donnent que la formation 1983-1985.
  - **Chantal Taïba** : *Jeune Afrique* (2006) dit seulement « En 1982, elle a 17 ans » — une année se déduit, elle n'est pas écrite.
  - **Gbizié Troupa Bruno** : le communiqué du ministère de la Culture (22 août 2026) donne le décès, pas la naissance.
  - **Victor Guéi** : Music In Africa et Afrisson donnent le décès du 12 juin 2006, pas la naissance.
  - **Josiane Yapo** : AllAfrica parle d'une actrice « à 30 ans » en 2004 ; le document n'a pas pu être rouvert pour vérification, donc rien n'est ajouté.

**Vérifié**
- `composer test` : **165 tests, 5 662 assertions** ; `composer format:check` : 163 fichiers ; `composer analyse` : aucun problème. Production re-seedée : `naky-sy-savane` et `philippe-lacote` s'affichent sans année, `angeline-nadie` garde 1968 avec Linfodrome en référence.

**Reste**
- 26 fiches n'ont pas d'année de naissance : c'est désormais un état assumé, pas un oubli. Toute année rétablie devra venir avec sa référence, comme les onze de la séance 104.

---

## Séance 106 — 25 novembre 2026 · Le garde-fou des années de naissance et de mort

**Fait**
- Le test de recouvrement porte une **cinquième vérification** : pour chaque fiche, les années de `birthDate` et `deathDate` de l'infobox sont comparées aux jetons de la notice ; si une année manque à la notice, la fiche doit citer **au moins une référence qui n'est pas Wikipédia** (les éditeurs contenant « wiki », donc Wikidata, sont exclus au même titre). Sinon le test échoue avec `slug (naissance 1953) : année absente de la notice et sans référence hors Wikipédia`.
- La liste des références est chargée avec `with('references')` : une requête de plus, pas une par fiche.
- Aucun contenu n'a changé : le corpus est déjà conforme (les onze années hors notice de la séance 104 ont toutes leur référence propre, et les vingt-six fiches sans année ont un champ vide).

**Vérifié**
- Garde-fou éprouvé par mutation, puis restauré : donner `1953` comme année de naissance à **Josiane Yapo** (référence Wikipédia seule, notice sans 1953) fait échouer le test en citant exactement `josiane-yapo (naissance 1953)` ; la valeur remise à vide, le test repasse au vert.
- Contre-épreuve sans mutation : les années de la séance 104 absentes de la notice (Irié Goli Bi 1960, Mehansio 1986, Papa Ministre 1979…) passent bien grâce à leur référence propre.
- `composer test` : **165 tests, 5 663 assertions** ; `composer format:check` : 163 fichiers ; `composer analyse` : aucun problème.

**Reste**
- Le garde-fou contrôle la présence de l'année dans la notice et l'existence d'une référence hors Wikipédia, pas la qualité de cette référence : c'est la leçon des séances 104-105, où deux d'entre elles ont été retirées à la main.

---

## Séance 107 — 25 novembre 2026 · Le garde-fou des lieux

**Fait**
- Le même contrôle s'applique maintenant aux champs `birthPlace` et `deathPlace` : si aucun mot du lieu (plus de deux lettres) ne figure dans la notice, la fiche doit citer une référence hors Wikipédia, sinon le test échoue avec `slug (lieu de mort Treichville) : lieu absent de la notice et sans référence hors Wikipédia`.
- La comparaison est **insensible aux accents**, via `noticeCoveragePlain()` : la notice écrit « bouake », la fiche « Bouaké », et cela ne doit pas être un faux positif. Un mot suffit (la ville), les précisions entre parenthèses ne sont donc pas obligatoires.
- La simulation sur le corpus a trouvé **trois lieux faux**, corrigés d'après la notice :
  - **Siméon Aké** : né à **Bingerville** (la fiche disait Tagbougbe).
  - **Emmanuel Eboué** : né à **Abidjan** (la fiche disait Koukoua).
  - **Paco Séry** : né à **Divo** (la fiche disait Treichville, alors que son propre texte disait Divo dans le résumé et la première phrase).

**Vérifié**
- Garde-fou éprouvé par mutation, puis restauré : donner `Treichville` comme lieu de mort à Josiane Yapo (référence Wikipédia seule) fait échouer le test en citant exactement `josiane-yapo (lieu de mort Treichville)` ; remis à Ouagadougou, le test repasse au vert.
- `composer test` : **165 tests, 5 664 assertions** ; `composer format:check` : 163 fichiers ; `composer analyse` : aucun problème. Production re-seedée, les trois fiches corrigées répondent en 200.

**Reste**
- Le garde-fou ne vérifie que la présence d'un mot du lieu dans la notice : un lieu composé dont la ville est citée passe, même si la précision entre parenthèses est inventée. Une relecture reste nécessaire pour les lieux à plusieurs niveaux.

---

## Séance 108 — 26 novembre 2026 · Le mot principal du lieu

**Fait**
- Le contrôle des lieux exige désormais **tous les mots de la ville**, c'est-à-dire la partie avant la parenthèse : `Treichville (Abidjan)` n'est accepté que si la notice parle de Treichville, pas parce qu'elle parle d'Abidjan. Une précision inventée entre parenthèses ne peut donc plus sauver un lieu faux.
- La règle reste insensible aux accents et tolère les villes composées (`Grand-Bassam` exige les deux mots). Un lieu sans mot utile (moins de trois lettres) est accepté par défaut.
- Aucune donnée à corriger : la simulation sur les 423 lieux du corpus donne **0 écart** sous la règle resserrée. Les écarts de la séance 107 venaient tous de la partie entre parenthèses.

**Vérifié**
- Le trou de la séance 107 est refermé, éprouvé par mutation puis restauré : `Treichville (Ouagadougou)` comme lieu de mort de Josiane Yapo échoue maintenant avec `josiane-yapo (lieu de mort Treichville (Ouagadougou))`, alors que l'ancienne règle l'acceptait grâce à Ouagadougou.
- `composer test` : **165 tests, 5 664 assertions** ; `composer format:check` : 163 fichiers ; `composer analyse` : aucun problème. Production re-seedée, les trois fiches corrigées en séance 107 répondent en 200.
- Caches de production reconstruits après la coupure SSH de la séance précédente : `config:cache`, `route:cache` et `view:cache` réussissent sur le commit `0d7f1d9` (Laravel 13.39.0, PHP 8.4.28, `APP_ENV=production`). Le site répond en **200** sur `/`, `/api/v1/health` et `/api/v1/categories`, et les trois fiches corrigées servent bien `Bingerville` (Siméon Aké), `Abidjan` (Emmanuel Éboué) et `Divo` (Paco Séry).

**Reste**
- Un lieu dont la ville est citée mais dont le pays ou la région entre parenthèses est faux passe encore : le garde-fou compare des mots, il ne valide pas la hiérarchie administrative.
- Le test tolère une phrase dont une ancre (nom propre, chiffre) est absente de la notice : l'ancre inconnue fait sortir la phrase du contrôle au lieu de la signaler. Une phrase qui invente un nom échappe donc au seuil de recouvrement.

---

## Séance 109 — 26 novembre 2026 · Les ancres inconnues d'une phrase

**Motif** : dans le test de recouvrement, une phrase dont un nom propre, une année ou un chiffre manquait à la notice sortait du contrôle au lieu d'échouer — le trou restant après les séances 107 et 108.

**Fait**
- Nouvelle assertion `$unsourcedAnchors` : une phrase dont une ancre est absente de la notice échoue, sauf si la fiche possède une référence propre hors Wikipédia — la règle déjà appliquée aux années et aux lieux.
- `noticeCoverageSentenceAnchors()` définit ce qu'est une ancre, pour éviter de condamner la langue courante : années (16xx-202x), nombres, et noms propres. Ne sont pas des ancres : la majuscule de début de phrase, un mot capitalisé précédé d'un déterminant ou d'un numéral (« les Éléphants », « du Front », « deux Coupes »), un sobriquet entre guillemets (« Big »), un sigle (CAN, PDCI-RDA) et les noms communs capitalisés listés par `noticeCoverageCommonCapitals()`.
- Le nom du sujet lui-même est écarté : il est garanti par le titre de l'article.
- Les âges (« à 33 ans ») sont écartés : ils découlent des dates, déjà contrôlées par le garde-fou des années.
- Un nombre se compare chiffre à chiffre : `1 500` et `1500` sont le même nombre, et `1 000` se lit aussi quand la notice écrit les milliers séparément.
- Comparaison insensible aux accents, aux traits d'union et aux apostrophes, comme pour les lieux : `Tiérou` et `Tierou`, `Houphouët-Boigny`, `N’Goran`.

**Corrigé — 27 phrases dans 24 fiches (26 passages)**
- *Détails que la notice ne porte pas* : « succédant à Jeannot Ahoussou-Kouadio » (Kandia Camara), la date de 2020 et le mois de nomination (Vagondo Diomandé), « depuis le 23 septembre 2026 » (Fodjo Kadjo Abo), le mari de Marie Laure N'Goran, le collège de Plymouth et les années 1980 (Gina Dick Boguifo), « cité Arras 1 » (Sidney Karams), « à Claix » (Lacina Traoré), « à Johannesburg », « au Qatar » requalifié en `Al-Gjarafa`, la date de prêt 2012 et 2014 (Jonathan Kodjia), le nombre de rencontres de 2014-2015 (Jean-Philippe Gbamin), le quartier de Marcory (Magic System), le prix de 1995 (Fadika Kramo Lanciné), la date de 1964 remplacée par Tokyo (Gaoussou Koné), la clause Saint-Étienne de 2005 (Siaka Tiéné), « à Paris » (Decothey), le nom du pasteur, la précision « Yambo Ouologuem ».
- *Formes alignées sur la notice* : « Johannesbourg », « Saint Marc and Saint John », « Al-Gjarafa », « Bamba Kakary » écarté au profit des seuls noms portés par la notice, « Isaïe Biton » sans le patronyme, « Barry Copa », « le président Ouattara », « Puissance des lettres » (le titre que donne la notice), « championnat belge » au lieu de « champion de Belgique », « à Nice » au lieu de « en France », « à l'Udinese » au lieu de « en Italie ».

**Vérifié**
- Le garde-fou échoue là où il doit : ajouter « par Kwamé Zongo » à la fiche Magic System (sans référence propre) fait échouer le test avec `magic-system (nom propre Kwamé Zongo)` ; la phrase restaurée, le test repasse au vert.
- `composer test` : **165 tests, 5 665 assertions** ; `composer format:check` : 163 fichiers ; `composer analyse` : aucun problème.

**Reste**
- Les sigles ne sont pas vérifiés : la notice peut écrire « Coupe d'Afrique des nations » là où la fiche écrit « CAN ».
- Un nom propre qui est aussi un nom commun capitalisé (liste `noticeCoverageCommonCapitals()`) passe sans contrôle ; la liste devra grandir avec le corpus.
- Les variantes orthographiques suivent la notice, y compris quand elle est fautive : la fiche dit désormais « Al-Gjarafa » et « Saint Marc and Saint John ».
- Les textes corrigés ne sont pas encore en production : un `db:seed --class=PersonalitiesSeeder --force` reste à lancer.

---

## Séance 110 — 26 novembre 2026 · Les ancres en production et un cas permanent

**Motif** : la séance 109 avait éprouvé le garde-fou par une mutation manuelle, puis restaurée — rien dans la suite ne prouvait qu'il échouerait encore. Les phrases corrigées n'étaient pas non plus en production.

**Fait**
- Le contrôle des ancres sort de la boucle du test dans `noticeCoverageUnsourcedAnchors(Article $article, string $noticeText)` : pour une fiche sans référence propre, il rend la liste de ses ancres absentes de la notice. Le balayage des 401 fiches et le nouveau cas permanent passent par la même fonction, donc le cas éprouve exactement le chemin du corpus.
- Nouveau test permanent « échoue sur une ancre inventée, absente de la notice et sans référence propre » : il constate d'abord que la fiche Magic System, couverte par la notice seule, ne signale aucune ancre ; il lui ajoute ensuite « Le groupe se produit en 1723 par Kwamé Zongo. » et exige les deux signalements, le nom propre et l'année.
- Production re-seedée sur le commit `4152bc3` (`db:seed --class=PersonalitiesSeeder --force`, 4 209 ms), puis `config:cache`, `route:cache` et `view:cache` reconstruits.

**Vérifié**
- `composer test` : **166 tests, 5 670 assertions** ; `composer format:check` : 163 fichiers ; `composer analyse` : 75 fichiers, aucun problème.
- Les fiches corrigées sont servies : `kandia-camara` (sans « Ahoussou »), `seko-fofana` (« Udinese ») et `gaoussou-kone` (section « Tokyo 1964 ») répondent en **200** sur `/api/v1/articles/{slug}`.

**Reste**
- Les titres de section échappent au contrôle des ancres : « Tokyo 1964 » (Gaoussou Koné) porte une année que la notice ne donne pas — elle ne dit que Tokyo — alors que le corps de la fiche a été aligné en séance 109.

---

## Séance 111 — 26 novembre 2026 · Les ancres des titres de section

**Motif** : le garde-fou des ancres ne lisait que le résumé et les paragraphes. La fiche Gaoussou Koné gardait donc un titre « Tokyo 1964 » alors que sa notice ne donne que Tokyo — le reste signalé en séance 110.

**Fait**
- `noticeCoverageUnsourcedAnchors()` contrôle désormais chaque titre de section comme une phrase ; chaque titre est traité seul, pour ne pas hériter du contexte de la phrase suivante.
- Le titre de Gaoussou Koné revient à « Tokyo », la seule forme que porte la notice ; le corps de la fiche avait été aligné en séance 109.
- Le titre de Mix Premier « Entre Cotonou et Abidjan » devient « Entre Cotonou et Port-Bouët » : la notice écrit que la famille s'installe à Port-Bouët en 1992 et ne nomme jamais Abidjan.
- Le cas permanent de la séance 110 ajoute un titre de section inventé (« Chapitre de 1834 par Zépherin Kacou ») et exige les deux signalements, en plus de ceux du corps.

**Vérifié**
- Le corpus des 401 fiches passe avec les titres sous contrôle : les seuls écarts étaient ces deux titres, tous deux corrigés.
- `composer test` : **166 tests, 5 672 assertions** ; `composer format:check` : 163 fichiers ; `composer analyse` : aucun problème.
- Production re-seedée et caches reconstruits ; `gaoussou-kone` répond en 200 et sert la section « Tokyo », sans « 1964 ».

**Reste**
- Un titre sans ancre vérifiable (« Débuts », « Carrière ») n'est pas contrôlé, et les sigles restent hors du garde-fou.

---

## Séance 112 — 26 novembre 2026 · Les sigles

**Motif** : dernier angle mort du garde-fou. Un sigle (CAN, PDCI-RDA) sortait du contrôle au motif qu'il abrégeait « un nom que la notice porte en clair » ; une fiche pouvait donc écrire une abréviation que sa notice ignore.

**Fait**
- Un sigle est désormais une ancre (`sigle`) : il ne passe que si la notice le porte tel quel, tous ses segments (`CFA2` compris), ou si elle en donne le nom en clair.
- `noticeCoverageAcronymExpansions()` fixe ce nom en clair, avec des variantes quand la notice écrit plus court : CAN (Coupe d'Afrique des nations, ou Coupe d'Afrique), PDCI-RDA, IAAF (forme française et forme anglaise de la notice), SG (Saint-Germain ou secrétaire général), etc. Un sigle absent de la table ne passe que s'il figure littéralement dans la notice.
- Le contrôle passe avant l'exemption de début de phrase et celle du déterminant : « la CAN » est vérifiée comme « CAN ». Un mot en capitales est vérifié même collé à un nom propre (« Paris SG » donne le sigle SG), et un sigle à chiffre reste un tout (« CFA2 »).
- Quatre fiches corrigées : Jean Konan Banny et Laurent Dona Fologo disaient PDCI-RDA là où leur notice ne dit que PDCI ; Tchiressoua Guel disait « Ligue des champions de la CAF » là où la notice dit « Ligue des champions africaine » ; Donald-Olivier Sié opposait le Paris SG, que sa notice ne nomme pas.
- Le cas permanent de la séance 110 ajoute « Il adhère ensuite à la CTP. » et exige `magic-system (sigle CTP)`.

**Vérifié**
- Corpus des 401 fiches vert avec les sigles sous contrôle ; les quatre écarts étaient ces quatre fiches, toutes alignées sur leur notice.
- `composer test` : **166 tests, 5 673 assertions** ; `composer format:check` : 163 fichiers ; `composer analyse` : aucun problème.
- Production re-seedée et caches reconstruits ; les fiches corrigées répondent en 200 et ne portent plus les sigles retirés.

**Reste**
- Un sigle absent de `noticeCoverageAcronymExpansions()` et absent littéralement de la notice échoue : la table devra grandir avec le corpus, comme `noticeCoverageCommonCapitals()`.
- Les fiches qui possèdent une référence propre hors Wikipédia restent hors de ces contrôles d'ancres, sigles compris.

---

## Séance 113 — 26 novembre 2026 · Les références propres, affirmation par affirmation

**Motif** : l'exemption des contrôles d'ancres était accordée à la fiche entière dès qu'elle citait une source non-Wikipédia. L'audit de la séance précédente a montré que 29 des 42 fiches n'en avaient pas besoin et que deux d'entre elles s'appuyaient sur une page d'accueil.

**Fait**
- `noticeCoverageOwnSourceClaims()` remplace l'exemption de fiche : chaque entrée lie une fiche, une affirmation normalisée (année, nombre, nom, lieu) et l'URL de la page qui la porte. Les neuf dates et lieux de la tranche 1 y sont inscrits après ouverture des pages : Africultures, Jeune Afrique, Takam Tikou (BnF), galerie LouiSimone Guirandou, Universal Music, Linfodrome, Qobuz (deux fiches) et le facilitateur FP Éditions.
- `noticeCoverageHasOwnSource()` ne sert plus au contrôle : seules les affirmations listées échappent à la notice, dans le texte comme dans l'infobox (année et lieu de naissance ou de mort).
- `noticeCoveragePendingClaims()` liste les sept affirmations de la tranche 2 encore à arbitrer — Yaya Diomandé, Tidjane Thiam, Charles Konan Banny, Hanny Tchelley — visible dans le test, à vider avant de clore l'audit.
- Le cas permanent ajoute une référence non-Wikipédia à la fiche Magic System et vérifie que le sigle inventé « CTP » reste signalé : une référence propre ne couvre plus la fiche.
- Piège corrigé : `array_merge` renumérote les clés numériques, donc « 1968 » ne matchait jamais l'exception ; l'union `+` conserve les clés.

**Vérifié**
- Corpus des 401 fiches vert : les neuf affirmations de la tranche 1 passent par leur liste, pas par une exemption de fiche.
- `composer test` : **166 tests, 5 675 assertions** ; `composer format:check` : 163 fichiers ; `composer analyse` : 75 fichiers, aucun problème.
- Production re-seedée et caches reconstruits ; `adama-dahico` et `cedric-marshall-kissy` répondent en 200 et servent leurs dates.

**Reste**
- Tranche 2 : sept affirmations dans quatre fiches (Yaya Diomandé, Tidjane Thiam, Charles Konan Banny, Hanny Tchelley), dont deux adossées à des pages d'accueil ; à vérifier puis, soit inscrire dans `noticeCoverageOwnSourceClaims()`, soit les aligner sur la notice.
- Une fois `noticeCoveragePendingClaims()` vide, l'audit des références propres est clos.

---

## Séance 114 — 26 novembre 2026 · Tranche 2 des références propres

**Motif** : les quatre fiches restantes de l'audit. La vérification a montré que deux affirmations n'étaient pas seulement non sourcées, mais fausses.

**Corrigé**
- **Tidjane Thiam** : « direction de la BICICI puis groupe Axa » remplacé par le parcours que porte la notice — retour chez McKinsey à Paris de 2000 à 2002, puis équipe dirigeante d'Aviva en France. Aucune source ne mentionne la BICICI, et son assureur est Aviva, pas Axa. La référence « Conseil constitutionnel » reste : elle documente la proclamation de 2025, pas la carrière.
- **Charles Konan Banny** : « formé à l'université de Dijon » remplacé par « diplômé de l'ESSEC en 1968 », la formation réelle (RFI, FratMat, Wikipédia) et la forme que porte la notice. La référence BCEAO reste, elle documente son gouvernorat.
- **Hanny Tchelley** : « Kidderminster » devient « Kiddeminster », l'orthographe de la notice, reprise de sa référence Africultures — même règle que « Al-Gjarafa » en séance 109.
- **Yaya Diomandé** : les quatre affirmations (2020, JC Lattès, Moussa, Adjamé) versées dans `noticeCoverageOwnSourceClaims()` avec la page JC Lattès ; `noticeCoveragePendingClaims()` est supprimée, la liste d'attente est vide.

**Vérifié**
- Corpus des 401 fiches vert ; plus aucune exception de fiche, seulement treize affirmations vérifiées, chacune adossée à sa page.
- `composer test` : **166 tests, 5 675 assertions** ; `composer format:check` : 163 fichiers ; `composer analyse` : 75 fichiers, aucun problème.
- Production re-seedée et caches reconstruits ; les trois fiches corrigées répondent en 200 (Thiam sans BICICI ni Axa, Banny avec ESSEC 1968, Tchelley avec Kiddeminster).

**Reste**
- L'audit des références propres est clos : plus aucune fiche n'échappe globalement aux garde-fous d'ancres.
- Les 22 références qui sont des pages d'accueil restent faibles ; elles ne portent plus aucune exception et pourront être remplacées par des pages précises lors d'un prochain passage.

---

## Séance 115 — 26 novembre 2026 · Les pages d'accueil remplacées

**Motif** : l'audit des références propres avait relevé 22 références qui pointaient vers l'accueil d'un site, sans page portant l'information.

**Résultat** : 18 remplacées par la page précise, 4 retirées quand la notice suffit et qu'aucune page ne porte le fait. Il reste **40 références propres sur 38 fiches**, et plus aucune page d'accueil.

**Remplacées**
- **Conseil constitutionnel** : décision du 8 septembre 2025 (PDF) pour Tidjane Thiam, page 2011-2015 pour Francis Wodié.
- **BCEAO** : « Les dates qui ont marqué la vie de la BCEAO » pour Charles Konan Banny (nomination en 1993, prise de fonction en 1994, départ pour Matignon en 2005).
- **Présidence** : « Les anciens présidents » pour Houphouët-Boigny et Bédié, « Le Président » pour Ouattara, « Le Vice-Président » pour Tiémoko Meyliet Koné.
- **Ministères** : « Anciens ministres de l'éducation » pour Mariatou Koné ; RENACAFCI pour Anne Désirée Ouloto ; biographie du ministère de la Solidarité pour Belmonde Dogo ; « Anciens ministres » de la Femme pour Hortense Aka-Anghui et Jeanne Gervais.
- **Assemblée nationale** (assnat.ci) : composition du Bureau de 2017 pour Véronique Aka et Célestine Olibé Trazéré ; résultats définitifs de la CEI (Cocody 2011) pour Yasmina Ouégnin.
- **Éditeurs** : fiches Karthala du Sanvi (Henriette Diabaté) et de L'envers d'une légende (Marcel Amondji) ; fiche Flammarion de Kocoumbo (Aké Loba).

**Retirées**
- **Mamadou Koulibaly** : la page de l'Assemblée dit qu'il quitte la présidence en 2010 (remplacé en 2012), quand la fiche dit 2001-2012. La référence ne porte donc pas la fiche ; le point reste à arbitrer.
- **Anoma Gladys Rose** : aucune page officielle ne documente son mandat de 1966 à 1980.
- **Bernard Dadié** : la fiche citait Présence africaine pour *Climbié*, mais les sources (RFI, bibliographies) donnent Seghers en 1956. Référence fausse, retirée ; la notice porte le roman et l'année.
- **Jean-Marie Adiaffi** : aucune fiche produit Hatier pour *La Carte d'identité*.

**Vérifié**
- Aucune référence en page d'accueil ; le test de recouvrement reste vert.
- `composer test` : **166 tests, 5 675 assertions** ; `composer format:check` : 163 fichiers ; `composer analyse` : 75 fichiers, aucun problème.
- Production re-seedée et caches reconstruits ; l'API renvoie les nouvelles URL et les fiches concernées répondent en 200.

---

## Séance 116 — 26 novembre 2026 · Arbitrage de la date de Mamadou Koulibaly

**Question** : la page historique de l'Assemblée nationale dit qu'il « quitte les rênes en 2010 », « remplacé en 2012 » ; la fiche dit 2001-2012.

**Sources**
- Wikipédia : président de l'Assemblée du 22 janvier 2001 au 12 mars 2012 (11 ans, 1 mois et 19 jours).
- Le Monde/AFP du 12 mars 2012 : Guillaume Soro est élu président de l'Assemblée « une première depuis dix ans ».
- Africa Check : « Mamadou Koulibaly va céder son fauteuil à Guillaume Soro en 2012 » ; le mandat des députés élus en 2000 a été prolongé par décrets successifs.
- La page de l'Assemblée : le « 2010 » correspond au départ de fait pendant la crise post-électorale, pas à la transmission du fauteuil, qui n'a lieu qu'à l'installation de la nouvelle Assemblée, le 12 mars 2012.

**Décision** : la fiche avait raison sur le fond. Le corps dit désormais « jusqu'en 2012 » au lieu de « pendant onze ans », pour que la date de fin soit lisible sans introduire de jour ou de mois absents de la notice. La référence de l'Assemblée n'est pas rétablie : sa page ne porte pas le mandat 2001-2012.

**Vérifié**
- Test de recouvrement vert ; `composer test` : 166 tests, 5 675 assertions ; format 163 fichiers ; analyse 75 fichiers sans erreur.
- Production re-seedée et caches reconstruits ; la fiche répond en 200 avec la nouvelle formulation.

---

## Séance 117 — 26 novembre 2026 · Garde-fou contre les pages d'accueil

**Ajout** : `noticeCoverageHomePageReferences()` et un troisième test dans `PersonalitiesNoticeCoverageTest`. Une référence dont l'URL n'a ni chemin (ou seulement « / ») ni requête est refusée : les 22 cas corrigés en séance 115 ne peuvent pas revenir. Une URL à requête, comme `assnat.ci/?page`, reste acceptée car elle mène à une page réelle.

**Vérifié** : le corpus des 401 fiches passe ; le test injecte `https://africultures.com` et vérifie qu'elle est signalée, puis qu'une page précise ne l'est pas. `composer test` : 167 tests, 5 678 assertions ; format 163 fichiers ; analyse 75 fichiers sans erreur.

---

## Séance 118 — 26 novembre 2026 · Refus des pages d'accueil à la saisie

**Ajout** : `App\Support\ReferenceUrl::isHomePage()` et une règle de validation sur `references.*.url` dans `ArticleRequest`. Une URL sans chemin (ou seulement « / ») et sans requête est refusée avec le message « L’adresse de la source doit pointer vers une page précise, pas vers l’accueil d’un site. » Une URL à requête, comme `assnat.ci/?page`, reste acceptée.

**Test** : dans `AdminContentTest`, un contributeur soumet une source `https://example.test` : redirection vers le formulaire, erreur sur `references.0.url`, aucun article créé. La même soumission avec `https://example.test/page` aboutit et enregistre l’URL.

**Vérifié** : `composer test` : 168 tests, 5 685 assertions ; format 164 fichiers ; analyse 76 fichiers sans erreur.

---

## Séance 119 — 26 novembre 2026 · Même règle pour la source de l'image

**Ajout** : la règle de page d'accueil s'applique aussi à `cover_image_source_url` dans le formulaire d'article. La closure est factorisée dans `ArticleRequest::precisePageRule()`, appelée par les deux champs avec un message adapté : « L’adresse de la page source de l’image doit pointer vers une page précise, pas vers l’accueil d’un site. » Une URL à requête reste acceptée, comme pour les sources.

**Test** : dans `AdminContentTest`, une soumission avec `cover_image_source_url = https://example.test` est refusée (erreur sur `cover_image_source_url`, aucun article créé) ; la même avec la page du fichier aboutit et enregistre l'adresse.

**Reste** : aucune référence de production à reprendre — le corpus est déjà propre, la règle ne bloque que les nouvelles saisies.

---

## Séance 120 — 26 novembre 2026 · Aide visible sous les champs d'adresse

**Ajout** : le formulaire d'article affiche « Une page précise, pas l’accueil d’un site. » sous l'adresse de chaque source et sous la page source de l'image. La ligne de source enveloppe son champ d'adresse dans `.ref-url` (grille d'une colonne) pour que l'aide reste sous le champ dans la grille à six colonnes, et le gabarit de ligne ajoutée par le bouton « Ajouter une source » porte la même aide.

**Corrigé à l'écran** : la colonne d'adresse (1.4fr, 205 px) coupait la phrase en deux lignes et l'étirement de la grille allongeait le bouton « Retirer ». La grille passe à `1.35fr .85fr .85fr 78px 2.1fr auto` (adresse à 295 px, phrase sur une ligne) avec `align-items: start`. Vérifié dans le navigateur à 1280 px et à 390 px, sur la ligne d'origine et sur une ligne ajoutée par le bouton.

**Vérifié** : `composer test` : 169 tests, 5 692 assertions ; format 164 fichiers ; analyse 76 fichiers sans erreur.

**Reste** : rien — la règle et son rappel sont désormais au même endroit.

---

## Blocages

**Aucun blocage.** L'API répond en HTTPS sur le compte dédié.

**Mailjet** n'est pas bloquant : `MAIL_MAILER=log` jusqu'à réception de la clé SMTP.

**Historique Git** : les commits antérieurs à la séance 5 contiennent les hôtes et noms de bases de l'ancien compte. La réécriture (`git filter-repo` + `push --force`) n'a pas été faite : destructive, elle attend une décision explicite.

---

## Travail restant détaillé

Voir le backlog ordonné dans `IVOIREPEDIA_CONTEXT.md` §14 (Sprint 0 à Sprint 5, puis V1).
