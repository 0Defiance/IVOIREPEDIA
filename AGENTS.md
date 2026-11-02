# AGENTS.md — règle de travail sur IVOIREPEDIA

Ce fichier fixe la **définition de « fait »** appliquée à chaque intervention dans ce dépôt. Aucune tâche n'est considérée terminée tant que les trois points ci-dessous ne sont pas satisfaits. La structure reprend le modèle du projet Soutrali ; les commandes et chemins sont ceux d'IVOIREPEDIA (voir `IVOIREPEDIA_CONTEXT.md` §15.5).

## 1. Accessible

Une fonctionnalité n'existe que si l'on y arrive par le chemin normal de l'utilisateur, sans modifier le code pour l'atteindre :

- **Pages (App Router)** : route dans `src/app/**` **et** point d'entrée visible (lien, bouton, menu) depuis un écran déjà accessible ; la page s'affiche sans flag de debug ni activation manuelle.
- **API** : Route Handler dans `src/app/api/**/route.ts`, appelable en HTTP avec les mêmes paramètres que ceux que l'interface envoie.
- **Espaces protégés (contributeur, éditorial, admin)** : la page existe sous son segment et ses actions s'exécutent réellement, avec les permissions vérifiées côté serveur.

Vérification concrète : atteindre la fonctionnalité avec `pnpm dev` en suivant uniquement les chemins décrits dans CONTEXT §7, ou avec `curl` sur l'API.

## 2. Testable directement

Chaque nouveau comportement est couvert par un test **ajouté à la suite existante** — on n'ajoute jamais un second outil de test. L'outil est **Vitest** (CONTEXT §5, §15.3).

| Couche | Fichier | Commande |
|---|---|---|
| Logique pure (workflow, rbac, slug, sanitize, validateurs Zod) | `tests/unit/…` | `pnpm test` |
| Services (transitions complètes, permissions, intégration BDD) | `tests/integration/…` | `pnpm test` |

Le test reproduit l'usage réel : un appel au service ou à la route avec assertions de statut **et** de contenu. Un test d'une fonction privée sans chemin d'appel réel ne suffit pas. Priorité absolue : **permissions, workflow, sanitisation** (CONTEXT §15.3).

## 3. Vérifier, documenter, committer

Mêmes commandes que la CI prévue (CONTEXT §15.4), à exécuter avant chaque commit :

```bash
pnpm lint && pnpm typecheck && pnpm test && pnpm build
```

*Ces commandes deviennent exécutables au Sprint 0, quand le socle est initialisé. En attendant, un commit de documentation reste possible, mais reste soumis aux deux règles ci-dessous.*

**Documentation** : entrée dans `docs/SUIVI_DEVELOPPEMENT.md` (fait / vérifié / reste) et, si une décision change, mise à jour de `IVOIREPEDIA_CONTEXT.md` **dans la même PR** (règle de maintenance CONTEXT §19).

**Commit** : **Conventional Commits en anglais** (CONTEXT §15.2 : `feat(article): add autosave`, `docs(context): …`), une PR = un sujet, puis **pousser sur `origin/main`** — l'objectif permanent reste un dépôt local et distant **au même niveau d'information**.
