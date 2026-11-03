# AGENTS.md — règle de travail sur IVOIREPEDIA

Ce fichier fixe la **définition de « fait »** appliquée à chaque intervention dans ce dépôt. Aucune tâche n'est considérée terminée tant que les trois points ci-dessous ne sont pas satisfaits. Les commandes et chemins sont ceux d'IVOIREPEDIA (voir `IVOIREPEDIA_CONTEXT.md` §15.5).

## 1. Accessible

Une fonctionnalité n'existe que si l'on y arrive par le chemin normal de l'utilisateur, sans modifier le code pour l'atteindre :

- **Flutter (`app/`)** : route enregistrée dans `app/lib/src/app.dart` **et** point d'entrée visible (menu, bouton, lien) depuis un écran déjà accessible ; l'écran s'affiche sans flag de debug ni activation manuelle.
- **API (`backend/`)** : route déclarée dans `backend/routes/api.php` et appelable en HTTP (`/api/v1/...`) avec les mêmes paramètres que ceux que l'app envoie.
- **Back-office** : la ressource Filament est présente dans le menu `/admin` et ses actions s'exécutent réellement.

Vérification concrète : atteindre la fonctionnalité avec `flutter run -d web-server --web-port 8082` + `php artisan serve --port 8000` en suivant uniquement les chemins décrits dans `docs/INSTALLATION.md` (au Sprint 0 ; en attendant, CONTEXT §7), ou avec `curl` sur l'API.

## 2. Testable directement

Chaque nouveau comportement est couvert par un test **ajouté à la suite existante** — on n'ajoute jamais un second outil de test :

| Couche | Fichier | Commande |
|---|---|---|
| Logique métier, services, routes, policies (Workflow, RBAC, slug, FormRequest) | `backend/tests/…/…Test.php` | `cd backend && composer test` |
| Écrans et logique Flutter (éditeur, navigation, parcours) | `app/test/…_test.dart` | `cd app && flutter test` |

Le test reproduit l'usage réel : un appel HTTP authentifié sur la route avec assertions de statut **et** de contenu, ou un parcours de widgets qui navigue jusqu'à l'écran. Un test d'une méthode privée sans route ni écran ne suffit pas. Priorité absolue : **permissions, workflow, validation d'entrées** (CONTEXT §15.3).

## 3. Vérifier, documenter, committer

Mêmes commandes que la CI prévue (CONTEXT §15.4), à exécuter avant chaque commit :

```bash
cd backend && composer test && composer format:check && composer analyse
cd app && flutter analyze && flutter test
```

*Ces commandes deviennent exécutables au Sprint 0, quand `backend/` et `app/` sont initialisés. En attendant, un commit de documentation reste possible, mais reste soumis aux deux règles ci-dessous.*

**Documentation** : entrée dans `docs/SUIVI_DEVELOPPEMENT.md` (fait / vérifié / reste) et, si une décision change, mise à jour de `IVOIREPEDIA_CONTEXT.md` **dans la même PR** (règle de maintenance CONTEXT §19).

**Commit** : **Conventional Commits en anglais** (CONTEXT §15.2 : `feat(article): add autosave`, `docs(context): …`), une PR = un sujet, puis **pousser sur `origin/main`** — l'objectif permanent reste un dépôt local et distant **au même niveau d'information**.
