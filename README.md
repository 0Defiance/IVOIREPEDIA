# IVOIREPEDIA — Encyclopédie Inclusive Ivoirienne

> **Version** : 1.1 · **Dernière mise à jour** : 2 novembre 2026 · **Statut** : pré-MVP — cadrage consolidé et stack validée, aucune ligne de code · **Langue de travail** : français

**IVOIREPEDIA** est une encyclopédie numérique libre et open source consacrée exclusivement à la documentation, la structuration et la valorisation du savoir ivoirien : histoire, géographie, personnalités, institutions, langues, culture, économie, patrimoine.

> Ce dépôt est la source de contexte du projet. Une personne ou une IA qui n'a rien suivi doit pouvoir comprendre **ce qu'est IVOIREPEDIA, ce qui est décidé, ce qui n'est pas, et comment reprendre le travail** en lisant les fichiers ci-dessous.

## Stack technique (validée le 2 novembre 2026 — modèle Soutrali)

| Couche | Choix |
|---|---|
| Interface | **Flutter** (`app/`) — site web d'abord, Android ensuite, une seule base de code |
| Backend | **Laravel** (`backend/`) — API REST `/api/v1` + back-office Filament sur `/admin` |
| Base de données | **MySQL** via **XAMPP** / **phpMyAdmin** en local (développement 100 % local d'abord) |
| Authentification | **Laravel Sanctum** (session cookie web, jeton révocable Android) |
| Tests / CI | **Pest** + **flutter_test** ; GitHub Actions (2 jobs : backend, flutter) |

Même objectif multiplateforme que le projet [Soutrali](https://github.com/0Defiance/soutrali) : web d'abord, Android ensuite. Détails et ADR-001→008 dans le CONTEXT.

## Où est quoi

| Chemin | Contenu |
|---|---|
| [`IVOIREPEDIA_CONTEXT.md`](IVOIREPEDIA_CONTEXT.md) | **Source de vérité opérationnelle** — stack, ADR, modèle de données MySQL, workflow éditorial, RBAC, contrat d'API `/api/v1`, backlog. **Lire avant toute intervention.** En cas de contradiction entre documents, ce fichier fait foi. |
| [`docs/IVOIREPEDIA_Document_de_Contextualisation.md`](docs/IVOIREPEDIA_Document_de_Contextualisation.md) | Vision complète du produit (multilinguisme, sources orales, géolocalisation, hors-ligne…) — statuts ✅ / 🟡 / ❓. Sa stack d'origine est supplantée par le CONTEXT. |
| [`AGENTS.md`](AGENTS.md) | **Règle de travail** : définition de « fait », vérifications avant commit, parité permanente local / distant |
| [`docs/SUIVI_DEVELOPPEMENT.md`](docs/SUIVI_DEVELOPPEMENT.md) | Journal technique : fait / vérifié / reste, à alimenter à chaque séance |
| [`docs/`](docs/) | Documents source : cahier des charges et stacks techniques phases 1/2 (PDF) |
| [`LICENSE`](LICENSE) | Licence MIT du code |

## Règle de travail permanente

Le dépôt local et le dépôt GitHub restent **au même niveau d'information** : tout travail committé localement est poussé sur `origin/main` dans la même séance (détail dans [`AGENTS.md`](AGENTS.md) §3).

## Statut et prochaine étape

Aucune ligne de code à ce jour. Prochaine étape : **Sprint 0 — Fondations** (CONTEXT §14) : créer `backend/` (Laravel) et `app/` (Flutter), base `ivoirepedia` via phpMyAdmin, migrations + seeders, scripts Composer (Pest/Pint/Larastan) et `flutter analyze`/`flutter test`, CI GitHub Actions, `docs/INSTALLATION.md` avec les versions constatées, déploiement « hello world ».

## Ordre de lecture conseillé

- **Nouveau développeur** : CONTEXT §1 → §6 → §14 (30 min), puis premier ticket du backlog (§14).
- **IA assistant** : CONTEXT §0.1 (TL;DR) puis les sections 4 à 12 avant d'écrire du code.
