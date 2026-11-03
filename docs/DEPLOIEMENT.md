# IVOIREPEDIA — Déploiement sur Alwaysdata + Mailjet

> **Objet :** mettre le backend Laravel en ligne sur un hébergement mutualisé Alwaysdata, avec sa base MySQL et ses emails transactionnels Mailjet.
>
> **Complément local :** [`INSTALLATION.md`](INSTALLATION.md). **État réel :** [`SUIVI_DEVELOPPEMENT.md`](SUIVI_DEVELOPPEMENT.md).
>
> **Version :** 1.0 · **Dernière mise à jour :** 3 novembre 2026
>
> Faits vérifiés dans la documentation officielle Alwaysdata et Mailjet le 3 novembre 2026 (sources en fin de document).

---

## Sommaire

1. [Ce qui se partage avec Soutrali (et ce qui ne se partage pas)](#1-ce-qui-se-partage-avec-soutrali-et-ce-qui-ne-se-partage-pas)
2. [Préparer le compte Alwaysdata](#2-préparer-le-compte-alwaysdata)
3. [Premier déploiement du backend](#3-premier-déploiement-du-backend)
4. [Emails transactionnels avec Mailjet](#4-emails-transactionnels-avec-mailjet)
5. [Déploiements suivants](#5-déploiements-suivants)
6. [Vérifications après déploiement](#6-vérifications-après-déploiement)
7. [Limites et pièges connus](#7-limites-et-pièges-connus)

---

## 1. Ce qui se partage avec Soutrali (et ce qui ne se partage pas)

Un compte Alwaysdata = **un utilisateur UNIX**, plusieurs sites et plusieurs bases. On peut donc réutiliser le compte de Soutrali, à condition de séparer ce qui doit l'être :

| Élément | Partagé ? | Pourquoi |
|---|---|---|
| Compte Alwaysdata (identifiant, SSH) | ✅ Oui | Un seul accès à administrer |
| Version de PHP | ⚠️ **Au niveau du compte** (`Environment > PHP`) | Seule vraie contrainte : si Soutrali exige 8.4 et IVOIREPEDIA 8.3, il faut s'aligner ou fixer la version par site (plus gourmand en RAM) |
| Site web (domaine) | ❌ Non | Un site dédié : `ivoirepedia.alwaysdata.net` |
| Base MySQL | ❌ Non | `soutrali_ivoirepedia` (prod) et `soutrali_ivoirepedia_dev` (dev) — **jamais** la base de Soutrali |
| Utilisateur MySQL | ❌ Non | Un utilisateur dédié, droits limités à ses propres bases |
| Dossier de déploiement | ❌ Non | `~/ivoirepedia/` — les migrations d'un projet ne doivent jamais toucher l'autre |
| Compte Mailjet | ✅ Possible | Mais **une clé SMTP dédiée** à IVOIREPEDIA, pour la révoquer sans casser Soutrali |

**Règle** : partager l'accès, jamais les données. Deux projets dans une même base rendent toute restauration et toute suppression dangereuses.

---

## 2. Préparer le compte Alwaysdata

Ces étapes se font **dans le panneau** (`https://admin.alwaysdata.com`), pas en SSH.

### 2.1 Version de PHP

`Environment > PHP` → choisir **PHP 8.3** (ou la plus récente ≥ 8.3 compatible avec Laravel 13). C'est la version utilisée en ligne de commande et par les tâches planifiées. Éviter de multiplier les versions par site : Alwaysdata documente une consommation RAM supérieure.

**Constaté le 3 novembre 2026** : le compte est en **PHP 8.4.27** en CLI (`php -v`), avec Composer en `/usr/bin/composer`. Laravel 13 exige 8.3+ : 8.4 convient, aucune action nécessaire.

### 2.2 Bases MySQL

`Databases > MySQL` → créer **deux bases** et **un utilisateur** :

| Base | Usage |
|---|---|
| `soutrali_ivoirepedia` | Production |
| `soutrali_ivoirepedia_dev` | Développement (poste de travail) |

Puis un utilisateur `soutrali_ivoirepedia` avec `GRANT ALL PRIVILEGES` sur ces deux bases.

> **Important** : la création de bases et d'utilisateurs est **impossible en SQL** depuis un client tiers (phpMyAdmin, DBeaver…) — Alwaysdata l'interdit pour raison de sécurité. Le panneau ou l'API sont les seuls chemins.

**Accès distant** (pour que le poste de travail atteigne la base de dev) : renseigner la restriction d'IP de l'utilisateur MySQL. Alwaysdata n'accepte qu'une **adresse IPv4** ou un masque IPv4. Sans restriction, ne pas exposer la base plus que nécessaire : le développement peut aussi passer par un tunnel SSH.

### 2.3 Accès SSH

`Remote access > SSH` → vérifier que l'accès est actif et déposer une **clé publique**, pour ne pas dépendre d'un mot de passe.

Une clé **dédiée au déploiement** est générée dans le dépôt (dossier `.deploy/`, exclu par `.gitignore`, sans phrase de passe) :

```bash
ssh-keygen -t ed25519 -f .deploy/ivoirepedia_ed25519 -N "" -C "ivoirepedia-deploy"
cat .deploy/ivoirepedia_ed25519.pub   # à coller dans le panneau
```

Toutes les commandes de ce guide utilisent ensuite `-i .deploy/ivoirepedia_ed25519`. Ne jamais committer `.deploy/` : la clé privée donne accès au compte hébergeur.

| Paramètre | Valeur |
|---|---|
| Hôte | `ssh-soutrali.alwaysdata.net` |
| Port | `22` |
| Utilisateur | `soutrali` |
| Racine | `/home/soutrali/` |

Test : `ssh -i .deploy/ivoirepedia_ed25519 soutrali@ssh-soutrali.alwaysdata.net "php -v"` doit afficher PHP 8.3.

État constaté le 3 novembre 2026 : `ssh-soutrali.alwaysdata.net:22` et `mysql-soutrali.alwaysdata.net:3306` répondent, `https://soutrali.alwaysdata.net` renvoie `200` (site Soutrali en ligne), `https://ivoirepedia.alwaysdata.net` ne répond pas encore (site non créé). L'authentification par clé était refusée avant le dépôt de `ivoirepedia_ed25519.pub` dans le panneau.

### 2.4 Site web

Le répertoire racine **doit exister avant** la création du site (le panneau ne le crée pas) :

```bash
ssh -i .deploy/ivoirepedia_ed25519 soutrali@ssh-soutrali.alwaysdata.net
mkdir -p ~/ivoirepedia
```

Puis `Web > Sites > Ajouter un site` :

| Champ | Valeur |
|---|---|
| Type | **PHP** |
| Adresses | `ivoirepedia.alwaysdata.net` |
| Chemin | `/home/soutrali/ivoirepedia/backend/public` |
| Version PHP | celle du compte (§2.1) |

Le type PHP est servi par Apache : le `.htaccess` livré par Laravel dans `public/` prend en charge les URL sans `index.php`.

> **Piège du nom de domaine** : le sous-domaine offert se termine **obligatoirement par `.alwaysdata.net`**. Saisir `ivoirepedia.alwaysdata.com` renvoie « Le domaine alwaysdata.com ne vous appartient pas » — `.com` est le domaine de l'éditeur, pas le nôtre. Ne pas mettre non plus de `www.` sur un sous-domaine `alwaysdata.net` tant qu'aucun domaine propre n'est branché : `www` est une adresse distincte, à n'ajouter qu'avec un domaine à soi. La documentation le confirme : « The subdomain assigned to you when your account is created will end with a .net extension and not a .com extension ».

### 2.5 phpMyAdmin

Toujours disponible, rien à installer : **<https://phpmyadmin.alwaysdata.com>**.

| Champ | Valeur |
|---|---|
| Utilisateur MySQL | `soutrali_ivoirepedia` (l'utilisateur MySQL, pas le compte Alwaysdata) |
| Mot de passe | celui défini dans `Databases > MySQL` |

Les deux bases (`soutrali_ivoirepedia` et `soutrali_ivoirepedia_dev`) apparaissent ensuite dans la colonne de gauche. C'est l'interface prévue par l'hébergeur pour consulter les tables, éditer une ligne ou exporter un dump ; il n'y a pas de phpMyAdmin à installer dans `~/ivoirepedia`.

---

## 3. Premier déploiement du backend

Le dépôt GitHub est **public** : le serveur peut cloner et tirer sans clé de déploiement.

```bash
ssh -i .deploy/ivoirepedia_ed25519 soutrali@ssh-soutrali.alwaysdata.net

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
DB_HOST="mysql-soutrali.alwaysdata.net"
DB_PORT=3306
DB_DATABASE="soutrali_ivoirepedia"
DB_USERNAME="soutrali_ivoirepedia"
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

### État réel du déploiement (3 novembre 2026)

| Étape | État |
|---|---|
| Clé SSH `ivoirepedia-deploy` déposée dans le panneau | ✅ fait |
| Bases `soutrali_ivoirepedia` + `soutrali_ivoirepedia_dev` et utilisateur MySQL | ✅ fait |
| Dépôt cloné dans `~/ivoirepedia` | ✅ fait (commit `b23ab6e`) |
| `backend/.env` de production en place (`APP_KEY` généré) | ✅ fait (fichier non versionné, copié par `scp`) |
| `composer install --no-dev --optimize-autoloader` | ✅ fait sur le serveur |
| `php artisan migrate --seed --force` sur la base de production | ✅ fait (9 tables + catégories ; `DevAdminSeeder` ignoré, comme prévu) |
| Base de développement migrée + seedée depuis le poste de travail | ✅ fait |
| Site PHP créé dans le panneau (`ivoirepedia.alwaysdata.net`) | ⏳ **à faire** — adresse en `.com` refusée (§2.4) |
| Vérification HTTP de `/api/v1/health` | ⏳ en attente du site |
| Mailjet (`MAIL_MAILER=log` pour l'instant) | ⏳ en attente des clés |

### Tâches planifiées

`Advanced > Scheduled tasks` → commande, toutes les minutes :

```
php /home/soutrali/ivoirepedia/backend/artisan schedule:run
```

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
php artisan config:cache && php artisan route:cache
```

`--ff-only` échoue volontairement si le serveur a divergé : c'est le signal qu'un fichier a été modifié à la main en production.

---

## 6. Vérifications après déploiement

| Test | Commande / action | Attendu |
|---|---|---|
| API vivante | `curl -s https://ivoirepedia.alwaysdata.net/api/v1/health` | `{"status":"ok","service":"ivoirepedia-api","version":"v1"}` |
| HTTPS + redirection | `curl -sI http://ivoirepedia.alwaysdata.net` | `301` vers `https://` |
| Base connectée | `php artisan migrate:status` en SSH | Migrations listées, aucune « Pending » |
| Panneau admin | `https://ivoirepedia.alwaysdata.net/admin` | Écran de connexion Filament (à partir du Sprint 5) |
| Email | `Mail::raw(...)` en tinker | Message reçu, expéditeur validé |
| Journaux | `backend/storage/logs/laravel.log` en SSH | Aucune erreur 500 |

---

## 7. Limites et pièges connus

| Point | Détail |
|---|---|
| Création de base | Panneau ou API uniquement — jamais en SQL |
| Restriction MySQL | IPv4 seulement (adresse ou masque) |
| Pas de root | Aucune commande système privilégiée ; PHP tourne sous l'utilisateur du compte |
| Version PHP | Réglée au niveau du compte par défaut (voir §1 pour le partage avec Soutrali) |
| Composer | Déjà présent côté serveur : `composer install` fonctionne directement |
| File d'attente | Pas de worker permanent au MVP : `QUEUE_CONNECTION=database` piloté par une tâche planifiée, ou `sync` tant que rien n'est asynchrone |
| Sauvegardes | Sauvegardes Alwaysdata activées par défaut ; **tester une restauration** avant la bêta (risque R-04) |
| Médias | `storage/app/public` + `php artisan storage:link`, à recréer si le dossier est vidé lors d'un déploiement |

---

## Sources vérifiées

- Types de sites et chemin du site : https://help.alwaysdata.com/en/docs/web-hosting/sites/add-a-site/
- Versions PHP et choix au niveau du compte : https://help.alwaysdata.com/en/docs/web-hosting/languages/php/configuration/
- Composer déjà installé : https://help.alwaysdata.com/en/docs/web-hosting/languages/php/packages/
- Accès SSH (hôte, port, pas de root) : https://help.alwaysdata.com/en/docs/web-hosting/remote-access/ssh/
- MySQL (hôte `mysql-soutrali.alwaysdata.net`, restriction IPv4, création via panneau) : https://help.alwaysdata.com/en/docs/web-hosting/databases/mariadb/
- Tâches planifiées : https://help.alwaysdata.com/en/docs/web-hosting/tasks/
- Déploiement Git : https://help.alwaysdata.com/en/blog/2018-02-05-deploy-at-lightning-speed-with-git-hooks/
- SMTP Mailjet (hôte, ports, identifiants) : https://dev.mailjet.com/docs/smtp-relay/configuration
- Expéditeurs et quotas Mailjet : https://www.mailjet.com/pricing/
