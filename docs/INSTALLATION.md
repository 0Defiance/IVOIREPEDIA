# IVOIREPEDIA — Installation et démarrage local

> **Objet :** permettre à une personne qui n'a jamais ouvert le projet de le faire tourner sur son poste, puis de vérifier que chaque couche répond.
>
> **Compléments :** [`DEPLOIEMENT.md`](DEPLOIEMENT.md) (Alwaysdata + Mailjet), [`SUIVI_DEVELOPPEMENT.md`](SUIVI_DEVELOPPEMENT.md) (état réel), [`IVOIREPEDIA_CONTEXT.md`](../IVOIREPEDIA_CONTEXT.md) (architecture et décisions).
>
> **Version :** 1.0 · **Dernière mise à jour :** 3 novembre 2026
>
> Les versions ci-dessous sont celles **constatées par exécution** sur le poste de développement le 3 novembre 2026.

---

## Sommaire

1. [Principe : plus de MySQL local](#1-principe--plus-de-mysql-local)
2. [Prérequis](#2-prérequis)
3. [Ports de développement](#3-ports-de-développement)
4. [Base de données](#4-base-de-données)
5. [Backend Laravel](#5-backend-laravel)
6. [Application Flutter Web](#6-application-flutter-web)
7. [Liste de vérification](#7-liste-de-vérification)
8. [Problèmes connus](#8-problèmes-connus)

---

## 1. Principe : plus de MySQL local

Décision du 3 novembre 2026 (CONTEXT ADR-002) : **la base de développement est hébergée sur Alwaysdata**, comme en production. On supprime XAMPP et phpMyAdmin locaux — un seul moteur, donc plus d'écart entre le poste et le serveur.

Conséquences à connaître :

- **Il faut une connexion Internet** pour démarrer le backend et lancer les migrations. Le développement de l'interface Flutter, lui, reste possible hors ligne.
- **Deux bases distinctes** vivent sur le serveur dédié : `ivoirepedia_dev` (poste de travail) et `ivoirepedia_prod` (production). Ne jamais pointer le `.env` local vers la base de production.
- **Les tests ne touchent jamais la base distante** : `phpunit.xml` force SQLite **en mémoire**. `composer test` fonctionne donc sans réseau (CONTEXT §15.3).
- La création de la base et de l'utilisateur MySQL se fait **uniquement dans le panneau Alwaysdata** (ou son API) : l'hébergeur interdit `CREATE DATABASE` depuis un client tiers. Procédure : [`DEPLOIEMENT.md` §2](DEPLOIEMENT.md).

---

## 2. Prérequis

| Outil | Version constatée | Rôle | Comment vérifier |
|---|---|---|---|
| PHP CLI | **8.3.33** | Laravel 13, Artisan, tests | `php -v` |
| Composer | **2.10.3** — absent du PATH sur ce poste | Dépendances PHP | `php "C:\Users\Abd Al Fattah\AppData\Local\Programs\Composer\composer.phar" --version` |
| Flutter / Dart | **3.47.7 / 3.13.5** | Interface web puis Android | `flutter --version` |
| Git | ≥ 2.40 | Versionnement et parité local ↔ distant | `git --version` |
| Compte Alwaysdata | — | Base MySQL distante (et production) | `ssh ivoirepedia@ssh-ivoirepedia.alwaysdata.net` |
| Navigateur récent | — | Recette du site | — |

**Points d'attention relevés le 3 novembre 2026 :**

- **Le PHP de XAMPP est en 8.2 et ne doit plus servir.** Laravel 13 exige PHP 8.3+ en CLI ; le PHP constaté en ligne de commande sur ce poste est le 8.3.33 installé via WinGet.
- **Composer est installé mais hors du PATH** : appeler `php "<chemin>/composer.phar" <commande>`. Ajouter le dossier au PATH ou créer un alias évite de répéter le chemin.
- **XAMPP n'est plus nécessaire.** Il peut rester installé, mais plus aucun composant du projet ne s'en sert.

---

## 3. Ports de développement

| Service | Port | Adresse locale | Rôle |
|---|---:|---|---|
| API Laravel | `8000` | `http://127.0.0.1:8000` | Routes `/api/v1`, sessions Sanctum, panneau `/admin` |
| Flutter Web | `8082` | `http://127.0.0.1:8082` | Site IVOIREPEDIA |
| MySQL Alwaysdata | `3306` | `mysql-ivoirepedia.alwaysdata.net:3306` | Consommée uniquement par Laravel, jamais par Flutter |

Les ports `8000` et `8082` sont distincts **par conception** : le navigateur les voit comme deux origines. Sanctum, cookies CSRF et CORS doivent donc autoriser explicitement `127.0.0.1:8082` — c'est déjà prévu dans `backend/.env.example` (`SANCTUM_STATEFUL_DOMAINS`). En production, web, API et `/admin` sont servis sous une seule origine HTTPS.

---

## 4. Base de données

La base n'est **pas** créée localement : elle l'est une seule fois dans le panneau Alwaysdata (voir [`DEPLOIEMENT.md` §2](DEPLOIEMENT.md)). Récapitulatif de ce que le `.env` local doit contenir :

```dotenv
DB_CONNECTION=mysql
DB_HOST="mysql-ivoirepedia.alwaysdata.net"
DB_PORT=3306
DB_DATABASE="ivoirepedia_dev"
DB_USERNAME="ivoirepedia_app"
DB_PASSWORD=<mot de passe choisi dans le panneau>
```

Le mot de passe est choisi dans le panneau et recopié dans `backend/.env`. **Il ne figure jamais dans ce document, un ticket, une capture ou un commit.**

Vérifier la connexion avant d'aller plus loin :

```bash
cd backend
php artisan migrate:status
```

Si la commande affiche des migrations en attente plutôt qu'une erreur de connexion, la base répond.

---

## 5. Backend Laravel

Depuis `backend/`, dans un terminal :

```bash
# Composer hors PATH sur ce poste : utiliser le chemin exact (§2)
php "C:/Users/Abd Al Fattah/AppData/Local/Programs/Composer/composer.phar" install
cp .env.example .env
# puis renseigner DB_* et MAIL_* dans .env (jamais versionné)
php artisan key:generate
php artisan migrate --seed     # 10 tables + 8 catégories + admin de dev
php artisan serve --port 8000
```

`--seed` crée `admin@ivoirepedia.test` / `password` — **compte de développement uniquement**, jamais en production (`DevAdminSeeder` sort immédiatement si `APP_ENV=production`).

Vérification immédiate de l'API :

```bash
curl http://127.0.0.1:8000/api/v1/health
# {"status":"ok","service":"ivoirepedia-api","version":"v1"}
```

---

## 6. Application Flutter Web

```bash
cd app
flutter pub get
flutter run -d web-server --web-port 8082
```

Le site s'ouvre sur `http://127.0.0.1:8082`. Au Sprint 0, il affiche l'écran d'accueil IVOIREPEDIA (preuve que la chaîne Flutter fonctionne) ; les écrans réels arrivent au Sprint 4.

---

## 7. Liste de vérification

À exécuter dans cet ordre ; chaque ligne doit passer avant de considérer l'installation terminée.

```bash
# 1. Backend — même triplet que la CI (CONTEXT §15.4)
cd backend
composer test            # Pest, 3 tests / 4 assertions au Sprint 0
composer format:check    # Pint : aucun écart de style
composer analyse         # Larastan niveau 5 : aucune erreur

# 2. API
php artisan route:list --path=api
curl http://127.0.0.1:8000/api/v1/health

# 3. Application Flutter
cd ../app
flutter analyze          # "No issues found!"
flutter test             # écran d'accueil : 1 test vert
```

---

## 8. Problèmes connus

| Symptôme | Cause | Solution |
|---|---|---|
| `SQLSTATE[HY000] [1045] Access denied` | Mot de passe ou nom d'utilisateur MySQL erroné dans `.env` | Reprendre les valeurs exactes de **Databases > MySQL** dans le panneau Alwaysdata |
| `SQLSTATE[HY000] [2002]` / timeout | Base distante injoignable : accès distant non autorisé ou réseau coupé | Vérifier la restriction d'IP de l'utilisateur MySQL (IPv4 uniquement chez Alwaysdata) et la connexion Internet |
| `Unknown database 'ivoirepedia_dev'` | La base n'a pas été créée dans le panneau | La créer dans **Databases > MySQL** (impossible en SQL depuis un client tiers) |
| `composer : commande introuvable` | Composer hors du PATH | Utiliser `php "<chemin>/composer.phar" <commande>` |
| `Class "..." not found` après ajout d'un import | Pint a requalifié un import vers un namespace inexistant | Vérifier avec `composer format:check`, corriger l'import, relancer les tests |
| `flutter test` échoue sur `Counter increments` | Ancien test du modèle `flutter create` | Remplacé au Sprint 0 par le test de l'écran d'accueil |
