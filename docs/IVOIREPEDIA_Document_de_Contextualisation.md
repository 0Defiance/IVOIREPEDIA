# IVOIREPEDIA — Document de contextualisation (équipe dev & IA)

> **Version** : 1.0 — novembre 2026
> **Statut du projet** : phase de cadrage (aucune ligne de code écrite à ce jour)
> **Usage** : ce fichier est la source de vérité de départ. Toute personne ou IA qui rejoint le projet doit le lire en entier avant de produire quoi que ce soit.
> **Convention** : les éléments marqués ✅ sont des décisions actées. Ceux marqués 🟡 sont des **hypothèses de travail** à valider. Ceux marqués ❓ sont des **questions ouvertes**.
>
> **⚠️ Stack technique (mise à jour du 2 nov. 2026)** : les sections de ce document qui décrivent une stack (§5, §6, §19-§20…) datent du cadrage initial et sont **supplantées par [`IVOIREPEDIA_CONTEXT.md`](../IVOIREPEDIA_CONTEXT.md)** — la stack validée est désormais le modèle Soutrali : **Flutter (`app/`) + Laravel (`backend/`) + MySQL/XAMPP** (ADR-001 à 008 du CONTEXT). Ce document reste la référence pour la **vision produit** (multilinguisme, sources orales, géolocalisation, hors-ligne, validation par cercles). En cas de contradiction, le CONTEXT fait foi (CONTEXT §2.1).

---

## 0. TL;DR (à lire en 1 minute)

**Ivoirepedia** est une encyclopédie numérique collaborative dédiée à la Côte d'Ivoire : « un Wikipédia à l'ivoirienne », inclusive, multilingue et fondée autant sur l'oralité que sur l'écrit.

Ce qui la distingue de Wikipédia :

1. **Un seul article, plusieurs langues** (français + langues ivoiriennes + nouchi) au lieu d'articles séparés par langue.
2. **Les sources orales sont des sources valides** (griots, anciens, détenteurs de savoirs), avec métadonnées et validation communautaire.
3. **Accessibilité extrême** : ultra-léger (2G), hors-ligne, SMS, USSD, WhatsApp, audio.
4. **Validation par cercles** (local → sages → expert académique → rédacteur) plutôt qu'édition anonyme ouverte.
5. **Géolocalisation centrale** : tout contenu rattaché à un territoire.
6. **Style narratif** (biographies humanisées) tout en restant factuel et sourcé.

**Contrainte n°1 de conception** : un utilisateur sur un téléphone Android d'entrée de gamme, en 2G/3G, avec peu de data, doit pouvoir lire, écouter et contribuer.

---

## 1. Contexte et problématique

### 1.1 Constat
- Le patrimoine culturel ivoirien est sous-documenté dans les encyclopédies internationales.
- Beaucoup de savoirs sont **oraux** et disparaissent avec les générations.
- La Côte d'Ivoire compte **plus de 60 langues** ; elles sont marginalisées numériquement face au français.
- Les connexions sont variables, la data est chère, une partie de la population est peu alphabétisée en français écrit.

### 1.2 Mission
Documenter, préserver et valoriser les savoirs ivoiriens, avec les communautés qui les détiennent, sous une forme accessible à tous.

### 1.3 Publics cibles

| Public | Besoin principal | Contrainte |
|---|---|---|
| Élèves / étudiants | Contenus fiables, citables, en français | Smartphone Android, data limitée |
| Grand public urbain (Abidjan, Bouaké…) | Culture, gastronomie, nouchi, histoire | Mobile-first |
| Populations rurales | Retrouver/transmettre leurs savoirs, en langue locale | 2G, faible alphabétisation, audio préféré |
| Détenteurs de savoirs (griots, anciens, artisans) | Être reconnus et protégés | Souvent non écrivants → contribution assistée |
| Chercheurs / enseignants | Sources, citations, API | Exigence de rigueur |
| Diaspora | Reconnexion culturelle | Bonne connexion, forte demande multimédia |
| Contributeurs / validateurs | Outils simples, reconnaissance | Niveaux techniques très variés |

### 1.4 Hors périmètre (explicite)
- Ce n'est **pas** un réseau social ni un média d'actualité.
- Ce n'est **pas** un outil d'opinion politique : neutralité éditoriale stricte (voir §10).
- La marketplace et les formations sont des **modules ultérieurs** (Phase 3+), pas le cœur du MVP.

---

## 2. Principes directeurs (non négociables)

1. ✅ **Mobile-first, low-bandwidth-first** : toute fonctionnalité est conçue d'abord pour 2G/3G.
2. ✅ **Plurilinguisme de premier rang** : une langue ivoirienne n'est jamais traitée comme une « traduction secondaire ».
3. ✅ **Oralité = source de plein droit**, avec traçabilité (qui, quand, où, dans quel contexte).
4. ✅ **Consentement et protection des savoirs** : certains savoirs sont sacrés ou restreints. Aucun contenu de ce type n'est publié sans validation des détenteurs légitimes.
5. ✅ **Souveraineté des données** : hébergement principal en Afrique de l'Ouest si faisable, avec sauvegardes répliquées hors pays.
6. ✅ **Licences ouvertes mais respectueuses** : contenu sous licence ouverte par défaut, avec mécanisme de **restriction culturelle** (voir §9.4).
7. ✅ **Transparence éditoriale** : chaque article expose contributeurs, sources, statut de validation, historique.
8. ✅ **Pas de publicité**, pas de revente de données personnelles.
9. ✅ **Dégradation gracieuse** : si une fonctionnalité riche échoue (3D, vidéo), le texte reste lisible.
10. ✅ **Open source** pour le code (licence à choisir, voir §21).

---

## 3. Glossaire métier

| Terme | Définition dans le projet |
|---|---|
| **Article** | Unité de contenu encyclopédique, une seule entité logique, plusieurs versions linguistiques. |
| **Variante linguistique** (`article_locale`) | Contenu d'un article dans une langue donnée. |
| **Source orale** | Enregistrement audio/vidéo d'un témoignage, conte, chant, récit, avec métadonnées complètes. |
| **Détenteur de savoir** | Personne reconnue par sa communauté comme dépositaire d'un savoir (griot, chef, guérisseur, artisan, ancien). |
| **Conseil des sages** | Panel de validateurs culturels, organisé par aire culturelle. |
| **Cercle de validation** | Étape du workflow éditorial (voir §8). |
| **Savoir restreint** | Savoir à diffusion limitée (sacré, initiatique, genré, familial). Voir §9.4. |
| **Nouchi** | Argot ivoirien urbain, traité comme une variante linguistique à part entière. |
| **Mode léger** | Rendu texte quasi pur, cible < 50 Ko par page. |
| **Griot (assistant)** | Nom de code de l'assistant IA de l'encyclopédie (⚠ ne pas confondre avec les griots humains, qui sont des contributeurs/sources). |
| **Territoire** | Entité géographique hiérarchique (district > région > département > sous-préfecture > commune/village/quartier). |
| **Pack hors-ligne** | Lot de contenus téléchargeable par territoire ou thème. |

---

## 4. Périmètre fonctionnel

### 4.1 Domaines de contenu (taxonomie de premier niveau)
1. Géographie et territoires
2. Histoire
3. Peuples et cultures
4. Langues et communication (dont nouchi, proverbes, anthroponymie, toponymie)
5. Arts et patrimoine (musique, danse, littérature orale/écrite, arts plastiques, cinéma, architecture, artisanat)
6. Gastronomie
7. Économie et métiers
8. Éducation et savoirs (dont médecine traditionnelle, savoirs scientifiques locaux)
9. Vie quotidienne (transports, habitat, vêtements, sports, jeux)
10. Personnalités
11. Société et institutions (chefferies, religions, droit coutumier, médias)
12. Environnement et biodiversité

### 4.2 Types d'article (modèles de page)
`person`, `place`, `event`, `ethnic_group`, `language`, `dish`, `object_artifact`, `practice_ritual`, `organization`, `species`, `work` (œuvre), `concept`, `oral_text` (conte, épopée, proverbe), `route` (parcours culturel).

Chaque type a un **gabarit** (champs structurés + sections recommandées).

### 4.3 Fonctionnalités par priorité (MoSCoW)

**MUST (MVP)**
- Lecture d'articles multilingues avec bascule de langue
- Recherche plein texte multilingue
- Comptes (email + téléphone/OTP)
- Création/édition d'articles (éditeur riche) avec brouillon, relecture, publication
- Workflow de validation à 2 niveaux minimum (relecteur local + validateur culturel)
- Historique des versions, diff, rollback
- Sources écrites **et orales** avec métadonnées
- Upload et lecture audio (compressé), images optimisées
- Géolocalisation des articles + carte de base
- Mode léger + PWA hors-ligne basique
- Signalement de contenu / modération
- Rôles et permissions
- Journal d'audit

**SHOULD (Phase 2)**
- Application Android (wrapper PWA puis natif si besoin)
- Packs hors-ligne par territoire
- Audio synthétisé (TTS) pour le français ; enregistrements humains pour les langues locales
- Quiz et parcours d'apprentissage simples
- Bot WhatsApp
- Tableaux de bord contributeurs / régions
- Glossaire contextuel au survol/au toucher
- Import de contenus existants (Wikidata/Commons)

**COULD (Phase 3)**
- SMS et USSD
- Assistant IA « Griot » (RAG sur le corpus validé)
- Visites 360°, modèles 3D
- Gamification complète (points, badges, classements)
- Annuaire d'artisans, formations, paiements mobile money
- API publique documentée + écosystème

**WON'T (pour l'instant)**
- Messagerie privée, fil social, publicité, NFT/crypto, marketplace de contenu des détenteurs de savoirs sans cadre juridique clair

---

## 5. Architecture technique

### 5.1 Principe : monolithe modulaire d'abord
🟡 Pour une petite équipe et un budget contraint, on démarre par un **monolithe modulaire** (un seul déployable, modules bien séparés). On n'éclate en services que sur besoin avéré (ex. : traitement média, IA).

### 5.2 Stack recommandée 🟡

| Couche | Choix par défaut | Alternative | Justification |
|---|---|---|---|
| Front web | **Next.js (React) + TypeScript**, rendu serveur/statique | SvelteKit | SSR/ISR = pages légères et SEO ; écosystème large |
| Mobile | **PWA** d'abord ; **React Native** ou **Flutter** ensuite | Capacitor | PWA = 1 seule base, installable, hors-ligne |
| Backend | **Node.js + NestJS (ou Fastify) + TypeScript** | Python FastAPI / Django | Même langage front/back ; modules clairs |
| Base de données | **PostgreSQL 16 + PostGIS** | — | Relationnel + géospatial + JSONB |
| Recherche | **Meilisearch** (démarrage) → OpenSearch si volumétrie | Typesense | Léger, multilingue, simple à opérer |
| Cache / files | **Redis** (cache, rate limit, jobs via BullMQ) | — | Standard |
| Stockage objets | **S3-compatible** (MinIO auto-hébergé ou Cloudflare R2) | — | Médias volumineux |
| Médias | **FFmpeg** (audio/vidéo), **libvips/sharp** (images) | — | Transcodage multi-débits |
| Auth | Sessions + JWT court + refresh ; OTP SMS ; OAuth optionnel | Keycloak | Téléphone = identifiant majeur en CI |
| IA (Phase 3) | Modèles via API + **RAG** (pgvector) | modèles auto-hébergés | Voir §15 |
| Observabilité | OpenTelemetry, Prometheus/Grafana, Sentry | — | Diagnostiquer en conditions réelles |
| CI/CD | GitHub Actions, déploiement conteneurisé (Docker) | GitLab CI | — |
| Infra | Docker Compose → Kubernetes **seulement si nécessaire** | — | Éviter la sur-ingénierie |

### 5.3 Schéma logique

```
 [Utilisateurs]
   │  Web/PWA   │ App mobile │ WhatsApp │ SMS/USSD (via passerelle)
   ▼
 [CDN / Edge cache]  ── pages statiques, médias, packs hors-ligne
   ▼
 [API Gateway / Reverse proxy (rate limit, WAF)]
   ▼
 ┌─────────────── Monolithe modulaire ────────────────┐
 │ auth │ users │ articles │ locales │ sources │ media │
 │ geo  │ workflow │ moderation │ search │ notif │ i18n│
 └───────┬──────────────┬──────────────┬──────────────┘
         ▼              ▼              ▼
   PostgreSQL/PostGIS  Redis        Object storage
         │                              ▲
         ▼                              │
     Meilisearch                 Worker médias (FFmpeg/sharp)
```

### 5.4 Stratégie low-bandwidth (exigences techniques)
- **Budget de poids par page** : mode léger ≤ 50 Ko (HTML+CSS+JS critique, compressé), mode standard ≤ 500 Ko hors médias lourds.
- Pas de bibliothèque JS lourde sur les pages de lecture : **JS minimal, hydratation partielle**.
- Images : WebP/AVIF, `srcset`, `loading="lazy"`, placeholders ; **jamais** d'image non redimensionnée.
- Audio : Opus (≈ 16–24 kbps voix) comme format par défaut ; MP3 en repli.
- Vidéo : HLS multi-débits (240p/360p/480p) ; **audio-only** proposé systématiquement.
- Service Worker : stratégie *stale-while-revalidate* pour les articles, *cache-first* pour assets statiques.
- Détection de connexion (`Save-Data`, `navigator.connection`) → bascule automatique vers le mode léger.
- Polices : système par défaut ; si police web, sous-ensemble (subset) + `font-display: swap`.
- Tests de performance en CI avec profil réseau « Slow 3G » et appareil « Android entrée de gamme ».

### 5.5 Hébergement 🟡 ❓
- Cible : hébergement principal dans un data center ouest-africain si SLA acceptable ; sinon cloud européen proche + CDN avec présence africaine.
- Sauvegardes : quotidiennes, chiffrées, **3 copies / 2 supports / 1 hors-site** (règle 3-2-1).
- ❓ À trancher : fournisseur précis, coûts, exigences légales locales sur la localisation des données.

---

## 6. Modèle de données (PostgreSQL + PostGIS)

> Schéma de **référence** (à affiner). Convention : `snake_case`, clés `uuid`, horodatages `timestamptz`, suppression logique via `deleted_at`.

```sql
-- Extensions
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;

-- ========== UTILISATEURS & RÔLES ==========
CREATE TABLE users (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  display_name  text NOT NULL,
  email         citext UNIQUE,
  phone_e164    text UNIQUE,               -- ex. +225XXXXXXXXXX
  password_hash text,
  preferred_langs text[] DEFAULT '{fr}',
  home_territory_id uuid,                  -- FK territories
  bio           text,
  is_verified   boolean DEFAULT false,
  status        text NOT NULL DEFAULT 'active', -- active|suspended|deleted
  created_at    timestamptz DEFAULT now(),
  deleted_at    timestamptz
);

CREATE TABLE roles (
  id   smallserial PRIMARY KEY,
  code text UNIQUE NOT NULL  -- reader, contributor, local_reviewer, cultural_validator,
                             -- academic_expert, editor, moderator, admin
);

CREATE TABLE user_roles (
  user_id uuid REFERENCES users(id),
  role_id smallint REFERENCES roles(id),
  scope_territory_id uuid,   -- rôle limité à un territoire (validateur régional)
  scope_domain text,         -- rôle limité à un domaine (ex. 'gastronomie')
  scope_language text,       -- rôle limité à une langue
  granted_by uuid REFERENCES users(id),
  granted_at timestamptz DEFAULT now(),
  PRIMARY KEY (user_id, role_id, COALESCE(scope_territory_id, '00000000-0000-0000-0000-000000000000'::uuid))
);

-- Profil d'expertise affiché publiquement
CREATE TABLE expertise_profiles (
  user_id uuid PRIMARY KEY REFERENCES users(id),
  title text,                -- "Griot", "Agricultrice sénoufo", "Historien"
  community text,            -- communauté d'appartenance
  credentials text,
  verified_by uuid REFERENCES users(id)
);

-- ========== LANGUES ==========
CREATE TABLE languages (
  code        text PRIMARY KEY,       -- ISO 639-3 (bci, dyu, bev, sef…), 'fr', 'nou' (nouchi, code interne si absent d'ISO)
  name_fr     text NOT NULL,
  name_native text,
  script      text DEFAULT 'Latn',    -- Latn, Nkoo…
  is_active   boolean DEFAULT false,
  rtl         boolean DEFAULT false
);

-- ========== TERRITOIRES ==========
CREATE TABLE territories (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id  uuid REFERENCES territories(id),
  level      text NOT NULL,           -- district|region|department|sub_prefecture|commune|village|quartier
  slug       text UNIQUE NOT NULL,
  geom       geometry(MultiPolygon, 4326),
  centroid   geography(Point, 4326),
  wikidata_qid text,
  osm_id     bigint
);
CREATE TABLE territory_names (
  territory_id uuid REFERENCES territories(id),
  lang_code text REFERENCES languages(code),
  name text NOT NULL,
  meaning text,                        -- toponymie : signification du nom
  PRIMARY KEY (territory_id, lang_code)
);

-- ========== ARTICLES ==========
CREATE TABLE articles (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  type        text NOT NULL,           -- person|place|event|dish|…
  slug        text UNIQUE NOT NULL,    -- slug canonique stable (indépendant de la langue)
  domain_id   uuid,                    -- taxonomie
  primary_territory_id uuid REFERENCES territories(id),
  location    geography(Point, 4326),
  structured  jsonb DEFAULT '{}',      -- champs structurés selon `type`
  access_level text NOT NULL DEFAULT 'public', -- public|community|restricted|sacred_hidden (§9.4)
  license     text DEFAULT 'CC-BY-SA-4.0',
  status      text NOT NULL DEFAULT 'draft',   -- draft|in_review|validated|published|contested|archived
  published_at timestamptz,
  created_by  uuid REFERENCES users(id),
  created_at  timestamptz DEFAULT now(),
  deleted_at  timestamptz
);

-- Contenu par langue (un article, N variantes)
CREATE TABLE article_locales (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  article_id  uuid NOT NULL REFERENCES articles(id),
  lang_code   text NOT NULL REFERENCES languages(code),
  title       text NOT NULL,
  summary     text,                   -- chapeau 2-3 lignes
  body        jsonb NOT NULL,         -- document structuré (voir §6.2)
  body_html_cache text,
  audio_media_id uuid,                -- version audio de l'article
  translation_of uuid REFERENCES article_locales(id), -- si traduit d'une autre variante
  is_original boolean DEFAULT false,  -- rédigé directement dans cette langue
  quality_level text DEFAULT 'stub',  -- stub|draft|standard|reviewed|featured
  current_revision_id uuid,
  UNIQUE (article_id, lang_code)
);

CREATE TABLE revisions (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  article_locale_id uuid NOT NULL REFERENCES article_locales(id),
  parent_revision_id uuid REFERENCES revisions(id),
  body          jsonb NOT NULL,
  edit_summary  text,
  author_id     uuid REFERENCES users(id),
  created_at    timestamptz DEFAULT now(),
  state         text DEFAULT 'proposed' -- proposed|accepted|rejected|reverted
);

-- ========== SOURCES ==========
CREATE TABLE sources (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  kind        text NOT NULL,          -- written|oral|audiovisual|archive|web|dataset
  title       text,
  author      text,
  publisher   text,
  year        int,
  url         text,
  archive_ref text,                   -- cote d'archive
  reliability text,                   -- primary|secondary|tertiary
  notes       text
);

-- Métadonnées spécifiques aux sources ORALES (obligatoires pour kind='oral')
CREATE TABLE oral_source_details (
  source_id       uuid PRIMARY KEY REFERENCES sources(id),
  narrator_name   text NOT NULL,
  narrator_role   text,               -- griot, chef de village, guérisseuse…
  narrator_community text,
  recorded_at     date,
  recorded_place  text,
  recorded_point  geography(Point, 4326),
  recorded_by     uuid REFERENCES users(id),
  context         text,               -- cérémonie, entretien, enseignement…
  language_code   text REFERENCES languages(code),
  consent_status  text NOT NULL,      -- full_public|public_attributed|community_only|restricted|withdrawn
  consent_document_media_id uuid,     -- preuve de consentement (audio/écrit)
  transcription   text,
  translation_fr  text
);

-- Lien article ↔ sources (avec précision de l'affirmation)
CREATE TABLE article_sources (
  article_locale_id uuid REFERENCES article_locales(id),
  source_id uuid REFERENCES sources(id),
  claim_anchor text,                  -- ancre dans le texte (id de bloc)
  locator text,                       -- page, minute 03:12…
  PRIMARY KEY (article_locale_id, source_id, claim_anchor)
);

-- ========== MÉDIAS ==========
CREATE TABLE media (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  kind        text NOT NULL,          -- image|audio|video|model3d|pano360|document
  storage_key text NOT NULL,
  original_mime text,
  duration_s  int,
  width int, height int,
  renditions  jsonb DEFAULT '[]',     -- [{kind:'opus_24k', key:'…', bytes:…}, …]
  alt_text    jsonb DEFAULT '{}',     -- {fr:'…', bci:'…'}  (accessibilité)
  caption     jsonb DEFAULT '{}',
  credits     text,
  license     text,
  uploaded_by uuid REFERENCES users(id),
  processing_state text DEFAULT 'pending',
  created_at  timestamptz DEFAULT now()
);

-- ========== RELATIONS ENTRE ARTICLES ==========
CREATE TABLE article_links (
  from_article uuid REFERENCES articles(id),
  to_article   uuid REFERENCES articles(id),
  relation     text,                  -- see_also|part_of|born_in|practiced_in|ingredient_of|…
  PRIMARY KEY (from_article, to_article, relation)
);

-- ========== TAXONOMIE ==========
CREATE TABLE domains (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), parent_id uuid, slug text UNIQUE, labels jsonb);
CREATE TABLE tags    (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), slug text UNIQUE, labels jsonb);
CREATE TABLE article_tags (article_id uuid, tag_id uuid, PRIMARY KEY(article_id, tag_id));
CREATE TABLE ethnic_groups (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), parent_id uuid, slug text UNIQUE, labels jsonb, language_codes text[]);

-- ========== WORKFLOW & MODÉRATION ==========
CREATE TABLE review_tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  revision_id uuid REFERENCES revisions(id),
  circle text NOT NULL,               -- local|cultural|academic|editorial
  assigned_to uuid REFERENCES users(id),
  decision text,                      -- approved|changes_requested|rejected|abstained
  comment text,
  decided_at timestamptz,
  created_at timestamptz DEFAULT now()
);
CREATE TABLE discussions (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), article_id uuid, thread jsonb, status text, created_at timestamptz DEFAULT now());
CREATE TABLE reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  target_type text, target_id uuid,
  reporter_id uuid REFERENCES users(id),
  reason text, details text,
  status text DEFAULT 'open', handled_by uuid, handled_at timestamptz
);
CREATE TABLE audit_log (
  id bigserial PRIMARY KEY, actor_id uuid, action text, target_type text, target_id uuid,
  meta jsonb, ip_hash text, at timestamptz DEFAULT now()
);

-- ========== ENGAGEMENT (Phase 2+) ==========
CREATE TABLE contributions_points (user_id uuid, action text, points int, ref_id uuid, at timestamptz DEFAULT now());
CREATE TABLE badges (code text PRIMARY KEY, labels jsonb);
CREATE TABLE user_badges (user_id uuid, badge_code text, awarded_at timestamptz DEFAULT now(), PRIMARY KEY(user_id, badge_code));
CREATE TABLE quizzes (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), article_id uuid, lang_code text, questions jsonb);

-- ========== INDEX CLÉS ==========
CREATE INDEX idx_articles_geo ON articles USING gist (location);
CREATE INDEX idx_territories_geom ON territories USING gist (geom);
CREATE INDEX idx_article_locales_lang ON article_locales (lang_code);
CREATE INDEX idx_articles_status ON articles (status) WHERE deleted_at IS NULL;
CREATE INDEX idx_titles_trgm ON article_locales USING gin (title gin_trgm_ops);
```

### 6.2 Format du corps d'article (`body` JSONB)
Document **structuré en blocs** (inspiré ProseMirror/TipTap), pas du HTML brut : permet de rendre en mode léger, audio, SMS, PDF.

```json
{
  "version": 1,
  "blocks": [
    { "id": "b1", "type": "paragraph", "content": [
        { "text": "L'attiéké est un couscous de manioc fermenté…" },
        { "text": "Ébrié", "link": { "article": "ebrie-peuple" } }
    ]},
    { "id": "b2", "type": "heading", "level": 2, "text": "Origine" },
    { "id": "b3", "type": "callout", "variant": "comprendre", "content": [ … ] },
    { "id": "b4", "type": "oral_quote", "source_id": "…", "text": "…", "lang": "bci", "media_id": "…" },
    { "id": "b5", "type": "proverb", "lang": "bci", "original": "…", "translation_fr": "…", "explanation": "…", "media_id": "…" },
    { "id": "b6", "type": "media", "media_id": "…", "layout": "inline" },
    { "id": "b7", "type": "map", "territory": "grand-bassam" },
    { "id": "b8", "type": "footnote_ref", "source_id": "…", "locator": "p. 45" }
  ]
}
```

Chaque bloc a un `id` stable → permet d'ancrer **sources, commentaires, audio synchronisé et validations par bloc**.

---

## 7. API (REST d'abord)

- Base : `/api/v1`, JSON, pagination par curseur, `Accept-Language` respecté, ETag/Cache-Control agressifs sur les lectures publiques.
- Documentation **OpenAPI 3.1** générée et versionnée dans le repo.
- Erreurs normalisées : RFC 9457 (`application/problem+json`).

### 7.1 Endpoints principaux (MVP)

| Méthode | Route | Rôle | Notes |
|---|---|---|---|
| GET | `/articles/{slug}?lang=bci&mode=light` | public | Renvoie la variante demandée + langues disponibles |
| GET | `/articles/{slug}/locales` | public | Liste des variantes et leur niveau de qualité |
| GET | `/search?q=&lang=&type=&territory=&has_audio=` | public | Multilingue, tolérance aux fautes, translittération |
| GET | `/geo/nearby?lat=&lng=&radius=&type=` | public | PostGIS |
| GET | `/territories/{slug}` / `/territories/{slug}/articles` | public | Hiérarchie + contenus |
| GET | `/media/{id}` | public | Redirection signée vers la rendition adaptée |
| POST | `/auth/otp/request` · `/auth/otp/verify` | public | Connexion par téléphone |
| POST | `/auth/login` · `/auth/refresh` · `/auth/logout` | public | — |
| POST | `/articles` | contributor | Création (brouillon) |
| PUT | `/articles/{id}/locales/{lang}` | contributor | Nouvelle révision |
| POST | `/revisions/{id}/submit` | contributor | Soumission à relecture |
| GET | `/review/queue` | reviewer+ | File filtrée par rôle/scope |
| POST | `/review/tasks/{id}/decision` | reviewer+ | approve / changes / reject |
| POST | `/sources` · `/sources/oral` | contributor | Oral = métadonnées obligatoires + consentement |
| POST | `/media/uploads` (reprise/chunk) | contributor | Upload résumable (tus.io) |
| POST | `/reports` | authentifié | Signalement |
| GET | `/packs/{territory}` | public | Manifest + liens du pack hors-ligne |
| GET | `/health` · `/version` | ops | — |

### 7.2 Exigences API
- Rate limiting par IP et par compte (Redis).
- Idempotency-Key sur les POST sensibles (uploads, soumissions).
- Uploads **résumables** (réseaux instables → indispensable).
- Aucune réponse publique ne doit exposer un contenu `restricted`/`sacred_hidden` (filtrage au niveau requête **et** test automatisé dédié).

---

## 8. Workflow éditorial

### 8.1 Machine à états d'une révision

```
draft ──submit──▶ in_review ──approve(local)──▶ cultural_review ──approve──▶ academic_review (optionnel selon type)
   ▲                  │                               │                         │
   └──changes_req─────┘◀───────changes_req────────────┘◀────changes_req────────┘
                                                                                  │
                                                                      editorial_polish ──▶ published
published ──new_revision──▶ (cycle) ; published ──dispute──▶ contested ──resolution──▶ published/archived
```

### 8.2 Cercles de validation

| Cercle | Qui | Ce qu'il vérifie | Obligatoire pour |
|---|---|---|---|
| 1. Relecture locale | Validateur régional/communautaire | Exactitude locale, noms, lieux, orthographe de la langue | Tous les articles |
| 2. Validation culturelle | Conseil des sages / détenteurs reconnus | Respect des savoirs, non-divulgation de restreint, justesse symbolique | Rituels, croyances, pratiques, oral_text, ethnic_group |
| 3. Validation académique | Expert universitaire | Rigueur historique/scientifique | Histoire, médecine traditionnelle, sciences |
| 4. Polissage éditorial | Éditeur | Style, cohérence, liens, accessibilité | Tous avant mise « à la une » |

### 8.3 Règles
- ✅ **SLA cibles** : relecture locale ≤ 7 jours (MVP), puis ≤ 3 jours.
- ✅ **Pas d'auto-validation** : un auteur ne peut pas valider sa propre révision.
- ✅ **Contenu sensible** (personne vivante controversée, conflit foncier, histoire récente politique) → passage obligatoire par un éditeur senior + droit de réponse.
- ✅ **Contestation** : n'importe quel utilisateur peut ouvrir une contestation motivée ; l'article affiche un bandeau « contesté » avec lien vers la discussion.
- ❓ Mécanisme de **départage** en cas de désaccord entre validateurs (vote pondéré ? arbitrage éditorial ?) à définir avec les comités.

### 8.4 Contribution assistée (pour détenteurs non écrivants) — **critique**

Parcours « **Collecteur** » : un collecteur formé enregistre le détenteur (audio/vidéo), remplit les métadonnées orales, obtient le consentement, **transcrit/traduit** (assisté par IA, toujours revu par un humain), puis soumet. Le détenteur est crédité comme **source et co-auteur**.

---

## 9. Exigences non fonctionnelles

### 9.1 Performance

| Métrique | Cible |
|---|---|
| TTFB page article (CDN chaud) | < 300 ms en Afrique de l'Ouest 🟡 |
| LCP mode léger (Slow 3G) | < 2,5 s |
| Poids mode léger | ≤ 50 Ko |
| API p95 (hors recherche) | < 200 ms |
| Recherche p95 | < 400 ms |
| Disponibilité | 99,5 % MVP → 99,9 % ensuite |

### 9.2 Accessibilité
WCAG 2.2 AA minimum ; navigation clavier ; lecteurs d'écran ; contrastes ; tailles de police réglables ; **alternatives audio** pour tout contenu ; textes alternatifs **dans la langue de la page** quand possible ; support des caractères API/diacritiques des langues ivoiriennes (UTF-8, normalisation NFC).

### 9.3 Sécurité
- OWASP ASVS niveau 2 comme référentiel.
- Mots de passe : Argon2id. OTP : expiration courte, limitation de tentatives, protection contre l'abus SMS (pumping).
- Chiffrement en transit (TLS 1.2+) et au repos (volumes + secrets).
- Modération des uploads : antivirus (ClamAV), contrôle MIME réel, strip EXIF (sauf géodonnées volontaires et consenties).
- Secrets via gestionnaire dédié (jamais dans le repo). Dépendances scannées (Dependabot/Trivy).
- Journal d'audit immuable pour actions sensibles (rôles, suppression, changement d'accès).
- Revue de sécurité avant chaque jalon public ; test d'intrusion avant le lancement public.

### 9.4 Savoirs restreints et protection culturelle ⚠

Niveaux d'accès sur chaque article **et** chaque média/source :

| `access_level` | Signification | Visibilité |
|---|---|---|
| `public` | Libre | Tous |
| `community` | Réservé aux membres vérifiés d'une communauté | Comptes avec appartenance validée |
| `restricted` | Résumé public, détail réservé | Résumé public ; détail aux validateurs/détenteurs |
| `sacred_hidden` | Existence documentée sans contenu | Jamais publié ; stub informatif uniquement |

Règles :
- Le retrait d'un consentement (`withdrawn`) entraîne le **retrait effectif** du contenu (soft-delete + purge des caches/CDN/packs hors-ligne sous 72 h).
- Les licences ouvertes s'accompagnent d'une **mention d'usage culturel** (étiquettes inspirées de Local Contexts / Traditional Knowledge labels). ❓ À valider juridiquement.
- Les enregistrements de personnes ne sont publiés qu'avec **consentement documenté**, plus strict pour les mineurs (jamais sans tuteur).

### 9.5 Données personnelles
- ✅ Minimisation : le téléphone et l'email ne sont jamais publics.
- ✅ Droit d'accès, de rectification, de suppression et de portabilité.
- ❓ Conformité à la **loi ivoirienne sur la protection des données à caractère personnel** (autorité : ARTCI) : analyse juridique à faire **avant** collecte de données utilisateurs. S'inspirer du RGPD comme niveau de référence.

### 9.6 Internationalisation (i18n/l10n)
- Interface d'abord en **français**, structure prête pour d'autres langues (ICU MessageFormat).
- Les **contenus** sont multilingues dès le MVP (modèle `article_locales`) ; l'**interface** suivra.
- Normalisation Unicode **NFC** ; recherche insensible aux accents **et** aux variantes d'orthographe (tables d'équivalence par langue, ex. ɔ/o, ɛ/e, ɲ/ny).
- Orthographes : pour chaque langue, définir une **orthographe de référence** et accepter les variantes. ❓ Dépend des comités linguistiques.
- Codes langue : ISO 639-3 ; `nouchi` n'ayant pas de code ISO stable, utiliser un code interne documenté.

---

## 10. Politique éditoriale (à respecter par humains **et** IA)

### 10.1 Ton et style 🟡
- **Voix active**, présent de narration quand pertinent, phrases courtes, vocabulaire accessible.
- **Chapeau** de 2–3 lignes obligatoire.
- Les **biographies** peuvent être narratives et humaines, **mais** : tout fait vérifiable est sourcé ; les citations sont attribuées (qui, quand, où) ; aucune anecdote non sourcée sur une personne vivante.
- Encadrés standards : « Comprendre », « Dans la pratique », « Variantes régionales », « Le saviez-vous ? » (sourcé).
- Noms propres : toujours donner la forme native + signification quand elle est connue + prononciation audio.

### 10.2 Neutralité et pluralité
- ✅ Sujets contestés : présenter **les perspectives documentées** (tradition orale, archives coloniales, travaux académiques) avec leurs sources, sans trancher par opinion de rédaction.
- ✅ Approche décoloniale = **rendre visibles les voix ivoiriennes**, pas réécrire l'histoire par affirmation. Les archives coloniales restent citées comme sources à lire de façon critique.
- ✅ Politique contemporaine : neutralité stricte, faits sourcés, droit de réponse.
- ✅ Aucun contenu haineux, ethniciste, ou incitant à la violence ; la description d'un conflit n'est pas son apologie.

### 10.3 Règle d'or des sources
> **Aucune affirmation factuelle importante sans source** (écrite **ou** orale avec métadonnées). Une source inventée ou non vérifiable est une faute éditoriale grave.

---

## 11. Rôles et permissions (RBAC + scopes)

| Capacité | Lecteur | Contrib. | Relecteur local | Validateur culturel | Expert acad. | Éditeur | Modérateur | Admin |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| Lire contenu public | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ |
| Créer/modifier brouillon | | ✔ | ✔ | ✔ | ✔ | ✔ | | ✔ |
| Uploader média/source | | ✔ | ✔ | ✔ | ✔ | ✔ | | ✔ |
| Valider cercle 1 (dans son scope) | | | ✔ | | | ✔ | | ✔ |
| Valider cercle 2 | | | | ✔ | | | | ✔ |
| Valider cercle 3 | | | | | ✔ | | | ✔ |
| Publier / mettre à la une | | | | | | ✔ | | ✔ |
| Masquer/supprimer contenu signalé | | | | | | | ✔ | ✔ |
| Gérer rôles / config | | | | | | | | ✔ |
| Accès contenu `restricted` | | | ✔ | ✔ | ✔ | | | ✔ |

Les rôles de validation sont **scopés** (territoire / domaine / langue) via `user_roles`.

---

## 12. Géolocalisation et cartographie
- Fond de carte : **OpenStreetMap** (tuiles auto-hébergées ou fournisseur), **vectoriel léger** si possible (PMTiles/MapLibre).
- Hiérarchie administrative : importer depuis sources ouvertes (OSM, Wikidata, données officielles) puis **corriger avec les comités locaux** (les noms de villages/quartiers manquent souvent).
- Mode « près de moi » : demande de permission explicite, **jamais** de stockage de position précise sans consentement.
- Carte hors-ligne : packs de tuiles par région.
- Confidentialité : pour lieux sacrés/fragiles, **flouter la position** (niveau commune) selon `access_level`.

---

## 13. Hors-ligne et canaux alternatifs

### 13.1 PWA / packs hors-ligne
- Manifest de pack : liste d'articles, médias (audio Opus basse définition par défaut), index de recherche local (version allégée), tuiles de carte.
- Mise à jour différentielle ; vérification d'intégrité (hash) ; taille affichée avant téléchargement.

### 13.2 SMS / USSD (Phase 3) ❓
- Passerelle via un agrégateur (ex. Africa's Talking ou opérateurs locaux) — **fournisseur à valider** en Côte d'Ivoire.
- **Les shortcodes et codes USSD cités dans les premiers documents (ex. « *123# », « 1234 ») sont de simples exemples**, pas des numéros réels. L'obtention d'un code court/USSD passe par les opérateurs et l'ARTCI : démarches, délais et coûts à instruire.
- Réponses SMS : ≤ 160 car. (GSM-7) ; attention aux caractères non-GSM (ɔ, ɛ, ɲ) qui basculent en UCS-2 (70 car.) → prévoir translittération.

### 13.3 WhatsApp (Phase 2)
- WhatsApp Business Platform (API officielle) : tarification par conversation, modèles de message à faire approuver. Prévoir un budget et la conformité aux conditions d'usage.

---

## 14. Médias : pipeline de traitement
1. Upload résumable → stockage brut (bucket privé).
2. Job asynchrone : antivirus → validation MIME → extraction métadonnées.
3. Images : génération de renditions (320/640/1280, WebP/AVIF) + blurhash.
4. Audio : normalisation du volume (EBU R128), Opus 24 kbps + MP3 repli, waveform, **transcription automatique** (brouillon) à relire.
5. Vidéo : HLS multi-débits + piste audio seule + sous-titres.
6. Publication des renditions sur CDN ; `processing_state = ready`.
7. Rejeu possible si échec (idempotent, file BullMQ avec retries et dead-letter).

---

## 15. IA : cadre d'usage

### 15.1 Usages prévus

| Usage | Phase | Garde-fous |
|---|---|---|
| Aide à la transcription audio → texte | 2 | Toujours relue par humain ; marquée « brouillon automatique » |
| Aide à la traduction FR ↔ langues locales | 2–3 | Qualité souvent faible pour langues peu dotées → **jamais publié sans relecture par un locuteur** |
| Résumés / chapeaux proposés | 2 | Suggestion uniquement |
| Détection de doublons, liens manquants | 2 | Suggestion |
| Modération (toxicité, spam) | 2 | Décision finale humaine pour cas ambigus |
| Assistant « Griot » (Q/R) | 3 | RAG **uniquement** sur contenu validé et public ; citations obligatoires |

### 15.2 Règles impératives pour tout composant IA
1. **Ne jamais inventer** de faits, citations, sources, témoignages, noms de contributeurs ou d'URL.
2. **Citer** les articles/sources utilisés ; si l'information n'est pas dans le corpus : le dire clairement.
3. **Ne jamais exposer** de contenu `restricted`/`community`/`sacred_hidden` ni le déduire.
4. **Signaler l'incertitude** surtout sur les langues peu dotées (baoulé, dioula, bété, sénoufo, etc.) : ne pas présenter une traduction automatique comme fiable.
5. **Pas de génération de « voix » de griots ou d'anciens** (clonage vocal) ni de faux témoignages. Les voix sont toujours des enregistrements réels et consentis.
6. **Étiquetage** : tout contenu produit ou assisté par IA est marqué comme tel dans les métadonnées.
7. **Neutralité** sur sujets politiques/ethniques sensibles ; refuser l'incitation à la haine.
8. **Respect de la vie privée** : ne pas retrouver/inférer d'informations personnelles.
9. En cas de doute culturel → **escalade vers un validateur humain**.

### 15.3 Architecture RAG (Phase 3)
- Chunking par bloc/section avec métadonnées (langue, territoire, type, access_level).
- Embeddings multilingues stockés en **pgvector** ; filtre **obligatoire** `access_level='public' AND status='published'`.
- Réponse structurée : `answer`, `citations[]`, `confidence`, `suggested_articles[]`.
- Évaluation continue sur un jeu de questions de référence rédigé par les comités (fidélité, absence d'hallucination, respect des restrictions).

---

## 16. Organisation du dépôt et conventions de code

### 16.1 Monorepo 🟡

```
ivoirepedia/
├─ apps/
│  ├─ web/            # Next.js (lecture + contribution)
│  ├─ api/            # NestJS (modules métier)
│  ├─ worker/         # jobs médias, indexation, notifications
│  └─ admin/          # back-office (peut être une route protégée de web)
├─ packages/
│  ├─ ui/             # design system (composants accessibles)
│  ├─ schema/         # types partagés, validation (zod), OpenAPI
│  ├─ i18n/           # langues, normalisation, translittération
│  └─ editor/         # éditeur par blocs (TipTap/ProseMirror)
├─ infra/             # docker, compose, IaC, scripts de déploiement
├─ db/                # migrations SQL, seeds (langues, territoires, taxonomie)
├─ docs/              # ADR, guides, specs
└─ .github/workflows/
```

### 16.2 Conventions
- TypeScript strict ; ESLint + Prettier ; commits **Conventional Commits** ; branches `main` (protégée) + `feat/*`, `fix/*`.
- Revue de code obligatoire (≥ 1 relecteur) ; CI verte requise (lint, types, tests, a11y, budget de poids).
- Migrations **versionnées et réversibles** ; jamais de modification manuelle de la base en production.
- Tests : unitaires (logique métier), intégration (API + DB), e2e (parcours critiques), **tests de permissions** (matrice §11), tests de non-fuite de contenu restreint.
- Documentation des décisions : **ADR** (voir §20).

### 16.3 Definition of Done (par ticket)
- [ ] Critères d'acceptation validés
- [ ] Tests ajoutés/mis à jour et passants
- [ ] Budget de poids respecté (mode léger)
- [ ] Accessibilité vérifiée (axe + clavier)
- [ ] Permissions et niveaux d'accès testés
- [ ] Textes en français relus ; pas de chaîne en dur (i18n)
- [ ] Journal d'audit alimenté si action sensible
- [ ] Doc/ADR/OpenAPI mis à jour
- [ ] Testé sur appareil Android d'entrée de gamme + profil Slow 3G (pour le front)

---

## 17. Design et UX

- **Mobile-first**, navigation à une main, grandes zones tactiles (≥ 44 px).
- **Identité** : s'inspirer de la palette nationale (orange, blanc, vert) et de motifs textiles (kita, pagne baoulé, wax) **avec modération** et avec l'accord des artisans/communautés concernées pour les motifs porteurs de sens. 🟡
- Lecture : typographie confortable, contraste élevé, mode sombre, taille réglable.
- **Sélecteur de langue** toujours visible ; indication claire du niveau de qualité d'une variante (« stub », « validée »).
- **Bouton « Écouter »** sur chaque article (audio humain si dispo, sinon TTS FR ; sinon masqué).
- **États de chargement** et **états d'erreur réseau** explicites ; actions en file d'attente quand hors-ligne (contribution différée).
- Parcours de contribution **très simplifié** pour les non-experts (formulaire guidé, dictée vocale, photo/audio d'abord).
- Recherche d'usages : ateliers et tests avec utilisateurs **réels hors Abidjan** dès le prototype.

---

## 18. Gamification (Phase 2+) — garde-fous
- Récompenser la **qualité** (articles validés, sources apportées) plutôt que le volume brut.
- Éviter les incitations qui poussent à inventer des sources ou à publier vite.
- Reconnaissance **non monétaire** par défaut ; rémunération possible pour collecteurs/validateurs via budget dédié. ❓

---

## 19. Feuille de route (indicative 🟡)

| Phase | Durée | Objectifs | Sortie |
|---|---|---|---|
| **0. Cadrage** | 1–2 mois | Cahier des charges final, comités, juridique, choix infra, design system, 3 régions pilotes | Docs validés, équipe constituée |
| **1. MVP** | ~6 mois | Lecture multilingue, contribution + workflow, sources orales, recherche, carte de base, PWA/mode léger, ~300–500 articles de qualité, 3 langues (fr + 2) | Bêta fermée (≈100 testeurs) |
| **2. Lancement** | ~6 mois | Ouverture publique, app Android, packs hors-ligne, WhatsApp, quiz/parcours, ~1 000+ articles, 5 langues | Version 1.0 publique |
| **3. Expansion** | 12 mois | SMS/USSD, assistant « Griot » (RAG), 360°/3D, API publique, ~10 langues | Écosystème ouvert |
| **4. Pérennisation** | continu | Modules économiques (formations, artisans), intégration scolaire, réplication régionale | Modèle soutenable |

> ⚠ Les volumes d'articles et d'utilisateurs avancés dans les premières discussions (50 000 articles, 1 M d'utilisateurs) sont des **ambitions de long terme**, pas des engagements. Le goulot n'est pas la technique mais la **production de contenu validé**.

### 19.1 MVP : backlog initial par épopées

| Épopée | Contenu |
|---|---|
| E1 Fondations | Repo, CI/CD, environnements, auth, rôles, audit |
| E2 Contenu | Modèle article/locales/révisions, éditeur par blocs, gabarits par type |
| E3 Langues | Référentiel de langues, bascule, normalisation/recherche multi-orthographes |
| E4 Sources | Sources écrites + orales, consentement, citations par bloc |
| E5 Médias | Upload résumable, pipeline audio/image, lecteur audio léger |
| E6 Workflow | Files de relecture, décisions, contestation, notifications |
| E7 Recherche | Indexation Meilisearch, facettes, suggestions |
| E8 Géo | Territoires, import OSM/Wikidata, carte, « près de moi » |
| E9 Léger/Hors-ligne | Mode léger, Service Worker, pack hors-ligne basique |
| E10 Modération | Signalement, outils modérateur, règles automatiques de base |
| E11 Qualité | Budgets de perf, a11y, tests de permissions, observabilité |

---

## 20. Registre des décisions (ADR initial)

| # | Décision | Statut | Raison |
|---|---|---|---|
| ADR-001 | Monolithe modulaire plutôt que microservices | ✅ | Petite équipe, vitesse, coût |
| ADR-002 | PostgreSQL + PostGIS comme source de vérité | ✅ | Relationnel + géo + JSONB |
| ADR-003 | Contenu stocké en **blocs JSON** (pas HTML brut) | ✅ | Multi-rendu (léger, audio, SMS, PDF), ancrage des sources |
| ADR-004 | **Un article / N variantes linguistiques** | ✅ | Cœur de la différenciation |
| ADR-005 | PWA avant app native | 🟡 | Coût, hors-ligne suffisant en MVP |
| ADR-006 | Meilisearch au démarrage | 🟡 | Simplicité d'opération |
| ADR-007 | Opus pour l'audio par défaut | ✅ | Qualité voix à très bas débit |
| ADR-008 | Niveaux d'accès culturels (`access_level`) natifs | ✅ | Protection des savoirs |
| ADR-009 | IA = assistance, jamais autorité éditoriale | ✅ | Fiabilité, éthique |
| ADR-010 | Licence code / licence contenu | ❓ | Voir §21 |

> Chaque nouvelle décision structurante = un fichier `docs/adr/NNN-titre.md` (contexte, options, décision, conséquences).

---

## 21. Questions ouvertes (à traiter en priorité)

### Juridique et gouvernance
1. ❓ **Forme juridique** de la structure porteuse (association, fondation, société à mission, coopérative) et gouvernance des comités.
2. ❓ **Licence du contenu** : CC-BY-SA classique vs licence adaptée aux savoirs traditionnels ; articulation avec les droits des communautés et le droit d'auteur local (BURIDA pour la musique).
3. ❓ **Licence du code** (AGPL, MIT, Apache-2.0…).
4. ❓ Conformité **données personnelles** locales (ARTCI) et contrats de consentement types.
5. ❓ Statut des **enregistrements de mineurs** et des personnes vulnérables.

### Contenu et comités
6. ❓ Composition et mode de désignation des **comités par aire culturelle** ; critère de légitimité d'un « sage ».
7. ❓ **Orthographes de référence** par langue ; qui arbitre ?
8. ❓ Traitement des **sujets politiquement sensibles** (histoire récente, conflits) : procédure et comité éthique.
9. ❓ Stratégie pour **amorcer** le contenu : partenariats universités/musées, imports (Wikidata/Commons — vérifier licences), campagnes de collecte.

### Technique et opérations
10. ❓ Hébergement et fournisseur définitifs ; coûts de bande passante/CDN en Afrique.
11. ❓ Faisabilité, coûts et délais **SMS/USSD/WhatsApp** en Côte d'Ivoire.
12. ❓ Choix du **TTS** pour le français ivoirien ; viabilité d'un TTS pour langues locales (très probablement : enregistrements humains).
13. ❓ Modèle de **sauvegarde** et de continuité (que devient l'encyclopédie si la structure disparaît ? → archivage ouvert, miroirs).

### Économie
14. ❓ Modèle de revenus : le freemium/marketplace est une **piste**, pas une certitude. Le budget (~250 M FCFA année 1) et les prix (ex. 2 000 FCFA/mois) évoqués au départ sont des **ordres de grandeur non validés** à rebâtir avec devis réels.
15. ❓ Rémunération des collecteurs, validateurs et détenteurs de savoirs (équité, reconnaissance, partage de valeur).

---

## 22. Risques majeurs (vue dev)

| Risque | Impact | Parade technique/projet |
|---|---|---|
| Pénurie de contenu validé | Très élevé | Priorité à l'outillage de **collecte assistée**, partenariats, objectifs réalistes |
| Fuite de contenu restreint | Très élevé | Filtrage serveur strict, tests automatisés, purge de caches, revue de sécurité |
| Qualité de traduction/transcription IA sur langues peu dotées | Élevé | Relecture humaine obligatoire, étiquetage, ne jamais publier en l'état |
| Faible connectivité → abandon | Élevé | Budgets de poids en CI, hors-ligne, audio, tests terrain |
| Dépendance à un seul fournisseur (SMS, cloud) | Moyen | Abstractions, plan B, export de données |
| Sur-ingénierie précoce | Moyen | Monolithe, MVP strict, ADR, revues de périmètre |
| Controverses ethniques/politiques | Élevé | Comité éthique, workflow dédié, neutralité, modération |
| Dette de modération (vandalisme, spam) | Moyen | Workflow de validation avant publication, rate limits, outils modérateur |
| Perte de données | Très élevé | 3-2-1, tests de restauration trimestriels |

---

## 23. Instructions spécifiques pour une IA qui intervient sur ce projet

> Cette section est destinée à tout assistant IA (codage, rédaction, analyse) utilisé par l'équipe.

**Rôle** : assister, jamais décider seul des questions culturelles, juridiques ou éditoriales.

**Toujours** :
- Lire ce document avant d'agir ; respecter les ✅, traiter les 🟡 comme modifiables, signaler les ❓ rencontrés.
- Proposer du code **accessible, léger, testé**, conforme aux conventions §16.
- Penser **mobile + 2G + hors-ligne** à chaque proposition.
- Utiliser le modèle de données §6 ; si une évolution est nécessaire, proposer une **migration** et un **ADR**.
- Écrire les textes utilisateur en **français clair** ; ne jamais coder de chaînes en dur.
- Préciser les **hypothèses** et les **limites** de tes réponses.

**Jamais** :
- Inventer des sources, citations, noms de personnes, de communautés, d'institutions, d'URL, d'adresses email ou de numéros (⚠ les contacts et codes courts cités dans des brouillons antérieurs étaient **illustratifs**, pas réels).
- Produire des contenus culturels (rituels, croyances, savoirs sacrés, généalogies) **sans** les marquer comme « à valider par un détenteur légitime ».
- Contourner les niveaux d'accès (§9.4) ou exposer des données personnelles.
- Présenter une traduction automatique d'une langue ivoirienne comme fiable.
- Ajouter de la publicité, du tracking tiers ou des dépendances lourdes sans ADR.
- Cloner ou imiter la voix de personnes réelles.

**Format de réponse attendu** : concis, structuré, avec exemples exécutables ; indiquer clairement ce qui est **fait**, **supposé** et **à valider**.

---

## 24. Check-list d'onboarding (premier jour / première semaine)

**Jour 1**
- [ ] Lire ce document en entier (≈ 45 min)
- [ ] Accès au dépôt, à la CI, au gestionnaire de secrets, au canal d'équipe
- [ ] Cloner le monorepo, lancer l'environnement local (Docker Compose : Postgres/PostGIS, Redis, Meilisearch, MinIO)
- [ ] Charger les seeds (langues, taxonomie, échantillon de territoires)

**Semaine 1**
- [ ] Lire ADR-001 à ADR-010
- [ ] Parcourir 3 articles de démonstration dans les 3 modes (standard, léger, hors-ligne)
- [ ] Mesurer le poids d'une page avec le profil Slow 3G
- [ ] Réaliser un petit ticket « good first issue » jusqu'à la Definition of Done
- [ ] Rencontrer un membre d'un comité (histoire/langues) pour comprendre le terrain

---

## 25. Annexes

### 25.1 Exemple d'article structuré (extrait JSON)

```json
{
  "slug": "attieke",
  "type": "dish",
  "structured": {
    "main_ingredient": "manioc",
    "origin_peoples": ["ebrie", "adjoukrou", "abbey"],
    "region_tags": ["lagunes", "sud"],
    "typical_pairings": ["poisson-braise", "garba-thon"]
  },
  "primary_territory": "grand-bassam",
  "access_level": "public",
  "locales": {
    "fr": {
      "title": "Attiéké",
      "summary": "Semoule de manioc fermentée, base de nombreux repas ivoiriens.",
      "quality_level": "standard"
    },
    "nou": { "title": "Attiéké", "quality_level": "stub" }
  }
}
```

> Exemple **illustratif** : le contenu réel doit être rédigé et validé avec les communautés concernées.

### 25.2 Exemple de métadonnées d'une source orale

```json
{
  "kind": "oral",
  "narrator_name": "[Nom du détenteur — à renseigner]",
  "narrator_role": "[ex. griot, productrice d'attiéké]",
  "narrator_community": "[communauté]",
  "recorded_at": "AAAA-MM-JJ",
  "recorded_place": "[village / commune]",
  "context": "[entretien, cérémonie…]",
  "language_code": "[ISO 639-3]",
  "consent_status": "public_attributed",
  "transcription": "[…]",
  "translation_fr": "[…]"
}
```

### 25.3 Variables d'environnement type (`.env.example`)

```
DATABASE_URL=postgres://ivp:ivp@localhost:5432/ivoirepedia
REDIS_URL=redis://localhost:6379
MEILI_URL=http://localhost:7700
MEILI_MASTER_KEY=change-me
S3_ENDPOINT=http://localhost:9000
S3_ACCESS_KEY=change-me
S3_SECRET_KEY=change-me
S3_BUCKET_RAW=ivp-raw
S3_BUCKET_PUBLIC=ivp-public
JWT_SECRET=change-me
SMS_PROVIDER=stub
WHATSAPP_ENABLED=false
FEATURE_GRIOT_ASSISTANT=false
```

### 25.4 Références d'inspiration
Wikipédia/MediaWiki et Wikidata (modèle contributif, données structurées) ; Wikimedia Commons ; OpenStreetMap ; Kamusi (langues africaines) ; Mukurtu CMS et *Local Contexts* (gestion des savoirs autochtones et niveaux d'accès) ; iNaturalist (science participative géolocalisée) ; StoryCorps (histoires orales). → À consulter pour les bonnes pratiques, **sans copier** ; vérifier les licences avant toute réutilisation.

---

### Historique du document

| Version | Date | Auteur | Changements |
|---|---|---|---|
| 1.0 | nov. 2026 | Cadrage initial | Création |

*Fin du document — toute modification majeure doit passer par une PR et, si elle change une décision, un ADR.*
