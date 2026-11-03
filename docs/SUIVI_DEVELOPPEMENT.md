# Suivi de développement — IVOIREPEDIA

> Journal technique étape par étape : **ce qui est fait, vérifié, bloqué et restant.**
> Modèle repris du projet Soutrali. Chaque séance de travail ajoute une entrée datée.
> Règle : ce journal, le dépôt local et le dépôt distant restent **au même niveau d'information**.

**Version** : 1.2 · **Dernière mise à jour** : 3 novembre 2026

**État en une phrase** : le **Sprint 0 est réalisé et vérifié** (`backend/` Laravel 13 + `app/` Flutter + CI, tous les contrôles au vert) ; l'hébergement **Alwaysdata** et les emails **Mailjet** remplacent l'environnement local, et **la mise en ligne attend les actions de panneau côté hébergeur**.

---

## Chronologie

### 2 novembre 2026 — Mise en place du dépôt et de la documentation de cadrage

**Fait**
- Dépôt GitHub `0Defiance/IVOIREPEDIA` initialisé (licence MIT) et cloné en local.
- Structure du dépôt alignée sur le modèle de création de Soutrali :
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
  - *Corrigé en séance 2 (ci-dessous) : le CONTEXT a été aligné sur le modèle Soutrali (Flutter + Laravel + MySQL), et la stack du document de contextualisation est désormais explicitement supplantée par une bannière ⚠️.*

**Reste (ordre prioritaire)**
1. **Sprint 0 — Fondations** (CONTEXT §14) : créer `backend/` (Laravel) et `app/` (Flutter) ; base `ivoirepedia` via phpMyAdmin + `.env.example` ; migrations + seeders ; scripts Composer (Pest/Pint/Larastan) + `flutter analyze`/`flutter test` ; CI GitHub Actions ; `docs/INSTALLATION.md` avec versions constatées ; déploiement « hello world ».
   - Critère de sortie : un nouvel arrivant suit CONTEXT §7 et obtient l'app Flutter **et** l'API en local ; la CI est verte.
2. Puis Sprint 1 — Authentification (EF-AUTH-01→05).
3. Questions ouvertes à traiter au fil de l'eau : éditeur riche Flutter à confirmer (Q8), licence du code (Q1), licence du contenu (Q2), nom de domaine / emails (Q3).

### 2 novembre 2026 (séance 2) — Adaptation de la stack au modèle Soutrali

**Fait**
- Décision : **aligner la stack technique d'IVOIREPEDIA sur celle de Soutrali**, même objectif multiplateforme (web d'abord, Android ensuite) — au lieu de Next.js + Prisma + PostgreSQL.
- `IVOIREPEDIA_CONTEXT.md` passé en **v1.1** : Flutter (`app/`) + Laravel (`backend/`, API `/api/v1` + Filament) + MySQL/XAMPP/phpMyAdmin + Sanctum + Pest/flutter_test.
  - ADR-001→008 réécrits ; §5 stack ; §6 arborescence `app/` + `backend/` ; §7 installation XAMPP (ports 8000/8082/3306) ; §8 schéma converti en **MySQL** (DDL, tables `article_tag` et `article_references` pivot/mot réservé, `position` au lieu de `order`) ; §8.3 infobox en règles `FormRequest` ; §9 workflow traduit en **PHP** (`app/Services/Workflow.php`) ; §11 contrat `/api/v1` + table d'erreurs 422 ; §13 sécurité adaptée (Eloquent, disque local) ; §14 backlog Sprint 0 réécrit ; §15.4 CI 2 jobs ; §17 risques R-05/R-08/R-09 (SPA → SEO limité) ; Q8/Q9 ajoutées.
- `README.md` (v1.1) : tableau de stack validée + prochaine étape Sprint 0 adaptée ; bannière ⚠️ ajoutée en tête du document de contextualisation (sa stack NestJS/PostGIS est supplantée, vision produit inchangée).
- `AGENTS.md` : chemins Flutter/Filament/Pest, commandes `composer test/format:check/analyse` + `flutter analyze/test`.
- `.gitignore` (modèle Soutrali : `app/`, `backend/`) et `.gitattributes` (`.dart`, `.php` au lieu de `.ts`).
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
- **Sprint 0 côté backend** : Laravel 13.39.0 installé, `composer.json` aligné sur le modèle Soutrali (Pest 4, Larastan 3, Pint, scripts `test` / `analyse` / `format` / `format:check`), `phpstan.neon` niveau 5.
  - 10 migrations fidèles au schéma §8.2 : `users` (+ `verification_tokens`, `sessions`), `categories`, `articles`, `article_versions`, `tags`, `article_tag`, `article_references`, `media`, `editorial_actions`.
  - Seeders `CategorySeeder` (8 catégories) et `DevAdminSeeder` (`admin@ivoirepedia.test`, refusé en production).
  - `app/Models/User.php` adapté (UUID, `password_hash`, `role`), `GET /api/v1/health` déclarée dans `routes/api.php` et câblée via `bootstrap/app.php`.
- **Sprint 0 côté app** : Flutter 3.47.7 / Dart 3.13.5 ; l'écran compteur de `flutter create` est remplacé par `app/lib/src/app.dart` (écran d'accueil IVOIREPEDIA) avec son test widget.
- **CI** : `.github/workflows/ci.yml`, deux jobs (backend PHP 8.3, Flutter 3.47.7), mêmes commandes que `AGENTS.md` §3.
- **Changement de cap demandé** : abandon des tests et du MySQL local ; l'hébergement **Alwaysdata** et les emails **Mailjet** sont retenus « comme Soutrali » — le compte Alwaysdata de Soutrali est réutilisé, avec des ressources IVOIREPEDIA séparées.
  - `IVOIREPEDIA_CONTEXT.md` v1.2 : **ADR-002 révisé** (base hébergée, dev et production), **ADR-008 réécrit** (Alwaysdata mutualisé dès le développement, VPS+Nginx abandonné), **ADR-009 ajouté** (Mailjet SMTP). §5, §7, §7.5, R-10, Q3 et Q9 mis à jour.
  - `backend/.env.example` : `DB_HOST` sur `mysql-soutrali.alwaysdata.net`, deux bases (dev/prod), SMTP Mailjet (port 587, `MAIL_SCHEME=null`).
  - `docs/INSTALLATION.md` créé (poste de travail, base distante, versions constatées) et `docs/DEPLOIEMENT.md` créé (panneau Alwaysdata, premier déploiement, Mailjet, vérifications, pièges) — faits vérifiés dans la documentation officielle des deux services.

**Vérifié**
- `cd backend && composer test` → 3 tests / 4 assertions, vert.
- `composer format:check` → 38 fichiers conformes ; `composer analyse` → « No errors » (niveau 5).
- `php artisan migrate:fresh --seed` → 10 migrations + `CategorySeeder` + `DevAdminSeeder` sans erreur.
- `php artisan serve` + `curl /api/v1/health` → `200` avec `{"status":"ok","service":"ivoirepedia-api","version":"v1"}`.
- `cd app && flutter analyze` → « No issues found! » ; `flutter test` → écran d'accueil, 1 test vert.
- **Accessibilité du compte `soutrali`** (sondes réseau, sans mot de passe) : `ssh-soutrali.alwaysdata.net:22` ouvert, `mysql-soutrali.alwaysdata.net:3306` ouvert, `https://soutrali.alwaysdata.net` → `200`, `https://ivoirepedia.alwaysdata.net` → aucun site. Authentification SSH par clé refusée avant dépôt de la clé dans le panneau.

**Reste**
1. **Panneau Alwaysdata** (actions humaines, cf. `docs/DEPLOIEMENT.md` §2) : PHP 8.3 au niveau du compte, créer `soutrali_ivoirepedia` et `soutrali_ivoirepedia_dev` + utilisateur MySQL dédié, déposer la clé publique de déploiement `.deploy/ivoirepedia_ed25519.pub` (générée le 3 nov. 2026, exclue de Git) dans `Accès distant > SSH`, créer le site PHP pointant sur `~/ivoirepedia/backend/public`, valider l'expéditeur Mailjet et générer la clé SMTP.
2. Renseigner `backend/.env` (DB_*, MAIL_*) puis `php artisan migrate --seed` sur la base de dev distante.
3. Déployer le backend et vérifier `https://ivoirepedia.alwaysdata.net/api/v1/health` en ligne.
4. Test d'envoi Mailjet (`Mail::raw` en tinker).
5. Puis Sprint 1 — Authentification (EF-AUTH-01→05).

---

## Blocages

**Déploiement en attente d'actions humaines** dans le panneau Alwaysdata (Création des bases MySQL et de l'utilisateur, dépôt de la clé SSH, création du site PHP, validation de l'expéditeur Mailjet). Toujours impossible en SQL ou en ligne de commande : ces opérations sont réservées au panneau ou à l'API de l'hébergeur (`docs/DEPLOIEMENT.md` §2).

---

## Travail restant détaillé

Voir le backlog ordonné dans `IVOIREPEDIA_CONTEXT.md` §14 (Sprint 0 à Sprint 5, puis V1).
