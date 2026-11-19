# Tableau de bord d'administration — note de cadrage

> **Statut** : phases 0 et 1 livrées ; phase 2 entamée (formulaire complet,
> sources, infobox, étiquettes, versions, journal). Restent l'éditeur visuel,
> le dépôt des médias, la 2FA et l'édition des contenus sourcés.
> **But** : définir ce que l'administration doit permettre, où elle vit, et dans
> quel ordre la construire — sans casser le contrat de l'API publique.
> **Références** : `IVOIREPEDIA_CONTEXT.md` §9 (workflow), §10 (RBAC),
> §8.2 (modèle de données), §11 (contrat d'API).

---

## 1. Le problème à résoudre

Aujourd'hui, le contenu est écrit par des scripts de *seed* : les articles, la
frise, les fiches géographiques et les statistiques arrivent en base par
migration/peuplement, et le site ne fait que lire. Dès qu'une personne doit
publier un article de plus, corriger une coquille ou retirer une source
contestée, il faut un accès au serveur. Ce n'est pas tenable, et cela rend les
règles du workflow éditorial (§9) purement théoriques.

Le tableau de bord doit répondre à trois besoins, dans cet ordre :

1. **Écrire et publier** un article avec ses sources, ses médias, sa catégorie
   et ses tags, en respectant le cycle DRAFT → SUBMITTED → IN_REVIEW →
   APPROVED → PUBLISHED.
2. **Administrer** les comptes (rôles, suspensions) et les référentiels
   (catégories, tags) — sans passer par la base.
3. **Voir** où en est le contenu : file d'attente de relecture, articles sans
   source, articles publiés sans image, liens morts.

---

## 2. Où vit l'administration

**Décision proposée : un panneau serveur rendu par Laravel, sur `/admin`,
séparé de l'application Flutter.**

| Option | Avantage | Inconvénient |
|---|---|---|
| **A. Filament sur `/admin`** (recommandée) | Ressources, formulaires, tableaux, filtres, rôles et journal d'activité fournis ; ~1 mois gagné sur l'éditeur et les listes | Dépendance supplémentaire ; il faut un éditeur riche pour le JSON Quill (champ JSON + aperçu) |
| B. Panneau Blade + Livewire maison | Aucune dépendance, contrôle total du rendu | Tout est à écrire : tables, filtres, permissions, téléversements, accessibilité |
| C. Écrans d'administration dans l'app Flutter | Une seule base de code | L'app est une SPA publique servie en statique ; il faudrait un second build, un routage protégé et un éditeur riche en Flutter — le plus coûteux |

Raisons de retenir A :

- le back-office est un outil de bureau, pas un écran public : il n'a rien à
  faire dans le bundle Flutter de 2,9 Mo servi aux lecteurs ;
- Laravel est déjà là, avec les modèles, les enums et les futures policies ;
- le HTML rendu côté serveur est plus simple à protéger (session, CSRF, 2FA)
  qu'une SPA à jetons porteurs ;
- `/admin` reste hors du périmètre de l'API `/api/v1` : aucun risque de fuite
  d'un brouillon vers le contrat public.

Point de vigilance : **Flutter sert `backend/public/index.php`** comme point
d'entrée du site. Les routes `/admin` de Laravel passent avant le repli SPA
(`routes/web.php` est chargé en premier), mais il faut vérifier que
`.htaccess` et le repli `index.html` ne capturent pas `/admin/*`. À contrôler
dès la première installation.

---

## 3. Rôles et permissions

Rôles du CONTEXT §10, stockés dans `users.role` (chaîne). À figer dans un enum
PHP `App\Enums\UserRole` avant d'écrire les policies — aujourd'hui la colonne
est une chaîne libre et `AuthController` écrit `'READER'` en dur.

| Capacité | READER | CONTRIBUTOR | EDITOR | ADMIN |
|---|:--:|:--:|:--:|:--:|
| Lire le site public | ✅ | ✅ | ✅ | ✅ |
| Proposer un article (brouillon + soumission) | — | ✅ | ✅ | ✅ |
| Modifier **ses** brouillons | — | ✅ | ✅ | ✅ |
| Modifier tout article | — | — | ✅ | ✅ |
| Prendre en relecture / demander une révision | — | — | ✅ | ✅ |
| Approuver | — | — | ✅ | ✅ |
| Publier / dépublier / archiver | — | — | ✅ | ✅ |
| Supprimer (suppression douce) | — | — | — | ✅ |
| Gérer catégories, tags, médias | — | — | ✅ | ✅ |
| Gérer les comptes et les rôles | — | — | — | ✅ |
| Consulter le journal éditorial | — | ses articles | tous | tous |

Trois règles à ne pas perdre de vue :

- **Un contributeur ne publie jamais.** Le passage à PUBLISHED est réservé à
  EDITOR/ADMIN ; c'est tout l'intérêt du statut APPROVED.
- **On ne modifie pas un article publié en place.** Toute correction crée une
  nouvelle version (`article_versions`, append-only) et un nouveau numéro ;
  la publication reste datée.
- **La suspension se fait par `users.suspended_at`**, déjà honorée par
  `AuthenticateApiToken` (403 `ACCOUNT_SUSPENDED`) : le panneau doit écrire ce
  champ, pas un booléen parallèle.

---

## 4. Les écrans

### 4.1 Articles (écran central)

Liste : titre, catégorie, statut, auteur, dernière action, date de publication.
Filtres : statut, catégorie, auteur, langue, « sans source », « sans image ».
Recherche sur le titre. Tri par date de dernière action.

Formulaire, en onglets pour ne pas noyer l'auteur :

1. **Essentiel** — titre, slug (généré depuis le titre, modifiable), résumé
   (≤ 500 caractères, compteur), catégorie, type (`ARTICLE`, `PORTRAIT`,
   `LIEU`, `RECIT`…).
2. **Corps** — `content` en JSON Delta Quill. Deux niveaux : un champ JSON brut
   avec validation de structure, puis (phase 3) un éditeur visuel. L'aperçu
   rend le Delta avec le même code de rendu que le site, pour que l'auteur voie
   ce que le lecteur verra.
3. **Infobox** — paires libellé/valeur validées par `FormRequest` (§8.3) :
   pas de clé inconnue, pas de valeur vide.
4. **Sources** — au moins une `article_references` avant de pouvoir soumettre :
   titre, institution, URL, date de consultation, positionnement. C'est la
   règle qui distingue l'encyclopédie d'un blog.
5. **Image de couverture** — `cover_image_url`, `alt` **obligatoire**,
   crédit, licence, URL de la source. Alt vide = soumission refusée
   (ENF-UX-04).
6. **Médias** — dépôt d'images/audio dans `media`, avec la même exigence d'alt.

### 4.2 Versions

Onglet en lecture seule sur la fiche article : numéro, auteur, date, motif,
empreinte SHA-256 tronquée, comparaison « version N ↔ version courante » sur
titre/résumé (le diff du Delta est un bonus, pas un prérequis).

### 4.3 Journal éditorial

`editorial_actions` en lecture seule, filtrable par article, acteur et type.
Aucun bouton de modification : la table est append-only par conception.

### 4.4 Catégories et tags

CRUD simple (nom, slug, description, couleur/icône pour les catégories).
Garde-fou : renommer un slug casse les URL publiques — prévenir et proposer
une redirection, ou interdire le changement de slug d'une catégorie utilisée.

### 4.5 Utilisateurs

Liste, recherche par courriel, changement de rôle, suspension/réactivation,
réinitialisation de mot de passe. Interdictions : se retirer soi-même le rôle
ADMIN, suspendre le dernier ADMIN. Révocation des jetons d'un compte
(`api_tokens`) à la suspension — sinon un jeton en cours reste valide jusqu'à
60 jours.

### 4.6 Contenus sourcés (frise, géographie, statistiques)

Ces tables (`history_stories`, `census_divisions`, `climate_*`,
`country_indicator*`) alimentent les pages « Histoire » et « Statistiques ».
Elles sont aujourd'hui peuplées par script. Prévoir une **consultation** en
phase 2 et une **édition** en phase 4 : ce sont des données chiffrées, une
faute de frappe y est plus grave qu'ailleurs. Chaque modification doit porter
sa source.

---

## 5. Tableau de bord d'accueil du panneau

Quatre blocs, pas plus :

- **File de relecture** — articles SUBMITTED et IN_REVIEW, du plus ancien au
  plus récent, avec l'âge en jours (au-delà de 7 jours, signalé).
- **Mes brouillons** — pour le contributeur connecté.
- **Qualité** — nombre d'articles publiés sans source, sans image, sans alt,
  résumé manquant, titre trop long, slug en double.
- **Activité** — les dix dernières actions éditoriales.

---

## 6. Authentification du panneau

- Session Laravel classique (cookies + CSRF), **indépendante** des jetons
  porteurs de l'API Flutter : deux mécanismes, deux usages, aucun partage de
  secret.
- `users.password_hash` porte déjà le nom de colonne imposé par §8.2 : le
  provider d'authentification doit être configuré en conséquence, sinon la
  connexion échoue silencieusement.
- Rôles READER sans droit éditorial : redirection vers une page « accès
  refusé », pas vers le site (sinon on croit à un bug).
- 2FA (TOTP) pour ADMIN et EDITOR dès la phase 2 : le panneau peut publier et
  supprimer.
- Limitation de tentatives sur la connexion, comme sur `/auth/login`.

---

## 7. Traçabilité

Chaque action passe par un service unique — `App\Services\Workflow` (§9) — qui
écrit la transition **et** la ligne `editorial_actions` dans la même
transaction. Aucune ressource du panneau ne doit écrire `articles.status`
directement. C'est la seule façon de garantir que le journal reste complet.

À journaliser aussi (table séparée ou colonne `context` JSON) : changement de
rôle, suspension, suppression d'un média, modification d'une donnée chiffrée.

---

## 8. Découpage proposé

| Phase | Contenu | Effort | Critère de sortie |
|---|---|---|---|
| **0** | Enum `UserRole`, policies, service `Workflow`, tests Pest des transitions | 2–3 j | Les 8 statuts et leurs transitions sont testés ; aucune ressource ne contourne le service |
| **1** | Installation du panneau, connexion, rôles, CRUD catégories/tags, liste d'articles en lecture | 3–4 j | `/admin` répond, un EDITOR se connecte, un READER est refusé |
| **2** | Formulaire article complet (essentiel, sources, couverture, médias), soumission, relecture, publication, versions | 6–8 j | Un article rédigé dans le panneau apparaît sur le site public après publication, avec ses sources et son crédit image |
| **3** | Éditeur visuel du Delta + aperçu fidèle, file de relecture, tableau de bord qualité | 5–6 j | Un article rédigé sans toucher au JSON brut se rend correctement |
| **4** | Utilisateurs avancés (2FA, révocation de jetons), édition des contenus sourcés, export | 4–5 j | Un ADMIN gère un compte de bout en bout sans accès serveur |

Total indicatif : **20 à 26 jours** de travail concentré, hors contenu.

Ordre recommandé : la phase 0 d'abord, même si elle ne se voit pas. Sans elle,
le panneau écrira les statuts à la main et le journal éditorial sera troué dès
la première semaine.

---

## 9. Ce que le panneau ne fait pas (MVP)

- Pas d'inscription publique depuis `/admin` : les comptes éditoriaux sont créés
  par un ADMIN. L'inscription publique reste celle de l'app (rôle READER).
- Pas de modération des commentaires : il n'y a pas de commentaires.
- Pas de gestion de thème, de traduction ou de SEO depuis le panneau.
- Pas de statistiques de fréquentation : ce n'est pas dans le périmètre actuel.

---

## 10. Questions ouvertes

1. **Filament ou maison ?** La branche Filament compatible avec Laravel 13 doit
   être vérifiée à l'installation (matrice de compatibilité du paquet) ; si elle
   n'existe pas, l'option B revient sur la table et l'effort de la phase 2
   double.
2. **Éditeur riche** : Q8 du CONTEXT reste ouverte. Le format de stockage est
   fixé (Delta Quill) ; l'éditeur du panneau est un choix d'implémentation.
3. **Hébergement** : le panneau tourne sur le même compte Alwaysdata que l'API.
   Vérifier la mémoire PHP disponible pour le téléversement d'images et la
   taille maximale de requête avant la phase 2.
4. **Sauvegardes** : avant d'ouvrir la publication à des tiers, il faut une
   sauvegarde de la base et des médias — un éditeur peut supprimer un article
   par erreur.
