# IVOIREPEDIA — Encyclopédie Inclusive Ivoirienne

> **Version** : 1.0 · **Dernière mise à jour** : 2 novembre 2026 · **Statut** : pré-MVP — cadrage consolidé, aucune ligne de code · **Langue de travail** : français

**IVOIREPEDIA** est une encyclopédie web libre et open source consacrée exclusivement à la documentation, la structuration et la valorisation du savoir ivoirien : histoire, géographie, personnalités, institutions, langues, culture, économie, patrimoine.

> Ce dépôt est la source de contexte du projet. Une personne ou une IA qui n'a rien suivi doit pouvoir comprendre **ce qu'est IVOIREPEDIA, ce qui est décidé, ce qui ne l'est pas, et comment reprendre le travail** en lisant les fichiers ci-dessous.

## Où est quoi

| Chemin | Contenu |
|---|---|
| [`IVOIREPEDIA_CONTEXT.md`](IVOIREPEDIA_CONTEXT.md) | **Source de vérité opérationnelle** — stack MVP, modèle de données, workflow éditorial, RBAC, contrat d'API, backlog. **Lire avant toute intervention.** En cas de contradiction entre documents, ce fichier fait foi. |
| [`docs/IVOIREPEDIA_Document_de_Contextualisation.md`](docs/IVOIREPEDIA_Document_de_Contextualisation.md) | Vision complète du produit (multilinguisme, sources orales, géolocalisation, hors-ligne…) — statuts ✅ / 🟡 / ❓ |
| [`AGENTS.md`](AGENTS.md) | **Règle de travail** : définition de « fait », vérifications avant commit, parité permanente local / distant |
| [`docs/SUIVI_DEVELOPPEMENT.md`](docs/SUIVI_DEVELOPPEMENT.md) | Journal technique : fait / vérifié / reste, à alimenter à chaque séance |
| [`docs/`](docs/) | Documents source : cahier des charges et stacks techniques (PDF) |
| [`LICENSE`](LICENSE) | Licence MIT du code |

## Règle de travail permanente

Le dépôt local et le dépôt GitHub restent **au même niveau d'information** : tout travail committé localement est poussé sur `origin/main` dans la même séance (détail dans [`AGENTS.md`](AGENTS.md) §3).

## Statut et prochaine étape

Aucune ligne de code à ce jour. Prochaine étape : **Sprint 0 — Fondations** (CONTEXT §14) : Next.js + TypeScript strict + Tailwind, PostgreSQL via Docker Compose, schéma Prisma + migration + seed, CI GitHub Actions, déploiement « hello world ».

## Ordre de lecture conseillé

- **Nouveau développeur** : CONTEXT §1 → §6 → §14 (30 min), puis premier ticket du backlog (§14).
- **IA assistant** : CONTEXT §0.1 (TL;DR) puis les sections 4 à 12 avant d'écrire du code.
