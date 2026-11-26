# Déployer l’API IMOVIA sur Render avec Neon

Le dépôt reste un monorepo. Le Blueprint à la racine configure uniquement le service API Render, avec `apps/api` comme dossier racine. PostgreSQL est fourni séparément par Neon.

## Mise en place

1. Pousser le dépôt complet sur GitHub, avec `render.yaml` à la racine.
2. Dans Render, choisir **New → Blueprint**, connecter `carracheDev/imovia` et sélectionner `main`.
3. Vérifier que le Blueprint ne prévoit que le service `imovia-api`.
4. Dans Neon, copier l’URL poolée de la branche à utiliser dans `DATABASE_URL` et l’URL directe dans `DIRECT_URL`. Garder le paramètre SSL de Neon dans les deux URLs.
5. Ajouter les variables SMTP et `OBJECT_STORAGE_*` dans le formulaire sécurisé Render. Ne pas déposer les secrets dans GitHub ni les envoyer dans un chat.
6. Déployer, suivre les journaux, puis vérifier `https://<service>.onrender.com/api/health`.
7. Configurer l’application Flutter avec l’URL de l’API pour les essais :

   ```sh
   flutter run --dart-define=API_BASE_URL=https://<service>.onrender.com/api
   ```

L’API utilise `DATABASE_URL` pour ses requêtes. Prisma lit `DIRECT_URL` pour appliquer les migrations au démarrage. En local, si `DIRECT_URL` est absent, Prisma retombe sur `DATABASE_URL`.

Le service web gratuit Render s’endort après 15 minutes sans requête et son réveil peut prendre environ une minute. Le service gratuit ne peut pas envoyer d’e-mails sur les ports SMTP 25, 465 ou 587 ; ce Blueprint utilise TLS sur le port 2525, que le relais SMTP doit accepter. Sinon, prendre un service Render payant ou adapter la livraison OTP à une API e-mail HTTPS.

Les photos nécessitent un stockage objet S3 compatible accessible par URL pré-signée. Le disque local Render n’est pas utilisé pour les médias. Configurer un bucket et ses identifiants avant de tester les téléversements.
