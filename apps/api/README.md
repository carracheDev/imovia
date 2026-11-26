# API CARANOVA — périmètre MVP

API NestJS centralisée pour l’application Flutter et le back-office Next. Le MVP reste un monolithe modulaire : PostgreSQL/Prisma, stockage objet compatible S3 et fournisseur SMTP existant.

## Modules livrés

- **Authentification** : code email à usage unique, session opaque stockée sous forme de hash, expiration/révocation, profils chercheur/propriétaire/agent.
- **Catalogue** : recherche paginée par critères essentiels, proximité géographique, détail public, lieux et statut de disponibilité.
- **Publication** : brouillon, informations structurées, préférences de contact, consignes de visite, photos signées et vérifiées, autorisation de publication versionnée.
- **Délégation propriétaire/agent** : autorisation explicite par bien, révocation immédiate, vérification serveur à chaque opération protégée.
- **Modération** : file paginée, prise en charge, approbation, refus, demande de corrections, suspension/restauration, validation individuelle des photos et historique.
- **Confiance** : favoris, signalements, notifications internes consultables, suspension des comptes, journal des actions sensibles.

Les demandes de rendez-vous avec créneaux, la messagerie, les paiements, les services immobiliers et l’analytique avancée restent hors MVP.

## Routes principales

Toutes les routes sont préfixées par `/api`. Les routes privées utilisent `Authorization: Bearer <sessionToken>`.

| Domaine | Routes |
| --- | --- |
| Session et profil | `POST /auth/otp/request`, `POST /auth/otp/verify`, `GET /auth/me`, `POST /auth/logout`, `PATCH /users/me/profile` |
| Recherche et annonce | `GET /properties`, `GET /properties/:slug`, `GET /properties/:slug/contact`, `GET /locations` |
| Gestion annonceur | `POST /properties`, `GET /properties/me/list`, `GET /properties/me/:id/history`, `PATCH /properties/me/:id`, `PATCH /properties/me/:id/availability`, routes `media/*`, `POST /properties/me/:id/submit` |
| Favoris et notifications | `GET /users/me/favorites`, `POST/DELETE /users/me/favorites/:propertyId`, `GET /users/me/notifications`, `PATCH /users/me/notifications/:id/read` |
| Autorisation agent | `GET/POST /properties/:propertyId/assignments`, `DELETE /properties/:propertyId/assignments/:agentUserId` |
| Signalements | `POST /properties/:propertyId/reports` ou `POST /users/:targetUserId/reports` (connecté), routes correspondantes sous `/public/...` (email requis) |
| Administration | `/admin/properties/*`, `GET/PATCH /admin/reports`, `GET /admin/users`, `PATCH /admin/users/:id/status`, `GET /admin/audit-logs` |

Les paramètres et DTO précis sont documentés par Swagger en développement sur `/api/docs`. En production, la documentation interactive est désactivée sauf si `SWAGGER_ENABLED=true` est explicitement défini.

## Flux de validation

1. Un utilisateur s’authentifie par email ; le code expire après cinq minutes et ne peut être essayé que cinq fois.
2. Un propriétaire crée un brouillon pour son bien. Un agent indique le propriétaire et attend que celui-ci lui accorde une autorisation sur ce brouillon.
3. L’annonceur charge les images via une URL temporaire. L’API vérifie le type réel, la signature et la taille avant de rendre le média disponible.
4. La soumission exige une localisation, une photo terminée, une déclaration d’autorisation et la version actuelle des conditions.
5. Un modérateur traite l’annonce. Une annonce n’est publique que si elle est publiée et possède au moins une photo approuvée. Les comptes annonceur et propriétaire doivent aussi être actifs.
6. Les actions d’administration et les transitions d’état sont conservées dans l’historique et le journal d’audit. Les coordonnées ne sont renvoyées que par `/contact` lorsque le propriétaire a activé le canal correspondant.

## Variables et lancement

Copier `.env.example` vers `.env`, puis configurer une base PostgreSQL, SMTP et un bucket privé S3 compatible. `AUTH_OTP_PEPPER` doit contenir au moins 32 octets aléatoires. `WEB_ORIGIN` accepte une liste séparée par des virgules.

```sh
npm run db:generate
npm run build
npx prisma migrate deploy
npm run start:dev
```

La migration `20261126120000_mvp_operations` est additive : elle ajoute les tables et champs du périmètre MVP, sans effacer de données. Elle doit être appliquée après vérification de la sauvegarde et du statut de la base cible. Aucun reset n’est requis.

Pour initialiser le premier compte administrateur, créer d’abord son compte avec OTP, puis attribuer le rôle `ADMIN` à son adresse vérifiée depuis un canal d’exploitation sécurisé (requête SQL manuelle avec l’adresse exacte). L’API ne permet jamais à un utilisateur de s’attribuer le rôle administrateur. Les rôles `OWNER` et `AGENT` sont des choix d’inscription contrôlés par les règles métier ; toutes les autorisations sur les biens restent vérifiées côté serveur.

## Vérification locale

- `npm run build` compile l’API TypeScript.
- `npx prisma validate` vérifie le schéma.
- `npx prisma migrate status` vérifie l’état de la base et nécessite que PostgreSQL soit démarré.
- `npm run test` et `npm run test:e2e` exécutent les tests unitaires et les parcours API existants.

Les commandes de migration et de test d’intégration nécessitent une base dédiée. Ne jamais pointer les tests vers la base de production ni utiliser une commande `reset` sur des données à conserver.
