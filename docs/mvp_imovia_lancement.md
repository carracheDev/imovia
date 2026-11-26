# MVP IMOVIA — version de lancement

## 1. Objectif du MVP

Le MVP d'IMOVIA vise à lancer un produit utile, crédible et exploitable sur le marché béninois, centré sur le cœur de valeur suivant :

- un catalogue immobilier fiable ;
- une recherche simple et exploitable ;
- une publication de biens claire et contrôlée ;
- une modération structurée et transparente ;
- une confiance accrue entre chercheurs, propriétaires et agents ;
- un back-office minimal mais fonctionnel pour gérer les annonces et les utilisateurs.

Le MVP doit permettre de tester le modèle de confiance sur le terrain sans surcharger le produit avec des fonctionnalités non essentielles.

---

## 2. Vision du produit

IMOVIA est une plateforme immobilière qui aide les utilisateurs à trouver, publier, gérer et vérifier des biens immobiliers de manière plus claire et plus fiable.

La promesse produit est la suivante :
- faciliter la recherche d’un bien ;
- sécuriser les annonces ;
- donner des outils simples aux propriétaires et agents ;
- aider l’équipe IMOVIA à modérer les contenus et contrôler la qualité.

---

## 3. Publics cibles

### 3.1. Chercheur / visiteur

Le chercheur cherche un logement, terrain, local ou bien immobilier à acheter ou louer.

Il veut :
- trouver rapidement un bien ;
- filtrer efficacement ;
- comparer les offres ;
- savoir si l’annonce est fiable ;
- contacter l’annonceur selon ses préférences ;
- demander une visite dans le parcours opérationnel complet prévu en V2.

### 3.2. Propriétaire

Le propriétaire veut publier et gérer ses biens sans confusion.

Il veut :
- publier une annonce en quelques étapes ;
- ajouter des photos et une ou plusieurs vidéos du bien ;
- définir son statut de disponibilité ;
- contrôler la publication ;
- gérer les demandes de contact ;
- suivre l’état de son annonce.

### 3.3. Agent immobilier

L’agent immobilier gère des biens pour lesquels il a un mandat ou une autorisation.

Il veut :
- gérer plusieurs biens ;
- publier ou modifier des annonces ;
- suivre les demandes ;
- respecter les permissions ;
- travailler via une interface simple et claire.

### 3.4. Admin IMOVIA

L’admin gère le fonctionnement de la plateforme.

Il doit :
- valider les annonces ;
- demander un complément ;
- refuser ou publier ;
- contrôler les signalements ;
- gérer les comptes ;
- gérer les permissions ;
- suivre les journaux et actions critiques.

---

## 4. Périmètre du MVP

### 4.1. Fonctionnalités incluses

Le MVP inclut :

- recherche de biens ;
- filtres par zone, type, prix, disponibilité et catégorie ;
- recherche autour d'un lieu choisi, avec rayon de recherche ;
- fiche détaillée d’un bien ;
- sélection et affichage cartographique de la localisation ;
- téléversement et affichage de photos et de vidéos dans les annonces ;
- publication d’annonce ;
- gestion des statuts de publication ;
- modération de base ;
- signalements basiques ;
- préférences de contact ;
- notifications essentielles ;
- historique des changements de statut ;
- gestion des profils annonceur / agent ;
- espace admin de modération ;
- backend centralisé ;
- permissions et rôles de base ;
- validations serveur.

Les vidéos font bien partie du MVP. Elles sont facultatives pour une annonce, mais les annonceurs doivent pouvoir en ajouter et les chercheurs doivent pouvoir les lire depuis la fiche du bien. Elles sont soumises à des contrôles de format, de taille et de durée qui seront définis avant l'implémentation, ainsi qu'à la modération. Les médias privés de vérification restent séparés et ne sont jamais affichés dans la galerie publique.

### Localisation et carte dans le MVP

La localisation est une fonction centrale du MVP. Elle ne doit pas se limiter à un texte libre ni à un simple nom de commune.

Le parcours annonceur doit permettre de :
- rechercher un lieu et choisir une suggestion de localisation ;
- associer la localisation choisie au bien et enregistrer ses coordonnées lorsque disponibles ;
- vérifier le lieu sélectionné avant de soumettre l'annonce.

Le parcours de recherche doit permettre de :
- rechercher par département, commune, arrondissement ou quartier ;
- choisir un lieu de référence et filtrer les biens dans un rayon ;
- consulter la localisation du bien sur une carte depuis sa fiche.

Les services de recherche d'adresse et de suggestions Google Places sont appelés par l'intermédiaire du backend. Les clés secrètes ne doivent pas être intégrées à l'application mobile.

#### Confidentialité de la localisation

- La carte publique montre une position approximative (zone ou quartier), pas le point exact du bien.
- Les coordonnées précises, lorsqu'elles sont disponibles, restent privées et ne sont accessibles qu'aux personnes autorisées pour la gestion ou la modération.
- L'adresse précise peut être communiquée par l'annonceur au chercheur selon ses préférences et le déroulement du contact ou de la visite.
- Une annonce sans coordonnées précises reste publiable si une localisation administrative suffisamment précise a été fournie ; elle ne sera alors pas présentée comme géolocalisée précisément.

### 4.2. Fonctionnalités hors scope du MVP

Le MVP ne comprend pas :

- site web public / landing page / PWA ;
- services immobiliers complets ;
- marketplace de prestataires ;
- paiements et encaissements ;
- commissions transactionnelles ;
- gestion avancée des visites ;
- messagerie avancée ;
- outils premium ;
- analytics avancés ;
- modèles économiques complexes.

---

## 5. Parcours utilisateurs critiques

## 5.1. Parcours 1 — recherche et consultation

1. Le visiteur ouvre l’application.
2. Il consulte le catalogue.
3. Il filtre selon la localisation, les types de biens et le budget, ou recherche autour d'un lieu choisi.
4. Il consulte la fiche d’un bien.
5. Il consulte les photos, peut lire les vidéos, examine les détails et voit une position approximative sur la carte.
6. Il peut enregistrer le bien en favori.
7. Il peut contacter l'annonceur selon ses préférences. La demande et la coordination complètes d'une visite (créneaux, réponse, report, annulation et historique) sont planifiées en V2.

### Critère de succès

Le visiteur peut trouver un bien et comprendre rapidement s’il est pertinent.

## 5.2. Parcours 2 — publication d’annonce

1. L’annonceur se connecte.
2. Il choisit le profil annonceur ou agent.
3. Il remplit les informations du bien.
4. Il choisit la localisation du bien, ajoute au moins une photo et peut ajouter une ou plusieurs vidéos.
5. Il indique les préférences de contact.
6. Il soumet l’annonce.
7. L’annonce passe en modération.
8. Elle est acceptée, refusée ou renvoyée à compléter.

### Critère de succès

L’annonceur peut publier une annonce sans confusion, et l’équipe IMOVIA reçoit une publication propre et exploitable.

## 5.3. Parcours 3 — modération admin

1. L’admin ouvre le tableau de bord.
2. Il vérifie la file d’annonces.
3. Il consulte les détails, statuts et médias.
4. Il valide, demande un complément ou refuse.
5. Il enregistre une décision et l’historique.
6. L’annonce passe dans le bon état.

### Critère de succès

L’admin peut traiter les annonces rapidement et de façon traçable.

## 5.4. Parcours 4 — gestion et confiance

1. Le propriétaire modifie une annonce.
2. Le système conserve l’historique.
3. Le statut change si besoin.
4. L’admin peut revoir la décision ou le bien.
5. Le visiteur peut voir un statut clair et fiable.

### Critère de succès

La confiance est visible dans la transparence des critiques, des statuts et de l’historique.

---

## 6. Modèle de données MVP

### 6.1. Entités clés

- User
- Role
- Permission
- OwnerProfile
- AgentProfile
- AdminProfile
- Property
- Listing
- PropertyStatus
- PropertyStatusHistory
- Category
- PropertyCharacteristic
- MediaAsset
- Location
- Favorite
- Notification
- Report
- ModerationReview
- AuditLog
- AuthSession

### 6.2. Règles de modélisation

- distinguer bien, annonce et gestionnaire de bien ;
- distinguer annonceur réel, agent mandaté et propriétaire déclaré ;
- garder l’historique des changements d’état ;
- conserver latitude et longitude lorsqu'elles sont disponibles, sans rendre ces coordonnées exactes publiques ;
- conserver les informations administratives de localisation même si aucune coordonnée n'est disponible ;
- distinguer les médias publics de l'annonce (photos et vidéos) des documents privés de vérification ;
- enregistrer le type et les métadonnées nécessaires de chaque média ;
- contrôler le téléversement et l'accès aux médias côté serveur ;
- sécuriser les pièces et documents ;
- stocker les permissions côté backend ;
- séparer les informations de contact des données publiques.

---

## 7. Statuts du MVP

Les statuts doivent être clairs et exploitables.

### 7.1. Statuts pour une annonce

- brouillon ;
- soumise ;
- en examen ;
- à compléter ;
- en vérification ;
- publiée ;
- refusée ;
- suspendue ;
- expirée ;
- indisponible.

### 7.2. Statuts de vérification

- téléphone vérifié ;
- profil examiné ;
- documents examinés ;
- visite physique effectuée ;
- anomalie signalée.

### 7.3. Règle essentielle

Chaque statut doit être compréhensible pour l’utilisateur et ne doit pas laisser croire à une validation totale ou absolue.

---

## 8. Rôles et permissions MVP

### 8.1. Roles

- visiteur / chercheur ;
- propriétaire ;
- agent immobilier ;
- admin IMOVIA.

### 8.2. Permissions de base

- visiter le catalogue ;
- publier une annonce ;
- modifier ses propres annonces ;
- voir les annonces publiées ;
- soumettre une annonce ;
- modérer une annonce ;
- suspendre ou refuser une annonce ;
- gérer les comptes ;
- journaliser les actions sensibles.

### 8.3. Règle de sécurité

La permission d’accès doit être contrôlée par le backend, pas seulement par l’interface.

---

## 9. UX / design MVP

## 9.1. Direction visuelle

La direction graphique doit rester premium, sobre, technologique et rassurante.

Les principes :
- fond noir profond ou gris profond ;
- cartes claires ;
- export premium minimal ;
- hiérarchie forte ;
- grandes images de biens ;
- boutons visibles et lisibles ;
- grande clarté autour de la confiance et de la qualité.

## 9.2. Écrans prioritaires du MVP

La référence détaillée des écrans et de leur attribution par profil/phase est [`IMOVIA_ecrans_MVP_par_utilisateur.md`](./IMOVIA_ecrans_MVP_par_utilisateur.md). Utiliser cette cartographie pour les maquettes et distinguer le contact simple du parcours complet de visites prévu en V2.

### Mobile
1. Accueil / découverte
2. Recherche
3. Résultats
4. Détail d’un bien
5. Favoris
6. Publier une annonce
7. Mes annonces
8. Profil utilisateur
9. Paramètres
10. Notifications

### Back-office web
1. Tableau de bord admin
2. Gestion des annonces
3. Détail d’annonce
4. Modération / validation
5. Utilisateurs
6. Signalements
7. Permissions et sécurité
8. Historique / audits

### 9.3. Objets visuels à prioriser

- carte bien
- fiche bien
- champ d'autocomplétion de lieu
- aperçu cartographique avec position approximative
- sélection du lieu et indication du rayon de recherche
- badge de statut
- recherche et filtres
- bouton CTA principal
- liste d’annonce
- modale de validation
- page admin de modération

---

## 10. Backend MVP - modules prioritaires

### 10.1. Modules obligatoires

- Auth & sessions
- Users & profiles
- Roles & permissions
- Properties
- Listings
- Media management
- Moderation
- Search & filters
- Notifications
- Audit logging

### 10.2. Modules non prioritaires pour le MVP

- services immobiliers
- prestataires
- demandes de service
- intégration premium / abonnement
- analytics avancés
- site public / PWA

---

## 11. Critères de validation du MVP

Le MVP est validé si :

- un visiteur peut trouver un bien ;
- une annonce peut être publiée correctement ;
- l’admin peut modérer les annonces ;
- les statuts sont compréhensibles ;
- les permissions sont respectées ;
- les données sensibles sont protégées ;
- les photos et vidéos sont associées au bon bien, contrôlées et affichées dans sa fiche ;
- la lecture des vidéos fonctionne sur les appareils mobiles pris en charge ;
- la recherche par lieu et rayon fonctionne lorsque des coordonnées sont disponibles ;
- la carte publique ne révèle pas la position exacte du bien ;
- le parcours recherche → détail → contact est fluide ;
- le parcours publication → modération → publication est fiable.

---

## 12. Ce qui est hors scope du MVP de lancement

Le MVP ne doit pas inclure :

- site public et marketing
- services immobiliers complets
- prestataires / services tiers
- paiement et encaissement
- modèle économique avancé
- fonctionnalités de croissance prématurées
- outils premium complexes

Le produit doit d’abord être fiable, crédible et exploitable avant d’être élargi.

---

## 13. Plan de livraison recommandé pour le lancement

### Phase 1 — préparation
- finaliser le périmètre ;
- valider les profils ;
- valider les statuts ;
- valider les règles de modération ;
- valider la charte visuelle ;
- préparer les entités backend.

### Phase 2 — MVP fonctionnel
- développer les utilisateurs, rôles et auth ;
- développer les biens et médias ;
- développer la recherche ;
- développer la publication ;
- développer la modération ;
- tester les parcours clés ;
- valider la sécurité et les permissions.

### Phase 3 — extensions après lancement
- **V2 :** parcours complet des demandes de visite, messagerie interne, signalements avancés et vérification documentaire dédiée ;
- **V3 :** services immobiliers et parcours prestataire.

---

## 14. Conclusion

Le MVP IMOVIA doit être durable, crédible et orienté confiance. Il n’a pas pour objectif de couvrir tout le secteur immobilier dès le départ.

Son rôle est simple :
- permettre à un chercheur de trouver des biens ;
- permettre à un annonceur de publier sereinement ;
- permettre à l’équipe IMOVIA de modérer proprement ;
- créer une base solide pour la croissance future.

C’est cette base qui permettra à IMOVIA de devenir un produit fiable, crédible et scalable sur le marché béninois.
