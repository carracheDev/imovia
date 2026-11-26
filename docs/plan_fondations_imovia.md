# Plan de fondations IMOVIA

## 1. Objectif de cette étape

Cette étape a pour but de poser les bases du produit avant le développement des écrans et du backend.

Elle permet de verrouiller :
- le périmètre MVP,
- les profils utilisateurs,
- les statuts et permissions,
- les règles de confiance,
- la direction visuelle,
- les fondations backend.

Le but n’est pas de tout construire d’un coup, mais de poser une base solide pour aller vite sans perdre l’alignement.

---

## 2. Ordre de lancement recommandé

On suit l’ordre suivant :

1. Plan produit / périmètre
2. Fondations UX / design
3. Fondations backend
4. MVP
5. V2
6. V3

L’ordre est important : on veut éviter de concevoir un design sans logique métier, et un backend sans parcours utilisateur cohérent.

---

## 3. Positionnement produit IMOVIA

### 3.1. Positionnement général

IMOVIA est une plateforme immobilière premium et fiable, destinée au marché béninois.

Elle doit rassurer, clarifier et sécuriser la recherche et la publication d’offres immobilières.

La promesse de marque est :
- immobilier transparent,
- annonces fiables,
- parcours rassurant,
- confiance sur le marché local,
- outil professionnel pour les acteurs du secteur.

### 3.2. Différenciation

IMOVIA ne doit pas être un simple site d’annonces.

Sa vraie valeur est :
- la confiance,
- la clarté des statuts,
- la qualité de la modération,
- la fiabilité des informations,
- la compréhension du marché local,
- la gestion professionnelle des biens.

---

## 4. Périmètre par phase

## 4.1. MVP

### Objectif

Lancer un produit utile et crédible pour :
- les visiteurs qui cherchent un bien,
- les propriétaires qui veulent publier,
- les agents qui gèrent des biens,
- l’équipe IMOVIA qui modère et valide.

### Inclusions MVP

- catalogue de biens ;
- recherche et filtres de base ;
- fiche détaillée de bien ;
- publication de bien ;
- gestion du statut d’une annonce ;
- modération et validation ;
- fichiers photos et vidéos de base ;
- profils utilisateur et annonceur ;
- préférence de contact ;
- signalements basiques ;
- notifications essentielles ;
- historique d’état ;
- gestion admin simple ;
- rôles et permissions de base ;
- API centrale et backend de base.

### Hors scope du MVP

- site web public / landing page / PWA ;
- gestion avancée des services immobiliers ;
- marketplace de prestataires ;
- paiements / commission transactionnelle ;
- outils premium avancés ;
- analytics avancés ;
- services de forte complexité non nécessaires au lancement.

## 4.2. V2

### Objectif

Faire du produit un outil d’exploitation plus solide.

### Inclusions V2

- demandes de visite ;
- calendrier de visite ;
- messagerie interne ;
- signalements avancés ;
- vérification documentaire ;
- gestion opérationnelle des demandes ;
- back-office plus avancé ;
- reporting interne ;
- permissions plus fines ;
- gestion plus lourde de l’audit.

## 4.3. V3

### Objectif

Étendre IMOVIA à un écosystème immobilier plus large.

### Inclusions V3

- services immobiliers ;
- catalogue de prestations ;
- prestataires ;
- demandes de service ;
- outils professionnels premium ;
- portail/marketing plus avancé ;
- nouveaux modules business et de croissance.

---

## 5. Utilisateurs et rôles

## 5.1. Chercheur / visiteur

Le chercheur consulte le catalogue, filtre, compare et peut demander une visite.

## 5.2. Propriétaire

Le propriétaire publie et gère ses biens.

## 5.3. Agent immobilier

L’agent gère des biens qui lui sont attribués avec autorisation claire.

## 5.4. Admin IMOVIA

L’admin gère la modération, les comptes, les signalements, les statuts et les permissions.

## 5.5. Prestataire (phase V2/V3)

Le prestataire intervient dans les services immobiliers et les offres associées.

---

## 6. Règles de confiance et de sécurité

La confiance est un axe fondamental du produit.

### 6.1. Règles métier clés

- une annonce ne doit pas être publiée sans validation ;
- chaque statut a un historique ;
- les documents privés ne doivent pas être exposés publiquement ;
- les frais éventuels doivent être clairs avant validation ;
- les permissions doivent être gérées côté backend ;
- les actions sensibles doivent être journalisées ;
- les signalements doivent avoir un parcours clair ;
- les vérification et labels doivent être précis et non trompeurs.

### 6.2. Règles de modération

Les annonces doivent être vérifiées selon :
- complétude,
- cohérence,
- qualité des médias,
- doublons,
- contenu interdit,
- signalements,
- autorisation du bien,
- disponibilité et exactitude des informations.

### 6.3. Labels de confiance

Le système doit distinguer :
- téléphone vérifié,
- profil examiné,
- pièce vérifiée,
- visite physique effectuée,
- anomalie signalée,
- document examiné,
- pièce de propriété déclarée.

Le libellé “vérifié” doit toujours être explicite et ne pas laisser penser qu’une garantie juridique totale existe.

---

## 7. Base de données et backend à poser dès maintenant

La base backend doit être construite selon le flux produit MVP.

### 7.1. Entités métiers à poser

- User
- Role
- Permission
- ProfileOwner
- ProfileAgent
- Admin
- Property
- PropertyListing
- PropertyStatusHistory
- Category
- PropertyCharacteristic
- MediaAsset
- Location
- SearchFilter
- Favorite
- Notification
- Report
- ModerationReview
- VisitRequest
- VisitSchedule
- AuditLog
- Session / AuthToken

### 7.2. Règles de modélisation

- distinguer bien / annonce / propriétaire / agent / gestionnaire ;
- distinguer statut d’annotation et statut de disponibilité ;
- garder l’historique des changements ;
- garder des permissions côté API ;
- séparer médias publics et médias privés ;
- prévoir des schemas de validation côté backend ;
- séparer les données de publication des données de contact.

### 7.3. Services backend prioritaires

- AuthService
- UserService
- ProfileService
- PropertyService
- ListingService
- MediaService
- ModerationService
- SearchService
- NotificationService
- AuditService

---

## 8. Fondations UX / design

### 8.1. Direction visuelle

La direction proposée est :
- noir profond,
- fond clair et fond sombre,
- gris comme base,
- hiérarchie claire,
- minimalisme premium,
- écrans très lisibles,
- cartes élégantes,
- boutons très visibles,
- utilisation de photos dans les écrans clés.

### 8.2. Palette de base

- noir principal : #0B0B0B
- gris foncé : #1F1F1F
- gris moyen : #6B7280
- gris clair : #E5E7EB
- blanc : #FFFFFF
- accent monochrome : #101114

Les couleurs de succès, d'erreur, d'avertissement et d'information sont réservées aux états fonctionnels ; elles ne font pas partie de la palette de marque.

### 8.3. Composants de base à faire d’abord

- bouton principal / secondaire / tertiaire
- input / textarea / select
- badge / statut / label
- carte de bien
- carte de résultats
- nav mobile
- menu principal
- filtre de recherche
- modal / bottom sheet
- notification toast
- table / KPI / dashboard admin

### 8.4. Écrans MVP prioritaires

La cartographie détaillée des écrans, par profil et par phase, se trouve dans [`IMOVIA_ecrans_MVP_par_utilisateur.md`](./IMOVIA_ecrans_MVP_par_utilisateur.md). Cette liste est limitée aux parcours du lancement ; les visites complètes, la messagerie et la vérification documentaire dédiée sont en V2, les parcours prestataire en V3.

#### Mobile
- accueil / découverte
- recherche
- résultats
- détail bien
- favori / liste de favoris
- publier une annonce
- mes annonces
- profil utilisateur
- paramètres
- notifications

#### Back-office
- dashboard admin
- gestion des annonces
- détail d’annonce
- modération
- gestion des utilisateurs
- signalements
- permissions et audit

---

## 9. Livrables attendus cette étape

Cette étape doit produire :

- un périmètre bien défini pour MVP / V2 / V3 ;
- un modèle métier centralisé ;
- la liste des profils et permissions ;
- la liste des statuts principaux ;
- la liste des entités backend clé ;
- les 3 parcours utilisateurs prioritaires ;
- la direction visuelle IMOVIA ;
- la palette et les tokens de base ;
- la liste des composants de base ;
- les écrans MVP sélectionnés.

---

## 10. Résultat attendu avant le développement réel

Avant de démarrer le développement complet, le projet doit être en capacité de répondre à ces questions :

- Qui utilise IMOVIA ?
- Quelles sont les actions clés ?
- Quelles sont les règles métier ?
- Quelles données sont obligatoires ?
- Quels statuts existent ?
- Qui peut faire quoi ?
- Quel est le cœur du MVP ?
- Quel est hors scope ?
- Quelle est la direction visuelle ?
- Quelles sont les fondations backend ?

Si ces points ne sont pas verrouillés, le développement devient dispersé.

---

## 11. Prochaine étape concrète

La prochaine étape logique est la création du plan MVP détaillé, avec :
- utilisateurs,
- parcours,
- fonctionnalités,
- modules backend,
- écrans mobile,
- pages back-office,
- priorités de livraison.

C’est la base sur laquelle les screens et l’API seront ensuite construits.
