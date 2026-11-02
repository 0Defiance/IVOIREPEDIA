# Suivi de développement — IVOIREPEDIA

> Journal technique étape par étape : **ce qui est fait, vérifié, bloqué et restant.**
> Modèle repris du projet Soutrali. Chaque séance de travail ajoute une entrée datée.
> Règle : ce journal, le dépôt local et le dépôt distant restent **au même niveau d'information**.

**Version** : 1.0 · **Dernière mise à jour** : 2 novembre 2026

**État en une phrase** : le cadrage est consolidé et publié (CONTEXT + document de contextualisation + documents source), le dépôt GitHub et le local sont alignés, mais **aucune ligne de code n'existe encore** — la prochaine étape est le Sprint 0 (fondations).

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
- Les deux documents de cadrage décrivent des stacks différentes : le **CONTEXT** (MVP : Next.js + Prisma + PostgreSQL, monolithe) et le **document de contextualisation** (horizon plus large : NestJS + PostGIS + Meilisearch, monorepo, 🟡 hypothèses). Règle en vigueur : **`IVOIREPEDIA_CONTEXT.md` fait foi** en cas de contradiction (CONTEXT §2). Le document de contextualisation reste la référence pour la vision produit (langues, sources orales, géo, hors-ligne).

**Reste (ordre prioritaire)**
1. **Sprint 0 — Fondations** (CONTEXT §14) : initialiser Next.js + TS strict + Tailwind + ESLint/Prettier ; Docker Compose PostgreSQL + `.env.example` + `env.ts` ; schéma Prisma + 1ʳᵉ migration + `seed.ts` ; CI GitHub Actions ; déploiement « hello world ».
   - Critère de sortie : `pnpm dev` fonctionne chez un nouvel arrivant en suivant CONTEXT §7 ; la CI est verte.
2. Puis Sprint 1 — Authentification (EF-AUTH-01→05).
3. Questions ouvertes à traiter au fil de l'eau : licence du code (Q1), licence du contenu (Q2), nom de domaine / emails (Q3).

---

## Blocages

_Aucun pour l'instant._

---

## Travail restant détaillé

Voir le backlog ordonné dans `IVOIREPEDIA_CONTEXT.md` §14 (Sprint 0 à Sprint 5, puis V1).
