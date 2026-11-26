# IMOVIA

Plateforme immobilière progressive pour le Bénin. Le périmètre MVP et les parcours sont décrits dans [le cahier des charges](./docs/IMOVIA_cahier_des_charges_v3_MVP_V2_V3.md) et [la cartographie des écrans](./docs/IMOVIA_ecrans_MVP_par_utilisateur.md).

## Stack

- `apps/api` : NestJS, TypeScript, Prisma et PostgreSQL.
- `apps/mobile` : application mobile Flutter, recréée depuis un squelette vierge.
- `apps/admin` : back-office Next.js, séparé de l'application mobile.
- `docker-compose.yml` : PostgreSQL, Mailpit et stockage objet S3 local pour le développement.
- Interface : palette monochrome IMOVIA — noir `#0B0B0B`, gris foncé `#1F1F1F`, gris moyen `#6B7280`, gris clair `#E5E7EB`, blanc `#FFFFFF`, accent `#101114`.

Le contrat HTTP/OpenAPI est la frontière entre les deux applications ; les types TypeScript ne sont pas partagés directement avec Dart.

## Démarrage local

Prérequis : Node.js, npm, Flutter/Dart, Docker Compose.

1. Copier `.env.example` vers `.env` à la racine.
2. Copier `apps/api/.env.example` vers `apps/api/.env` et remplacer `AUTH_OTP_PEPPER` par une valeur aléatoire d'au moins 32 octets.
3. Démarrer PostgreSQL, Mailpit et le stockage objet : `make infra-up`.
4. Lancer l'API : `make api`.
5. Lancer l'interface admin : `make admin` (http://localhost:3001).
6. Lancer l'application mobile sur un simulateur ou un appareil : `make mobile`.

L'API répond sur `http://localhost:3000/api/health` et sa documentation sur `http://localhost:3000/api/docs`. PostgreSQL est exposé sur le port local `55432` par défaut pour éviter les conflits avec un serveur déjà installé.
Pour connecter les interfaces à une autre API, configure leur adresse via variables d'environnement. L'émulateur Android utilise généralement `10.0.2.2` pour joindre l'API locale ; un appareil physique utilise l'adresse réseau de la machine de développement. Les appels du navigateur vers l'API sont limités aux origines exactes configurées dans `WEB_ORIGIN` (`http://localhost:3001` en local, plusieurs origines séparées par des virgules si nécessaire). En production, renseigne l'origine publique du back-office ; n'utilise pas `*`.

En local, les emails OTP sont capturés par Mailpit, accessible sur `http://localhost:8025` (SMTP `localhost:1025`). En production, configure un relais SMTP réel et vérifie son domaine d'envoi avant le déploiement.
La livraison email en production exige TLS (`SMTP_SECURE=true` ou `SMTP_REQUIRE_TLS=true`).
Le stockage objet S3 local est accessible sur `http://localhost:18333`. L'API crée le bucket privé et configure son accès CORS au démarrage local. Les identifiants de développement sont définis dans [storage/s3.json](./storage/s3.json) et repris dans `.env.example`.

En production, configure `OBJECT_STORAGE_ENDPOINT`, `OBJECT_STORAGE_BUCKET`, `OBJECT_STORAGE_ACCESS_KEY`, `OBJECT_STORAGE_SECRET_KEY` et `OBJECT_STORAGE_REGION`. L'endpoint doit être accessible par le navigateur pour les téléversements directs ; le bucket doit exister et autoriser les requêtes CORS depuis l'origine web.

### Recherche de lieux Google Maps

Active Places API (New) et la facturation dans Google Cloud, puis renseigne `GOOGLE_MAPS_API_KEY` dans `apps/api/.env`. La clé reste côté API : restreins-la à Places API et à l’adresse IP du serveur, puis fixe des quotas et alertes de facturation dans Google Cloud. Sans clé, l’API démarre, mais les suggestions et les annonces géolocalisées retournent une erreur explicite.

Les suggestions sont limitées au Bénin, temporisées pendant la saisie et attribuées à Google Maps dans l’interface. Les Place IDs peuvent être conservés. Les coordonnées retournées par Google sont mises en cache au plus 30 jours et rafraîchies chaque jour à partir du 25e jour ; les coordonnées expirées sont supprimées. Le rafraîchissement appelle Places API pour chaque lieu Google distinct : prévois cette consommation et surveille les quotas/factures Google Cloud. Le rayon du catalogue est sélectionnable de 1 à 50 km et utilise une distance Haversine exacte en PostgreSQL ; seules les annonces avec des coordonnées Google encore valides sont incluses. Les libellés Google ne sont pas conservés en base.

## Authentification (fondation)

- `POST /api/auth/otp/request` avec une adresse email.
- `POST /api/auth/otp/verify` avec l'email et le code reçu renvoie un jeton de session opaque ; le client l'envoie en `Authorization: Bearer ...`.
- `GET /api/auth/me`, `POST /api/auth/logout` et `PATCH /api/users/me/profile` nécessitent une session.
- Le code email expire après 5 minutes, les demandes sont limitées par adresse et chaque code autorise au plus cinq tentatives.
- Le jeton brut n'est jamais stocké en base ; les sessions et codes sont enregistrés sous forme de hash.
- Le client conserve actuellement le jeton en mémoire uniquement ; un rechargement de page nécessite une nouvelle vérification e-mail.

## Annonces (fondation)

- `GET /api/locations` et `GET /api/locations?parentId=...` parcourent la hiérarchie des localisations historiques.
- `GET /api/places/autocomplete?input=...&sessionToken=...` propose des lieux au Bénin ; `GET /api/places/:placeId?sessionToken=...` confirme le lieu sélectionné.
- `GET /api/properties` expose uniquement les annonces publiées et disponibles, avec filtres et pagination. `centerLatitude`, `centerLongitude` et `radiusKm` activent la recherche par proximité (1–50 km).
- `GET /api/properties/:slug` expose une fiche publique publiée.
- Les profils propriétaires/agents authentifiés peuvent enregistrer des brouillons avec `POST /api/properties`, consulter leur portefeuille avec `GET /api/properties/me/list` et modifier leurs brouillons.
- Les photos JPEG, PNG et WebP (5 Mo maximum chacune, 20 par annonce) sont envoyées directement vers le stockage objet : demander les champs signés avec `POST /api/properties/me/:id/media/upload-url`, envoyer le fichier en multipart à l'URL retournée, puis confirmer avec `POST /api/properties/me/:id/media/:mediaId/complete`.
- Le serveur vérifie la taille, le type et la signature du fichier. Les brouillons restent privés ; un modérateur doit approuver chaque photo avant la publication.
- La photo de couverture est la première photo prête par défaut ; elle peut être modifiée via `PATCH /api/properties/me/:id/media/:mediaId/cover`.
- Les fiches publiées exposent uniquement les photos approuvées via `GET /api/properties/:slug/media/:mediaId`. Les liens de lecture sont signés et temporaires.
- L'ancienne interface Flutter a été supprimée. Le nouveau projet mobile est un squelette vierge ; les parcours seront réimplémentés à partir de la cartographie MVP et des contrats de l'API.
- Le back-office Next.js vient d'être créé ; il reste à construire et consommera la même API centrale avec des permissions administrateur distinctes.

## Commandes utiles

- `make infra-up` / `make infra-down` : démarrer/arrêter l'infrastructure locale (PostgreSQL, Mailpit, stockage objet).
- `make api-test` : tests backend.
- `make api-build` : compilation NestJS.
- `make mobile-test` : tests Flutter.
- `make mobile-analyze` : analyse statique Flutter.
- `make admin-build` / `make admin-lint` : compilation et lint du back-office Next.js.
- `make db-generate` : générer le client Prisma.

Les identifiants PostgreSQL fournis sont uniquement destinés au développement local.
