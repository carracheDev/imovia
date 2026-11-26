# Déployer l’API IMOVIA sur Render

Le dépôt reste un monorepo. Le Blueprint à la racine configure un seul service web Render avec `apps/api` comme dossier racine. Flutter, le design system et les documents ne sont donc pas des services Render.

## Mise en place

1. Pousser le dépôt complet sur GitHub, avec `render.yaml` à la racine.
2. Dans Render, créer un **Blueprint** et connecter le dépôt GitHub et la branche à déployer.
3. Vérifier les services proposés : `imovia-api` et `imovia-db`. Le Blueprint lance les migrations Prisma au démarrage puis démarre NestJS.
4. Renseigner les variables `SMTP_*`, `OBJECT_STORAGE_*` et, si nécessaire, `GOOGLE_MAPS_API_KEY` dans l’assistant Render. Ne pas ajouter les secrets dans GitHub.
5. Une fois le déploiement terminé, vérifier `https://<service>.onrender.com/api/health`.
6. Configurer l’URL HTTPS de l’API dans `apps/mobile/lib/core/network/api_config.dart` pour les essais sur téléphone.

L’instance web gratuite Render s’endort après 15 minutes sans requête et son réveil peut prendre environ une minute. Le PostgreSQL gratuit est limité à 1 Go, n’a pas de sauvegardes et expire après 30 jours. Ces ressources conviennent à un bac à sable temporaire, pas à la conservation de données importantes.

Le service gratuit ne peut pas envoyer d’e-mails par SMTP sur les ports 25, 465 ou 587. Le Blueprint utilise le port TLS 2525 ; le fournisseur SMTP choisi doit le prendre en charge. Sinon, il faudra utiliser une instance Render payante ou adapter la livraison OTP à une API e-mail HTTPS.

Les photos nécessitent un stockage objet S3 compatible accessible par URL publique pré-signée. Le disque local du service Render n’est pas utilisé pour les médias. Configurer un bucket séparé et ses identifiants avant de tester l’envoi de photos.
