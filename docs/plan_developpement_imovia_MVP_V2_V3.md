# Plan de développement IMOVIA par phases

## 1. Vision d'ensemble

IMOVIA est développé selon une logique de progression claire et réaliste :

- MVP : construire la base du produit, la confiance, le catalogue, la publication et la modération immobilières.
- V2 : faire fonctionner le produit comme un outil de gestion et d'exploitation opérationnelle.
- V3 : étendre le produit à un écosystème immobilier plus large avec des services, des prestataires et des usages avancés.

Cette séparation est essentielle pour éviter de construire un produit trop large, trop coûteux et trop complexe avant d'avoir validé le cœur du besoin.

---

## 2. Principe directeur

Le projet doit être développé en 3 niveaux de maturité :

1. Fondations produit, données et UX.
2. MVP à livrer en priorité.
3. V2 et V3 uniquement après validation des bases.

Le design system et le backend doivent être conçus en cohérence avec les règles métier, les rôles et les parcours utilisateurs.

---

## 3. Axe de travail : produit, UX et backend

Le développement suit trois axes simultanés :

### 3.1. Axe produit
- définir le périmètre MVP ;
- clarifier les profils utilisateurs ;
- définir les règles de publication et de modération ;
- valider les statuts et permissions ;
- préciser les éléments hors scope du MVP.

### 3.2. Axe UX / design
- fondations visuelles ;
- thème clair et sombre ;
- composants fondamentaux ;
- parcours utilisateur MVP ;
- écrans mobiles et back-office prioritaires.

### 3.3. Axe backend
- rôles et permissions ;
- authentification ;
- profils ;
- biens ;
- médias ;
- statut des annonces ;
- recherche ;
- modération ;
- APIs centralisées.

---

## 4. Phase 1 — Fondations

### Objectif

Définir les bases de travail du produit et garantir que le design et le backend suivent le même cadre métier.

### Livrables principaux

- cahier des charges finalisé et priorisé ;
- périmètre MVP défini ;
- périmètre V2 et V3 défini ;
- profils utilisateur validés ;
- rôles et permissions définis ;
- statuts des biens et annonces validés ;
- palette visuelle et style directionnel adopté ;
- design tokens et composants de base ;
- structure backend de base ;
- entités métiers principales définies.

### Travaux UI / Design

- palette de marque ;
- thème clair pour le MVP ; thème sombre reporté après validation produit ;
- typographie ;
- spacing ;
- boutons ;
- inputs ;
- cards ;
- badges ;
- navigation ;
- écrans pilotes du MVP.

### Travaux backend

- Auth / OTP / sessions ;
- Users / profils ;
- Roles / permissions ;
- Owner / Agent / Admin ;
- Entités Property, Listing, Media ;
- Catégories et caractéristiques ;
- Localités ;
- Statuts et historique ;
- API de base ;
- sécurité et validations backend.

### Hors scope de la fondation

- services immobiliers complets ;
- site public de marketing ;
- features premium ;
- monetisation avancée ;
- modules non essentiels au cœur du produit.

---

## 5. Phase 2 — MVP

### Objectif

Lancer une plateforme utile, crédible et exploitable centrée sur :
- le catalogue immobilier ;
- la publication d'annonces ;
- la modération ;
- la confiance ;
- la gestion simple des biens et des profils.

### Périmètre du MVP

#### 5.1. Fonctionnalités du MVP

- catalogue public des biens ;
- recherche et filtres de base ;
- fiche détaillée d'un bien ;
- publication d'une annonce par un propriétaire ou un agent ;
- gestion des biens et de leur statut ;
- soumission et modération des annonces ;
- photos et médias de base ;
- profils annonceur et propriétaire ;
- préférences de contact ;
- signalements basiques ;
- notifications essentielles ;
- historique des changements ;
- back-office admin simplifié ;
- journalisation des actions sensibles ;
- permissions de base ;
- recherche et affichage des biens selon la zone et les critères essentiels.

#### 5.2. UI du MVP

Application mobile :
- accueil / découverte ;
- recherche ;
- résultats ;
- détail de bien ;
- favoris ;
- publier une annonce ;
- mes annonces ;
- profil ;
- paramètres ;
- notifications ;
- messages de base si nécessaire.

Back-office :
- tableau de bord admin ;
- gestion des annonces ;
- détail d'une annonce ;
- modération ;
- validation / refus ;
- gestion des utilisateurs ;
- gestion des statuts ;
- signalements simples ;
- permissions et audit.

#### 5.3. Backend du MVP

- Authentification ;
- OTP et sessions ;
- profils utilisateur ;
- propriétaires / agents / admin ;
- publication et publication / soumission ;
- modération ;
- statuts d'annonce ;
- catégories et caractéristiques ;
- médias ;
- recherche et filtres ;
- notifications de base ;
- audit des actions sensibles ;
- API backend centralisée ;
- gestion des permissions ;
- stockage des médias ;
- validation côté backend.

#### 5.4. Hors scope du MVP

- paiement / encaissement ;
- commission transactionnelle ;
- services immobiliers complets ;
- prestataires avancés ;
- marketplace de services ;
- outils premium ;
- site public de marketing ;
- analytics avancés ;
- modèle économique complexe.

### Critères de fin du MVP

Le MVP est prêt lorsque :
- un visiteur peut consulter le catalogue ;
- un propriétaire peut publier un bien ;
- un agent peut gérer les biens pour lesquels il a une autorisation ;
- les annonces passent par une modération ;
- les photos se chargent correctement ;
- les filtres et recherches fonctionnent ;
- les permissions et rôles sont respectés ;
- le back-office permet un traitement minimal des annonces ;
- les données sensibles sont sécurisées ;
- la confiance est visible dans les statuts et la transparence de l'information.

---

## 6. Phase 3 — V2

### Objectif

Transformer IMOVIA en outil plus opérationnel, avec un meilleur parcours de gestion des demandes et un meilleur niveau de confiance.

### Périmètre V2

#### 6.1. Fonctionnalités de la V2

- demandes de visite complètes ;
- sélection de créneaux ;
- acceptation / refus / report / annulation ;
- historique des demandes ;
- messagerie interne ;
- signalements détaillés ;
- vérification documentaire ;
- gestion des pièces justificatives ;
- back-office plus complet ;
- gestion avancée des statuts ;
- reporting et analyses internes ;
- navigation plus fluide selon le type d’utilisateur ;
- amélioration des tableaux de bord et des tâches admin.

#### 6.2. UI V2

- demandes de visite ;
- calendrier de visites ;
- messagerie ;
- conversations ;
- signalements et traitement ;
- vérification des biens ;
- vues d’état détaillées ;
- back-office plus riche ;
- filtres avancés et dashboards admin.

#### 6.3. Backend V2

- demande de visite ;
- messagerie ;
- notifications avancées ;
- signalements ;
- vérification documentaire ;
- pièces et documents attachés ;
- historique détaillé ;
- demandes/réponses ;
- rapports et analytics internes ;
- permissions plus fines ;
- workflow administratif détaillé.

#### 6.4. Hors scope de la V2

- services immobiliers complets ;
- prestataires avancés ;
- site public marketing ;
- modèle économique premium ;
- fonctionnalités non directement liées à la gestion immobilière et à la confiance.

---

## 7. Phase 4 — V3

### Objectif

Étendre IMOVIA à un écosystème plus large autour des services immobiliers et des professionnels.

### Périmètre V3

#### 7.1. Fonctionnalités de la V3

- catalogue de services immobiliers ;
- gestion des prestataires ;
- demandes de service ;
- gestion des services par catégories ;
- outils de gestion pour professionnels ;
- offres premium ;
- services de vérification avancés ;
- outils d’analytics plus avancés ;
- site web public ou portail visuel ;
- extensions de marketing et d’acquisition ;
- modèles économiques plus complexes, une fois validés.

#### 7.2. UI V3

- services immobiliers ;
- fiches prestataires ;
- demandes de service ;
- back-office étendu ;
- site public ;
- modules premium ou outils pro ;
- dashboards avancés.

#### 7.3. Backend V3

- prestataires ;
- services catalog ;
- demandes de service ;
- catalogue / classification ;
- analytics et reporting avancés ;
- systèmes de facturation si validés ;
- gestion des abonnements / premium ;
- intégration marketing ;
- API étendue pour les services et prestataires.

#### 7.4. Conditions d'ouverture de la V3

La V3 ne doit pas démarrer avant :
- stabilisation du MVP ;
- validation des besoins réels ;
- validation juridique sur les commissions ou frais ;
- validation du modèle commercial ;
- validation des services et prestataires.

---

## 8. Rôle du site public / PWA / portail public

Le site public, la PWA ou un portail consultatif ne constituent pas le cœur fonctionnel de IMOVIA.

Ils sont considérés comme des canaux de visibilité et d'acquisition :
- utiles pour la diffusion des annonces publiques ;
- utiles pour le référencement ;
- utiles pour impression de marque ;
- utiles pour la visibilité du catalogue.

### Positionnement recommandé

- MVP : hors périmètre principal ;
- V2 : optionnel, si besoin de visibilité et d’acquisition est confirmé ;
- V3 : possible en fonction du besoin commercial et du positionnement stratégique.

Le site public ne doit pas retarder la livraison du produit principal.

---

## 9. Plan de travail recommandé

### 9.1. Priorité 1 : Fondations
- cahier des charges finalisé ;
- design tokens ;
- UX base ;
- modèles de données ;
- rôles et permissions ;
- statuts et coutures ;
- base API.

### 9.2. Priorité 2 : MVP
- backend central ;
- auth ;
- biens ;
- médias ;
- modération ;
- recherche ;
- design mobile et admin basics ;
- validations de parcours.

### 9.3. Priorité 3 : V2
- demande de visite ;
- messagerie ;
- signalements ;
- vérification documentaire ;
- avancées back-office ;
- reporting interne.

### 9.4. Priorité 4 : V3
- services immobiliers ;
- prestataires ;
- site public ;
- modules premium ;
- extension de l’écosystème.

---

## 10. Conclusion

Le bon développement de IMOVIA ne doit pas viser immédiatement tout le système complet. Il doit s'articuler autour d'un cœur très clair :

- confiance ;
- catalogue ;
- publication ;
- modération ;
- données propres ;
- permissions ;
- produits de base.

Ensuite, le produit peut évoluer vers :
- gestion opérationnelle (V2) ;
- écosystème immobilier (V3).

C’est la manière la plus disciplinée pour construire une plateforme sérieuse, exploitable et crédible au Bénin.
