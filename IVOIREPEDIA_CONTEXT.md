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
| Stack MVP | Next.js (App Router) + TypeScript + Prisma + PostgreSQL + Auth.js + Tailwind + TipTap. **Rien d'autre sans ADR.** |
| Architecture | **Monolithe modulaire** (un seul dépôt, un seul déploiement). Pas de microservices. |
| Périmètre | **MVP uniquement** (section 3). Ne jamais implémenter une fonctionnalité V1/V2 sans demande explicite. |
| Langue | Code, commits, noms de variables et tables : **anglais**. Interface utilisateur et docs : **français**. |
| Pédagogie | Le dev est en apprentissage : **explique chaque terme technique en une phrase**, propose de petits changements (diffs courts), justifie tes choix. |
| Sécurité | Valider toute entrée avec Zod, vérifier les permissions côté serveur, ne jamais faire confiance au client (section 11). |
| Logique métier | Dans `src/server/services/*`, **jamais** dans les handlers d'API ni dans les composants React. |
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
| Cahier des charges | Acteurs, exigences fonctionnelles (codes `EF-*`) et non fonctionnelles (`ENF-*`) | `IVOIREPEDIA_Cahier_des_Charges.docx` |
| Conception UML | Cas d'utilisation, séquences, classes | `IVOIREPEDIA_Conception_UML.docx` |
| Roadmap technique | Vision CTO 12 mois et 5 ans | `IVOIREPEDIA_Roadmap_Technique.docx` |

### 2.1 Divergences connues entre les documents (⚠️ à lire)

Les documents ont été rédigés successivement. **En cas de contradiction, ce fichier fait foi.**

| # | Sujet | Ce que disent les anciens docs | **Décision en vigueur** |
|---|---|---|---|
| D1 | Stack | Roadmap : NestJS + MongoDB + Elasticsearch + Kubernetes | **MVP : Next.js + Prisma + PostgreSQL seul.** La stack de la roadmap est un horizon V2+ (ADR-001, ADR-003). |
| D2 | Contenu des articles | Roadmap : stocké dans MongoDB | **Colonne `Json` (jsonb) dans PostgreSQL** (ADR-003). |
| D3 | Noms des statuts | UML : français (`BROUILLON`, `SOUMIS`…) | **Enums anglais** (`DRAFT`, `SUBMITTED`…), libellés français via un fichier de traduction UI (ADR-006). |
| D4 | Statut après demande de révision | UML séquence 2.4 : `IN_REVISION` | **`REVISION_REQUESTED`** (section 8). |
| D5 | Versions | UML : une version à chaque sauvegarde | **Une version = un jalon** (soumission, édition d'un article publié, publication, rollback). L'auto-save ne crée pas de version (ADR-005). |
| D6 | Recherche | UML : `LIKE '%terme%'` | MVP : `contains` insensible à la casse ; **V1 : full-text PostgreSQL** (`tsvector` + `unaccent`). |
| D7 | Rôles admin | CDC : Admin Contenu + Admin Technique | **Un seul rôle applicatif `ADMIN`.** « Admin technique » = accès infrastructure (Vercel, BDD), pas un rôle en base. |
| D8 | Rôle à l'inscription | CDC : « Lecteur inscrit » | Inscription → `READER`. Promotion en `CONTRIBUTOR` par un `ADMIN`. |

---

## 3. Périmètre

### 3.1 MVP (à construire maintenant)
Inscription / connexion / vérification email / reset mot de passe · Création et édition d'articles (brouillon, auto-save) · Éditeur riche · Catégories, tags · Image de couverture · Références bibliographiques · Soumission → révision → approbation → publication · Historique des versions · Recherche simple · Pages publiques (accueil, article, catégorie, résultats) · Admin minimal (utilisateurs, catégories, file de validation) · SEO de base.

### 3.2 Hors MVP (ne pas implémenter sans demande)
Elasticsearch · Application mobile · API publique · Multilingue (langues locales) · IA de modération · Cartes interactives · Commentaires · 2FA · OAuth Google/Facebook · Export chercheurs · Temps réel (WebSocket) · Kubernetes · Microservices · Redis (hors rate-limiting).

> Règle : si une demande touche à la section 3.2, **demander confirmation** avant d'écrire du code.

---

## 4. Décisions d'architecture (ADR)

Chaque décision est numérotée. Pour en changer : ouvrir une PR qui ajoute un nouvel ADR dans `docs/adr/` et met à jour ce fichier.

### ADR-001 — Monolithe modulaire (Next.js full-stack)
- **Décision** : une seule application Next.js (App Router) pour l'interface et le backend (Route Handlers).
- **Pourquoi** : un seul déploiement, un seul langage (TypeScript), débogage simple, coût zéro pour démarrer.
- **Risque** : couplage si le code est mal organisé → **respecter la séparation en couches (section 6.2)**.
- **Sortie** : si un module devient un goulot (recherche, médias), il pourra être extrait en service indépendant.

### ADR-002 — PostgreSQL + Prisma
- **Décision** : PostgreSQL comme unique base de données, Prisma comme ORM.
- **Pourquoi** : relations fortes (utilisateurs ↔ articles ↔ versions), transactions ACID (indispensables au workflow), `jsonb` pour le contenu flexible, full-text natif pour la V1.
- **ORM ?** Un ORM (*Object-Relational Mapper*) traduit le code TypeScript en requêtes SQL et génère des types sûrs.

### ADR-003 — Pas de MongoDB ni d'Elasticsearch au MVP
- **Décision** : le contenu riche est stocké en `Json` dans PostgreSQL.
- **Pourquoi** : une seule base à sauvegarder, administrer et apprendre. Elasticsearch sera réévalué quand la recherche PostgreSQL deviendra insuffisante (seuil indicatif : plusieurs milliers d'articles ou besoin de tolérance aux fautes avancée).

### ADR-004 — Auth.js (ex-NextAuth) avec sessions JWT en cookie HttpOnly
- **Décision** : authentification par email + mot de passe (provider *Credentials*), sessions JWT.
- **Pourquoi** : brique éprouvée, évite d'écrire de la cryptographie maison.
- **⚠️ À vérifier avant implémentation** : la version et l'API d'Auth.js évoluent ; **lire la documentation officielle courante** avant de coder. Le provider Credentials impose la stratégie de session JWT.
- **Sécurité** : mots de passe hachés avec bcrypt (≥ 12 rounds) ou argon2.

### ADR-005 — Versionnage par jalons
- **Décision** : le champ `Article.content` contient toujours le contenu courant. Une ligne `ArticleVersion` (snapshot immuable) est créée à : soumission, chaque sauvegarde d'un article **publié**, publication, rollback.
- **Pourquoi** : l'auto-save toutes les 60 s créerait des centaines de versions inutiles.
- **Intégrité** : `contentHash` (SHA-256) pour détecter les doublons.

### ADR-006 — Convention de langue
- **Code, schéma BDD, API, commits, branches** : anglais.
- **Interface, messages d'erreur utilisateur, documentation** : français.
- Les enums sont en anglais ; les libellés français sont dans `src/lib/i18n/fr.ts`.

### ADR-007 — Mutations via Route Handlers + couche service
- **Décision** : toute écriture passe par `src/app/api/**/route.ts` qui appelle `src/server/services/*`. Les Server Components lisent via les services.
- **Pourquoi** : API testable, prête pour une future API publique, logique métier isolée.

### ADR-008 — Hébergement MVP
- Vercel (app) + PostgreSQL managé (Neon ou Supabase) + Cloudinary (images, CDN). Offres gratuites au départ.
- **À vérifier** : conditions et quotas des offres gratuites évoluent ; contrôler les tarifs actuels avant le lancement public.
- **Souveraineté** : hébergement hors Côte d'Ivoire au départ (latence ≈ 150 ms acceptable). Rapatriement des données étudié à moyen terme (voir roadmap).

---

## 5. Stack technique

| Couche | Choix | Rôle |
|---|---|---|
| Langage | TypeScript (mode `strict`) | JavaScript typé : détecte les erreurs avant l'exécution |
| Framework | Next.js, App Router | Pages, routage, rendu serveur, API |
| UI | React + Tailwind CSS | Composants + styles utilitaires |
| Éditeur riche | TipTap (JSON ProseMirror) | Édition de texte structurée |
| ORM / BDD | Prisma + PostgreSQL | Accès et stockage des données |
| Auth | Auth.js (Credentials) | Connexion, sessions |
| Validation | Zod | Schémas de validation des entrées (API et formulaires) |
| Sanitisation | `sanitize-html` | Nettoyage du HTML rendu (anti-XSS) |
| Emails | Resend (ou SMTP) | Vérification email, reset, notifications |
| Médias | Cloudinary (upload signé) | Stockage et optimisation d'images |
| Rate-limiting | Upstash Ratelimit (free tier) | Anti-brute-force sur login/inscription |
| Tests | Vitest (unitaires/intégration), Playwright (e2e, V1) | Qualité |
| Qualité | ESLint + Prettier + `tsc --noEmit` | Style et typage |
| CI | GitHub Actions | Lint, types, tests, build à chaque PR |
| Gestionnaire de paquets | pnpm (npm accepté) | Dépendances |

**Versions** : utiliser la version stable courante de Node.js (LTS) et des dépendances à l'initialisation, puis **figer via le lockfile** (`pnpm-lock.yaml`). Ne pas copier de numéros de version depuis ce document.

> **Règle d'ajout de dépendance** : toute nouvelle librairie doit être justifiée dans la PR (besoin, alternatives, taille, maintenance). Préférer la plateforme standard (Web APIs, Node) quand c'est suffisant.

---

## 6. Organisation du code

### 6.1 Arborescence cible

```
ivoirepedia/
├─ prisma/
│  ├─ schema.prisma
│  ├─ migrations/
│  └─ seed.ts                 # catégories de base + compte admin de dev
├─ src/
│  ├─ app/
│  │  ├─ (public)/            # accueil, article/[slug], categorie/[slug], recherche
│  │  ├─ (auth)/              # connexion, inscription, mot-de-passe-oublie
│  │  ├─ (contributeur)/      # mes-articles, articles/[id]/editer
│  │  ├─ (editorial)/         # revision (file d'attente), revision/[id]
│  │  ├─ admin/               # utilisateurs, categories
│  │  └─ api/                 # Route Handlers (fines : parse → service → réponse)
│  ├─ server/
│  │  ├─ services/            # LOGIQUE MÉTIER (article.service.ts, workflow.service.ts…)
│  │  ├─ policies/            # permissions (rbac.ts, article.policy.ts)
│  │  └─ mail/                # templates et envoi d'emails
│  ├─ lib/                    # utilitaires purs : db.ts, env.ts, slug.ts, sanitize.ts, workflow.ts, i18n/fr.ts
│  ├─ validators/             # schémas Zod partagés front/back
│  └─ components/             # composants React (ui/, article/, editor/, admin/)
├─ tests/                     # unit/ et integration/
├─ docs/                      # adr/, diagrammes, documents Word
├─ .github/workflows/ci.yml
├─ docker-compose.yml         # PostgreSQL local
├─ .env.example
└─ IVOIREPEDIA_CONTEXT.md
```

### 6.2 Architecture en couches (règle d'or)

```
Navigateur ──► Route Handler (api/) ──► Service (server/services) ──► Prisma ──► PostgreSQL
                 │ valide (Zod)           │ règles métier + permissions
                 │ authentifie            │ transactions
                 └ formate la réponse     └ audit (EditorialAction)
```

| Couche | Autorisé | Interdit |
|---|---|---|
| Route Handler | Lire la requête, valider avec Zod, récupérer la session, appeler un service, renvoyer JSON | Requêtes Prisma directes, règles métier |
| Service | Règles métier, vérification des permissions, transactions Prisma, envoi d'emails | Dépendre de `Request`/`Response` |
| `lib/` | Fonctions pures et testables | Effets de bord, accès BDD (sauf `db.ts`) |
| Composants React | Affichage, état d'UI | Logique métier, accès BDD |

---

## 7. Installation locale (onboarding 30 minutes)

### 7.1 Prérequis
Node.js (LTS), pnpm, Docker (pour PostgreSQL local), Git.

### 7.2 Démarrage

```bash
git clone <url-du-depot> ivoirepedia && cd ivoirepedia
cp .env.example .env            # puis compléter les valeurs
docker compose up -d            # démarre PostgreSQL local
pnpm install
pnpm prisma migrate dev         # crée les tables
pnpm prisma db seed             # catégories + admin de dev
pnpm dev                        # http://localhost:3000
```

### 7.3 Commandes utiles

| Commande | Effet |
|---|---|
| `pnpm dev` | Serveur de développement |
| `pnpm lint` / `pnpm typecheck` | ESLint / vérification TypeScript |
| `pnpm test` | Tests Vitest |
| `pnpm prisma studio` | Interface graphique de la BDD |
| `pnpm prisma migrate dev --name <nom>` | Nouvelle migration après changement du schéma |
| `pnpm build` | Build de production |

### 7.4 Variables d'environnement (`.env.example`)

```bash
# Base de données
DATABASE_URL="postgresql://ivoirepedia:ivoirepedia@localhost:5432/ivoirepedia"
DIRECT_URL="postgresql://ivoirepedia:ivoirepedia@localhost:5432/ivoirepedia"  # migrations (Neon)

# Auth
AUTH_SECRET=""                # générer : openssl rand -base64 32
AUTH_URL="http://localhost:3000"

# Application
APP_URL="http://localhost:3000"
ALLOW_SELF_REVIEW="true"      # true en phase solo : un ADMIN peut valider ses propres articles

# Emails
RESEND_API_KEY=""
EMAIL_FROM="IVOIREPEDIA <no-reply@exemple.ci>"

# Médias
CLOUDINARY_CLOUD_NAME=""
CLOUDINARY_API_KEY=""
CLOUDINARY_API_SECRET=""

# Rate limiting
UPSTASH_REDIS_REST_URL=""
UPSTASH_REDIS_REST_TOKEN=""
```

> **Règle** : aucun secret dans le dépôt. `.env` est dans `.gitignore`. Les variables sont lues via `src/lib/env.ts` (validation Zod au démarrage : l'app refuse de démarrer si une variable manque).

`docker-compose.yml` minimal :

```yaml
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_USER: ivoirepedia
      POSTGRES_PASSWORD: ivoirepedia
      POSTGRES_DB: ivoirepedia
    ports: ["5432:5432"]
    volumes: [pgdata:/var/lib/postgresql/data]
volumes:
  pgdata:
```

---

## 8. Modèle de données

### 8.1 Correspondance des noms (documents UML → code)

| UML (français) | Code (anglais) |
|---|---|
| Utilisateur | `User` |
| Article | `Article` |
| VersionArticle | `ArticleVersion` |
| ActionEditoriale | `EditorialAction` |
| Catégorie | `Category` |
| Tag | `Tag` |
| Référence | `Reference` |
| Média | `Media` |

### 8.2 Schéma Prisma de référence (`prisma/schema.prisma`)

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider  = "postgresql"
  url       = env("DATABASE_URL")
  directUrl = env("DIRECT_URL")
}

// ───────────── Enums ─────────────
enum Role {
  READER
  CONTRIBUTOR
  EDITOR
  ADMIN
}

enum ArticleType {
  BIOGRAPHY
  REGION
  INSTITUTION
  EVENT
  CONCEPT
  CULTURE
  GASTRONOMY
  OTHER
}

enum ArticleStatus {
  DRAFT
  SUBMITTED
  IN_REVIEW
  REVISION_REQUESTED
  APPROVED
  PUBLISHED
  ARCHIVED
  DELETED
}

enum EditorialActionType {
  SUBMITTED
  REVIEW_STARTED
  REVISION_REQUESTED
  APPROVED
  PUBLISHED
  ARCHIVED
  RESTORED
  EDITED_PUBLISHED
  ROLLED_BACK
  DELETED
}

enum MediaType {
  IMAGE
  AUDIO
}

enum TokenType {
  EMAIL_VERIFY
  PASSWORD_RESET
}

enum ReferenceKind {
  BOOK
  ARTICLE
  WEB
  OTHER
}

// ───────────── Utilisateurs ─────────────
model User {
  id            String    @id @default(uuid())
  name          String    @db.VarChar(100)
  email         String    @unique
  passwordHash  String
  role          Role      @default(READER)
  emailVerified DateTime?
  bio           String?   @db.VarChar(500)
  avatarUrl     String?
  suspendedAt   DateTime?
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt

  articles Article[]
  versions ArticleVersion[]
  actions  EditorialAction[]
  tokens   VerificationToken[]
}

model VerificationToken {
  id        String    @id @default(uuid())
  userId    String
  user      User      @relation(fields: [userId], references: [id], onDelete: Cascade)
  type      TokenType
  tokenHash String    @unique // on stocke le HASH du token, jamais le token brut
  expiresAt DateTime
  usedAt    DateTime?
  createdAt DateTime  @default(now())

  @@index([userId, type])
}

// ───────────── Contenu ─────────────
model Article {
  id            String        @id @default(uuid())
  title         String        @db.VarChar(255)
  slug          String        @unique
  summary       String        @db.VarChar(500)
  content       Json                          // JSON TipTap (source de vérité)
  contentHtml   String?       @db.Text        // HTML sanitisé (cache de rendu)
  type          ArticleType
  status        ArticleStatus @default(DRAFT)
  infobox       Json?                         // données structurées selon `type` (cf. 8.3)
  coverImageUrl String?
  coverImageAlt String?
  lockVersion   Int           @default(0)     // verrou optimiste (cf. 9.4)
  currentVersion Int          @default(0)     // dernier numéro d'ArticleVersion

  authorId   String
  author     User     @relation(fields: [authorId], references: [id])
  categoryId String
  category   Category @relation(fields: [categoryId], references: [id])

  tags       Tag[]
  references Reference[]
  media      Media[]
  versions   ArticleVersion[]
  actions    EditorialAction[]

  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
  publishedAt DateTime?
  deletedAt   DateTime?

  @@index([status, publishedAt])
  @@index([categoryId])
  @@index([authorId])
}

model ArticleVersion {
  id          String   @id @default(uuid())
  articleId   String
  article     Article  @relation(fields: [articleId], references: [id], onDelete: Cascade)
  number      Int
  title       String   @db.VarChar(255)
  summary     String   @db.VarChar(500)
  content     Json
  contentHash String   // SHA-256 du JSON canonique
  authorId    String
  author      User     @relation(fields: [authorId], references: [id])
  reason      String?  @db.VarChar(255)
  createdAt   DateTime @default(now())

  @@unique([articleId, number])
}

model Category {
  id          String     @id @default(uuid())
  name        String     @unique
  slug        String     @unique
  description String?
  order       Int        @default(0)
  parentId    String?
  parent      Category?  @relation("CategoryTree", fields: [parentId], references: [id])
  children    Category[] @relation("CategoryTree")
  articles    Article[]
}

model Tag {
  id       String    @id @default(uuid())
  name     String    @unique
  slug     String    @unique
  articles Article[]
}

model Reference {
  id         String        @id @default(uuid())
  articleId  String
  article    Article       @relation(fields: [articleId], references: [id], onDelete: Cascade)
  order      Int
  kind       ReferenceKind @default(OTHER)
  authors    String?
  title      String
  publisher  String?
  year       Int?
  url        String?
  accessedAt DateTime?
  note       String?

  @@index([articleId, order])
}

model Media {
  id        String    @id @default(uuid())
  articleId String
  article   Article   @relation(fields: [articleId], references: [id], onDelete: Cascade)
  type      MediaType
  url       String
  publicId  String    // identifiant Cloudinary (pour suppression)
  alt       String    // OBLIGATOIRE (accessibilité, ENF-UX-04)
  credit    String?
  license   String?
  sizeBytes Int?
  createdAt DateTime  @default(now())
}

// ───────────── Traçabilité (append-only) ─────────────
model EditorialAction {
  id         String              @id @default(uuid())
  articleId  String
  article    Article             @relation(fields: [articleId], references: [id], onDelete: Cascade)
  actorId    String
  actor      User                @relation(fields: [actorId], references: [id])
  type       EditorialActionType
  fromStatus ArticleStatus?
  toStatus   ArticleStatus?
  comment    String?             @db.Text
  createdAt  DateTime            @default(now())

  @@index([articleId, createdAt])
}
```

**Règles de données**
- `EditorialAction` est **append-only** : jamais de `update` ni `delete` (hors purge programmée).
- `Article.deletedAt` = suppression douce. Purge définitive après 90 jours (tâche V1).
- Le `slug` est généré depuis le titre (sans accents, en minuscules, tirets), suffixé en cas de doublon. Seul un `ADMIN` peut le modifier après publication (les URLs publiées doivent rester stables).
- Le `contentHtml` est **recalculé et sanitisé côté serveur** à chaque sauvegarde ; il n'est jamais accepté depuis le client.
- Recherche V1 : ajouter une colonne `tsvector` via migration SQL manuelle (Prisma ne la gère que via `Unsupported("tsvector")`), config `french` + extension `unaccent`.

### 8.3 Infobox structurée par type d'article (Zod)

```ts
// src/validators/infobox.ts
import { z } from "zod";

export const biographyInfobox = z.object({
  fullName: z.string().max(200),
  birthDate: z.string().optional(),       // ISO ou partielle ("1905", "1905-10")
  birthPlace: z.string().optional(),
  deathDate: z.string().optional(),
  deathPlace: z.string().optional(),
  nationality: z.array(z.string()).default([]),
  occupations: z.array(z.string()).default([]),
});

export const regionInfobox = z.object({
  level: z.enum(["DISTRICT", "REGION", "DEPARTMENT", "SUB_PREFECTURE", "VILLAGE"]),
  population: z.number().int().positive().optional(),
  populationYear: z.number().int().optional(),   // année du recensement source
  areaKm2: z.number().positive().optional(),
  ethnicGroups: z.array(z.string()).default([]),
  languages: z.array(z.string()).default([]),
});

export const institutionInfobox = z.object({
  officialName: z.string(),
  acronym: z.string().optional(),
  institutionType: z.string(),                   // Université, Ministère, ONG…
  foundedYear: z.number().int().optional(),
  headquarters: z.string().optional(),
});

export const infoboxByType = {
  BIOGRAPHY: biographyInfobox,
  REGION: regionInfobox,
  INSTITUTION: institutionInfobox,
} as const; // autres types : infobox absente au MVP
```

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
| `submit` | `DRAFT`, `REVISION_REQUESTED` | `SUBMITTED` | CONTRIBUTOR, EDITOR, ADMIN | Seul **l'auteur** ; titre, résumé, contenu non vide, catégorie requis ; crée une `ArticleVersion` |
| `start_review` | `SUBMITTED` | `IN_REVIEW` | EDITOR, ADMIN | Pas l'auteur (sauf `ALLOW_SELF_REVIEW`) |
| `request_revision` | `IN_REVIEW` | `REVISION_REQUESTED` | EDITOR, ADMIN | **Commentaire obligatoire** ; notifie l'auteur |
| `approve` | `IN_REVIEW` | `APPROVED` | EDITOR, ADMIN | — |
| `publish` | `APPROVED` | `PUBLISHED` | EDITOR, ADMIN | Renseigne `publishedAt` ; crée une version ; (raccourci UI « Approuver et publier » = `approve` + `publish` dans **une** transaction) |
| `archive` | `PUBLISHED` | `ARCHIVED` | EDITOR, ADMIN | — |
| `restore` | `ARCHIVED` | `PUBLISHED` | EDITOR, ADMIN | — |
| `delete` | tout sauf `DELETED` | `DELETED` | ADMIN | Suppression douce (`deletedAt`) |

**Règles d'édition par statut**

| Statut | Qui peut modifier le contenu |
|---|---|
| `DRAFT`, `REVISION_REQUESTED` | L'auteur ; ADMIN |
| `SUBMITTED` | Personne (verrouillé) |
| `IN_REVIEW` | EDITOR / ADMIN (corrections mineures, tracées) |
| `PUBLISHED` | EDITOR / ADMIN uniquement (chaque sauvegarde = nouvelle version + action `EDITED_PUBLISHED`) |
| `ARCHIVED`, `DELETED` | ADMIN |

> Les contributeurs ne peuvent pas modifier directement un article publié au MVP. La « proposition de modification » est une fonctionnalité V1.

### 9.3 Implémentation de référence (`src/lib/workflow.ts`, fonction pure)

```ts
import { ArticleStatus as S, Role } from "@prisma/client";

export type WorkflowAction =
  | "submit" | "start_review" | "request_revision"
  | "approve" | "publish" | "archive" | "restore" | "delete";

type Rule = {
  from: S[];
  to: S;
  roles: Role[];
  authorOnly?: boolean;        // l'acteur doit être l'auteur
  notAuthor?: boolean;         // l'acteur ne doit pas être l'auteur
  commentRequired?: boolean;
};

export const RULES: Record<WorkflowAction, Rule> = {
  submit:           { from: [S.DRAFT, S.REVISION_REQUESTED], to: S.SUBMITTED,
                      roles: ["CONTRIBUTOR", "EDITOR", "ADMIN"], authorOnly: true },
  start_review:     { from: [S.SUBMITTED], to: S.IN_REVIEW,
                      roles: ["EDITOR", "ADMIN"], notAuthor: true },
  request_revision: { from: [S.IN_REVIEW], to: S.REVISION_REQUESTED,
                      roles: ["EDITOR", "ADMIN"], commentRequired: true },
  approve:          { from: [S.IN_REVIEW], to: S.APPROVED, roles: ["EDITOR", "ADMIN"] },
  publish:          { from: [S.APPROVED], to: S.PUBLISHED, roles: ["EDITOR", "ADMIN"] },
  archive:          { from: [S.PUBLISHED], to: S.ARCHIVED, roles: ["EDITOR", "ADMIN"] },
  restore:          { from: [S.ARCHIVED], to: S.PUBLISHED, roles: ["EDITOR", "ADMIN"] },
  delete:           { from: [S.DRAFT, S.SUBMITTED, S.IN_REVIEW, S.REVISION_REQUESTED,
                             S.APPROVED, S.PUBLISHED, S.ARCHIVED],
                      to: S.DELETED, roles: ["ADMIN"] },
};

export class WorkflowError extends Error {
  constructor(public code: "FORBIDDEN" | "INVALID_TRANSITION" | "COMMENT_REQUIRED",
              message: string) { super(message); }
}

export function assertTransition(args: {
  action: WorkflowAction;
  status: S;
  actorId: string;
  actorRole: Role;
  authorId: string;
  comment?: string;
  allowSelfReview?: boolean;
}): S {
  const rule = RULES[args.action];
  if (!rule.roles.includes(args.actorRole))
    throw new WorkflowError("FORBIDDEN", "Rôle insuffisant.");
  if (!rule.from.includes(args.status))
    throw new WorkflowError("INVALID_TRANSITION",
      `Impossible de faire « ${args.action} » depuis le statut ${args.status}.`);
  if (rule.authorOnly && args.actorId !== args.authorId)
    throw new WorkflowError("FORBIDDEN", "Seul l'auteur peut effectuer cette action.");
  if (rule.notAuthor && args.actorId === args.authorId && !args.allowSelfReview)
    throw new WorkflowError("FORBIDDEN", "Vous ne pouvez pas réviser votre propre article.");
  if (rule.commentRequired && !args.comment?.trim())
    throw new WorkflowError("COMMENT_REQUIRED", "Un commentaire est obligatoire.");
  return rule.to;
}
```

> **Première tâche de test recommandée** : écrire les tests Vitest de `assertTransition` (fonction pure, aucun mock nécessaire). C'est le meilleur entraînement du projet.

### 9.4 Service de transition (squelette)

```ts
// src/server/services/workflow.service.ts  (squelette — à compléter)
export async function transitionArticle(input: {
  articleId: string; action: WorkflowAction; actor: SessionUser; comment?: string;
}) {
  return prisma.$transaction(async (tx) => {
    const article = await tx.article.findUniqueOrThrow({ where: { id: input.articleId } });

    const toStatus = assertTransition({ /* … voir 9.3 … */ });

    await tx.article.update({
      where: { id: article.id },
      data: {
        status: toStatus,
        publishedAt: toStatus === "PUBLISHED" && !article.publishedAt ? new Date() : undefined,
        deletedAt: toStatus === "DELETED" ? new Date() : undefined,
        lockVersion: { increment: 1 },
      },
    });

    // 1. snapshot si submit / publish
    // 2. EditorialAction (append-only) avec fromStatus/toStatus/comment
    // 3. email de notification APRÈS la transaction (ne pas bloquer ni annuler si l'email échoue)
  });
}
```

**Verrou optimiste** : `PATCH /api/articles/:id` exige `lockVersion` dans le corps. Si la valeur en base diffère → réponse **409 CONFLICT** (« L'article a été modifié entre-temps »). Évite que deux personnes s'écrasent mutuellement.

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
- Un utilisateur `suspendedAt != null` ne peut plus se connecter.
- Les vérifications de permission sont **toujours côté serveur** (services). Masquer un bouton dans l'UI n'est **pas** une protection.
- Un article non publié n'est visible que par son auteur, les EDITOR et les ADMIN.
- Phase solo : le fondateur est `ADMIN` et utilise `ALLOW_SELF_REVIEW=true`. **Le désactiver dès l'arrivée du premier éditeur.**

---

## 11. Contrat d'API (MVP)

Base : `/api`. Format JSON. Authentification par cookie de session. Validation Zod sur **toutes** les entrées.

### 11.1 Endpoints

| Méthode | Route | Accès | Description | EF |
|---|---|---|---|---|
| POST | `/auth/register` | public | Inscription (crée `READER`, envoie email de vérification) | AUTH-01/02 |
| POST | `/auth/verify-email` | public | Valide le token email | AUTH-02 |
| POST | `/auth/forgot-password` | public | Envoie un lien de réinitialisation (réponse identique que l'email existe ou non) | AUTH-05 |
| POST | `/auth/reset-password` | public | Définit un nouveau mot de passe | AUTH-05 |
| *(Auth.js)* | `/auth/[...nextauth]` | public | Connexion / déconnexion / session | AUTH-03/04 |
| GET | `/articles` | public | Liste des articles **publiés** (`?category=&tag=&page=&limit=`) | RCH-02/05 |
| GET | `/articles/:slug` | public* | Détail (publié ; sinon auteur/éditeur/admin) | ART |
| POST | `/articles` | CONTRIBUTOR+ | Crée un brouillon | ART-01 |
| PATCH | `/articles/:id` | selon statut (9.2) | Met à jour (auto-save inclus) ; exige `lockVersion` | ART-02/03 |
| POST | `/articles/:id/transition` | selon 9.2 | Corps : `{ action, comment? }` | WF |
| GET | `/articles/:id/versions` | EDITOR+ / auteur | Historique des versions | ART-10 |
| GET | `/me/articles` | CONTRIBUTOR+ | Mes articles et statuts | WF-05 |
| GET | `/review/queue` | EDITOR+ | Articles `SUBMITTED` / `IN_REVIEW` | WF-01 |
| GET | `/search?q=&page=` | public | Recherche dans les articles publiés | RCH-01 |
| GET | `/categories` | public | Arbre des catégories | CAT |
| POST/PATCH | `/admin/categories` | ADMIN | Gestion des catégories | ADM-03 |
| GET/PATCH | `/admin/users` | ADMIN | Liste, changement de rôle, suspension | ADM-02 |
| POST | `/upload/sign` | CONTRIBUTOR+ | Signature d'upload Cloudinary | ART-06 |

*V1 : `POST /articles/:id/rollback`, signalements, logs d'activité.*

### 11.2 Format d'erreur unique

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
| 400 | `VALIDATION_ERROR`, `COMMENT_REQUIRED` | Entrée invalide |
| 401 | `UNAUTHENTICATED` | Pas de session |
| 403 | `FORBIDDEN` | Permission refusée |
| 404 | `NOT_FOUND` | Ressource absente ou non visible |
| 409 | `CONFLICT`, `INVALID_TRANSITION` | Verrou optimiste, transition interdite |
| 429 | `RATE_LIMITED` | Trop de requêtes |
| 500 | `INTERNAL_ERROR` | Erreur serveur (message générique, détails dans les logs) |

### 11.3 Pagination
`?page=1&limit=20` (limite maximale 20 : ENF-PERF-05). Réponse : `{ data: [...], meta: { page, limit, total } }`.

---

## 12. Séquences clés (résumé)

**Inscription** : formulaire → `POST /auth/register` → validation Zod → email unique ? → hash bcrypt → `INSERT User` → création `VerificationToken` (hash) → envoi email → réponse 201.

**Connexion** : `signIn("credentials")` → recherche user par email → vérification suspension + `emailVerified` → `bcrypt.compare` → JWT dans cookie HttpOnly/Secure/SameSite=Lax. Message d'erreur **identique** pour « email inconnu » et « mauvais mot de passe ».

**Rédaction → publication** : `POST /articles` (DRAFT) → auto-save `PATCH` toutes les 60 s → `transition: submit` (snapshot v1, email aux éditeurs) → `start_review` → `approve` + `publish` (snapshot, `publishedAt`) → page publique générée.

**Demande de révision** : `request_revision` avec commentaire → statut `REVISION_REQUESTED` → email à l'auteur → l'auteur corrige et re-soumet (`submit`).

---

## 13. Sécurité (règles non négociables)

| Menace | Règle |
|---|---|
| Injection SQL | Prisma uniquement (requêtes paramétrées). Si `$queryRaw` est nécessaire : **template literal tagué**, jamais de concaténation. |
| XSS | Le contenu est du JSON TipTap ; le HTML est généré côté serveur puis passé dans `sanitize-html` (liste blanche de balises/attributs, pas de `script`, pas d'attributs `on*`, liens `http(s)`/`mailto` seulement). Interdit : `dangerouslySetInnerHTML` avec du HTML non sanitisé. |
| CSRF | Cookies `SameSite=Lax`+, protections Auth.js ; vérifier l'`Origin` sur les mutations. |
| Mots de passe | bcrypt ≥ 12 rounds (ou argon2), longueur minimale 10 caractères, jamais loggés. |
| Brute-force | Rate-limit sur `/login`, `/register`, `/forgot-password` (par IP et par email). |
| Énumération de comptes | Réponses identiques pour « email existe / n'existe pas » (reset, inscription). |
| Tokens (vérif. email, reset) | Aléatoires (≥ 32 octets), **stockés hachés**, usage unique, expiration courte. |
| Upload | Signature Cloudinary côté serveur ; whitelist MIME (`image/jpeg`, `png`, `webp`) ; taille max définie ; `alt` obligatoire. |
| Autorisation | Vérifiée dans chaque service (jamais seulement dans l'UI). Tester le cas « utilisateur A accède à la ressource de B ». |
| Secrets | Variables d'environnement validées par `env.ts` ; jamais dans le code ni les logs. |
| En-têtes HTTP | HTTPS forcé, HSTS, `Content-Security-Policy` raisonnable, `X-Content-Type-Options: nosniff`. |
| Dépendances | Dependabot activé ; `pnpm audit` en CI. |
| Sauvegardes | Sauvegarde BDD quotidienne **dès la première semaine** ; **tester une restauration** au moins une fois avant le lancement public. |

**Données personnelles** : le traitement de données personnelles (email, nom) est encadré en Côte d'Ivoire par la loi n° 2013-450 relative à la protection des données à caractère personnel, sous le contrôle de l'ARTCI. Prévoir avant le lancement public : politique de confidentialité, mentions légales, possibilité de suppression de compte. *Ce document n'est pas un avis juridique : faire valider les obligations exactes (déclarations, hébergement) par un juriste.*

---

## 14. Backlog ordonné du MVP

Durées **indicatives** pour un développeur seul à temps partiel ; ajuster selon la disponibilité réelle. Chaque ticket = une branche + une PR. Les codes `EF-*` renvoient au cahier des charges.

### Sprint 0 — Fondations (≈ 1 semaine)
- [ ] Initialiser Next.js + TypeScript strict + Tailwind + ESLint/Prettier
- [ ] Docker Compose PostgreSQL + `.env.example` + `env.ts` (validation Zod)
- [ ] Schéma Prisma (section 8.2) + 1ʳᵉ migration + `seed.ts` (catégories de base, admin de dev)
- [ ] CI GitHub Actions (lint, typecheck, test, build)
- [ ] Déploiement « hello world » sur Vercel + BDD managée
- **Critère de sortie** : `pnpm dev` fonctionne chez un nouvel arrivant en suivant la section 7 ; la CI est verte.

### Sprint 1 — Authentification (≈ 2 semaines) · EF-AUTH-01→05
- [ ] Inscription + hash du mot de passe
- [ ] Vérification email (token haché, expiration)
- [ ] Connexion / déconnexion (Auth.js)
- [ ] Reset du mot de passe
- [ ] Rate-limiting sur routes sensibles
- [ ] Middleware de protection de routes + helper `requireRole()`
- **Critère de sortie** : un utilisateur s'inscrit, vérifie son email, se connecte ; un ADMIN peut le promouvoir en base (via Prisma Studio, l'UI admin vient au Sprint 5).

### Sprint 2 — Articles & éditeur (≈ 2-3 semaines) · EF-ART-01→09
- [ ] `lib/slug.ts` (+ tests)
- [ ] Service article : créer / lire / mettre à jour (avec `lockVersion`)
- [ ] Éditeur TipTap + auto-save 60 s
- [ ] Sélection catégorie + tags
- [ ] Références bibliographiques (ajout / ordre / suppression)
- [ ] Upload image de couverture (Cloudinary signé) avec `alt`
- [ ] Prévisualisation
- [ ] Rendu HTML sanitisé (`lib/sanitize.ts` + tests XSS)
- **Critère de sortie** : un CONTRIBUTOR crée, édite et prévisualise un brouillon.

### Sprint 3 — Workflow & versions (≈ 2-3 semaines) · EF-WF-01→06, EF-ART-10
- [ ] `lib/workflow.ts` + **tests exhaustifs** (chaque transition, chaque rôle)
- [ ] `workflow.service.ts` avec transaction + `EditorialAction`
- [ ] Création des `ArticleVersion` aux jalons (ADR-005)
- [ ] File de révision `/revision` + page de relecture
- [ ] Emails de notification (soumission, révision demandée, publication)
- [ ] Page « Mes articles » avec statuts
- [ ] Historique des versions (lecture seule)
- **Critère de sortie** : cycle complet brouillon → publié, avec traçabilité, testé par test d'intégration.

### Sprint 4 — Lecture publique, navigation, recherche (≈ 2 semaines) · EF-RCH-01→05, 08
- [ ] Accueil (récents / mis en avant), page article (infobox, références, tags)
- [ ] Pages catégorie (arborescence) et tag
- [ ] Recherche simple + page de résultats paginée
- [ ] SEO : URLs lisibles, métadonnées (`title`, `description`, `og:image`), `robots.txt`
- [ ] Responsive mobile-first
- **Critère de sortie** : un visiteur anonyme trouve et lit un article publié depuis un mobile.

### Sprint 5 — Admin & durcissement (≈ 2 semaines) · EF-ADM-01→03,05,08
- [ ] Admin utilisateurs (rôle, suspension)
- [ ] Admin catégories
- [ ] Tableau de bord minimal (compteurs)
- [ ] Sauvegardes automatiques + **test de restauration**
- [ ] Revue sécurité (checklist section 13) + en-têtes HTTP
- [ ] Pages légales (confidentialité, mentions, licence du contenu)
- [ ] Contenu initial : **au moins 30 articles de qualité** avant ouverture publique
- **Critère de sortie** : bêta privée avec 5-10 testeurs.

### Après le MVP (V1)
Rollback · Recherche full-text PostgreSQL · Commentaires éditoriaux · Signalements · Logs d'activité · Autocomplétion · Wiki-links `[[Terme]]` · Audio · API publique en lecture · Premiers contributeurs externes (voir `CONTRIBUTING.md` à rédiger).

---

## 15. Conventions de développement

### 15.1 Code
- TypeScript `strict: true`. Pas de `any` sans commentaire justificatif.
- Fichiers : `kebab-case.ts` ; composants React : `PascalCase.tsx` ; services : `<domaine>.service.ts`.
- Fonctions courtes, une responsabilité. Les noms disent **ce que ça fait**, pas comment.
- Commentaires : expliquer le **pourquoi**, pas le **quoi**. Les règles métier non évidentes sont commentées avec une référence (`// cf. CONTEXT §9.2`).
- Pas de logique dupliquée entre front et back : schémas Zod dans `src/validators/`, partagés.

### 15.2 Git
- Branche principale `main` toujours déployable. Branches courtes : `feat/ef-art-01-create-draft`, `fix/…`, `docs/…`, `chore/…`.
- **Conventional Commits** : `feat(article): add autosave`, `fix(auth): normalize email`, `test(workflow): cover revision path`.
- Une PR = un sujet, relue (même en solo : relire sa propre PR sur GitHub avant de merger).
- Chaque PR référence un code `EF-*` ou `ENF-*` quand c'est pertinent.

### 15.3 Tests

| Niveau | Outil | Cible minimale MVP |
|---|---|---|
| Unitaire | Vitest | `workflow.ts`, `rbac`, `slug.ts`, `sanitize.ts`, validateurs Zod |
| Intégration | Vitest + BDD de test | Services `article` et `workflow` (transitions complètes) |
| E2E | Playwright | V1 : parcours inscription → publication |

> Priorité absolue de test : **permissions, workflow, sanitisation**. Ce sont les zones où un bug = faille ou corruption de contenu.

### 15.4 CI (`.github/workflows/ci.yml` — canevas)

```yaml
name: CI
on: [pull_request, push]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with: { node-version: lts/*, cache: pnpm }
      - run: pnpm install --frozen-lockfile
      - run: pnpm prisma validate
      - run: pnpm lint
      - run: pnpm typecheck
      - run: pnpm test
      - run: pnpm build
```

*(Vérifier les versions actuelles des actions GitHub à la mise en place.)*

### 15.5 Definition of Done (une tâche est terminée quand…)
- [ ] Le comportement correspond à l'exigence `EF-*` citée
- [ ] Entrées validées (Zod) et permissions vérifiées côté serveur
- [ ] Tests ajoutés pour la logique métier touchée
- [ ] `lint`, `typecheck`, `test`, `build` passent en local et en CI
- [ ] Aucun secret ni donnée personnelle dans le code ou les logs
- [ ] Textes d'interface en français, accessibles (alt, labels, contraste)
- [ ] Ce fichier et/ou un ADR mis à jour si une décision a changé

---

## 16. Instructions spécifiques aux assistants IA

### 16.1 Comportement attendu
1. **Lire avant d'écrire** : consulter les sections 4, 6, 8, 9, 10, 13 avant de proposer du code.
2. **Respecter le périmètre** : MVP seulement (section 3). Signaler gentiment toute demande hors périmètre.
3. **Petits pas** : proposer des changements courts et vérifiables (un fichier ou une fonction à la fois), avec la commande pour les tester.
4. **Pédagogie** : le développeur est en apprentissage. Pour chaque concept non trivial (ORM, transaction, JWT, verrou optimiste…), donner une définition en une phrase et le *pourquoi*.
5. **Cohérence** : réutiliser les noms de la section 8.1, les codes d'erreur de 11.2, les conventions de 15.
6. **Honnêteté** : si une information dépend de la version d'une librairie (Auth.js, Next.js, Prisma, Cloudinary, Resend…), **dire de vérifier la documentation officielle** plutôt que d'affirmer de mémoire.
7. **Tests d'abord pour la logique métier** : proposer les tests de `workflow`/`rbac` avant ou avec l'implémentation.

### 16.2 À ne jamais faire
- Ajouter une dépendance, un service cloud ou un changement d'architecture sans ADR.
- Mettre de la logique métier dans un handler d'API ou un composant React.
- Écrire une requête SQL par concaténation de chaînes.
- Afficher du HTML non sanitisé ; accepter `contentHtml` depuis le client.
- Contourner `assertTransition` pour changer un statut.
- Modifier ou supprimer des lignes d'`EditorialAction`.
- Stocker un token ou un mot de passe en clair.
- Introduire du code mort « pour plus tard » (YAGNI).
- Réécrire de gros pans du projet sans demande explicite.

### 16.3 Modèles de prompts utiles (pour le dev)

**Implémenter un ticket**
> Contexte : IVOIREPEDIA (voir CONTEXT.md). Ticket : « EF-ART-01 Créer un brouillon ». Respecte les couches de la section 6.2 et le schéma 8.2. Donne : (1) le schéma Zod, (2) le service, (3) le Route Handler, (4) les tests Vitest. Explique chaque concept nouveau en une phrase.

**Revue de code**
> Relis ce diff selon la Definition of Done (15.5) et la checklist sécurité (13). Liste d'abord les problèmes bloquants, puis les améliorations. Explique chaque remarque.

**Comprendre une erreur**
> Voici l'erreur et le fichier concerné. Explique la cause en termes simples, propose la correction minimale, puis dis comment éviter ce type d'erreur à l'avenir.

**Écrire des tests**
> Écris les tests Vitest de `assertTransition` : un test par ligne du tableau 9.2, plus les cas d'échec (mauvais rôle, mauvais statut, commentaire manquant, auto-révision).

---

## 17. Risques et questions ouvertes

### 17.1 Risques principaux

| Risque | Gravité | Mitigation |
|---|---|---|
| Surcharge / abandon du projet solo | Élevée | Sprints courts, périmètre MVP strict, 1 fonctionnalité à la fois, publier tôt |
| Dérive de périmètre (scope creep) | Élevée | Section 3.2 ; toute addition passe par un ticket explicite |
| Faille de sécurité (XSS, contrôle d'accès) | Élevée | Section 13, tests ciblés, services comme unique point d'écriture |
| Perte de données | Élevée | Sauvegardes dès S0 + test de restauration |
| Plateforme vide au lancement | Moyenne | ≥ 30 articles de qualité avant ouverture ; recruter 2-3 éditeurs de confiance |
| Qualité éditoriale / vandalisme | Moyenne | Workflow strict, pas de modification directe des articles publiés par les contributeurs |
| Dépendance aux offres gratuites cloud | Moyenne | Garder le code portable (PostgreSQL standard, Cloudinary derrière une interface `media.service`) |

### 17.2 Questions ouvertes (à trancher avant la bêta publique)

| # | Question | Échéance |
|---|---|---|
| Q1 | **Licence du code** (MIT, Apache-2.0, AGPL-3.0…) | Avant le 1ᵉʳ contributeur externe |
| Q2 | **Licence du contenu** : confirmer CC BY-SA 4.0 et rédiger la charte éditoriale | Avant la bêta privée |
| Q3 | Nom de domaine et adresse d'expédition des emails (SPF/DKIM) | Sprint 1 |
| Q4 | Charte éditoriale : critères de notoriété, sources acceptées, neutralité, traitement de la tradition orale | Sprint 3 |
| Q5 | Politique de modération (vandalisme, contenus sensibles, droit de réponse) | Sprint 5 |
| Q6 | Conformité données personnelles : déclarations ARTCI, hébergement, durée de conservation | Avant la bêta publique |
| Q7 | Stratégie de recrutement des premiers éditeurs et contributeurs | Sprint 4 |

---

## 18. Glossaire

| Terme | Définition |
|---|---|
| **ADR** | *Architecture Decision Record* : note courte qui consigne une décision technique et sa justification. |
| **API / Route Handler** | Point d'entrée HTTP du serveur (ex. `POST /api/articles`) qui reçoit une requête et renvoie du JSON. |
| **Append-only** | Table où l'on n'ajoute que des lignes, sans jamais modifier ni supprimer (journal fiable). |
| **bcrypt** | Algorithme de hachage lent pour mots de passe : transforme un mot de passe en empreinte non réversible. |
| **CI** | *Continuous Integration* : exécution automatique des vérifications (lint, tests, build) à chaque modification. |
| **CRUD** | Create, Read, Update, Delete : les 4 opérations de base sur les données. |
| **CSP** | *Content Security Policy* : en-tête HTTP limitant les sources de scripts autorisées (défense contre XSS). |
| **Hash / empreinte** | Résultat d'une fonction à sens unique appliquée à une donnée (ex. SHA-256). |
| **jsonb** | Type PostgreSQL pour stocker du JSON de façon indexable et performante. |
| **JWT** | *JSON Web Token* : jeton signé prouvant l'identité de l'utilisateur, transporté ici dans un cookie HttpOnly. |
| **MVP** | *Minimum Viable Product* : plus petite version utilisable du produit. |
| **ORM** | *Object-Relational Mapper* : traduit le code en requêtes SQL (ici Prisma). |
| **Rate limiting** | Limitation du nombre de requêtes par période pour contrer abus et brute-force. |
| **RBAC** | *Role-Based Access Control* : contrôle d'accès fondé sur les rôles. |
| **Sanitisation** | Nettoyage d'un contenu HTML pour retirer tout code dangereux. |
| **Slug** | Version « URL » d'un titre : `felix-houphouet-boigny`. |
| **Soft delete** | Suppression logique : la ligne est marquée supprimée mais conservée un temps. |
| **TipTap / ProseMirror** | Éditeur de texte riche dont le contenu est un arbre JSON structuré. |
| **Transaction** | Groupe d'opérations BDD exécutées « tout ou rien ». |
| **Verrou optimiste** | Détection de modifications concurrentes via un numéro de version ; conflit → 409. |
| **XSS** | *Cross-Site Scripting* : injection de script malveillant dans une page vue par d'autres utilisateurs. |
| **YAGNI** | *You Aren't Gonna Need It* : ne pas construire ce dont on n'a pas encore besoin. |
| **Zod** | Librairie TypeScript de validation de données par schémas. |

---

## 19. Historique du document

| Date | Version | Changement |
|---|---|---|
| 2026-11-02 | 1.0 | Création : consolidation du cahier des charges, de la conception UML et de la roadmap ; décisions ADR-001 à 008 ; backlog MVP. |

> **Règle de maintenance** : tout changement d'architecture, de modèle de données ou de workflow doit mettre à jour ce fichier **dans la même PR**. Un contexte obsolète est pire que pas de contexte.
