# IVOIREPEDIA — Déploiement sur Alwaysdata + Mailjet

> **Objet :** mettre le backend Laravel en ligne sur un hébergement mutualisé Alwaysdata **dédié à IVOIREPEDIA**, avec sa base MySQL et ses emails transactionnels Mailjet.
>
> **Complément local :** [`INSTALLATION.md`](INSTALLATION.md). **État réel :** [`SUIVI_DEVELOPPEMENT.md`](SUIVI_DEVELOPPEMENT.md).
>
> **Version :** 2.5 · **Dernière mise à jour :** 28 novembre 2026
>
> **Convention de lecture** : `ivoirepedia` désigne l'identifiant du compte Alwaysdata. S'il diffère, remplacer cette valeur partout (hôtes, bases, chemins) — le raisonnement ne change pas.

---

## Sommaire

1. [Un compte dédié, sans partage](#1-un-compte-dédié-sans-partage)
2. [Préparer le compte Alwaysdata](#2-préparer-le-compte-alwaysdata)
3. [Premier déploiement du backend](#3-premier-déploiement-du-backend)
4. [Emails transactionnels avec Mailjet](#4-emails-transactionnels-avec-mailjet)
5. [Déploiements suivants](#5-déploiements-suivants)
6. [Vérifications après déploiement](#6-vérifications-après-déploiement)
7. [Limites et pièges connus](#7-limites-et-pièges-connus)
8. [Sauvegardes et restauration](#8-sauvegardes-et-restauration)

---

## 1. Un compte dédié, sans partage

IVOIREPEDIA possède **son propre compte d'hébergement**. Aucun site, aucune base, aucun identifiant n'est partagé avec un autre projet.

| Élément | Valeur |
|---|---|
| Compte Alwaysdata | `ivoirepedia` (identifiant du compte, distinct de tout autre projet) |
| Adresse gratuite | `ivoirepedia.alwaysdata.net` — l'adresse `<compte>.alwaysdata.net` est attribuée au compte à sa création |
| Dossier de déploiement | `~/ivoirepedia/` (dans `/home/ivoirepedia/`) |
| Bases MySQL | `ivoirepedia_prod` (production) et `ivoirepedia_dev` (poste de travail) |
| Utilisateur MySQL | `ivoirepedia_app`, droits limités à ces deux bases |
| phpMyAdmin | <https://phpmyadmin.alwaysdata.com>, avec **l'utilisateur MySQL du compte** — jamais celui d'un autre projet |
| Mailjet | Compte IVOIREPEDIA, expéditeur `no-reply@ivoirepedia.ci` |

**Pourquoi un compte dédié** : sur un compte partagé, un seul domaine gratuit existe (`<compte>.alwaysdata.net`) et il est déjà occupé ; les adresses dérivées sont refusées par le panneau. Un compte dédié redonne l'adresse `ivoirepedia.alwaysdata.net`, isole les quotas, les sauvegardes et les identifiants, et permet de changer de formule ou de résilier sans impacter un autre projet.

> **Règle** : un projet = un compte = ses bases = ses clés. Toute exception doit être écrite ici et dans le CONTEXT (ADR-008).

---

## 2. Préparer le compte Alwaysdata

Ces étapes se font **dans le panneau** (`https://admin.alwaysdata.com`), pas en SSH.

### 2.1 Version de PHP

`Environment > PHP` → choisir la version la plus récente ≥ 8.3 compatible avec Laravel 13. C'est la version utilisée en ligne de commande et par les tâches planifiées.

**Constaté le 3 novembre 2026** sur l'hébergement Alwaysdata : PHP **8.4.27** en CLI, Composer en `/usr/bin/composer`. 8.4 convient à Laravel 13, aucune action nécessaire.

### 2.2 Bases MySQL

`Databases > MySQL` → créer **deux bases** et **un utilisateur** :

| Nom saisi dans le panneau | Nom complet | Usage |
|---|---|---|
| `prod` | `ivoirepedia_prod` | Production |
| `dev` | `ivoirepedia_dev` | Développement (poste de travail) |

Le panneau **préfixe automatiquement** le nom saisi par l'identifiant du compte : saisir `prod`, pas `ivoirepedia_prod`.

Puis un utilisateur `app` (nom complet `ivoirepedia_app`) avec `GRANT ALL PRIVILEGES` sur ces deux bases seulement.

> **Important** : la création de bases et d'utilisateurs est **impossible en SQL** depuis un client tiers (phpMyAdmin, DBeaver…) — Alwaysdata l'interdit pour raison de sécurité. Le panneau ou l'API sont les seuls chemins.

**Accès distant** (pour que le poste de travail atteigne la base de dev) : renseigner la restriction d'IP de l'utilisateur MySQL. Alwaysdata n'accepte qu'une **adresse IPv4** ou un masque IPv4. Sans restriction, ne pas exposer la base plus que nécessaire : le développement peut aussi passer par un tunnel SSH.

### 2.3 Accès SSH

`Remote access > SSH` → vérifier que l'accès est actif et déposer une **clé publique**, pour ne pas dépendre d'un mot de passe.

Une clé **dédiée au déploiement** est générée dans le dépôt (dossier `.deploy/`, exclu par `.gitignore`, sans phrase de passe) :

```bash
ssh-keygen -t ed25519 -f .deploy/ivoirepedia_ed25519 -N "" -C "ivoirepedia-deploy"
cat .deploy/ivoirepedia_ed25519.pub   # à coller dans le panneau
```

Toutes les commandes de ce guide utilisent ensuite `-i .deploy/ivoirepedia_ed25519`. Ne jamais committer `.deploy/` : la clé privée donne accès au compte hébergeur. Une clé par compte : celle d'un autre projet ne doit pas être réutilisée.

| Paramètre | Valeur |
|---|---|
| Hôte | `ssh-ivoirepedia.alwaysdata.net` |
| Port | `22` |
| Utilisateur | `ivoirepedia` |
| Racine | `/home/ivoirepedia/` |

Test : `ssh -i .deploy/ivoirepedia_ed25519 ivoirepedia@ssh-ivoirepedia.alwaysdata.net "php -v"` doit afficher PHP 8.4.

### 2.4 Site web

Le répertoire racine **doit exister avant** la création du site (le panneau ne le crée pas) :

```bash
ssh -i .deploy/ivoirepedia_ed25519 ivoirepedia@ssh-ivoirepedia.alwaysdata.net
mkdir -p ~/ivoirepedia
```

Puis `Web > Sites > Ajouter un site` :

| Champ | Valeur |
|---|---|
| Type | **PHP** |
| Adresses | `ivoirepedia.alwaysdata.net` |
| Chemin | `/home/ivoirepedia/ivoirepedia/backend/public` (dans le panneau, saisir `ivoirepedia/backend/public` : le préfixe `/home/ivoirepedia/` est déjà affiché — ne pas le retaper, ne pas laisser le `www` par défaut) |
| Version PHP | celle du compte (§2.1) |

Le type PHP est servi par Apache : le `.htaccess` livré par Laravel dans `public/` prend en charge les URL sans `index.php`.

> **Piège du nom de domaine (constaté le 3 novembre 2026)** : le compte ne possède **qu'une seule adresse gratuite**, `<compte>.alwaysdata.net`, attribuée à sa création.
>
> - `ivoirepedia.alwaysdata.com` → « Le domaine alwaysdata.com ne vous appartient pas » : `.com` est le domaine de l'éditeur.
> - Sur un compte dont l'adresse `X.alwaysdata.net` est déjà occupée, ni `ivoirepedia.alwaysdata.net` ni un sous-domaine de `X.alwaysdata.net` ne sont attribuables sans domaine propre : c'est précisément ce qui a motivé le compte dédié.
> - Ne pas mettre de `www.` tant qu'aucun domaine propre n'est branché : `www` est une adresse distincte.

### 2.5 phpMyAdmin

Toujours disponible, rien à installer : **<https://phpmyadmin.alwaysdata.com>**.

| Champ | Valeur |
|---|---|
| Utilisateur MySQL | `ivoirepedia_app` (l'utilisateur MySQL du compte, pas le compte Alwaysdata) |
| Mot de passe | celui défini dans `Databases > MySQL` |

Les deux bases (`ivoirepedia_prod` et `ivoirepedia_dev`) apparaissent ensuite dans la colonne de gauche, et **uniquement celles-là** : l'utilisateur n'a de droits que sur elles. C'est l'interface prévue par l'hébergeur pour consulter les tables, éditer une ligne ou exporter un dump ; il n'y a pas de phpMyAdmin à installer dans `~/ivoirepedia`.

Un mot de passe par utilisateur MySQL, jamais réutilisé d'un projet à l'autre : en cas de fuite, seul ce compte est concerné et la rotation se fait dans le panneau.

---

## 3. Premier déploiement du backend

Le dépôt GitHub est **public** : le serveur peut cloner et tirer sans clé de déploiement.

```bash
ssh -i .deploy/ivoirepedia_ed25519 ivoirepedia@ssh-ivoirepedia.alwaysdata.net

cd ~/ivoirepedia
git clone https://github.com/0Defiance/IVOIREPEDIA.git .

cd backend
composer install --no-dev --optimize-autoloader   # composer est déjà installé sur Alwaysdata
cp .env.example .env
```

Renseigner ensuite `backend/.env` **sur le serveur** (jamais dans le dépôt) :

```dotenv
APP_NAME=IVOIREPEDIA
APP_ENV=production
APP_DEBUG=false
APP_URL=https://ivoirepedia.alwaysdata.net
FRONTEND_URL=https://ivoirepedia.alwaysdata.net

DB_CONNECTION=mysql
DB_HOST="mysql-ivoirepedia.alwaysdata.net"
DB_PORT=3306
DB_DATABASE="ivoirepedia_prod"
DB_USERNAME="ivoirepedia_app"
DB_PASSWORD=<mot de passe du panneau>

SESSION_DRIVER=database
SESSION_SECURE_COOKIE=true
SANCTUM_STATEFUL_DOMAINS=ivoirepedia.alwaysdata.net

MAIL_MAILER=smtp
MAIL_SCHEME=null
MAIL_HOST=in-v3.mailjet.com
MAIL_PORT=587
MAIL_USERNAME=<clé API Mailjet>
MAIL_PASSWORD=<clé secrète SMTP Mailjet>
MAIL_FROM_ADDRESS="no-reply@ivoirepedia.ci"
```

Puis :

```bash
php artisan key:generate --force
php artisan migrate --force          # jamais --seed : pas de compte de démo en production
php artisan config:cache
php artisan route:cache
php artisan view:cache
chmod -R u+rwX storage bootstrap/cache
```

Le processus PHP tourne sous l'utilisateur du compte : aucun `chown` système n'est nécessaire (et il n'y a pas d'accès root).

Pour le premier administrateur de production, utiliser une commande ponctuelle via `php artisan tinker` avec un mot de passe fort : `DevAdminSeeder` refuse de s'exécuter en production, c'est volontaire.

### Tâches planifiées

`Advanced > Scheduled tasks` → commande, toutes les minutes :

```
php /home/ivoirepedia/ivoirepedia/backend/artisan schedule:run
```

**Statut au 28 novembre 2026 : cette tâche n'existe pas.** Le compte refuse
`crontab` (« You (ivoirepedia) are not allowed to use this program ») et rien ne
déclenche `schedule:run` : une entrée planifiée peut être écrite dans
`routes/console.php` et listée par `php artisan schedule:list`, elle ne se
exécutera pas avant la création de cette tâche dans le panneau. La sauvegarde
quotidienne ne dépend pas d'elle (§8.2).

---

### Publier le site Flutter (racine du domaine)

Le site public est une application Flutter Web servie **à la racine du domaine**,
par le même site PHP : une seule adresse (`https://ivoirepedia.alwaysdata.net/`)
suffit, et les appels API restent sur la même origine (pas de CORS en
production).

La racine du document est `backend/public/` : elle contient `index.php` (Laravel)
**et** les fichiers du build Flutter. `backend/public/.htaccess` répartit les
requêtes : `/api`, `/admin`, `/livewire`, `/sanctum` vont à Laravel, un fichier
réel est servi tel quel, tout le reste reçoit `index.html` (l'application
reconstruit l'écran à partir de l'URL).

```bash
cd app
MSYS_NO_PATHCONV=1 flutter build web --release --base-href=/ --dart-define=API_BASE_URL=/api/v1

# Brotli précompressé (qualité 11) pour le JS et le wasm : Apache sert les
# variantes `.br` aux navigateurs qui annoncent `br` (règles versionnées dans
# `backend/public/.htaccess`). À rejouer après chaque build, avant l'envoi.
python ../tools/precompress_web.py build/web

tar -czf - -C build/web . | \
  ssh -i ../.deploy/ivoirepedia_ed25519 ivoirepedia@ssh-ivoirepedia.alwaysdata.net \
  'tar -xzf - -C ~/ivoirepedia/backend/public'
```

Contrôle obligatoire après l'envoi, avec les en-têtes exacts d'un navigateur
(`Accept-Encoding: gzip, deflate, br, zstd` : `curl` avec `br` seul ne
révélait pas la double compression de novembre 2026). Le script décompresse
le JS et le wasm et les compare octet à octet aux originaux :

```bash
cd app
python ../tools/verify_deploy.py
```

Tout doit afficher `OK`, sinon ne pas annoncer la mise en ligne : corriger
d'abord côté serveur (le plus souvent `.htaccess` ou variantes `.br`).

Le build n'embarque plus de `.htaccess` : celui de Laravel, versionné dans le
dépôt, est la seule source de vérité pour la racine.

Vérification : `https://ivoirepedia.alwaysdata.net/` renvoie le HTML du bootstrap,
les routes s'ouvrent directement (`/statistiques`, `/histoires`,
`/articles/{slug}`) et se rechargent sans erreur, et la console montre
`main.dart.js` puis `/api/v1/...` en `200`.

> Les adresses utilisent la stratégie d'URL par chemin (`usePathUrlStrategy`) :
> pas de `#`, des liens partageables et lisibles. Le contenu reste rendu côté
> client sur la plupart des pages (limitation R-09, CONTEXT §17). Les articles
> font exception côté serveur : `public/.htaccess` envoie `/articles/{slug}` et
> `/sitemap.xml` à Laravel. Un visiteur reçoit la coquille Flutter avec le
> titre, l'Open Graph et la canonique de l'article (l'application affiche
> ensuite sa page de lecture habituelle) ; un robot ou `?html=1` reçoit le HTML
> complet, et le sitemap est servi en XML.

---

## 4. Emails transactionnels avec Mailjet

### 4.1 Côté Mailjet

1. **Valider l'expéditeur** : `Account settings > Senders & Domains`. Soit une adresse unique (un email d'activation y arrive), soit — recommandé — le **domaine** `ivoirepedia.ci`, validé par enregistrement DNS puis authentifié **SPF/DKIM**.
2. **Créer une clé SMTP dédiée** : `Account settings > SMTP and SEND API Settings` → « Generate Secret Key ».
   - Identifiant SMTP = **clé API**
   - Mot de passe SMTP = **clé secrète**
3. Ne pas confondre avec la clé de l'API REST v3 : le SMTP n'utilise pas le même couple.

### 4.2 Côté Laravel

| Variable | Valeur |
|---|---|
| `MAIL_MAILER` | `smtp` |
| `MAIL_HOST` | `in-v3.mailjet.com` |
| `MAIL_PORT` | `587` (STARTTLS) — `465` en SSL implicite si 587 est bloqué |
| `MAIL_SCHEME` | `null` (port 587) — `smtps` **uniquement** avec le port 465 |
| `MAIL_USERNAME` | clé API |
| `MAIL_PASSWORD` | clé secrète SMTP |

> `MAIL_SCHEME` n'accepte que `null`, `smtp` ou `smtps`. Mettre `tls` ou `ssl` provoque une `UnsupportedSchemeException`. Après modification : `php artisan config:clear`.

### 4.3 Test d'envoi

```bash
cd ~/ivoirepedia/backend
php artisan tinker
>>> Mail::raw('Test IVOIREPEDIA', fn ($m) => $m->to('<adresse-de-test>')->subject('Test SMTP'));
```

Message reçu = SMTP opérationnel. Un 401 signale une clé API/secrète invalide ; un 403 sur l'expéditeur une adresse non validée dans Mailjet.

### 4.4 Quotas du plan gratuit

6 000 emails/mois, **200 par jour**, 1 000 contacts — suffisant pour la vérification d'adresse et les notifications du MVP ; à surveiller dès l'ouverture publique.

---

## 5. Déploiements suivants

À chaque mise en ligne, sur le serveur :

```bash
cd ~/ivoirepedia
git pull --ff-only
cd backend
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan config:cache && php artisan route:cache && php artisan view:cache
```

`--ff-only` échoue volontairement si le serveur a divergé : c'est le signal qu'un fichier a été modifié à la main en production.

**Site Flutter (racine de `backend/public/`)** : le build Flutter ne contient **aucun** `.htaccess`. Celui du dépôt, `backend/public/.htaccess`, est versionné et reste la seule source de vérité pour la racine : il répartit les requêtes entre Laravel (`/api`, `/admin`, `/articles/{slug}`, `/sitemap.xml`) et `index.html`, et fixe les en-têtes de cache et de compression. L'extraction du `tar` du build dans `~/ivoirepedia/backend/public` ne le touche pas ; après un envoi, vérifier qu'il est toujours là : `ls -a ~/ivoirepedia/backend/public | grep htaccess` (le build n'apporte ni ne remplace ce fichier).

---

## 6. Vérifications après déploiement

| Test | Commande / action | Attendu |
|---|---|---|
| API vivante | `curl -s https://ivoirepedia.alwaysdata.net/api/v1/health` | `{"status":"ok","service":"ivoirepedia-api","version":"v1"}` |
| HTTPS + redirection | `curl -sI http://ivoirepedia.alwaysdata.net` | `301` vers `https://` |
| Base connectée | `php artisan migrate:status` en SSH | Migrations listées, aucune « Pending » |
| Panneau admin | `curl -sI https://ivoirepedia.alwaysdata.net/admin` | `302` vers `/admin/connexion` : le panneau (Blade, session par cookie) est en service, pas Filament |
| Email | `Mail::raw(...)` en tinker | Message reçu, expéditeur validé |
| Article — visiteur | `curl -s https://ivoirepedia.alwaysdata.net/articles/<slug> \| grep 'og:title'` | Balises présentes et coquille Flutter (`flutter_bootstrap.js`) |
| Parcours navigateur | `python ../tools/verify_deploy.py` (depuis `app/`) | `OK` partout, JS/wasm décompressés identiques aux originaux |
| Article — robot | `curl -s -A 'Googlebot/2.1' https://ivoirepedia.alwaysdata.net/articles/<slug> \| grep -E 'og:title\|<h1>'` | Balises et texte de l'article dans le HTML |
| Sitemap | `curl -sI https://ivoirepedia.alwaysdata.net/sitemap.xml` | `200`, `application/xml` |
| Robots | `curl -s https://ivoirepedia.alwaysdata.net/robots.txt` | Ligne `Sitemap:` présente |
| Journaux | `backend/storage/logs/laravel.log` en SSH | Aucune erreur 500 |
| En-têtes de sécurité | `curl -sI https://ivoirepedia.alwaysdata.net/` | `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`, `HSTS` et `Content-Security-Policy-Report-Only` (docs/SECURITE.md) |
| Limitation de débit | 12 tentatives de `POST /api/v1/auth/login` | `429` dès le quota de 10 par minute dépassé |
| Secrets non servis | `curl -s https://ivoirepedia.alwaysdata.net/.env` | Coquille Flutter, jamais le contenu du fichier |
| Dépendances | `cd backend && composer audit --locked` | « No security vulnerability advisories found. » |

---

## 7. Limites et pièges connus

| Point | Détail |
|---|---|
| Une adresse gratuite par compte | `<compte>.alwaysdata.net`, non modifiable ; toute autre adresse exige un domaine propre ou un chemin (`exemple.net/blog`) |
| Création de base | Panneau ou API uniquement — jamais en SQL |
| Restriction MySQL | IPv4 seulement (adresse ou masque) |
| Pas de root | Aucune commande système privilégiée ; PHP tourne sous l'utilisateur du compte |
| Composer | Déjà présent côté serveur : `composer install` fonctionne directement |
| File d'attente | Pas de worker permanent au MVP : `QUEUE_CONNECTION=database` piloté par une tâche planifiée, ou `sync` tant que rien n'est asynchrone |
| Sauvegardes | Dump quotidien vérifié (§8) et copie hors-site vers un disque objet S3 (§8.5) ; sauvegardes Alwaysdata du compte en filet de dernier recours ; alerte courriel si aucun dump depuis 36 h (§8.6). Le disque hors-site n'est actif qu'une fois ses quatre clés renseignées |
| Médias | `storage/app/public` + `php artisan storage:link`, à recréer si le dossier est vidé lors d'un déploiement |

---

## 8. Sauvegardes et restauration

Une sauvegarde qu'on n'a jamais restaurée n'est pas une sauvegarde (risque R-04,
CONTEXT §17). L'export, l'automatisation et l'essai de restauration ci-dessous
ont été mis en service et vérifiés le 28 novembre 2026.

**Ce que couvre l'export** : la base entière (`mysqldump --single-transaction`,
donc sans bloquer les visites) et `backend/storage/app`, c'est-à-dire les médias
téléversés — `storage/logs` est exclu. Les identifiants ne quittent pas le
serveur : la commande demande la configuration à Laravel, la range dans un
fichier d'options `600` et le supprime en fin de course. `mysqldump`, `gzip` et
`tar` sont cherchés en chemin absolu : une tâche planifiée n'hérite pas du
`PATH` du shell.

### 8.1 Sauvegarder à la main

Une seule commande fabrique un dump, côté serveur :

```bash
cd ~/ivoirepedia/backend
php artisan backup:run                       # base du .env (ivoirepedia_prod)
php artisan backup:run --database ivoirepedia_dev --keep=1
php artisan backup:run --dry-run             # le plan, sans rien exécuter
```

Depuis le poste de travail, le même travail plus le rapatriement :

```bash
python tools/backup_db.py backup                       # appelle `backup:run` par SSH, puis scp
python tools/backup_db.py backup --database ivoirepedia_dev --keep 3
```

Nommage : `db-<base>-<horodatage>.sql.gz` et `media-<base>-<horodatage>.tar.gz`
dans `~/backups` (`BACKUP_DIR` pour choisir un autre dossier). **La base fait
partie du nom**, et la rétention se calcule base par base
(`App\Support\BackupRetention`) : une série de sauvegardes de `ivoirepedia_dev`
ne peut pas évincer le dernier dump de production. `--keep` compte des paires
**par base** (7 par défaut).

Le poste rapatrie la paire du jour dans `backups/<horodatage>/`, dossier ignoré
par Git : une sauvegarde est une donnée, pas du code. Les fichiers à l'ancien
nom (`db-<horodatage>.sql.gz`, avant le 28 novembre 2026) restent sur le
serveur : ils ne portent pas de nom de base et ne sont donc plus purgés
automatiquement.

### 8.2 Automatique : deux déclencheurs, un seul travail

`routes/console.php` planifie `backup:run --keep=7` chaque nuit à **3 h 30**.
Cette entrée ne s'exécute que si le compte lance `php artisan schedule:run`
chaque minute — la tâche du panneau décrite au §3. **Elle n'existe pas encore
au 28 novembre 2026** : `php artisan schedule:list` affiche bien l'entrée, mais
rien ne la déclenche, et `crontab` est refusé au compte.

En attendant, et en secours si la tâche disparaît, le middleware
`TriggerDailyBackup` (global, `bootstrap/app.php`) déclenche la sauvegarde
**dans un autre processus PHP** (`exec` détaché, `App\Support\DailyBackup`) :
la requête qui la déclenche n'attend rien, elle paie un `stat` sur le repère.
Un verrou (`~/backups/.backup.lock`) et une réservation immédiate
(`~/backups/.backup-pending`) empêchent deux requêtes simultanées de lancer
deux dumps ; `backup:run` écrit le repère `~/backups/.last-backup` à la fin
(succès : dans 24 h ; échec : retentative dans une heure) et lève la
réservation. Une réservation qui a plus d'une heure **sans repère** vaut un
lancement resté sans effet (processus tué, dossier plein) : la requête
suivante retente, au lieu d'attendre le lendemain.

Le déclencheur est **global, API comprise**, et pas limité aux pages publiques :
le 28 novembre 2026, une journée sans visite d'article — trois appels d'API et
un chargement de coquille Flutter — ne produisait **aucune** sauvegarde. Une
journée de trafic purement applicatif doit compter comme une journée normale.

Vérifié le 28 novembre 2026, même jour :
- repère supprimé, **trois appels** de `/api/v1/health` sur une base sans aucune
  visite d'article → `db-ivoirepedia_prod-20261128-025228.sql.gz` apparaît,
  repère réécrit, un quatrième appel ne relance rien ;
- latence des appels : 0,58 s en moyenne, identique à une journée où rien ne
  tourne (le dump synchrone coûtait auparavant ~1 s à l'appel qui le portait).

Créer la tâche du panneau supprime ce déclencheur de secours sans autre
changement.

### 8.3 Restaurer, et le prouver

```bash
python tools/backup_db.py counts --database ivoirepedia_dev          # état avant
python tools/backup_db.py restore \
    --dump backups/20261128-022621/db-ivoirepedia_prod-20261128-022618.sql.gz \
    --database ivoirepedia_dev --yes
```

`restore` envoie le dump, l'injecte avec `mysql`, puis imprime les compteurs de
tables **avant et après** et nomme celles qui ont bougé. La base visée doit être
nommée explicitement et `--yes` est obligatoire : une restauration écrase la
base cible. **Sauvegarder la base cible avant d'y restaurer autre chose** —
prévoir trois commandes, pas deux.

Essai réel du 28 novembre 2026, dump de production restauré dans
`ivoirepedia_dev` : 89 → **480 articles**, 2 → 1 compte, et
`GET /api/v1/search?q=a` sur l'API locale passe de 89 à **479** résultats, les
chiffres de la production. Le dump de dev pris avant l'essai a ensuite été
restauré : retour à 89 articles et 2 comptes. La production n'a pas été touchée.

### 8.4 En cas d'incident en production

1. **Sauvegarder l'état cassé** avant tout
(`php artisan backup:run --database ivoirepedia_prod`) : il peut contenir des
données à récupérer à la main.
2. Restaurer la dernière paire saine dans `ivoirepedia_prod`, puis vérifier
`python tools/backup_db.py counts --database ivoirepedia_prod`,
`curl -s https://ivoirepedia.alwaysdata.net/api/v1/health` et l'ouverture d'un
article dans le navigateur.
3. Vider les caches (`cd ~/ivoirepedia/backend && php artisan cache:clear && php artisan config:clear`)
et consigner l'incident dans `docs/SUIVI_DEVELOPPEMENT.md`.

### 8.5 Copie hors-site : les dumps quittent l'hébergeur

Un dump rangé dans `~/backups` reste sur la même machine et le même compte que
la base : la perte du compte emporte les deux (risque R-04). `backup:run`
envoie donc chaque paire sur un disque objet **compatible S3**, avec sa propre
rétention — `App\Support\OffsiteBackups`.

Configuration (serveur, `.env`, jamais dans le dépôt) :

```bash
BACKUP_OFFSITE_DISK=offsite                 # nom du disque config/filesystems.php
BACKUP_OFFSITE_ENDPOINT=https://<compte>.r2.cloudflarestorage.com
BACKUP_OFFSITE_BUCKET=ivoirepedia-backups
BACKUP_OFFSITE_KEY=...                      # jeton d'API du fournisseur
BACKUP_OFFSITE_SECRET=...
BACKUP_OFFSITE_REGION=auto                  # R2 ; sinon la région du fournisseur
BACKUP_OFFSITE_PREFIX=ivoirepedia
BACKUP_OFFSITE_KEEP=30                      # archives par type et par base
```

Les clés sont celles du fournisseur de stockage, **pas** celles du serveur : un
jeton compromis ne donne jamais accès à autre chose qu'aux sauvegardes. Tant
que `BACKUP_OFFSITE_DISK` est vide, la copie est désactivée sans erreur et le
dump local reste la seule copie — `php artisan backup:offsite` le dit alors
explicitement (code de sortie 1).

```bash
php artisan backup:offsite --dry-run        # ce qui partirait
php artisan backup:offsite                  # envoi + purge distante
```

À la fin d'une sauvegarde réussie, `backup:run` l'appelle seul et **avant**
d'écrire le repère du jour : une copie hors-site en échec laisse le repère en
échec, donc une nouvelle tentative dans l'heure, alors que le dump local n'est
jamais supprimé. L'envoi se fait en flux (`writeStream`) : une archive de 40 Mo
ne passe pas en mémoire. Une archive déjà présente à la même taille n'est pas
renvoyée ; une taille différente la renvoie.

> **État au 28 novembre 2026** : le code est livré et testé, mais aucun compte
> de stockage n'est encore ouvert — aucune copie n'existe donc hors du serveur
> tant que les quatre clés ci-dessus ne sont pas renseignées. C'est la seule
> étape qui reste sur ce chantier.

### 8.6 Alerte : plus aucun dump depuis 36 h

Une sauvegarde qui s'arrête sans le dire est plus dangereuse qu'une sauvegarde
absente : le site répond, tout semble normal. `App\Support\BackupWatch` lit,
après l'envoi de la réponse (même middleware que le déclencheur), le nom du
dernier dump **de la base courante** et la date de la dernière alerte : deux
`stat`, aucune archive ouverte.

```bash
BACKUP_ALERT_EMAIL=admin@ivoirepedia.ci     # destinataire ; vide = journaux seuls
BACKUP_ALERT_AFTER=129600                   # 36 h
BACKUP_ALERT_COOLDOWN=86400                 # une alerte par jour au plus
```

Quand le dernier dump dépasse le seuil — ou qu'il n'y en a aucun — un courriel
part avec l'âge du dernier dump, la base, le dossier et les trois commandes à
lancer (`backup:run`, `backup:offsite`, lecture du journal). Le repère
`.last-alert` dans `~/backups` limite à un envoi par 24 h : une panne dure ne
produit pas un courriel par visite. Sans destinataire, l'alerte reste dans
`laravel.log` (`Sauvegarde : le dernier dump de … a N h`) et rien n'est envoyé.

### 8.7 Ce qui reste à faire

- **La tâche planifiée du panneau** (§3) : elle rendrait la sauvegarde nocturne
  indépendante des visites et supprimerait le déclencheur de secours.
- **Renseigner les clés du disque hors-site** (§8.5) : le code est prêt, le
  compte de stockage ne l'est pas.
- Le **nettoyage des anciens dumps** (`db-<horodatage>.sql.gz`) une fois une
  paire au nouveau nom conservée.

---

## Sources vérifiées

- Types de sites et chemin du site : https://help.alwaysdata.com/en/docs/web-hosting/sites/add-a-site/
- Versions PHP et choix au niveau du compte : https://help.alwaysdata.com/en/docs/web-hosting/languages/php/configuration/
- Composer déjà installé : https://help.alwaysdata.com/en/docs/web-hosting/languages/php/packages/
- Accès SSH (hôte, port, pas de root) et adresse gratuite en `.net` : https://help.alwaysdata.com/en/docs/technical-specifications/login-details/
- MySQL (hôte `mysql-<compte>.alwaysdata.net`, restriction IPv4, création via panneau) : https://help.alwaysdata.com/en/docs/web-hosting/databases/mariadb/
- Tâches planifiées : https://help.alwaysdata.com/en/docs/web-hosting/tasks/
- Déploiement Git : https://help.alwaysdata.com/en/blog/2018-02-05-deploy-at-lightning-speed-with-git-hooks/
- SMTP Mailjet (hôte, ports, identifiants) : https://dev.mailjet.com/docs/smtp-relay/configuration
- Expéditeurs et quotas Mailjet : https://www.mailjet.com/pricing/
