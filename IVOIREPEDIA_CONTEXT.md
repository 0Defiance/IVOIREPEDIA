# IVOIREPEDIA — Fichier de contexte (équipe dev + assistants IA)

> **À placer à la racine du dépôt.** Peut être renommé `CONTEXT.md`, `CLAUDE.md` ou `AGENTS.md` selon l'outil IA utilisé.
> Dernière mise à jour : 2 novembre 2026 · Statut : **pré-MVP, développement solo**

---

## 0. Comment utiliser ce fichier

**Si tu es un développeur humain** : lis les sections 1 à 6 (30 min), puis va directement à la section 14 (backlog) pour trouver ta première tâche.

**Si tu es une IA (assistant de code)** : ce fichier est ta source de vérité. Lis la section 0.1 ci-dessous avant toute réponse, puis les sections 4 à 12 avant d'écrire du code.

### 0.1 TL;DR pour les IA

| Sujet | Règle |
|---|---|
| Projet | Encyclopédie web libre dédiée à la Côte d'Ivoire (articles structurés, validés par des éditeurs, versionnés). |
| Équipe actuelle | **1 seul développeur, niveau junior/intermédiaire en progression.** Pas encore de contributeurs externes. |
| Stack MVP | **Flutter** (`app/` : web d'abord, Android ensuite) + **Laravel** (`backend/` : API REST `/api/v1` + admin Filament) + **MySQL hébergé sur Alwaysdata** (dev et production) + **Mailjet** pour les emails. **Rien d'autre sans ADR.** |
| Architecture | **Monolithe modulaire** : un seul dépôt, un seul backend Laravel, une seule base. Pas de microservices. |
| Périmètre | **MVP uniquement** (section 3). Ne jamais implémenter une fonctionnalité V1/V2 sans demande explicite. |
| Langue | Code, commits, noms de variables et tables : **anglais**. Interface utilisateur et docs : **français**. |
| Pédagogie | Le dev est en apprentissage : **explique chaque terme technique en une phrase**, propose de petits changements (diffs courts), justifie tes choix. |
| Sécurité | Valider toute entrée côté serveur (Laravel `FormRequest`), vérifier les permissions côté serveur (Policies), ne jamais faire confiance au client (section 13). |
| Logique métier | Dans `backend/app/Services/*`, **jamais** dans les contrôleurs Laravel ni dans les widgets Flutter. |
| En cas de doute | Pose **une** question de clarification plutôt que d'inventer. Signale toute divergence avec ce fichier. |

---

## 1. Présentation du projet

**IVOIREPEDIA** est une encyclopédie numérique libre et open source consacrée exclusivement à la documentation, la structuration et la valorisation du savoir ivoirien : histoire, géographie, personnalités, institutions, langues, culture, économie, patrimoine.

### 1.1 Problème résolu
- Savoir ivoirien dispersé, peu sourcé, souvent rédigé depuis un regard extérieur.
- Pas de modèle de données unifié pour les biographies, régions, institutions.
- Peu de traçabilité éditoriale (qui a écrit quoi, sur quelle source).

### 1.2 Principes directeurs
1. **Fiabilité avant volume** : tout article publié est relu par un éditeur et cite ses sources.
2. **Traçabilité totale** : chaque modification est versionnée et attribuée.
3. **Simplicité technique** : le projet doit rester maintenable par une personne seule.
4. **Ouverture** : code open source, contenu sous licence libre (CC BY-SA 4.0 prévue), API et exports à terme.
5. **Évolutivité maîtrisée** : on prévoit la croissance, on ne la construit pas avant d'en avoir besoin (principe YAGNI).

### 1.3 Public cible
Élèves et étudiants, enseignants, grand public ivoirien, diaspora (priorité 1) ; chercheurs, journalistes, institutions (priorité 2).

---

## 2. Documents de référence et ordre de priorité

| Document | Rôle | Fichier |
|---|---|---|
| **Ce fichier** | Source de vérité opérationnelle | `IVOIREPEDIA_CONTEXT.md` |
| Cahier des charges | Acteurs, exigences fonctionnelles (codes `EF-*`) et non fonctionnelles (`ENF-*`) | `docs/CDC_Encyclopedie_Inclusive_Ivoirienne.pdf` |
| Stack Phase 1 — local | XAMPP, phpMyAdmin, Laravel, MySQL : environnement de développement | `docs/EII_Stack_Technique_Phase1_Local.pdf` |
| Stack Phase 2 — production | VPS Nginx, API `/api/v1` + Sanctum, application mobile, SMS/USSD | `docs/EII_Stack_Technique_Phase2_Production.pdf` |
| Vision produit | Multilingue, sources orales, géolocalisation, hors-ligne (statuts ✅ 🟡 ❓) | `docs/IVOIREPEDIA_Document_de_Contextualisation.md` |
| Répertoire des sources | Où chercher l'information : institutions ivoiriennes, statistiques, patrimoine, archives, recherche, presse, droit, langues, images ; statut de chaque adresse | `docs/SOURCES_INFORMATION.md` |
| Règle de travail | Définition de « fait », vérifications avant commit | `AGENTS.md` |

### 2.1 Divergences connues entre les documents (⚠️ à lire)

Les documents ont été rédigés successivement. **En cas de contradiction, ce fichier fait foi.**

| # | Sujet | Ce que disent les anciens docs | **Décision en vigueur** |
|---|---|---|---|
| D1 | Stack | Vision : NestJS + MongoDB + Elasticsearch + Kubernetes | **MVP : Flutter (`app/`) + Laravel (`backend/`) + MySQL seul** (ADR-001→004, 2 nov. 2026). NestJS / microservices = horizon V2+. |
| D2 | Contenu des articles | Vision : stocké dans MongoDB | **Colonne `JSON` dans MySQL** contenant le Delta de l'éditeur Quill (ADR-003). |
| D3 | Noms des statuts | UML : français (`BROUILLON`, `SOUMIS`…) | **Enums PHP anglais** (`DRAFT`, `SUBMITTED`…), libellés français côté Flutter (ADR-006). |
| D4 | Statut après demande de révision | UML séquence 2.4 : `IN_REVISION` | **`REVISION_REQUESTED`** (section 8). |
| D5 | Versions | UML : une version à chaque sauvegarde | **Une version = un jalon** (soumission, édition d'un article publié, publication, rollback). L'auto-save ne crée pas de version (ADR-005). |
| D6 | Recherche | UML : `LIKE '%terme%'` | MVP : `LIKE` insensible à la casse ; **V1 : full-text MySQL** (`FULLTEXT`, parseur `ngram` si besoin français). |
| D7 | Rôles admin | CDC : Admin Contenu + Admin Technique | **Un seul rôle applicatif `ADMIN`.** « Admin technique » = accès infrastructure (serveur, BDD), pas un rôle en base. |
| D8 | Rôle à l'inscription | CDC : « Lecteur inscrit » | Inscription → `READER`. Promotion en `CONTRIBUTOR` par un `ADMIN`. |
| D9 | Interface | PDFs EII : Blade + Tailwind (Phase 1), PWA Android (Phase 2) | **Flutter Web d'abord, Android ensuite** — une seule base de code pour les deux cibles (ADR-001). Blade/PWA abandonnés. |

> Les PDFs EII restent la référence pour tout ce qui concerne **la base, l'API et la production** (XAMPP, MySQL, `/api/v1`, Sanctum, VPS Nginx) : ils sont en phase avec cette décision. Seule la couche **interface** a changé (D9).

---

## 3. Périmètre

### 3.1 MVP (à construire maintenant)
Site web **Flutter Web** · Inscription / connexion / vérification email / reset mot de passe · Création et édition d'articles (brouillon, auto-save) · Éditeur riche · Catégories, tags · Image de couverture · Références bibliographiques · Soumission → révision → approbation → publication · Historique des versions · Recherche simple · Pages publiques (accueil, article, catégorie, résultats) · Admin minimal (utilisateurs, catégories, file de validation) · SEO de base (limité : voir §17, risque R-09).

### 3.2 Hors MVP (ne pas implémenter sans demande)
Elasticsearch / Meilisearch · Publication Android/iOS (le code Flutter est partagé d'emblée ; la cible mobile vient **après validation du web**, cf. ADR-001) · API publique · Multilingue (langues locales) · IA de modération · Cartes interactives · Commentaires · 2FA · OAuth Google/Facebook · Export chercheurs · Temps réel (WebSocket) · Kubernetes · Microservices · Redis (hors rate-limiting).

> Règle : si une demande touche à la section 3.2, **demander confirmation** avant d'écrire du code.

---

## 4. Décisions d'architecture (ADR)

Chaque décision est numérotée. Pour en changer : ouvrir une PR qui ajoute un nouvel ADR dans `docs/adr/` et met à jour ce fichier.

### ADR-001 — Un dépôt, deux applications : Flutter (`app/`) + Laravel monolithe modulaire (`backend/`)
- **Décision** : `app/` Flutter/Dart pour toute l'interface (site web d'abord, Android ensuite) ; `backend/` Laravel pour l'API REST `/api/v1` **et** le panneau d'administration Filament sur `/admin`. Une seule base, un seul déploiement backend.
- **Pourquoi** : objectif multiplateforme — une seule base de code pour le web puis Android ; backend et base indépendants des interfaces ; le monolithe limite les composants à installer, surveiller et maintenir pour un dev seul.
- **Risque** : deux langages (Dart, PHP) pour une personne seule → **le backend est l'unique source des règles métier**, l'app n'affiche et n'appelle que l'API ; couplage → respecter la séparation en couches (section 6.2).
- **Sortie** : si un module devient un goulot (recherche, médias), il pourra être extrait en service indépendant.

### ADR-002 — MySQL + Eloquent (hébergé sur Alwaysdata, développement **et** production)
- **Décision** : MySQL comme unique base de données, Eloquent comme ORM, migrations versionnées. **La base de développement est hébergée sur Alwaysdata**, comme celle de production (révision du 3 nov. 2026 : XAMPP et phpMyAdmin locaux sont abandonnés). Deux bases distinctes sur le serveur dédié : `ivoirepedia_dev` et `ivoirepedia_prod`.
- **Pourquoi** : un seul moteur, donc plus d'écart entre le poste et le serveur ; relations fortes (utilisateurs ↔ articles ↔ versions) et transactions ACID indispensables au workflow ; Eloquent = l'ORM intégré à Laravel (traduit le PHP en requêtes SQL).
- **Conséquences** : le développement du backend exige une connexion Internet ; **les tests n'y touchent jamais** (`phpunit.xml` force SQLite en mémoire) ; la création des bases et des utilisateurs passe obligatoirement par le panneau Alwaysdata, qui interdit `CREATE DATABASE` depuis un client tiers. Procédures : `docs/INSTALLATION.md` §1 et `docs/DEPLOIEMENT.md` §2.
- **⚠️ Moteur réel** : Alwaysdata sert **MariaDB** (10.11 / 11.4 / 11.8). Éviter les fonctions propres à un moteur ; consigner la version réelle dans `docs/INSTALLATION.md`.

### ADR-003 — Pas de MongoDB, Elasticsearch ni Meilisearch au MVP
- **Décision** : le contenu riche est stocké en colonne `JSON` de MySQL.
- **Pourquoi** : une seule base à sauvegarder, administrer et apprendre. La recherche utilise `LIKE` au MVP ; full-text MySQL en V1 ; Meilisearch sera réévalué au seuil défini dans le PDF Phase 2 (plusieurs milliers d'articles ou tolérance aux fautes avancée).

### ADR-004 — Laravel Sanctum (session web + jeton révocable Android)
- **Décision** : authentification par email + mot de passe. Côté web (Flutter Web), session par **cookie** (`HttpOnly`, `SameSite=Lax`) ; côté Android plus tard, **jeton personnel révocable** dans `flutter_secure_storage`. Mêmes comptes et rôles pour l'app, l'API et Filament.
- **Pourquoi** : brique officielle de Laravel, évite d'écrire de la cryptographie maison ; un seul système d'authentification pour les trois surfaces.
- **Sécurité** : mots de passe hachés avec `Hash::make()` (bcrypt, ≥ 12 rounds), jamais stockés ni loggés en clair.

### ADR-005 — Versionnage par jalons
- **Décision** : le champ `articles.content` (JSON) contient toujours le contenu courant. Une ligne `article_versions` (snapshot immuable) est créée à : soumission, chaque sauvegarde d'un article **publié**, publication, rollback.
- **Pourquoi** : l'auto-save toutes les 60 s créerait des centaines de versions inutiles.
- **Intégrité** : `content_hash` (SHA-256) pour détecter les doublons.

### ADR-006 — Convention de langue
- **Code, schéma BDD, API, commits, branches** : anglais.
- **Interface, messages d'erreur utilisateur, documentation** : français.
- Les enums PHP sont en anglais (`App\Enums\*`) ; les libellés français vivent côté Flutter (`app/lib/`, fichiers de libellés).

### ADR-007 — API REST versionnée `/api/v1` + couche Service
- **Décision** : toute écriture passe par `backend/routes/api.php` → contrôleur `Api/V1` (mince) → `backend/app/Services/*`. Filament appelle les **mêmes** Services. Les widgets Flutter lisent et écrivent uniquement via l'API.
- **Pourquoi** : API testable avec Pest, prête pour une future API publique, logique métier isolée ; une action d'administration ne peut pas contourner les règles de statut ni la traçabilité.

### ADR-008 — Hébergement : Alwaysdata (mutualisé), dès le développement
- **Décision (révisée le 3 nov. 2026)** : **Alwaysdata** héberge l'application **dès le développement**, sur un **compte dédié à IVOIREPEDIA**. Un site PHP (`ivoirepedia.alwaysdata.net`), un dossier `~/ivoirepedia/`, des bases MySQL dédiées et un utilisateur MySQL propre. Le compte d'un autre projet n'est jamais réutilisé : son unique adresse gratuite y est déjà prise et les données, quotas et identifiants doivent rester séparés. Le VPS + Nginx du PDF Phase 2 est abandonné pour le MVP.
- **Pourquoi** : arrêter de maintenir un environnement local (XAMPP) qui divergera de la production ; l'hébergeur fournit PHP 8.3+, Composer, MySQL sauvegardé, HTTPS et tâches planifiées ; le coût est celui d'un compte mutualisé unique. Cela supprime le risque R-08 et réduit R-04.
- **Médias** : disque local (`storage/app/public`) au MVP ; stockage objet + CDN (type Cloudflare R2) en Phase 2.
- **Souveraineté** : hébergement hors Côte d'Ivoire (latence ≈ 150 ms acceptable). Rapatriement des données étudié à moyen terme (voir roadmap).
- **Limites assumées** : pas d'accès root, pas de worker permanent, version de PHP réglée au niveau du compte. Procédure et pièges : `docs/DEPLOIEMENT.md`.

### ADR-009 — Emails transactionnels par Mailjet (SMTP)
- **Décision** : Laravel Mail avec le **relais SMTP Mailjet** (`in-v3.mailjet.com`, port 587 en STARTTLS, `MAIL_SCHEME=null`). Identifiant = clé API, mot de passe = clé secrète SMTP **dédiée à IVOIREPEDIA**.
- **Pourquoi** : la vérification d'adresse, la réinitialisation de mot de passe et les notifications éditoriales en dépendent dès le Sprint 1 ; le SMTP évite un paquet supplémentaire (aucun SDK à maintenir) ; le plan gratuit (6 000 emails/mois, 200/jour) couvre le MVP. L'API REST v3 est écartée pour le MVP (YAGNI).
- **Contraintes** : l'adresse d'expédition doit être **validée** dans Mailjet (domaine recommandé, avec SPF/DKIM), sinon l'envoi est refusé en 403. Le domaine et l'adresse d'expédition restent la question ouverte Q3. En développement hors ligne, `MAIL_MAILER=log` évite de consommer le quota.

---

## 5. Stack technique

| Couche | Choix | Rôle |
|---|---|---|
| Interface | Flutter, langage Dart, canal stable | Une base de code : site web d'abord, application Android ensuite |
| Navigation Flutter | `go_router` | Routes nommées, redirections selon l'état de connexion |
| Appels HTTP Flutter | `dio` | API JSON, erreurs centralisées, délais d'attente |
| État de l'interface | Gestion simple par fonctionnalité ; `flutter_riverpod` seulement si besoin confirmé | Éviter une architecture d'état disproportionnée |
| Stockage de session mobile | `flutter_secure_storage` | Jetons Android dans le stockage protégé de l'appareil, jamais en clair |
| Éditeur riche | `flutter_quill` (Delta JSON) — **choix de référence, à confirmer avant le Sprint 2 (Q8)** | Édition structurée ; le Delta JSON est le contenu stocké |
| Backend / API | PHP 8.3+ avec Laravel, monolithe modulaire | API REST `/api/v1` JSON, règles métier testables côté serveur |
| Administration | Filament pour Laravel (`/admin`) | Utilisateurs, catégories, tableaux de bord — accès protégé par rôle et Policy |
| Authentification | Laravel Sanctum | Session cookie pour le web, jeton révocable pour Android |
| Base de données | MySQL/MariaDB hébergé sur **Alwaysdata** — base de dev et base de production distinctes | Stockage relationnel, migrations versionnées |
| Hébergement | **Alwaysdata** : site PHP + SSH, MySQL, HTTPS — compte dédié à IVOIREPEDIA (ADR-008) | Développement et production sur le même moteur (ADR-008) |
| Validation des entrées | Laravel validation (`FormRequest`) | Validation **faisant foi** côté serveur (remplace les schémas Zod) |
| Emails | Laravel Mail via **SMTP Mailjet** (`in-v3.mailjet.com`, port 587) | Vérification email, reset, notifications éditoriales (ADR-009) |
| Médias | Disque local `storage/app/public` (R2 + CDN en Phase 2) | Images de couverture et futures pièces jointes |
| Rate-limiting | `RateLimiter` intégré à Laravel | Anti-brute-force sur login / inscription / reset |
| Tests backend | Pest (tests `Unit` + `Feature`) | Règles métier, permissions, routes HTTP |
| Tests Flutter | `flutter_test` | Widgets critiques et parcours essentiels |
| Qualité | Pint (formatage), Larastan (analyse statique), `flutter analyze` | Style et erreurs détectées avant exécution |
| CI | GitHub Actions — 2 jobs (backend, flutter) | Tests, analyse et build web à chaque PR |
| Gestionnaire de dépendances | Composer (backend), `pub` (Flutter) | Fichiers de verrouillage `composer.lock`, `pubspec.lock` |

**Versions** : utiliser les versions stables courantes à l'initialisation, puis **figer via les lockfiles** (`composer.lock`, `pubspec.lock`). Versions constatées sur ce poste le 3 novembre 2026 : Laravel 13 / PHP 8.3 / Filament 5 / Sanctum 4 / Pest 4 ; Flutter stable récent (Dart ≥ 3.13). **Ne pas copier de numéros de version depuis ce document** — les figer dans `docs/INSTALLATION.md` après exécution réelle.

> **Règle d'ajout de dépendance** : toute nouvelle librairie doit être justifiée dans la PR (besoin, alternatives, taille, maintenance). Préférer le cadre standard (fonctions natives de Laravel, packages `flutter_*`) quand c'est suffisant.

---

## 6. Organisation du code

### 6.1 Arborescence cible

```
ivoirepedia/
├─ app/                      # Flutter/Dart — interface partagée (web puis Android)
│  ├─ lib/
│  │  ├─ main.dart
│  │  └─ src/
│  │     ├─ app.dart          # thème, routes (go_router)
│  │     ├─ core/            # client HTTP (dio), configuration, erreurs communes
│  │     └─ features/
│  │        ├─ auth/           # connexion, inscription, session
│  │        ├─ articles/       # lecture publique, recherche, catégories
│  │        ├─ editor/         # rédaction : éditeur Quill, auto-save
│  │        ├─ editorial/      # file de révision, relecture
│  │        └─ account/        # mes articles, profil
│  ├─ test/                   # tests flutter_test
│  ├─ web/                    # index.html, manifest
│  └─ pubspec.yaml
├─ backend/                   # Laravel — API /api/v1 + admin Filament
│  ├─ app/
│  │  ├─ Enums/               # Role, ArticleStatus, ArticleType… (anglais)
│  │  ├─ Exceptions/          # WorkflowException…
│  │  ├─ Http/
│  │  │  ├─ Controllers/Api/V1/   # contrôleurs minces
│  │  │  └─ Requests/             # validation FormRequest
│  │  ├─ Models/              # modèles Eloquent et relations
│  │  ├─ Policies/            # autorisations par ressource
│  │  ├─ Services/            # LOGIQUE MÉTIER (ArticleService, Workflow…)
│  │  └─ Filament/            # ressources et pages du panneau /admin
│  ├─ database/
│  │  ├─ migrations/          # schéma versionné (source de vérité du schéma)
│  │  ├─ seeders/             # catégories de base + admin de dev
│  │  └─ factories/
│  ├─ routes/api.php
│  ├─ storage/                # médias locaux (Phase 1)
│  ├─ tests/{Feature,Unit}/   # tests Pest
│  ├─ .env.example
│  └─ composer.json
├─ docs/                      # adr/, INSTALLATION, SUIVI, documents source
├─ .github/workflows/ci.yml   # créé au Sprint 0
├─ AGENTS.md
└─ IVOIREPEDIA_CONTEXT.md
```

### 6.2 Architecture en couches (règle d'or)

```
Flutter (app/) ──HTTP JSON /api/v1──► routes/api.php ──► Contrôleur ──► Service ──► Eloquent ──► MySQL
                                          │ FormRequest       │ règles métier + Policies
                                          │ Sanctum (session) │ transactions
Filament (/admin) ───────────────────────────────────────► mêmes Services
```

| Couche | Autorisé | Interdit |
|---|---|---|
| Contrôleur `Api/V1` | Recevoir la requête validée (FormRequest), récupérer l'utilisateur Sanctum, appeler un service, renvoyer JSON | Requêtes Eloquent directes, règles métier |
| Service (`app/Services`) | Règles métier, vérification des permissions (Policies), transactions, notifications | Dépendre des objets HTTP (`Request`) ou d'un widget Flutter |
| Model Eloquent | Relations, accès aux données, casts | Règles métier complexes |
| Filament | UI d'administration qui appelle les Services | Contourner les règles de statut ou de traçabilité |
| Widget Flutter | Affichage, état d'UI, appels API via `dio` | Logique métier, accès direct à la base |

---

## 7. Installation locale (onboarding)

> Guides pas-à-pas : `docs/INSTALLATION.md` (poste de travail, base distante) et `docs/DEPLOIEMENT.md` (Alwaysdata + Mailjet). Résumé ici.

### 7.1 Prérequis
**PHP CLI 8.3+**, Composer, Flutter SDK (stable), Git, et un **compte Alwaysdata** pour la base MySQL — plus de MySQL local (ADR-002).

**Leçons tirées du premier montage, à vérifier ici aussi :**
- Laravel 13 exige PHP 8.3+ en CLI ; le PHP livré par XAMPP est en 8.2 et ne doit plus servir.
- Composer peut être installé **hors du PATH** : si `composer --version` échoue alors que `backend/vendor/` existe, appeler `php <chemin>/composer.phar <commande>`.
- La base distante exige une connexion Internet ; les tests n'en dépendent pas (SQLite en mémoire, `phpunit.xml`).

### 7.2 Démarrage

```bash
git clone <url-du-depot> ivoirepedia && cd ivoirepedia

# 1. Base de données — créée dans le panneau Alwaysdata (Databases > MySQL), jamais en SQL :
#    ivoirepedia_dev + utilisateur dédié — cf. docs/DEPLOIEMENT.md §2

# 2. Backend Laravel (terminal 1)
cd backend
composer install
cp .env.example .env             # puis compléter DB_* et MAIL_* (jamais versionné)
php artisan key:generate
php artisan migrate --seed       # tables + catégories + admin de dev
php artisan serve --port 8000    # API /api/v1 + admin Filament /admin

# 3. Application Flutter (terminal 2)
cd app
flutter pub get
flutter run -d web-server --web-port 8082   # site sur http://127.0.0.1:8082
```

### 7.3 Ports de développement

| Service | Port | Adresse | Rôle |
|---|---:|---|---|
| API Laravel | `8000` | `http://127.0.0.1:8000` | Routes `/api/v1`, sessions Sanctum, panneau `/admin` |
| Flutter Web | `8082` | `http://127.0.0.1:8082` | Site IVOIREPEDIA |
| MySQL Alwaysdata | `3306` | `mysql-ivoirepedia.alwaysdata.net:3306` | Consommée uniquement par Laravel, jamais par Flutter |

Les deux origines (`:8000` et `:8082`) sont distinctes **par conception** : Sanctum, cookies CSRF et CORS doivent autoriser explicitement `127.0.0.1:8082` (`SANCTUM_STATEFUL_DOMAINS` + `config/cors.php` dans `backend/`). En production, servir app, API et `/admin` sous une seule origine HTTPS.

### 7.4 Commandes utiles

| Commande | Effet |
|---|---|
| `php artisan serve --port 8000` | Serveur de développement backend (+ `/admin`) |
| `cd backend && composer test` | Tests Pest (`php artisan test`) |
| `cd backend && composer format:check` / `composer analyse` | Pint (style) / Larastan (statique) |
| `php artisan migrate` / `migrate:rollback` | Appliquer / annuler les migrations |
| `php artisan db:seed` | Seed (catégories, admin de dev) |
| `php artisan tinker` | Console d'exploration de la base |
| `flutter run -d web-server --web-port 8082` | Site en développement |
| `flutter analyze` / `flutter test` | Analyse Dart / tests Flutter |
| `flutter build web --release` | Build web de production |

### 7.5 Variables d'environnement (`backend/.env.example`)

```bash
# Application
APP_NAME=IVOIREPEDIA
APP_URL=http://127.0.0.1:8000
APP_ENV=local

# Base de données — hébergée sur Alwaysdata (créée dans le panneau, jamais en SQL)
DB_CONNECTION=mysql
DB_HOST="mysql-ivoirepedia.alwaysdata.net"
DB_PORT=3306
DB_DATABASE="ivoirepedia_dev"
DB_USERNAME="ivoirepedia_app"
DB_PASSWORD=                       # mot de passe choisi dans le panneau, jamais commité

# Origines autorisées pour Sanctum / CORS (Flutter Web)
FRONTEND_URL=http://127.0.0.1:8082
SANCTUM_STATEFUL_DOMAINS=127.0.0.1:8082,localhost:8082

# Phase solo : un ADMIN peut valider ses propres articles (à désactiver dès le 1er éditeur)
ALLOW_SELF_REVIEW=true

# Emails — SMTP Mailjet (ADR-009) ; mettre MAIL_MAILER=log pour travailler hors ligne
MAIL_MAILER=smtp
MAIL_HOST=in-v3.mailjet.com
MAIL_PORT=587
MAIL_SCHEME=null
MAIL_USERNAME=                     # clé API Mailjet
MAIL_PASSWORD=                     # clé secrète SMTP
MAIL_FROM_ADDRESS="no-reply@ivoirepedia.ci"
```

> **Règle** : aucun secret dans le dépôt. `backend/.env` est dans `.gitignore` (seul `.env.example` est versionné). Les mots de passe SQL sont choisis par la personne qui installe et ne figurent jamais dans un commit, un ticket ou une capture.

---

## 8. Modèle de données

### 8.1 Correspondance des noms (documents UML → code)

| UML (français) | Modèle Eloquent | Table MySQL |
|---|---|---|
| Utilisateur | `User` | `users` |
| Article | `Article` | `articles` |
| VersionArticle | `ArticleVersion` | `article_versions` |
| ActionEditoriale | `EditorialAction` | `editorial_actions` |
| Catégorie | `Category` | `categories` |
| Tag | `Tag` | `tags` (+ pivot `article_tag`) |
| Référence | `Reference` | `article_references`* |
| Média | `Media` | `media` |

*\* `references` et `order` sont des **mots réservés MySQL** : tables `article_references` et colonne `position`.*

### 8.2 Schéma MySQL de référence (source d'exécution : `backend/database/migrations/`)

```sql
-- DDL de référence. Les migrations Laravel font foi pour l'historique du schéma.
SET NAMES utf8mb4;

CREATE TABLE users (
  id               CHAR(36)      NOT NULL PRIMARY KEY,        -- UUID
  name             VARCHAR(100)  NOT NULL,
  email            VARCHAR(255)  NOT NULL,
  password_hash    VARCHAR(255)  NOT NULL,                    -- Hash::make (bcrypt)
  role             VARCHAR(20)   NOT NULL DEFAULT 'READER',   -- enum PHP Role
  email_verified_at TIMESTAMP    NULL,
  bio              VARCHAR(500)  NULL,
  avatar_url       VARCHAR(500)  NULL,
  suspended_at     TIMESTAMP     NULL,
  created_at       TIMESTAMP     NULL,
  updated_at       TIMESTAMP     NULL,
  UNIQUE KEY uniq_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE verification_tokens (
  id          CHAR(36)     NOT NULL PRIMARY KEY,
  user_id     CHAR(36)     NOT NULL,
  type        VARCHAR(20)  NOT NULL,        -- EMAIL_VERIFY | PASSWORD_RESET
  token_hash  CHAR(64)     NOT NULL,        -- HASH du token, jamais le token brut
  expires_at  TIMESTAMP    NOT NULL,
  used_at     TIMESTAMP    NULL,
  created_at  TIMESTAMP    NULL,
  UNIQUE KEY uniq_tokens_hash (token_hash),
  KEY idx_tokens_user_type (user_id, type),
  CONSTRAINT fk_tokens_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE categories (
  id          CHAR(36)      NOT NULL PRIMARY KEY,
  name        VARCHAR(100)  NOT NULL,
  slug        VARCHAR(120)  NOT NULL,
  description TEXT          NULL,
  position    INT           NOT NULL DEFAULT 0,   -- ex. « order » (mot réservé)
  parent_id   CHAR(36)      NULL,
  created_at  TIMESTAMP     NULL,
  updated_at  TIMESTAMP     NULL,
  UNIQUE KEY uniq_categories_name (name),
  UNIQUE KEY uniq_categories_slug (slug),
  KEY idx_categories_parent (parent_id),
  CONSTRAINT fk_categories_parent FOREIGN KEY (parent_id) REFERENCES categories (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE articles (
  id               CHAR(36)      NOT NULL PRIMARY KEY,
  title            VARCHAR(255)  NOT NULL,
  slug             VARCHAR(255)  NOT NULL,
  summary          VARCHAR(500)  NOT NULL,
  content          JSON          NOT NULL,     -- Delta Quill (source de vérité, ADR-003)
  infobox          JSON          NULL,         -- données structurées selon `type` (cf. 8.3)
  type             VARCHAR(20)   NOT NULL,     -- enum PHP ArticleType
  status           VARCHAR(20)   NOT NULL DEFAULT 'DRAFT',  -- enum PHP ArticleStatus
  cover_image_url  VARCHAR(500)  NULL,
  cover_image_alt  VARCHAR(255)  NULL,         -- OBLIGATOIRE si image (accessibilité, ENF-UX-04)
  lock_version     INT           NOT NULL DEFAULT 0,   -- verrou optimiste (cf. 9.4)
  current_version  INT           NOT NULL DEFAULT 0,   -- dernier numéro d'article_versions
  author_id        CHAR(36)      NOT NULL,
  category_id      CHAR(36)      NOT NULL,
  created_at       TIMESTAMP     NULL,
  updated_at       TIMESTAMP     NULL,
  published_at     TIMESTAMP     NULL,
  deleted_at       TIMESTAMP     NULL,         -- suppression douce (SoftDeletes)
  UNIQUE KEY uniq_articles_slug (slug),
  KEY idx_articles_status_published (status, published_at),
  KEY idx_articles_category (category_id),
  KEY idx_articles_author (author_id),
  CONSTRAINT fk_articles_author   FOREIGN KEY (author_id)   REFERENCES users (id),
  CONSTRAINT fk_articles_category FOREIGN KEY (category_id) REFERENCES categories (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE article_versions (
  id           CHAR(36)      NOT NULL PRIMARY KEY,
  article_id   CHAR(36)      NOT NULL,
  number       INT           NOT NULL,
  title        VARCHAR(255)  NOT NULL,
  summary      VARCHAR(500)  NOT NULL,
  content      JSON          NOT NULL,
  content_hash CHAR(64)      NOT NULL,         -- SHA-256 du JSON canonique
  author_id    CHAR(36)      NOT NULL,
  reason       VARCHAR(255)  NULL,
  created_at   TIMESTAMP     NULL,
  UNIQUE KEY uniq_version (article_id, number),
  CONSTRAINT fk_versions_article FOREIGN KEY (article_id) REFERENCES articles (id) ON DELETE CASCADE,
  CONSTRAINT fk_versions_author  FOREIGN KEY (author_id)  REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tags (
  id         CHAR(36)     NOT NULL PRIMARY KEY,
  name       VARCHAR(100) NOT NULL,
  slug       VARCHAR(120) NOT NULL,
  created_at TIMESTAMP    NULL,
  updated_at TIMESTAMP    NULL,
  UNIQUE KEY uniq_tags_name (name),
  UNIQUE KEY uniq_tags_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE article_tag (            -- table pivot (relation plusieurs-à-plusieurs)
  article_id CHAR(36) NOT NULL,
  tag_id     CHAR(36) NOT NULL,
  PRIMARY KEY (article_id, tag_id),
  CONSTRAINT fk_pivot_article FOREIGN KEY (article_id) REFERENCES articles (id) ON DELETE CASCADE,
  CONSTRAINT fk_pivot_tag     FOREIGN KEY (tag_id)     REFERENCES tags (id)     ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE article_references (     -- « references » est un mot réservé MySQL
  id          CHAR(36)      NOT NULL PRIMARY KEY,
  article_id  CHAR(36)      NOT NULL,
  position    INT           NOT NULL,          -- ex. « order » (mot réservé)
  kind        VARCHAR(10)   NOT NULL DEFAULT 'OTHER',  -- enum PHP ReferenceKind
  authors     VARCHAR(255)  NULL,
  title       VARCHAR(255)  NOT NULL,
  publisher   VARCHAR(255)  NULL,
  year        SMALLINT      NULL,
  url         VARCHAR(500)  NULL,
  accessed_at DATE          NULL,
  note        TEXT          NULL,
  KEY idx_references_article (article_id, position),
  CONSTRAINT fk_references_article FOREIGN KEY (article_id) REFERENCES articles (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE media (
  id         CHAR(36)      NOT NULL PRIMARY KEY,
  article_id CHAR(36)      NOT NULL,
  type       VARCHAR(10)   NOT NULL,           -- enum PHP MediaType (IMAGE | AUDIO)
  path       VARCHAR(500)  NOT NULL,           -- clé de stockage (disque local ; remplace l'ID Cloudinary)
  alt        VARCHAR(255)  NOT NULL,           -- OBLIGATOIRE (accessibilité, ENF-UX-04)
  credit     VARCHAR(255)  NULL,
  license    VARCHAR(100)  NULL,
  size_bytes INT           NULL,
  created_at TIMESTAMP     NULL,
  CONSTRAINT fk_media_article FOREIGN KEY (article_id) REFERENCES articles (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE editorial_actions (      -- append-only : jamais d'UPDATE ni de DELETE
  id          CHAR(36)     NOT NULL PRIMARY KEY,
  article_id  CHAR(36)     NOT NULL,
  actor_id    CHAR(36)     NOT NULL,
  type        VARCHAR(20)  NOT NULL,           -- enum PHP EditorialActionType
  from_status VARCHAR(20)  NULL,
  to_status   VARCHAR(20)  NULL,
  comment     TEXT         NULL,
  created_at  TIMESTAMP    NULL,
  KEY idx_actions_article (article_id, created_at),
  CONSTRAINT fk_actions_article FOREIGN KEY (article_id) REFERENCES articles (id) ON DELETE CASCADE,
  CONSTRAINT fk_actions_actor   FOREIGN KEY (actor_id)   REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Tables statistiques (séance 14)** — hors périmètre éditorial, alimentées par commande :

| Table | Rôle | Alimentation |
|---|---|---|
| `country_indicators` | Dernière valeur connue d'un indicateur national + provenance (organisme, URL, licence) | `php artisan country:sync-statistics` |
| `country_indicator_points` | Série annuelle d'un indicateur (une ligne par année) | idem |
| `census_divisions` | Districts, régions et villes du RGPH 2021 (population, ménages, taille moyenne) | idem, depuis `database/data/rgph-2021.json` |
| `climate_cities`, `climate_months`, `climate_years` | Normales mensuelles et cumuls annuels 1991-2020 par ville (réanalyse ERA5, CC BY 4.0) | idem, depuis `database/data/climate-normals.json` |
| `history_stories` | Récits de la section « Histoire incroyable », avec leur source datée | `php artisan history:sync-stories`, depuis `database/data/history-stories.php` |

Ces tables sont en **lecture seule** pour l'API publique (`GET /api/v1/statistics`, cache 6 h) ; aucune route d'écriture n'existe. Les données du recensement sont figées dans `backend/database/data/rgph-2021.json`, avec l'URL et la licence du document officiel, pour que l'import soit reproductible sans réseau.

**Règles de données**
- `editorial_actions` est **append-only** : jamais de `update` ni `delete` (hors purge programmée).
- `articles.deleted_at` = suppression douce (trait Laravel `SoftDeletes`). Purge définitive après 90 jours (tâche V1).
- Le `slug` est généré depuis le titre (`Str::slug`, sans accents, minuscules, tirets), suffixé en cas de doublon. Seul un `ADMIN` peut le modifier après publication (les URLs publiées doivent rester stables).
- Le rendu se fait **depuis le JSON Delta côté Flutter** : aucun HTML n'est stocké ni injecté (l'ancienne colonne `contentHtml` disparaît avec le changement de stack — voir D9). Si un rendu serveur est ajouté en V1 (SEO), le HTML devra être généré **et sanitisé côté serveur**.
- Recherche V1 : colonne générée ou champ aplatî en texte + index `FULLTEXT` MySQL (parseur `ngram` si la tokenisation française est insuffisante).

### 8.3 Infobox structurée par type d'article (validation Laravel)

```php
// backend/app/Http/Requests/ArticleRequest.php (règles d'infobox par type)
// Un type sans ligne ici n'a pas d'infobox au MVP.
$infoboxRules = [
    'BIOGRAPHY' => [
        'infobox' => ['required', 'array'],
        'infobox.fullName'      => ['required', 'string', 'max:200'],
        'infobox.birthDate'     => ['nullable', 'string', 'max:20'],  // ISO ou partielle : "1905", "1905-10"
        'infobox.birthPlace'    => ['nullable', 'string', 'max:200'],
        'infobox.deathDate'     => ['nullable', 'string', 'max:20'],
        'infobox.deathPlace'    => ['nullable', 'string', 'max:200'],
        'infobox.nationalities' => ['sometimes', 'array', 'max:10'],
        'infobox.nationalities.*' => ['string', 'max:100'],
        'infobox.occupations'   => ['sometimes', 'array', 'max:20'],
        'infobox.occupations.*' => ['string', 'max:100'],
    ],
    'REGION' => [
        'infobox' => ['required', 'array'],
        'infobox.level'          => ['required', \Illuminate\Validation\Rule::in(
            ['DISTRICT', 'REGION', 'DEPARTMENT', 'SUB_PREFECTURE', 'VILLAGE'])],
        'infobox.population'     => ['nullable', 'integer', 'min:0'],
        'infobox.populationYear' => ['nullable', 'integer', 'min:1800', 'max:2100'],
        'infobox.areaKm2'        => ['nullable', 'numeric', 'min:0'],
        'infobox.ethnicGroups'   => ['sometimes', 'array'],
        'infobox.ethnicGroups.*' => ['string', 'max:100'],
        'infobox.languages'      => ['sometimes', 'array'],
        'infobox.languages.*'    => ['string', 'max:100'],
    ],
    'INSTITUTION' => [
        'infobox' => ['required', 'array'],
        'infobox.officialName'  => ['required', 'string', 'max:200'],
        'infobox.acronym'       => ['nullable', 'string', 'max:20'],
        'infobox.institutionType' => ['required', 'string', 'max:100'], // Université, Ministère, ONG…
        'infobox.foundedYear'   => ['nullable', 'integer', 'min:1000', 'max:2100'],
        'infobox.headquarters'  => ['nullable', 'string', 'max:200'],
    ],
    // autres types : infobox absente au MVP
];
```

> La validation serveur (`FormRequest`) est **la référence**. Flutter n'anticipe les erreurs que pour le confort d'usage : il ne doit jamais être la seule barrière.

---

## 9. Workflow éditorial (machine à états)

### 9.1 Diagramme

```
                    ┌──────────────── request_revision ────────────────┐
                    ▼                                                   │
  DRAFT ──submit──► SUBMITTED ──start_review──► IN_REVIEW ──approve──► APPROVED ──publish──► PUBLISHED
    ▲                  ▲                                                                        │  │
    │                  └── (submit après correction) ── REVISION_REQUESTED ◄───────────────────┘  │
    │                                                                    (depuis IN_REVIEW)        │
    │                                                                         archive │            │ restore
    │                                                                                 ▼            │
    └─────────────────────────────── DELETED (ADMIN, depuis n'importe quel état) ◄── ARCHIVED ─────┘
```

### 9.2 Table des transitions (source de vérité)

| Action | De | Vers | Rôles autorisés | Contraintes |
|---|---|---|---|---|
| `submit` | `DRAFT`, `REVISION_REQUESTED` | `SUBMITTED` | CONTRIBUTOR, EDITOR, ADMIN | Seul **l'auteur** ; titre, résumé, contenu non vide, catégorie requis ; crée une `article_versions` |
| `start_review` | `SUBMITTED` | `IN_REVIEW` | EDITOR, ADMIN | Pas l'auteur (sauf `ALLOW_SELF_REVIEW`) |
| `request_revision` | `IN_REVIEW` | `REVISION_REQUESTED` | EDITOR, ADMIN | **Commentaire obligatoire** ; notifie l'auteur |
| `approve` | `IN_REVIEW` | `APPROVED` | EDITOR, ADMIN | — |
| `publish` | `APPROVED` | `PUBLISHED` | EDITOR, ADMIN | Renseigne `published_at` ; crée une version ; (raccourci UI « Approuver et publier » = `approve` + `publish` dans **une** transaction) |
| `archive` | `PUBLISHED` | `ARCHIVED` | EDITOR, ADMIN | — |
| `restore` | `ARCHIVED` | `PUBLISHED` | EDITOR, ADMIN | — |
| `delete` | tout sauf `DELETED` | `DELETED` | ADMIN | Suppression douce (`deleted_at`) |

**Règles d'édition par statut**

| Statut | Qui peut modifier le contenu |
|---|---|
| `DRAFT`, `REVISION_REQUESTED` | L'auteur ; ADMIN |
| `SUBMITTED` | Personne (verrouillé) |
| `IN_REVIEW` | EDITOR / ADMIN (corrections mineures, tracées) |
| `PUBLISHED` | EDITOR / ADMIN uniquement (chaque sauvegarde = nouvelle version + action `EDITED_PUBLISHED`) |
| `ARCHIVED`, `DELETED` | ADMIN |

> Les contributeurs ne peuvent pas modifier directement un article publié au MVP. La « proposition de modification » est une fonctionnalité V1.

### 9.3 Implémentation de référence (`backend/app/Services/Workflow.php`, classe pure)

```php
<?php

namespace App\Services;

use App\Enums\ArticleStatus;
use App\Enums\Role;
use App\Exceptions\WorkflowException;

/**
 * Machine à états du workflow éditorial — classe pure, aucun accès BDD.
 * Règles : cf. CONTEXT §9.2 (source de vérité).
 */
final class Workflow
{
    public const RULES = [
        'submit' => [
            'from' => [ArticleStatus::DRAFT, ArticleStatus::REVISION_REQUESTED],
            'to' => ArticleStatus::SUBMITTED,
            'roles' => [Role::CONTRIBUTOR, Role::EDITOR, Role::ADMIN],
            'authorOnly' => true,
        ],
        'start_review' => [
            'from' => [ArticleStatus::SUBMITTED],
            'to' => ArticleStatus::IN_REVIEW,
            'roles' => [Role::EDITOR, Role::ADMIN],
            'notAuthor' => true,
        ],
        'request_revision' => [
            'from' => [ArticleStatus::IN_REVIEW],
            'to' => ArticleStatus::REVISION_REQUESTED,
            'roles' => [Role::EDITOR, Role::ADMIN],
            'commentRequired' => true,
        ],
        'approve' => [
            'from' => [ArticleStatus::IN_REVIEW],
            'to' => ArticleStatus::APPROVED,
            'roles' => [Role::EDITOR, Role::ADMIN],
        ],
        'publish' => [
            'from' => [ArticleStatus::APPROVED],
            'to' => ArticleStatus::PUBLISHED,
            'roles' => [Role::EDITOR, Role::ADMIN],
        ],
        'archive' => [
            'from' => [ArticleStatus::PUBLISHED],
            'to' => ArticleStatus::ARCHIVED,
            'roles' => [Role::EDITOR, Role::ADMIN],
        ],
        'restore' => [
            'from' => [ArticleStatus::ARCHIVED],
            'to' => ArticleStatus::PUBLISHED,
            'roles' => [Role::EDITOR, Role::ADMIN],
        ],
        'delete' => [
            'from' => [
                ArticleStatus::DRAFT, ArticleStatus::SUBMITTED, ArticleStatus::IN_REVIEW,
                ArticleStatus::REVISION_REQUESTED, ArticleStatus::APPROVED,
                ArticleStatus::PUBLISHED, ArticleStatus::ARCHIVED,
            ],
            'to' => ArticleStatus::DELETED,
            'roles' => [Role::ADMIN],
        ],
    ];

    /**
     * @throws WorkflowException code FORBIDDEN | INVALID_TRANSITION | COMMENT_REQUIRED
     */
    public static function assertTransition(array $args): ArticleStatus
    {
        $rule = self::RULES[$args['action']];

        if (!in_array($args['actorRole'], $rule['roles'], true)) {
            throw new WorkflowException('FORBIDDEN', 'Rôle insuffisant.');
        }
        if (!in_array($args['status'], $rule['from'], true)) {
            throw new WorkflowException(
                'INVALID_TRANSITION',
                "Impossible de faire « {$args['action']} » depuis le statut {$args['status']->value}."
            );
        }
        if (($rule['authorOnly'] ?? false) && $args['actorId'] !== $args['authorId']) {
            throw new WorkflowException('FORBIDDEN', "Seul l'auteur peut effectuer cette action.");
        }
        if (($rule['notAuthor'] ?? false)
            && $args['actorId'] === $args['authorId']
            && !($args['allowSelfReview'] ?? false)) {
            throw new WorkflowException('FORBIDDEN', 'Vous ne pouvez pas réviser votre propre article.');
        }
        if (($rule['commentRequired'] ?? false) && trim((string) ($args['comment'] ?? '')) === '') {
            throw new WorkflowException('COMMENT_REQUIRED', 'Un commentaire est obligatoire.');
        }

        return $rule['to'];
    }
}
```

> **Première tâche de test recommandée** : écrire les tests Pest de `Workflow::assertTransition` (classe pure, aucun mock nécessaire) : un test par ligne du tableau 9.2, plus les cas d'échec. C'est le meilleur entraînement du projet.

### 9.4 Service de transition (squelette)

```php
// backend/app/Services/ArticleService.php  (squelette — à compléter)
public function transition(Article $article, string $action, User $actor, ?string $comment = null): Article
{
    return DB::transaction(function () use ($article, $action, $actor, $comment) {
        $fresh = Article::query()->lockForUpdate()->findOrFail($article->id);

        $toStatus = Workflow::assertTransition([/* … voir 9.3 … */]);

        $fresh->update([
            'status' => $toStatus,
            'published_at' => $toStatus === ArticleStatus::PUBLISHED && $fresh->published_at === null
                ? now() : $fresh->published_at,
            'deleted_at' => $toStatus === ArticleStatus::DELETED ? now() : null,
            'lock_version' => $fresh->lock_version + 1,
        ]);

        // 1. snapshot si submit / publish (ADR-005)
        // 2. editorial_actions (append-only) : fromStatus, toStatus, comment
        // 3. notification email APRÈS la transaction (dispatch d'un job) :
        //    ne pas bloquer ni annuler la transition si l'email échoue

        return $fresh->refresh();
    });
}
```

**Verrou optimiste** : `PATCH /api/v1/articles/{id}` exige `lock_version` dans le corps. Si la valeur en base diffère → réponse **409 CONFLICT** (« L'article a été modifié entre-temps »). Évite que deux personnes s'écrasent mutuellement.

---

## 10. Rôles et permissions (RBAC)

*RBAC = Role-Based Access Control : les droits dépendent du rôle de l'utilisateur.*

| Action | Anonyme | READER | CONTRIBUTOR | EDITOR | ADMIN |
|---|:-:|:-:|:-:|:-:|:-:|
| Lire articles publiés | ✅ | ✅ | ✅ | ✅ | ✅ |
| Créer un compte | ✅ | — | — | — | — |
| Créer / éditer son brouillon | ❌ | ❌ | ✅ | ✅ | ✅ |
| Soumettre son article | ❌ | ❌ | ✅ | ✅ | ✅ |
| Voir la file de révision | ❌ | ❌ | ❌ | ✅ | ✅ |
| Approuver / demander révision / publier / archiver | ❌ | ❌ | ❌ | ✅ | ✅ |
| Éditer un article publié | ❌ | ❌ | ❌ | ✅ | ✅ |
| Gérer catégories | ❌ | ❌ | ❌ | ❌ | ✅ |
| Gérer utilisateurs (rôles, suspension) | ❌ | ❌ | ❌ | ❌ | ✅ |
| Supprimer (soft delete) | ❌ | ❌ | ❌ | ❌ | ✅ |

**Règles transverses**
- Un utilisateur `suspended_at != null` ne peut plus se connecter.
- Les vérifications de permission sont **toujours côté serveur** (Services + Policies Laravel). Masquer un bouton dans Flutter n'est **pas** une protection.
- Un article non publié n'est visible que par son auteur, les EDITOR et les ADMIN.
- Phase solo : le fondateur est `ADMIN` et utilise `ALLOW_SELF_REVIEW=true`. **Le désactiver dès l'arrivée du premier éditeur.**

---

## 11. Contrat d'API (MVP)

Base : `/api/v1`. Format JSON. Authentification : session Sanctum (cookie) côté web. Validation `FormRequest` sur **toutes** les entrées.

### 11.1 Endpoints

| Méthode | Route | Accès | Description | EF |
|---|---|---|---|---|
| POST | `/api/v1/register` | public | Inscription (crée `READER`, envoie email de vérification) | AUTH-01/02 |
| POST | `/api/v1/verify-email` | public | Valide le token email | AUTH-02 |
| POST | `/api/v1/forgot-password` | public | Envoie un lien de réinitialisation (réponse identique que l'email existe ou non) | AUTH-05 |
| POST | `/api/v1/reset-password` | public | Définit un nouveau mot de passe | AUTH-05 |
| POST | `/api/v1/login` | public | Connexion (session web / jeton Android) | AUTH-03 |
| POST | `/api/v1/logout` | authentifié | Déconnexion | AUTH-04 |
| GET | `/api/v1/me` | authentifié | Profil courant (sanctionne les sessions invalides) | AUTH-04 |
| GET | `/api/v1/articles` | public | Liste des articles **publiés** (`?category=&tag=&page=&limit=`) | RCH-02/05 |
| GET | `/api/v1/articles/{slug}` | public* | Détail (publié ; sinon auteur/éditeur/admin) | ART |
| POST | `/api/v1/articles` | CONTRIBUTOR+ | Crée un brouillon | ART-01 |
| PATCH | `/api/v1/articles/{id}` | selon statut (9.2) | Met à jour (auto-save inclus) ; exige `lock_version` | ART-02/03 |
| POST | `/api/v1/articles/{id}/transition` | selon 9.2 | Corps : `{ action, comment? }` | WF |
| GET | `/api/v1/articles/{id}/versions` | EDITOR+ / auteur | Historique des versions | ART-10 |
| GET | `/api/v1/me/articles` | CONTRIBUTOR+ | Mes articles et statuts | WF-05 |
| GET | `/api/v1/review/queue` | EDITOR+ | Articles `SUBMITTED` / `IN_REVIEW` | WF-01 |
| GET | `/api/v1/search?q=&page=` | public | Recherche dans les articles publiés | RCH-01 |
| GET | `/api/v1/categories` | public | Arbre des catégories | CAT |
| GET | `/api/v1/statistics` | public | Indicateurs du pays par thème, divisions du RGPH 2021 et climatologie des villes (cache 6 h) | STAT |
| GET | `/api/v1/history` | public | Récits sourcés de la section « Histoire incroyable » (cache 6 h) | HIS |
| POST | `/api/v1/articles/{id}/cover` | CONTRIBUTOR+ | Upload d'image (multipart) : MIME vérifié côté serveur, `alt` obligatoire | ART-06 |

*Gestion des catégories et des utilisateurs : **panneau Filament `/admin`** (ressources + Policies), pas de routes API admin dédiées au MVP.*
*V1 : `POST /api/v1/articles/{id}/rollback`, signalements, logs d'activité.*

### 11.2 Format d'erreur unique

Laravel renvoie `422 { message, errors }` pour la validation ; un handler d'exception unique (requete non transformée) adapte **toutes** les erreurs vers cette enveloppe :

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Le titre est obligatoire.",
    "details": [{ "path": ["title"], "message": "Required" }]
  }
}
```

| HTTP | `code` | Cas |
|---|---|---|
| 401 | `UNAUTHENTICATED` | Pas de session |
| 403 | `FORBIDDEN` | Permission refusée |
| 404 | `NOT_FOUND` | Ressource absente ou non visible |
| 409 | `CONFLICT`, `INVALID_TRANSITION` | Verrou optimiste, transition interdite |
| 422 | `VALIDATION_ERROR`, `COMMENT_REQUIRED` | Entrée invalide (FormRequest) ou commentaire manquant |
| 429 | `RATE_LIMITED` | Trop de requêtes |
| 500 | `INTERNAL_ERROR` | Erreur serveur (message générique, détails dans les logs) |

### 11.3 Pagination
`?page=1&limit=20` (limite maximale 20 : ENF-PERF-05). Réponse : `{ data: [...], meta: { page, limit, total } }`.

---

## 12. Séquences clés (résumé)

**Inscription** : formulaire Flutter → `POST /api/v1/register` → `FormRequest` → email unique ? → `Hash::make` (bcrypt) → `INSERT users` → création `verification_tokens` (hash) → email de vérification → réponse 201.

**Connexion** : `POST /api/v1/login` → recherche user par email → vérification suspension + `email_verified_at` → `Hash::check` → **session Sanctum en cookie HttpOnly / Secure / SameSite=Lax** (web) ou jeton dans `flutter_secure_storage` (Android, plus tard). Message d'erreur **identique** pour « email inconnu » et « mauvais mot de passe ».

**Rédaction → publication** : `POST /api/v1/articles` (DRAFT) → auto-save `PATCH` toutes les 60 s → `transition: submit` (snapshot v1, notification aux éditeurs) → `start_review` → `approve` + `publish` (snapshot, `published_at`) → l'article apparaît dans les pages publiques de l'app.

**Demande de révision** : `request_revision` avec commentaire → statut `REVISION_REQUESTED` → email à l'auteur → l'auteur corrige et re-soumet (`submit`).

---

## 13. Sécurité (règles non négociables)

| Menace | Règle |
|---|---|
| Injection SQL | Eloquent / Query Builder uniquement (requêtes paramétrées). Si `DB::raw` est nécessaire : **uniquement avec des liaisons (`?`)**, jamais de concaténation de chaînes. |
| XSS | Le contenu est du **JSON Delta rendu par des widgets Flutter** : aucun HTML n'est injecté. Si un HTML est généré côté serveur (exports, rendu SEO V1), il passe par une liste blanche de balises/attributs (`strip_tags` durci ou purifier dédié) avant stockage ou affichage. |
| CSRF | Cookies de session `SameSite=Lax` + tokens CSRF Laravel sur les mutations ; vérifier `Origin`/`Referer`. Les appels API depuis Android utiliseront un jeton Authorization (pas de cookie). |
| Mots de passe | `Hash::make` (bcrypt ≥ 12 rounds), longueur minimale 10 caractères, jamais loggés. |
| Brute-force | `RateLimiter` de Laravel sur `/login`, `/register`, `/forgot-password` (par IP et par email). |
| Énumération de comptes | Réponses identiques pour « email existe / n'existe pas » (reset, inscription). |
| Tokens (vérif. email, reset) | Aléatoires (≥ 32 octets), **stockés hachés** (`token_hash`), usage unique, expiration courte. |
| Upload | Validation MIME et taille **côté serveur** (jpeg/png/webp uniquement) ; stockage hors de la racine web via le disque `public` de Laravel ; `alt` obligatoire. |
| Autorisation | Vérifiée dans chaque Service et Policy (jamais seulement dans Flutter). Tester le cas « utilisateur A accède à la ressource de B ». |
| Secrets | `backend/.env` hors dépôt (`.gitignore`), jamais dans le code ni les logs ; `php artisan config:cache` en production. |
| En-têtes HTTP | HTTPS forcé (prod), HSTS, `Content-Security-Policy` raisonnable, `X-Content-Type-Options: nosniff` (configuration Nginx, PDF Phase 2). |
| Dépendances | Dependabot activé ; `composer audit` en CI. |
| Sauvegardes | Sauvegarde MySQL quotidienne **dès la première semaine de prod** ; **tester une restauration** au moins une fois avant le lancement public. |

**Données personnelles** : le traitement de données personnelles (email, nom) est encadré en Côte d'Ivoire par la loi n° 2013-450 relative à la protection des données à caractère personnel, sous le contrôle de l'ARTCI. Prévoir avant le lancement public : politique de confidentialité, mentions légales, possibilité de suppression de compte. *Ce document n'est pas un avis juridique : faire valider les obligations exactes (déclarations, hébergement) par un juriste.*

---

## 14. Backlog ordonné du MVP

Durées **indicatives** pour un développeur seul à temps partiel ; ajuster selon la disponibilité réelle. Chaque ticket = une branche + une PR. Les codes `EF-*` renvoient au cahier des charges.

### Sprint 0 — Fondations (≈ 1 semaine)
- [ ] Créer `backend/` (projet Laravel, Composer) et `app/` (projet Flutter, `flutter create`)
- [ ] Base `ivoirepedia` via phpMyAdmin + utilisateur SQL dédié ; `backend/.env.example` complet (§7.5)
- [ ] Migrations du schéma §8.2 + `seeders` (catégories de base, admin de dev)
- [ ] Scripts Composer : `test` (Pest), `format:check` (Pint), `analyse` (Larastan) ; `analysis_options.yaml` Flutter (flutter_lints)
- [ ] CI GitHub Actions (2 jobs : backend + flutter — canevas §15.4)
- [ ] `docs/INSTALLATION.md` avec les versions **réellement constatées**
- [ ] Déploiement « hello world » (API qui répond + site Flutter affiche un écran)
- **Critère de sortie** : un nouvel arrivant suit §7 et obtient l'app Flutter **et** l'API en local ; la CI est verte.

### Sprint 1 — Authentification (≈ 2 semaines) · EF-AUTH-01→05
- [ ] Inscription + hash du mot de passe (`Hash::make`)
- [ ] Vérification email (token haché, expiration)
- [ ] Connexion / déconnexion (Sanctum, session cookie) + `GET /api/v1/me`
- [ ] Reset du mot de passe
- [ ] Rate-limiting sur routes sensibles
- [ ] Middleware d'authentification + Policies (`requireRole()` équivalent)
- **Critère de sortie** : un utilisateur s'inscrit, vérifie son email, se connecte ; un ADMIN peut le promouvoir en base (via **phpMyAdmin**, l'UI admin vient au Sprint 5).

### Sprint 2 — Articles & éditeur (≈ 2-3 semaines) · EF-ART-01→09
- [ ] Génération de slug (`Str::slug` + suffixe anti-doublon, tests)
- [ ] Service article : créer / lire / mettre à jour (avec `lock_version` → 409)
- [ ] Éditeur `flutter_quill` + auto-save 60 s
- [ ] Sélection catégorie + tags
- [ ] Références bibliographiques (ajout / position / suppression)
- [ ] Upload image de couverture (disque local, MIME vérifié) avec `alt`
- [ ] Prévisualisation
- **Critère de sortie** : un CONTRIBUTOR crée, édite et prévisualise un brouillon depuis Flutter Web.

### Sprint 3 — Workflow & versions (≈ 2-3 semaines) · EF-WF-01→06, EF-ART-10
- [ ] `app/Services/Workflow.php` + **tests Pest exhaustifs** (chaque transition, chaque rôle)
- [ ] `ArticleService::transition` avec transaction + `editorial_actions`
- [ ] Création des `article_versions` aux jalons (ADR-005)
- [ ] File de révision (écran Flutter) + page de relecture
- [ ] Emails de notification (soumission, révision demandée, publication)
- [ ] Page « Mes articles » avec statuts
- [ ] Historique des versions (lecture seule)
- **Critère de sortie** : cycle complet brouillon → publié, avec traçabilité, couvert par tests d'intégration Pest.

### Sprint 4 — Lecture publique, navigation, recherche (≈ 2 semaines) · EF-RCH-01→05, 08
- [ ] Accueil (récents / mis en avant), page article (infobox, références, tags)
- [ ] Pages catégorie (arborescence) et tag
- [ ] Recherche simple + page de résultats paginée
- [ ] Navigation `go_router` avec URLs propres ; métadonnées de base via `web/index.html` (limitation SPA — cf. §17 R-09)
- [ ] Responsive mobile-first
- **Critère de sortie** : un visiteur anonyme trouve et lit un article publié depuis un mobile.

### Sprint 5 — Admin Filament & durcissement (≈ 2 semaines) · EF-ADM-01→03,05,08
- [ ] Panneau Filament `/admin` : ressources utilisateurs (rôle, suspension) et catégories
- [ ] Tableau de bord minimal (compteurs)
- [ ] Sauvegardes automatiques MySQL + **test de restauration**
- [ ] Revue sécurité (checklist section 13) + en-têtes HTTP
- [ ] Pages légales (confidentialité, mentions, licence du contenu)
- [ ] Contenu initial : **au moins 30 articles de qualité** avant ouverture publique
- **Critère de sortie** : bêta privée avec 5-10 testeurs.

### Après le MVP (V1)
Rollback · Recherche full-text MySQL · Commentaires éditoriaux · Signalements · Logs d'activité · Autocomplétion · Wiki-links `[[Terme]]` · Audio · API publique en lecture · Publication Android (packaging du code Flutter partagé) · Premiers contributeurs externes (voir `CONTRIBUTING.md` à rédiger).

---

## 15. Conventions de développement

### 15.1 Code
- **Dart** : `flutter analyze` sans erreur (règles `flutter_lints`) ; fichiers en `snake_case.dart`, classes en `PascalCase`.
- **PHP** : style **PSR-12** via Pint, analyse Larastan ; classes en `PascalCase`, méthodes en `camelCase` (autoload PSR-4 `App\`).
- Fonctions courtes, une responsabilité. Les noms disent **ce que ça fait**, pas comment.
- Commentaires : expliquer le **pourquoi**, pas le **quoi**. Les règles métier non évidentes sont commentées avec une référence (`// cf. CONTEXT §9.2`).
- Pas de logique dupliquée Flutter/backend : la validation `FormRequest` du backend est la référence, Flutter n'anticipe que pour l'UX.

### 15.2 Git
- Branche principale `main` toujours déployable. Branches courtes : `feat/ef-art-01-create-draft`, `fix/…`, `docs/…`, `chore/…`.
- **Conventional Commits** : `feat(article): add autosave`, `fix(auth): normalize email`, `test(workflow): cover revision path`.
- Une PR = un sujet, relue (même en solo : relire sa propre PR sur GitHub avant de merger).
- Chaque PR référence un code `EF-*` ou `ENF-*` quand c'est pertinent.

### 15.3 Tests

| Niveau | Outil | Fichiers | Cible minimale MVP |
|---|---|---|---|
| Unit (règles pures) | Pest | `backend/tests/Unit/…` | `Workflow`, RBAC/Policies, slug, règles d'infobox |
| Feature (HTTP) | Pest | `backend/tests/Feature/…` | Services `article` et `workflow` (transitions complètes), permissions, validation |
| Widgets / parcours Flutter | `flutter_test` | `app/test/…` | Écrans critiques : connexion, éditeur, file de révision |
| E2E | `integration_test` | V1 : parcours inscription → publication |

> Priorité absolue de test : **permissions, workflow, validation d'entrées**. Ce sont les zones où un bug = faille ou corruption de contenu.
> Un seul outil par couche : on n'ajoute jamais un second framework de test.

### 15.4 CI (`.github/workflows/ci.yml` — canevas, créé au Sprint 0)

```yaml
name: CI

on: [push, pull_request]

permissions:
  contents: read

jobs:
  backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
          extensions: mbstring, pdo_mysql, sqlite3, xml, curl, zip, bcmath, gd, intl
          coverage: none
      - uses: ramsey/composer-install@v3
        with:
          working-directory: backend
      - name: Préparer la clé d'application de test
        working-directory: backend
        run: |
          cp .env.example .env
          php artisan key:generate
      - run: composer test
        working-directory: backend
      - run: composer format:check
        working-directory: backend
      - run: composer analyse
        working-directory: backend

  flutter:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - run: flutter pub get
        working-directory: app
      - run: flutter analyze
        working-directory: app
      - run: flutter test
        working-directory: app
      - run: flutter build web --release
        working-directory: app
```

*(Vérifier les versions actuelles des actions GitHub à la mise en place, et figer la version de Flutter constatée.)*

### 15.5 Definition of Done (une tâche est terminée quand…)
- [ ] Le comportement correspond à l'exigence `EF-*` citée
- [ ] Entrées validées (`FormRequest`) et permissions vérifiées côté serveur (Services/Policies)
- [ ] Tests ajoutés pour la logique métier touchée (Pest ou flutter_test selon la couche)
- [ ] `composer test`, `composer format:check`, `composer analyse`, `flutter analyze`, `flutter test` passent en local et en CI
- [ ] Aucun secret ni donnée personnelle dans le code ou les logs
- [ ] Textes d'interface en français, accessibles (alt, labels, contraste)
- [ ] Ce fichier et/ou un ADR mis à jour si une décision a changé

---

## 16. Instructions spécifiques aux assistants IA

### 16.1 Comportement attendu
1. **Lire avant d'écrire** : consulter les sections 4, 6, 8, 9, 10, 13 avant de proposer du code.
2. **Respecter le périmètre** : MVP seulement (section 3). Signaler gentiment toute demande hors périmètre.
3. **Petits pas** : proposer des changements courts et vérifiables (un fichier ou une fonction à la fois), avec la commande pour les tester.
4. **Pédagogie** : le développeur est en apprentissage. Pour chaque concept non trivial (ORM, transaction, Policy, verrou optimiste, Delta Quill…), donner une définition en une phrase et le *pourquoi*.
5. **Cohérence** : réutiliser les noms de la section 8.1, les codes d'erreur de 11.2, les conventions de 15.
6. **Honnêteté** : si une information dépend de la version d'une librairie (Laravel, Filament, Sanctum, Flutter, Quill…), **dire de vérifier la documentation officielle** plutôt que d'affirmer de mémoire.
7. **Tests d'abord pour la logique métier** : proposer les tests Pest de `Workflow`/`Policies` avant ou avec l'implémentation.

### 16.2 À ne jamais faire
- Ajouter une dépendance, un service cloud ou un changement d'architecture sans ADR.
- Mettre de la logique métier dans un contrôleur Laravel, une route Filament ou un widget Flutter.
- Écrire une requête SQL par concaténation de chaînes.
- Insérer du HTML non sanitisé ; accepter un contenu ou un `content` non validé depuis le client.
- Contourner `Workflow::assertTransition` pour changer un statut.
- Modifier ou supprimer des lignes d'`editorial_actions`.
- Stocker un token ou un mot de passe en clair.
- Introduire du code mort « pour plus tard » (YAGNI).
- Réécrire de gros pans du projet sans demande explicite.

### 16.3 Modèles de prompts utiles (pour le dev)

**Implémenter un ticket**
> Contexte : IVOIREPEDIA (voir IVOIREPEDIA_CONTEXT.md). Ticket : « EF-ART-01 Créer un brouillon ». Respecte les couches de la section 6.2 et le schéma 8.2. Donne : (1) le `FormRequest`, (2) le Service, (3) le contrôleur `Api/V1`, (4) les tests Pest. Explique chaque concept nouveau en une phrase.

**Revue de code**
> Relis ce diff selon la Definition of Done (15.5) et la checklist sécurité (13). Liste d'abord les problèmes bloquants, puis les améliorations. Explique chaque remarque.

**Comprendre une erreur**
> Voici l'erreur et le fichier concerné. Explique la cause en termes simples, propose la correction minimale, puis dis comment éviter ce type d'erreur à l'avenir.

**Écrire des tests**
> Écris les tests Pest de `Workflow::assertTransition` : un test par ligne du tableau 9.2, plus les cas d'échec (mauvais rôle, mauvais statut, commentaire manquant, auto-révision).

---

## 17. Risques et questions ouvertes

### 17.1 Risques principaux

| # | Risque | Gravité | Mitigation |
|---|---|---|---|
| R-01 | Surcharge / abandon du projet solo | Élevée | Sprints courts, périmètre MVP strict, 1 fonctionnalité à la fois, publier tôt |
| R-02 | Dérive de périmètre (scope creep) | Élevée | Section 3.2 ; toute addition passe par un ticket explicite |
| R-03 | Faille de sécurité (XSS, contrôle d'accès) | Élevée | Section 13, tests Pest ciblés, Services comme unique point d'écriture |
| R-04 | Perte de données | Élevée | Sauvegardes MySQL dès S0 (prod) + test de restauration |
| R-05 | Charge cognitive : deux langages (Dart, PHP) pour un dev seul | Moyenne | Backend = unique source des règles métier ; l'app reste une couche d'affichage ; pédagogie du CONTEXT |
| R-06 | Plateforme vide au lancement | Moyenne | ≥ 30 articles de qualité avant ouverture ; recruter 2-3 éditeurs de confiance |
| R-07 | Qualité éditoriale / vandalisme | Moyenne | Workflow strict, pas de modification directe des articles publiés par les contributeurs |
| R-08 | Fragmentation moteur MySQL/MariaDB (XAMPP) | Moyenne | Migrations sans fonctions propriétaires, CI sur MySQL, moteur réel consigné dans INSTALLATION |
| R-09 | **SEO limité (Flutter Web = SPA côté client)** | Moyenne | Pages publiques sans rendu serveur. URLs propres en place depuis la version 1.8 (`/statistiques`, `/articles/{slug}`, sans dièse, servies à la racine du domaine) et métadonnées dans `web/index.html` ; réévaluer un prérendu/SSR statique en V1 si la visibilité devient critique |
| R-10 | Dépendance à l'hébergeur (Alwaysdata mutualisé) | Moyenne | Code portable (MySQL standard, médias derrière un `MediaService`), dépôt Git = source de vérité permettant de redéployer ailleurs ; limites assumées dans `docs/DEPLOIEMENT.md` §7 (ADR-008) |

### 17.2 Questions ouvertes (à trancher avant la bêta publique)

| # | Question | Échéance |
|---|---|---|
| Q1 | **Licence du code** (MIT, Apache-2.0, AGPL-3.0…) | Avant le 1ᵉʳ contributeur externe |
| Q2 | **Licence du contenu** : confirmer CC BY-SA 4.0 et rédiger la charte éditoriale | Avant la bêta privée |
| Q3 | Nom de domaine et adresse d'expédition des emails (SPF/DKIM) — **Mailjet retenu (ADR-009)**, le domaine d'expédition reste à trancher | Sprint 1 |
| Q4 | Charte éditoriale : critères de notoriété, sources acceptées, neutralité, traitement de la tradition orale | Sprint 3 |
| Q5 | Politique de modération (vandalisme, contenus sensibles, droit de réponse) | Sprint 5 |
| Q6 | Conformité données personnelles : déclarations ARTCI, hébergement, durée de conservation | Avant la bêta publique |
| Q7 | Stratégie de recrutement des premiers éditeurs et contributeurs | Sprint 4 |
| Q8 | **Éditeur riche Flutter** : confirmer `flutter_quill` (choix de référence §5) ou alternative avant de coder le Sprint 2 | Avant le Sprint 2 |
| Q9 | ~~Hébergeur de production~~ — **tranché le 3 nov. 2026 : Alwaysdata** (ADR-008). Restent les sauvegardes (test de restauration) et la supervision | Avant la bêta publique |

---

## 18. Glossaire

| Terme | Définition |
|---|---|
| **ADR** | *Architecture Decision Record* : note courte qui consigne une décision technique et sa justification. |
| **API REST / route** | Point d'entrée HTTP du serveur (ex. `POST /api/v1/articles`) qui reçoit une requête et renvoie du JSON. |
| **Append-only** | Table où l'on n'ajoute que des lignes, sans jamais modifier ni supprimer (journal fiable). |
| **bcrypt** | Algorithme de hachage lent pour mots de passe : transforme un mot de passe en empreinte non réversible. |
| **CI** | *Continuous Integration* : exécution automatique des vérifications (tests, analyse, build) à chaque modification. |
| **Composer / `pub`** | Gestionnaires de dépendances, respectivement PHP (backend) et Dart (Flutter). |
| **CRUD** | Create, Read, Update, Delete : les 4 opérations de base sur les données. |
| **CSP** | *Content Security Policy* : en-tête HTTP limitant les sources de scripts autorisées (défense contre XSS). |
| **Delta (Quill)** | Format JSON de l'éditeur `flutter_quill` : le contenu d'un article est stocké sous cette forme. |
| **Eloquent** | L'ORM de Laravel : traduit les objets PHP en requêtes SQL paramétrées. |
| **Filament** | Framework d'administration pour Laravel : construit le panneau `/admin` à partir des modèles. |
| **Hash / empreinte** | Résultat d'une fonction à sens unique appliquée à une donnée (ex. SHA-256). |
| **MVP** | *Minimum Viable Product* : plus petite version utilisable du produit. |
| **Pest / PHPUnit** | Frameworks de tests PHP ; le projet retient **Pest** (un seul outil de test). |
| **Pint / Larastan** | Outils de qualité PHP : formatage (PSR-12) et analyse statique. |
| **Rate limiting** | Limitation du nombre de requêtes par période pour contrer abus et brute-force. |
| **RBAC** | *Role-Based Access Control* : contrôle d'accès fondé sur les rôles. |
| **Sanctum** | Brique d'authentification de Laravel : sessions cookies (web) et jetons révocables (mobile). |
| **Slug** | Version « URL » d'un titre : `felix-houphouet-boigny`. |
| **Soft delete** | Suppression logique : la ligne est marquée supprimée (`deleted_at`) mais conservée un temps. |
| **Transaction** | Groupe d'opérations BDD exécutées « tout ou rien ». |
| **Verrou optimiste** | Détection de modifications concurrentes via un numéro de version (`lock_version`) ; conflit → 409. |
| **XAMPP** | Distribution locale Apache + PHP + MySQL/MariaDB + phpMyAdmin, pour le développement sans configuration serveur. |
| **XSS** | *Cross-Site Scripting* : injection de script malveillant dans une page vue par d'autres utilisateurs. |
| **YAGNI** | *You Aren't Gonna Need It* : ne pas construire ce dont on n'a pas encore besoin. |

---

## 19. Historique du document

| Date | Version | Changement |
|---|---|---|
| 2026-11-02 | 1.0 | Création : consolidation du cahier des charges, de la conception UML et de la roadmap ; décisions ADR-001 à 008 ; backlog MVP. |
| 2026-11-02 | 1.1 | **Adaptation de la stack au modèle Flutter + Laravel** : Flutter (`app/`) + Laravel (`backend/`) + MySQL/Filament/Sanctum remplacent Next.js + Prisma + PostgreSQL + Auth.js. Schéma converti en MySQL (§8.2), workflow traduit en PHP (§9), API versionnée `/api/v1` (§11), CI à deux jobs (§15.4), divergences D9 et nouveaux risques R-05/R-08/R-09. |
| 2026-11-03 | 1.2 | **Hébergement et emails tranchés** : Alwaysdata remplace XAMPP dès le développement (ADR-002 révisé, ADR-008 réécrit) et Mailjet devient le relais SMTP (ADR-009). §5 stack, §7 installation (base distante, ports), §7.5 variables d'environnement, R-10, Q3/Q9 mis à jour. Guides `docs/INSTALLATION.md` et `docs/DEPLOIEMENT.md`. |
| 2026-11-13 | 2.0 | **Chiffres datés et évolutions** : chaque indicateur expose `trend` (moyenne annuelle sur cinq ans, taux composé ou points par an), `meta.data_through` dit la dernière année publiée, `data.census.growth` la croissance nationale. `GET /api/v1/places/{slug}` ajoute `estimate` : population extrapolée pour 2026 depuis le RGPH 2021, avec sa méthode et son statut d'estimation. |
| 2026-11-13 | 1.9 | **Découverte et lecture** : `GET /api/v1/timeline` (frise construite sur les récits datés, colonne `year`), `GET /api/v1/places` et `/places/{slug}` (districts, régions, villes du RGPH avec climat et articles liés), `GET /api/v1/search/suggest`. Côté app : `/chronologie`, `/lieux`, `/lieux/{slug}`, `/ma-bibliotheque` ; partage WhatsApp/X/Facebook/LinkedIn, liens profonds par section, recherche instantanée avec historique, favoris et lectures locales, thème papier/sépia/nuit, taille du texte, mode lecture seule, sommaire suivi, notes cliquables. |
| 2026-11-13 | 1.8 | **Le site à la racine** : build Flutter servi à la racine du domaine (`--base-href=/`) à côté de `index.php`, `usePathUrlStrategy()` (adresses `/statistiques`, `/articles/{slug}`, sans dièse), `backend/public/.htaccess` qui répartit `/api` et `/admin` vers Laravel, fichiers réels servis directement, reste vers `index.html`, redirection 301 des anciennes adresses `/site/`. `app/web/.htaccess` supprimé au profit de celui de la racine. |
| 2026-11-13 | 1.7 | **Récits anciens** : quatre récits supplémentaires dans `history_stories` — Agni Ndénian et Abengourou (AKIRI 2026), traversée du Comoé et nom baoulé (Akofena), royaume du Sanvi et balahinma Manlan Ahua (Académie des sciences d'outre-mer), capture de Samory Touré à Guélémou (Revue historique des armées 2013). Chaque URL contrôlée avant publication. |
| 2026-11-13 | 1.6 | **Pluviométrie et Histoire incroyable** : trois tables de climatologie (ERA5 1991-2020, six villes), `data.climate` dans l'API statistique, graphiques à axes et barres mensuelles, table `history_stories`, endpoint `/api/v1/history`, page Flutter `/histoires`. §8.2 et §11.1 mis à jour. |
| 2026-11-11 | 1.5 | **Statistiques nationales et articles enrichis** : trois tables (`country_indicators`, `country_indicator_points`, `census_divisions`), endpoint public `GET /api/v1/statistics`, page Flutter `/statistiques`, commandes `country:sync-statistics` (Banque mondiale + RGPH 2021) et `articles:enrich-sources` (infobox et références vérifiées). §8.2 et §11.1 mis à jour. |
| 2026-11-11 | 1.4 | **Répertoire des sources documentaires** : `docs/SOURCES_INFORMATION.md` recense environ 150 plateformes (institutions ivoiriennes, statistiques internationales, cartographie, patrimoine, archives, recherche, presse, droit, langues, images), chacune vérifiée par requête HTTP le 11 novembre 2026 et assortie de son statut, de sa licence et des règles de citation. Ajouté au §2 comme document de référence. |
| 2026-11-03 | 1.3 | **Compte d'hébergement dédié** : IVOIREPEDIA quitte le compte Alwaysdata partagé (ADR-008) — compte, site `ivoirepedia.alwaysdata.net`, dossier, bases `ivoirepedia_prod`/`ivoirepedia_dev` et utilisateur MySQL propres, phpMyAdmin par compte. §5, §7, ADR-002 et ADR-008 alignés ; aucune référence à un autre projet ne subsiste dans le dépôt. |

> **Règle de maintenance** : tout changement d'architecture, de modèle de données ou de workflow doit mettre à jour ce fichier **dans la même PR**. Un contexte obsolète est pire que pas de contexte.
