# IVOIREPEDIA — Déploiement sur Alwaysdata + Mailjet

> **Objet :** mettre le backend Laravel en ligne sur un hébergement mutualisé Alwaysdata **dédié à IVOIREPEDIA**, avec sa base MySQL et ses emails transactionnels Mailjet.
>
> **Complément local :** [`INSTALLATION.md`](INSTALLATION.md). **État réel :** [`SUIVI_DEVELOPPEMENT.md`](SUIVI_DEVELOPPEMENT.md).
>
> **Version :** 2.0 · **Dernière mise à jour :** 3 novembre 2026
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
| Une adresse gratuite par compte | `<compte>.alwaysdata.net`, non modifiable ; toute autre adresse exige un domaine propre ou un chemin (`exemple.net/blog`) |
| Création de base | Panneau ou API uniquement — jamais en SQL |
| Restriction MySQL | IPv4 seulement (adresse ou masque) |
| Pas de root | Aucune commande système privilégiée ; PHP tourne sous l'utilisateur du compte |
| Composer | Déjà présent côté serveur : `composer install` fonctionne directement |
| File d'attente | Pas de worker permanent au MVP : `QUEUE_CONNECTION=database` piloté par une tâche planifiée, ou `sync` tant que rien n'est asynchrone |
| Sauvegardes | Sauvegardes Alwaysdata activées par défaut ; **tester une restauration** avant la bêta (risque R-04) |
| Médias | `storage/app/public` + `php artisan storage:link`, à recréer si le dossier est vidé lors d'un déploiement |

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
