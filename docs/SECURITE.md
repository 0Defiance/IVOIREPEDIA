# IVOIREPEDIA — Revue de sécurité

> **Objet :** état des règles de la section 13 du CONTEXT, en-têtes HTTP servis
> en production, et ce qui reste ouvert avant une bêta publique.
>
> **Version :** 1.1 · **Dernière vérification en production :** 28 novembre 2026
> (site public `https://ivoirepedia.alwaysdata.net`, CSP bloquante en service) ·
> **Compléments :** [`DEPLOIEMENT.md`](DEPLOIEMENT.md) §6 et §8,
> [`SUIVI_DEVELOPPEMENT.md`](SUIVI_DEVELOPPEMENT.md) séance 136.

---

## 1. En-têtes HTTP

Ils sont posés dans `backend/public/.htaccess` (`mod_headers`, `Header always
set`) : cette racine unique sert la coquille Flutter, les articles pré-rendus,
l'API et le panneau, donc un seul endroit couvre tout le site.

| En-tête | Valeur | Effet |
|---|---|---|
| `Strict-Transport-Security` | `max-age=31536000` | Un an sans repasser par HTTP. Ignoré en HTTP simple, posé sans condition. |
| `X-Frame-Options` | `SAMEORIGIN` | Le site ne se laisse pas encadrer par un site tiers (clickjacking). |
| `Content-Security-Policy` | voir §1.1 | **Mode bloquant** : le navigateur refuse tout ce que la politique n'autorise pas (script en ligne, hôte d'image inconnu). |
| `X-Content-Type-Options` | `nosniff` | Le navigateur ne devine pas un type non annoncé. |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | L'adresse complète ne fuit pas vers les sites tiers (partage, liens sortants). |

**HTTPS forcé.** Toute requête en HTTP simple reçoit un `301` vers la même
adresse en `https://` (API comprise), avant toute autre règle de réécriture.
La condition double (`HTTPS != on` **et** `X-Forwarded-Proto != https`) évite la
boucle : un fichier de diagnostic temporaire a montré que sur TLS Apache donne
`HTTPS=on` et le proxy `X-Forwarded-Proto: https`, et qu'en HTTP simple les deux
manquent.

**Cookies du panneau** (`/admin`) : `secure`, `httponly`, `samesite=lax` sur la
session ; le jeton `XSRF-TOKEN` reste lisible par le JavaScript de la page
(c'est son rôle) mais porte `secure` et `samesite=lax`.

### 1.1 Une CSP bloquante, et ce qu'il a fallu changer

La politique a d'abord été servie en `Report-Only` (séance 136) : Flutter Web
**compile du WebAssembly** (`'wasm-unsafe-eval'`), injecte ses feuilles de style
à la volée (`'unsafe-inline'` côté styles) et manipule des images et des polices
en `data:` et `blob:`. Depuis le 28 novembre 2026 (séance 142), elle est servie
en mode **bloquant** — `Content-Security-Policy`, sans `report-uri` : la console
du navigateur reste le seul rapport, ce qui suffit tant que le site n'a pas de
télémétrie.

Trois choses cassaient sous la politique appliquée ; elles ont été corrigées à
la source plutôt qu'en élargissant `script-src` :

- **deux scripts en ligne** : la couverture de lancement de `app/web/index.html`
  (et ses attributs `onload`/`onerror` sur la balise du chargeur) est devenue
  `app/web/loading.js`, qui crée lui-même la balise `flutter_bootstrap.js` et
  s'abonne à ses événements ; le formulaire d'article du panneau est devenu
  `backend/public/admin/article-form.js`, qui lit les compteurs dans le DOM au
  lieu de les recevoir d'un script injecté par Blade ;
- **les couvertures d'articles** sont hébergées par Wikimedia (75 en production
  le 28 novembre 2026 : 19 sur `upload.wikimedia.org`, 56 sur
  `thumb.wikimedia.org`) : sans ces deux hôtes dans `img-src`, elles
  disparaîtraient ;
- le bloc **JSON-LD** des pages pré-rendues est conservé : c'est un bloc de
  données, non exécuté, auquel la CSP ne s'applique pas.

La politique servie aujourd'hui :

```
default-src 'self';
script-src 'self' 'wasm-unsafe-eval';
style-src 'self' 'unsafe-inline';
img-src 'self' data: blob: https://upload.wikimedia.org https://thumb.wikimedia.org;
font-src 'self' data:;
connect-src 'self';
media-src 'self' blob:;
worker-src 'self' blob:;
frame-ancestors 'self';
base-uri 'self';
form-action 'self';
object-src 'none'
```

`script-src` reste `'self'` : ni `'unsafe-inline'`, ni `'unsafe-eval'`. Une
régression (script en ligne réintroduit, hôte d'image retiré) est signalée par
`backend/tests/Feature/Site/CspTest.php`, qui lit le `.htaccess` réellement
déployé et le HTML rendu du panneau comme d'une page d'article.

---

## 2. Checklist CONTEXT §13

« Vérifié » = contrôlé en production le 28 novembre 2026, pas seulement en test.

| Menace | Règle du CONTEXT | État | Preuve / écart |
|---|---|---|---|
| Injection SQL | Eloquent / Query Builder, `DB::raw` lié | ✅ | `GET /api/v1/search?q=' OR 1=1--` → `200`, JSON valide, `total: 0` (aucune fuite) |
| XSS | Contenu JSON rendu par Flutter, HTML serveur nettoyé | ✅ | `GET /api/v1/search?q=<script>alert(1)</script>` → `application/json`, la requête est renvoyée échappée (`<\/script>`) ; les pages pré-rendues passent par Blade (échappement `{{ }}`) |
| CSRF | `SameSite=Lax` + jetons sur les mutations | ✅ | Cookie de session `samesite=lax` ; mutations de l'API protégées par jeton porteur, pas par cookie |
| Mots de passe | `Hash::make`, ≥ 10 caractères, jamais loggés | ✅ | 10 cas dans `tests/Feature/Api/AuthTest.php` ; `422` vérifié en production sur un corps vide |
| Brute-force | `RateLimiter` sur `/login`, `/register`, `/forgot-password` | ✅ | 12 tentatives de connexion → `422, 422` puis **`429`** jusqu'à la fin de la fenêtre |
| Énumération de comptes | Réponses identiques | ✅ | `POST /auth/forgot-password` répond pareil pour un compte connu et inconnu (`PasswordResetService`) |
| Jetons (reset) | ≥ 32 octets, hachés, usage unique, expiration | ✅ | `PasswordResetService` : `token_hash`, consommation unique, expiration |
| Upload | MIME et taille serveur, hors racine web | ➖ | Aucun téléversement n'existe encore (l'image de couverture est une adresse) : à traiter avec le chantier médias |
| Autorisation | Service + Policy, cas « A accède à B » testé | ✅ | `401` sans jeton (`/auth/me`), `302` vers `/admin/connexion` sans session ; Policies couvertes par `tests/Feature/Admin/*` |
| Secrets | `.env` hors dépôt, jamais servi, `config:cache` | ✅ | `/.env`, `/backend/.env` et `/storage/logs/laravel.log` renvoient la coquille Flutter, jamais le contenu ; `config:cache` actif |
| En-têtes HTTP | HTTPS forcé, HSTS, CSP raisonnable, nosniff | ✅ | §1 : `301` depuis HTTP et **cinq** en-têtes, dont la CSP **bloquante** depuis la séance 142 (`CspTest` : 4 cas) |
| Dépendances | Dependabot + `composer audit` en CI | ✅ | `composer audit` trouvait **13 avis sur 5 paquets** (framework 13.39.0, Symfony 7.4.22) ; montée en 13.44.1 / 7.4.25 → « No security vulnerability advisories found » ; `.github/dependabot.yml` (composer, pub, actions) et étape `composer audit --locked` en CI |
| Sauvegardes | Quotidienne dès la première semaine, restauration testée | ✅ | `DEPLOIEMENT.md` §8 : dump quotidien automatique, restauration essayée dans `ivoirepedia_dev` |

**Erreurs en production** : `APP_DEBUG=false` ; `/api/v1/rien` renvoie un `404`
JSON (`{"message": "The route api/v1/rien could not be found."}`), sans trace ni
chemin de fichier.

---

## 3. Ce qui reste ouvert

| Point | Pourquoi ce n'est pas fait | Échéance proposée |
|---|---|---|
| `Permissions-Policy`, `Cross-Origin-Opener-Policy` | Non demandés, effet nul tant que le site ne charge rien de tiers | Plus tard |
| Mots de passe compromis (Have I Been Pwned) | Hors MVP (`ADR-003`, périmètre §3.2) | V2 |
| 2FA | Explicitement hors MVP (CONTEXT §3.2) | V2 |
| Suppression de compte en libre-service | Exigée par la loi 2013-450 citée au §13 ; aujourd'hui une demande passe par le panneau admin | Avant la bêta publique |
| Identité nominative du responsable de publication | La page `/mentions-legales` nomme l’éditeur et l’hébergeur et dit qui répond des contenus, mais pas la personne ; le nom sera publié à la même place | Avant la bêta publique |
| Déclaration ARTCI | Obligation juridique, pas technique ; à valider avec un juriste | Avant la bêta publique |
| Copie hors-site des sauvegardes | Règle 3-2-1 non satisfaite par un seul serveur | Avant la bêta publique |

---

## 4. Rejouer la vérification

```bash
B=https://ivoirepedia.alwaysdata.net
curl -sI $B/ | grep -iE "x-frame-options|content-security|x-content-type|referrer-policy|strict-transport"  # 5 en-têtes
curl -sI http://ivoirepedia.alwaysdata.net/ | head -3          # 301 vers https
curl -s -o /dev/null -w "%{http_code}\n" $B/api/v1/auth/me      # 401
for i in $(seq 1 12); do curl -s -o /dev/null -w "%{http_code} " -X POST \
  $B/api/v1/auth/login -H 'Content-Type: application/json' \
  -d '{"email":"inconnu@ivoirepedia.test","password":"mauvais-mot-de-passe"}'; done  # 429
curl -s "$B/api/v1/search?q=%27%20OR%201%3D1--" | head -c 80    # JSON, pas d'erreur SQL
curl -s "$B/.env" | head -c 40                                  # coquille Flutter, pas le .env
cd backend && composer audit --locked --no-interaction           # aucun avis
```
