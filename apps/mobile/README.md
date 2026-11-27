# IMOVIA mobile

Socle Flutter MVP. Aucun écran produit n’est inclus à ce stade : l’architecture, les tokens visuels et l’inventaire des composants sont définis avant de commencer les pages.

## Architecture

MVVM par feature : écran → ViewModel → interface de repository → repository API → services Dio. Riverpod fournit l’injection et les états ; GoRouter sera activé avec le premier parcours validé. Les DTO restent typés et convertis manuellement pour éviter la génération de code tant que le volume du MVP ne le justifie pas.

Voir [architecture mobile](../../docs/mobile-architecture.md) et [composants MVP](../../docs/mobile-components-mvp.md).

## API

Par défaut, l’application utilise l’API Render de production :
`https://imovia-1.onrender.com/api/`.

Pour le développement local, remplace l’URL au lancement avec `API_BASE_URL`.

Android Emulator :

```sh
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/
```

iOS Simulator :

```sh
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000/api/
```

Une URL déployée doit utiliser HTTPS. L’autorisation cleartext Android est limitée au manifeste debug. L’API expose son contrôle de santé sur `GET /api/health`.

## Validation du socle

```sh
flutter analyze
flutter test
```

Chaque lot de pages aura ses tests unitaires et widget, et les tests Flutter devront être verts avant de poursuivre au lot suivant.
