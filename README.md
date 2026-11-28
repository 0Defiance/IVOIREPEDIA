# IVOIREPEDIA — Encyclopédie Inclusive Ivoirienne

> **Version** : 1.4 · **Dernière mise à jour** : 27 novembre 2026 · **Statut** : **en ligne** — Sprints 0 et 1 réalisés (fondations, comptes lecteurs), panneau éditorial `/admin` opérationnel, 479 articles publiés sur `https://ivoirepedia.alwaysdata.net/` · **Langue de travail** : français

**IVOIREPEDIA** est une encyclopédie numérique libre et open source consacrée exclusivement à la documentation, la structuration et la valorisation du savoir ivoirien : histoire, géographie, personnalités, institutions, langues, culture, économie, patrimoine.

> Ce dépôt est la source de contexte du projet. Une personne ou une IA qui n'a rien suivi doit pouvoir comprendre **ce qu'est IVOIREPEDIA, ce qui est décidé, ce qui n'est pas, et comment reprendre le travail** en lisant les fichiers ci-dessous.

## Stack technique (validée le 2 novembre 2026)

| Couche | Choix |
|---|---|
| Interface | **Flutter** (`app/`) — site web d'abord, Android ensuite, une seule base de code |
| Backend | **Laravel** (`backend/`) — API REST `/api/v1` + panneau éditorial sur `/admin` (Blade et session par cookie, sans Filament) |
| Base de données | **MySQL** hébergé sur **Alwaysdata** — base de dev et base de production distinctes (plus de MySQL local) |
| Hébergement | **Alwaysdata** (site PHP + SSH) — **compte dédié à IVOIREPEDIA**, bases et identifiants propres |
| Authentification | **Laravel Sanctum** (session cookie web, jeton révocable Android) |
| Emails | **Mailjet** (relais SMTP) pour vérification d'adresse, reset et notifications |
| Tests / CI | **Pest** + **flutter_test** ; GitHub Actions (2 jobs : backend, flutter), dont le contrôle de formatage Dart |

Une seule base de code pour le web puis Android. Détails et ADR-001→009 dans le CONTEXT.

## Où est quoi

| Chemin | Contenu |
|---|---|
| [`IVOIREPEDIA_CONTEXT.md`](IVOIREPEDIA_CONTEXT.md) | **Source de vérité opérationnelle** — stack, ADR, modèle de données MySQL, workflow éditorial, RBAC, contrat d'API `/api/v1`, backlog. **Lire avant toute intervention.** En cas de contradiction entre documents, ce fichier fait foi. |
| [`docs/IVOIREPEDIA_Document_de_Contextualisation.md`](docs/IVOIREPEDIA_Document_de_Contextualisation.md) | Vision complète du produit (multilinguisme, sources orales, géolocalisation, hors-ligne…) — statuts ✅ / 🟡 / ❓. Sa stack d'origine est supplantée par le CONTEXT. |
| [`AGENTS.md`](AGENTS.md) | **Règle de travail** : définition de « fait », vérifications avant commit, parité permanente local / distant |
| [`docs/INSTALLATION.md`](docs/INSTALLATION.md) | Installation et démarrage sur le poste de travail (base MySQL distante) |
| [`docs/DEPLOIEMENT.md`](docs/DEPLOIEMENT.md) | Mise en ligne sur Alwaysdata + configuration Mailjet |
| [`docs/SOURCES_INFORMATION.md`](docs/SOURCES_INFORMATION.md) | Répertoire des sources documentaires : 176 plateformes vérifiées (institutions ivoiriennes, statistiques, patrimoine, archives, recherche, presse, droit, langues, images), avec statut, licence et règles de citation |
| [`docs/SECURITE.md`](docs/SECURITE.md) | Revue de sécurité : en-têtes HTTP servis, checklist du CONTEXT §13 vérifiée en production, points encore ouverts |
| [`docs/SUIVI_DEVELOPPEMENT.md`](docs/SUIVI_DEVELOPPEMENT.md) | Journal technique : fait / vérifié / reste, à alimenter à chaque séance |
| [`docs/`](docs/) | Documents source : cahier des charges et stacks techniques phases 1/2 (PDF) |
| [`LICENSE`](LICENSE) | Licence MIT du code |

## Règle de travail permanente

Le dépôt local et le dépôt GitHub restent **au même niveau d'information** : tout travail committé localement est poussé sur `origin/main` dans la même séance (détail dans [`AGENTS.md`](AGENTS.md) §3).

## Statut et prochaine étape

**Le site est en ligne** : `https://ivoirepedia.alwaysdata.net/` sert l'application Flutter à la racine du domaine et l'API `/api/v1` sur la même origine — l'ancienne adresse `/site/` y redirige en 301. Vérifié en production le 27 novembre 2026 (détail : séance 125 du journal).

- **Sprint 0 — fondations** : réalisé (Laravel 13.39.0, PHP 8.4.27, MySQL Alwaysdata, CI GitHub Actions à deux jobs, guides d'installation et de déploiement).
- **Sprint 1 — comptes lecteurs** : réalisé — inscription, connexion par jeton, mot de passe oublié, rôles READER / CONTRIBUTOR / ADMIN.
- **Panneau éditorial `/admin`** : cycle complet d'un article (rédaction, modification, transitions de relecture, catégories, étiquettes, utilisateurs, messages de contact).
- **Contenu publié** : 479 articles (403 biographies, 41 territoires, 30 sujets, 5 institutions).

Prochaine étape : **Sprint 2 — l'éditeur dans l'application** (routes d'écriture `/api/v1/articles` + éditeur Flutter), puis les contributions et discussions du Sprint 3 (CONTEXT §14).

Vérifications avant commit (AGENTS.md §3) : `cd backend && composer test && composer format:check && composer analyse`, puis `cd app && dart format --set-exit-if-changed lib test && flutter analyze && flutter test`.

## Ordre de lecture conseillé

- **Nouveau développeur** : CONTEXT §1 → §6 → §14 (30 min), puis premier ticket du backlog (§14).
- **IA assistant** : CONTEXT §0.1 (TL;DR) puis les sections 4 à 12 avant d'écrire du code.
