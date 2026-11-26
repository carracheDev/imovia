# IMOVIA
## Cahier des charges fonctionnel et technique — Version 3.0

**Slogan :** L'immobilier en toute confiance.  
**Version :** 3.0 — Découpage en phases MVP / V2 / V3  
**Date :** Novembre 2026  
**Marché de lancement :** République du Bénin  
**Application principale :** Flutter (Android et iOS)  
**Back-office :** Application web d'administration  
**Backend :** API centralisée  
**Statut :** Document de référence pour la conception, le développement, la validation par phases et le lancement progressif.

---

# 0. Décision de structuration du projet

Les décisions suivantes constituent le cadre de référence de cette version :

1. IMOVIA est développé en trois phases distinctes : MVP, V2 et V3.
2. Le MVP est centré sur la confiance, le catalogue, la publication et la modération immobilières.
3. La V2 ajoute les outils d'exploitation, de gestion et de traitement des demandes opérationnelles.
4. La V3 étend la plateforme à des services et des usages plus avancés liés à l'écosystème immobilier.
5. L'application mobile Flutter reste le produit principal, avec un back-office web dédié et un backend centralisé.
6. Les biens immobiliers, les opérations, les services et les profils professionnels sont distingués comme univers fonctionnels clairs.
7. Les fonctionnalités trop larges ou non essentielles au lancement ne sont pas prévues dans le MVP.
8. Les décisions juridiques, économiques et de conformité doivent être validées avant activation des modèles de commission ou d'encaissement.

---

# 1. Présentation générale

## 1.1. Présentation de IMOVIA

IMOVIA est une plateforme numérique immobilière destinée à organiser et faciliter la recherche, la publication, la consultation, la gestion et la modération des offres immobilières au Bénin.

Elle met en relation :
- les personnes qui recherchent un logement, un terrain ou un local ;
- les propriétaires qui souhaitent présenter et gérer leurs biens ;
- les agents immobiliers qui gèrent des biens pour leur compte ou pour celui de propriétaires ;
- les équipes IMOVIA chargées de l'administration, de la modération et des vérifications ;
- les prestataires et services liés à l'immobilier dans les phases ultérieures.

IMOVIA vise à rendre le marché immobilier plus lisible, plus fiable et plus sécurisé, en particulier dans un contexte où les risques de fraude, de manque de transparence et de manque de confiance sont réels.

## 1.2. Vision

Devenir la plateforme immobilière de référence au Bénin, reconnue pour la qualité de ses annonces, la transparence de ses informations, la qualité de sa modération et la confiance qu'elle inspire aux utilisateurs.

## 1.3. Mission

Rendre le marché immobilier béninois plus accessible, lisible et organisé grâce à des outils numériques adaptés aux pratiques locales, à la réalité du marché et à la nécessité de sécuriser les échanges.

## 1.4. Objectif général de la stratégie par phases

Le développement de IMOVIA s'organise autour de trois niveaux de maturité :

- la création d'un noyau fiable et utile (MVP) ;
- l’extension de la gestion immobilière et de l’exploitation (V2) ;
- l’élargissement de l’écosystème immobilier et des services associés (V3).

Cette logique évite de lancer une plateforme trop large et trop complexe avant que le besoin central ne soit validé.

---

# 2. Périmètre du produit et plateformes

## 2.1. Application mobile IMOVIA

L'application mobile est le produit principal destiné au grand public, aux annonceurs et aux professionnels.

Elle est développée avec Flutter et cible :
- Android ;
- iOS.

L'application doit permettre :
- la recherche de biens ;
- la consultation des fiches ;
- la publication d'annonces ;
- la gestion des biens par les annonceurs ;
- la consultation des préférences de contact ;
- le traitement des demandes de visite ;
- le suivi des demandes de service dans les phases avancées.

## 2.2. Back-office web

Le back-office est une interface web dédiée à l'équipe IMOVIA. Il permet de gérer les contenus, les profils, les signalements, les modérations, les vérifications et les statuts d'annonces.

Il doit être opérationnel dès le lancement du produit. Il ne doit pas être réduit à un simple tableau de bord. Il doit être un outil réel de gestion, de validation et de pilotage opérationnel.

## 2.3. Backend et API centrale

Le backend centralise les règles métier, les données, les permissions et les traitements.

L'application mobile et le back-office utilisent la même API et les mêmes données, avec des permissions distinctes selon le profil utilisateur et le rôle associé.

Aucune règle métier critique ne doit dépendre uniquement du frontend.

## 2.4. Structure de développement par phases

IMOVIA est conçu comme un produit à développement progressif :

- MVP : confiance, catalogue et publication immobilière ;
- V2 : gestion opérationnelle, visite, messagerie, modération avancée ;
- V3 : extension à l'écosystème immobilier et services professionnels.

## 2.5. Canal web public / site public / PWA

Le site web public, la PWA ou un portail public de consultation ne constituent pas le cœur fonctionnel de IMOVIA ni du MVP.

Ils sont considérés comme des canaux complémentaires de visibilité, d'acquisition et de partage de fiches publiques. Leur objectif est d’augmenter la visibilité du catalogue et de faciliter l’accès aux biens, mais ils ne doivent pas être prioritaires avant la livraison du cœur du produit : application mobile, back-office et API centrale.

Leur mise en place est donc :
- hors périmètre du MVP ;
- optionnelle dans la V2 si le besoin de visibilité et d’acquisition est validé ;
- potentiellement plus développé dans la V3 si le produit est bien stabilisé et que le besoin marketing est avéré.

Ils ne doivent jamais devenir un facteur de retard sur la mise en production du produit principal.

---

# 3. Découpage fonctionnel par phase

## 3.1. Phase 1 — MVP : les bases du marché immobilier fiable

### Objectif

Lancer une plateforme utile, crédible et exploitable dans un premier cycle, centrée sur :
- le catalogue immobilier ;
- la publication de biens ;
- la modération des annonces ;
- la confiance utilisateur ;
- la gestion simple des biens et des annonceurs.

### Valeur produite

Le MVP permet à un chercheur de découvrir des biens, à un propriétaire de publier un bien et à l'équipe IMOVIA de le contrôler avant publication.

### Fonctionnalités attendues

- catalogue public des biens ;
- recherche et filtres essentiels ;
- fiche détaillée d'un bien ;
- publication d'une annonce par un propriétaire ou un agent ;
- gestion du statut de l'annonce (brouillon, soumise, en examen, publiée, refusée, à compléter, suspendue) ;
- ajout de photos ;
- gestion des préférences de contact ;
- conditions de visite ;
- signalements de base ;
- gestion des profils annonceurs ;
- modération de base ;
- historique des changements d'état ;
- notifications essentielles ;
- gestion administrateur simplifiée ;
- journalisation des actions sensibles ;
- gestion des permissions par rôle.

### Hors scope du MVP

- commission transactionnelle activée ;
- encaissement de loyers ou de prix de vente ;
- paiement complexe ;
- services immobiliers complets ;
- gestion avancée des prestataires ;
- marketplace professionnelle de services ;
- outils premium pour agences ;
- analytics d'exploitation avancés ;
- fonctionnalités de monetisation complexe.

### Critères de réussite du MVP

Le MVP est considéré comme réussi lorsque :
- un visiteur peut consulter le catalogue ;
- un propriétaire peut publier un bien ;
- un agent peut gérer les biens pour lesquels il a une autorisation ;
- une annonce passe par une modération ;
- des photos peuvent être téléversées et affichées ;
- les recherches et filtres essentiels fonctionnent ;
- la fiche détaillée est consultable et partagée ;
- les moyens de contact respectent les préférences de confidentialité ;
- le back-office permet de traiter la modération et les statuts ;
- les opérations sensibles sont journalisées.

## 3.2. Phase 2 — V2 : opération immobilière et gestion des demandes

### Objectif

Ajouter les outils nécessaires à une exploitation plus professionnelle du produit avec une meilleure gestion des opérations immobilières et des interactions entre annonceurs et chercheurs.

### Valeur produite

La V2 permet de transformer IMOVIA d'un catalogue modéré en une plateforme opérationnelle, avec plus de traçabilité et une meilleure expérience de gestion des demandes.

### Fonctionnalités attendues

- demandes de visite complètes ;
- proposition de créneau, acceptation, refus, report, annulation ;
- historique des demandes et conditions acceptées ;
- messagerie interne entre chercheur et annonceur ;
- gestion des signalements détaillée ;
- modération avancée et traitement des plaintes ;
- vérification documentaire et profil plus stricte ;
- gestion des permissions plus fine par rôle ;
- amélioration du back-office admin ;
- suivi des demandes de service dans les limites du cas réel ;
- reporting interne sur les annonces, les demandes et les délais ;
- meilleure gestion des catégories, sous-catégories et caractéristiques configurables ;
- gestion des doublons et des contenus non conformes ;
- amélioration de la traçabilité des décisions et actions de modération.

### Sous-ensembles concernés

- visites ;
- messagerie ;
- signalements ;
- vérification ;
- audit ;
- reporting interne ;
- gestion de contenus et paramètres.

### Hors scope de la V2

- services immobiliers complets ;
- marketplace large de prestataires ;
- modèle de paiement non validé juridiquement ;
- outils premium avancés ;
- expansion de l'écosystème à des services non directement liés à la transaction et à la confiance immobilière.

## 3.3. Phase 3 — V3 : écosystème immobilier et services associés

### Objectif

Construire un environnement plus large autour des biens immobiliers, des services et des acteurs professionnels, sans perdre le cœur de confiance initiale.

### Valeur produite

La V3 transforme IMOVIA en plateforme plus complète, capable d’accueillir des services immobiliers, des prestataires, des outils d'exploitation et des modèles économiques impliquant plus de professionnels.

### Fonctionnalités attendues

- catalogue de services immobiliers ;
- gestion des prestataires et leur statut ;
- demandes de service ;
- gestion complète des prestataires ;
- offres premium ou outils professionnels ;
- gestion de portefeuille et de dossiers immobiliers plus complets ;
- services de vérification avancés ;
- support marketing de promotion ;
- outils internes d'analyse commerciale et d'exploitation ;
- extension du modèle économique après validation juridique et business ;
- services additionnels selon les besoins constatés sur le terrain.

### Conditions d'ouverture de la V3

La V3 ne doit pas être déclenchée avant :
- validation du marché, de la confiance et de la qualité du service ;
- validation juridique sur les commissions et frais ;
- validation du modèle opérationnel autour des services et prestataires ;
- stabilisation du MVP et de la V2.

---

# 4. Univers fonctionnels de IMOVIA

## 4.1. Univers 1 — Biens immobiliers

Cet univers regroupe les biens proposés à la location ou à la vente.

Catégories initialement prévues :
- chambre ;
- logement étudiant ;
- studio ;
- appartement ;
- maison ;
- villa ;
- terrain ;
- boutique ;
- local commercial ;
- bureau ;
- entrepôt ;
- immeuble ;
- autres espaces immobiliers configurables.

Chaque catégorie peut disposer de caractéristiques adaptées à son usage réel.

## 4.2. Univers 2 — Opérations immobilières

Chaque offre doit être rattachée à une opération clairement identifiée :
- location ;
- vente.

Selon l'opération, les données affichées doivent être explicites :
- loyer, caution, avance ou frais éventuels pour la location ;
- prix demandé, conditions et documents déclarés disponibles pour la vente.

Les informations doivent toujours être présentées de manière transparente. Les frais éventuels ne doivent pas être cachés ni rendus ambiguës.

## 4.3. Univers 3 — Services immobiliers

Les services immobiliers sont un univers distinct. Ils ne doivent pas être mélangés aux biens immobiliers.

Ils peuvent inclure, selon les compétences réellement tenues par la plateforme :
- gestion immobilière ;
- visites et accompagnement ;
- vérification ;
- production photo et vidéo ;
- travaux et entretien ;
- assistance et conseil ;
- services immobiliers complémentaires validés.

Ces services sont une extension naturelle de la plateforme, mais ne constituent pas la priorité de lancement.

---

# 5. Utilisateurs, profils et rôles

## 5.1. Chercheur / visiteur

Un chercheur est une personne qui consulte le catalogue, recherche un bien, compare les offres, contacte l'annonceur, peut enregistrer des biens en favoris et, en V2, gérer des demandes de visite complètes.

Un chercheur peut :
- chercher des biens ;
- filtrer par localisation, type de bien, budget, disponibilité ;
- consulter les fiches détaillées ;
- contacter l’annonceur selon les préférences de contact ;
- demander une visite dans le parcours complet prévu en V2 ;
- signaler une annonce suspecte.

## 5.2. Propriétaire

Un propriétaire publie et gère ses biens directement, ou via un agent mandaté.

Au MVP, il doit pouvoir :
- créer un bien ;
- compléter les informations ;
- téléverser des médias ;
- définir le statut de disponibilité ;
- modifier les informations disponibles ;
- recevoir les contacts selon ses préférences ;
- suivre l’historique du bien.

Le traitement des demandes de visite avec créneaux, réponses, reports, annulations et historique complet est prévu en V2.

## 5.3. Agent immobilier

Un agent immobilier peut gérer les biens pour lesquels il a reçu une autorisation ou un mandat déclaré.

Au MVP, un agent peut :
- gérer les biens de son portefeuille ;
- publier des annonces avec autorisation ;
- recevoir les contacts selon les préférences configurées ;
- mettre à jour les informations ;
- respecter les permissions définies pour chaque bien.

La coordination complète des visites et les outils avancés de portefeuille relèvent de la V2.

## 5.4. Admin IMOVIA

L'équipe IMOVIA est responsable de la modération, de la vérification, de la gestion des comptes et des contenus.

L'admin peut :
- examiner une annonce ;
- demander un complément ;
- refuser une annonce ;
- publier ou suspendre ;
- gérer les signalements ;
- contrôler les comptes et profils ;
- gérer les rôles et permissions ;
- surveiller les journaux d'audit.

## 5.5. Prestataire / service

Les prestataires sont une catégorie spécifique qui apparaît dans les phases V2/V3. Ils peuvent être des services externes ou des prestataires référencés selon les règles métiers et juridiques en vigueur.

---

# 6. Gestion des biens et annonces

## 6.1. Fiche d'un bien

Une fiche de bien peut contenir :
- titre ;
- catégorie ;
- opération ;
- description ;
- localisation (département, commune, arrondissement ou quartier) ;
- indications complémentaires ;
- prix demandé facultatif ;
- devise ;
- disponibilité ;
- caractéristiques ;
- conditions particulières ;
- photos et vidéos ;
- annonceur responsable ;
- statut de vérification.

Le prix peut être absent, auquel cas le système affiche "Prix sur demande".

## 6.2. Caractéristiques configurables

Les caractéristiques doivent être administrables depuis le back-office sans nécessiter une modification du code pour chaque nouvelle option simple.

Exemples :
- maison ou villa : chambres, salons, salles d'eau, cuisine, garage, cour, jardin, clôture, eau, électricité ;
- appartement : pièces, étage, ascenseur, parking, balcon, cuisine, salle d'eau ;
- terrain : superficie, forme, accès routier, viabilisation déclarée, usage prévu, documents déclarés disponibles ;
- local commercial : superficie, emplacement, accessibilité, eau, électricité et usage possible.

## 6.3. Disponibilité

Les états possibles incluent :
- disponible ;
- en cours de réservation ;
- indisponible ;
- loué ;
- vendu.

Une annonce indisponible ne doit plus apparaître dans les résultats actifs, sauf demande explicite du visiteur.

## 6.4. Relation annonceur — propriétaire — bien

Le modèle de données distingue clairement :
- le bien immobilier ;
- son propriétaire déclaré ;
- l'agent ou le compte gestionnaire ;
- l'autorisation ou le mandat ;
- l'annonce publiée ;
- l’historique des changements.

Cette distinction est indispensable pour éviter qu'un agent soit automatiquement considéré comme propriétaire du bien.

---

# 7. Publication et modération

## 7.1. Parcours de publication (MVP)

Le parcours de publication doit prévoir :
1. connexion de l'utilisateur ;
2. choix du profil annonceur ;
3. renseignement des informations du bien ;
4. ajout d’au moins une photo ;
5. ajout éventuel de vidéos ;
6. choix des préférences de contact ;
7. saisie des conditions de visite ;
8. confirmation de l’autorisation de publication ;
9. soumission de l'annonce ;
10. examen et modération par IMOVIA ;
11. publication, demande de complément ou refus.

## 7.2. Statuts

Les statuts doivent inclure :
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

Chaque changement de statut doit être historisé.

## 7.3. Modération

La modération porte notamment sur :
- complétude ;
- cohérence ;
- qualité des médias ;
- doublons ;
- contenus interdits ;
- signalements ;
- déclarations d’autorisation ;
- conformité aux règles de publication.

Une modification importante après publication peut déclencher une nouvelle modération.

---

# 8. Recherche et découverte

La recherche doit permettre de trouver un bien selon des critères adaptés au marché béninois :
- type de bien ;
- location ou vente ;
- département ;
- commune ;
- arrondissement ou quartier ;
- budget ;
- caractéristiques propres au bien ;
- disponibilité ;
- statut de vérification.

Les résultats doivent être paginés et les filtres doivent pouvoir être combinés.

La fiche détaillée doit être partageable.

Les résultats doivent distinguer clairement les annonces sponsorisées des résultats ordinaires.

Les règles de classement doivent être explicites et administrables. Une mise en avant payante ne doit jamais être présentée comme une meilleure vérification ou une garantie de qualité.

---

# 9. Photos et vidéos

Chaque annonce peut contenir plusieurs photos et, lorsque le format est accepté, une ou plusieurs vidéos.

Le système doit prévoir :
- téléversement sécurisé ;
- validation des formats et tailles ;
- compression et génération de miniatures ;
- stockage privé ou public selon le type de média ;
- contrôle des médias soumis ;
- suppression et remplacement ;
- association fiable des médias au bien concerné.

Les vidéos doivent être optimisées pour les connexions mobiles. Le lecteur doit permettre un chargement progressif et une qualité adaptée à la connexion lorsque l'infrastructure le permet.

Les médias privés de vérification ne doivent jamais être exposés dans les galeries publiques.

---

# 10. Contacts, messagerie et visites

## 10.1. Contacts

Les moyens de contact peuvent inclure :
- messagerie interne ;
- téléphone ;
- WhatsApp, selon les préférences de l'annonceur.

Les coordonnées privées ne sont exposées que selon les paramètres et le consentement de l'utilisateur.

## 10.2. Messagerie

La messagerie interne est prévue en V2. Elle doit permettre de retrouver les conversations, d'identifier le bien concerné et de recevoir les notifications essentielles.

Les règles de signalement et de modération doivent s'appliquer également aux abus dans les échanges.

## 10.3. Demandes de visite

Le parcours complet de demande de visite est prévu en V2. Le contact simple avec l'annonceur reste disponible au MVP selon les préférences configurées.

Le parcours doit prévoir :
- proposition ou sélection d'un créneau ;
- réponse de l'annonceur ;
- acceptation, refus, report ou annulation ;
- conditions de déplacement ;
- frais éventuels ;
- acceptation explicite des frais par le chercheur ;
- historique de la demande ;
- confirmation de réalisation, lorsque disponible.

Les frais de déplacement ne sont pas automatiquement des frais IMOVIA. Ils doivent être affichés avant confirmation. Le montant et les conditions acceptés doivent être conservés et ne peuvent pas être modifiés rétroactivement pour cette demande.

Au MVP, IMOVIA ne conserve pas les loyers ou les prix de vente et n'encaisse pas les transactions immobilières.

---

# 11. Services immobiliers

## 11.1. Catalogue des services

Un espace dédié permet de découvrir les services immobiliers disponibles au Bénin.

Chaque service doit être décrit avec :
- intitulé et catégorie ;
- description ;
- zone d'intervention ;
- fournisseur responsable ;
- conditions d'accès ;
- prix ou méthode de devis lorsqu’ils sont connus ;
- délai indicatif uniquement s’il est réellement maîtrisé ;
- modalités de demande ;
- statut actif ou indisponible.

## 11.2. Demande de service

Le parcours doit permettre au client de consulter le service, comprendre les conditions, transmettre les informations nécessaires et envoyer une demande.

Le système doit enregistrer le statut de la demande et les échanges associés.

## 11.3. Gestion des prestataires

Le back-office doit permettre d'enregistrer les prestataires, examiner leurs informations, gérer leurs services, contrôler leur statut et traiter les signalements.

La validation d'un prestataire ne constitue pas une garantie absolue sur toutes ses prestations. La portée du contrôle doit être expliquée.

Les services et prestataires sont des fonctions de la V2/V3, pas du MVP.

---

# 12. Vérification et confiance

Le cœur du projet est la confiance. La valeur de IMOVIA ne doit pas seulement reposer sur le catalogue, mais sur la qualité des informations, la capacité de vérification et la clarté des responsabilités.

Les statuts doivent décrire précisément ce qui a été contrôlé.

Exemples de contrôles distincts :
- téléphone vérifié ;
- profil examiné ;
- documents examinés ;
- visite physique effectuée ;
- anomalie signalée.

Les vérifications doivent être claires, compréhensibles et facilement auditable.

## 12.1. Vérification dans le MVP

Le MVP doit inclure :
- vérification basique de compte ;
- vérification de profil annonceur ;
- contrôle minimum des médias ;
- signalements ;
- modération des annonces ;
- statut de vérification lisible pour chaque annonce.

## 12.2. Vérification dans la V2

La V2 ajoute :
- vérification documentaire plus avancée ;
- historique de vérification ;
- gestion des pièces et documents ;
- procédure de traitement des anomalies ;
- suivi des actions de validation.

## 12.3. Vérification dans la V3

La V3 peut inclure :
- vérifications professionnelles plus poussées ;
- workflows de contrôle selon le type de service ;
- services premium de vérification ;
- traitement de dossiers suivant le niveau de risque.

---

# 13. Back-office et administration

## 13.1. Gestion des comptes et profils

Fonctions :
- consultation des profils ;
- gestion des statuts de vérification ;
- suspension et réactivation selon permission ;
- signalements liés à un compte ;
- gestion des rôles et permissions ;
- journalisation des actions sensibles.

## 13.2. Gestion des annonces et des biens

Fonctions :
- file des annonces à examiner ;
- filtres par statut, catégorie, zone et annonceur ;
- consultation des détails et médias ;
- validation, refus ou demande de complément ;
- suspension et réactivation ;
- gestion des doublons et signalements ;
- historique des modifications ;
- gestion des disponibilités lorsque l'équipe est autorisée à intervenir.

## 13.3. Gestion des services et prestataires

Fonctions :
- création et modification des catégories de services ;
- gestion du catalogue ;
- gestion des prestataires ;
- examen des profils et justificatifs ;
- activation ou désactivation d'un service ;
- suivi des demandes ;
- traitement des incidents et signalements.

## 13.4. Vérifications

Fonctions :
- réception des demandes ;
- affectation à un vérificateur ;
- suivi des étapes ;
- consultation sécurisée des pièces ;
- dépôt des rapports ;
- examen et validation du résultat par une personne habilitée ;
- historique des décisions.

## 13.5. Visites et signalements

Le back-office permet de suivre les demandes de visite en cas de litige ou de support, de consulter les conditions acceptées et de traiter les signalements.

Les équipes ne doivent pas pouvoir modifier silencieusement les conditions déjà acceptées.

## 13.6. Gestion des contenus et paramètres

Fonctions :
- catégories de biens ;
- types d'opérations ;
- caractéristiques configurables ;
- localisations administratives ;
- catégories de services ;
- contenus informatifs ;
- règles et textes affichés dans l'application ;
- paramètres fonctionnels autorisés.

## 13.7. Rôles, permissions et audit

Le back-office doit appliquer un contrôle d'accès par rôle et, si nécessaire, par permission.

Les actions sensibles doivent être journalisées : auteur, date, action, ressource concernée et résultat.

Les documents d'identité, pièces de propriété, informations privées et données de paiement éventuelles doivent être protégés par des permissions spécifiques.

---

# 14. Notifications, favoris et signalements

Les notifications évoluent avec les phases :

| Événements | Phase |
|---|---|
| OTP ; annonce soumise, acceptée, refusée ou à compléter ; changement de disponibilité ; réponse à un signalement lorsque cela est approprié. | MVP |
| Nouveau message ; demande de visite et visite acceptée, reportée ou annulée ; évolution du statut d'une vérification documentaire. | V2 |
| Demande de service et évolution de sa prestation. | V3 |

Un chercheur connecté peut ajouter ou retirer des biens de ses favoris.

Les signalements peuvent concerner :
- une fausse annonce ;
- un prix trompeur ;
- un bien indisponible ;
- une usurpation d'identité ;
- des médias non autorisés ;
- un comportement abusif ;
- des frais non annoncés.

Les sanctions importantes doivent faire l'objet d'une revue humaine et, si possible, d'une possibilité de recours.

---

# 15. Modèle économique et cadres de mise sur le marché

## 15.1. Priorité initiale

La priorité initiale est de construire un catalogue utile et de gagner la confiance des utilisateurs.

## 15.2. Pistes prévues dans le cahier

- consultation gratuite ;
- publication gratuite au lancement ;
- services de vérification facturables ;
- abonnements professionnels pour des outils et capacités supplémentaires ;
- annonces sponsorisées clairement identifiées ;
- production photo et vidéo ;
- services immobiliers proposés directement ou par des prestataires référencés.

## 15.3. Ce qui est autorisé au lancement

Les modèles économiques doivent être introduits progressivement après validation des besoins réels.

## 15.4. Ce qui est interdit tant que le cadre juridique n'est pas validé

Une commission sur une vente ou une location ne doit pas être activée sans étude juridique préalable. La loi béninoise n° 2022-30 du 20 décembre 2022 relative à la profession d'agent immobilier doit notamment être examinée avec un juriste compétent.

Au MVP, IMOVIA ne reçoit pas les loyers ni les prix de vente des biens. Les paiements éventuels liés aux prestations IMOVIA doivent être distingués des transactions entre propriétaires, agents et chercheurs.

---

# 16. Expérience utilisateur et identité visuelle

La direction artistique approuvée pour les maquettes est monochrome :
- noir principal : `#0B0B0B` ;
- gris foncé : `#1F1F1F` ;
- gris moyen : `#6B7280` ;
- gris clair : `#E5E7EB` ;
- blanc : `#FFFFFF` ;
- accent : `#101114`.

L'interface doit rester moderne, élégante, rassurante et accessible.

La navigation mobile doit distinguer clairement les grands besoins :
- découvrir des biens ;
- rechercher et filtrer ;
- accéder aux services ;
- publier ou gérer ses biens selon son profil ;
- consulter les favoris et le compte.

Les parcours propriétaires, agents, chercheurs et prestataires doivent être adaptés à leurs responsabilités sans multiplier inutilement les écrans.

Les écrans doivent prévoir les états de chargement, absence de résultats, erreur, absence de connexion et accès refusé.

La cartographie et les fiches de référence des écrans par utilisateur et par phase sont maintenues dans [`IMOVIA_ecrans_MVP_par_utilisateur.md`](./IMOVIA_ecrans_MVP_par_utilisateur.md). Elle précise le périmètre de maquette MVP, V2 et V3 et évite de présenter les fonctions des phases ultérieures comme disponibles au lancement.

---

# 17. Architecture technique

## 17.1. Architecture générale

Architecture client-serveur :
- application mobile Flutter ;
- back-office web ;
- backend central ;
- base de données ;
- stockage de médias ;
- services de notification et services techniques associés.

Le backend porte les règles métier et contrôle les accès. Les interfaces ne doivent jamais être considérées comme une frontière de sécurité suffisante.

## 17.2. Application mobile

Technologies recommandées :
- Flutter ;
- Dart ;
- Riverpod pour la gestion d'état ;
- GoRouter pour la navigation ;
- Dio pour les requêtes HTTP ;
- Freezed et json_serializable pour les modèles si nécessaire.

Organisation par fonctionnalités :
- authentification ;
- accueil et découverte ;
- recherche ;
- biens et annonces ;
- médias ;
- profils ;
- favoris ;
- messagerie ;
- visites ;
- services ;
- notifications ;
- espace annonceur ;
- paramètres.

La logique métier ne doit pas être concentrée dans les widgets.

## 17.3. Back-office web

Le back-office doit être une application web distincte, conçue pour les tâches administratives et professionnelles.

Le choix du framework frontend du back-office doit être confirmé dans la décision technique du projet. Il doit néanmoins consommer la même API centrale et appliquer les permissions retournées et contrôlées par le backend.

## 17.4. Backend

Technologies conservées :
- NestJS ;
- TypeScript ;
- Prisma ORM ;
- PostgreSQL ;
- API REST ;
- Swagger/OpenAPI.

Le backend doit rester un monolithe modulaire au départ, et non une architecture microservices prématurée.

Modules fonctionnels à prévoir :
- Auth ;
- Users ;
- Owner Profiles ;
- Agent Profiles ;
- Provider Profiles ;
- Properties ;
- Listings ;
- Categories ;
- Locations ;
- Media ;
- Search ;
- Favorites ;
- Messaging ;
- Visits ;
- Services Catalog ;
- Service Requests ;
- Verification ;
- Moderation ;
- Reports ;
- Notifications ;
- Admin ;
- Roles and Permissions ;
- Audit Logs ;
- Analytics.

## 17.5. Données et stockage

Les données structurées sont conservées dans PostgreSQL. Les photos, vidéos et documents privés utilisent un stockage adapté, avec des règles d'accès distinctes.

Les migrations Prisma doivent être versionnées et testées. Les documents privés ne doivent pas être accessibles par des URL publiques permanentes.

---

# 18. Sécurité, confidentialité et conformité

Exigences :
- validation des données côté backend ;
- contrôle d'accès par rôle et permission ;
- limitation des tentatives sensibles ;
- protection des sessions et jetons ;
- stockage sécurisé des secrets ;
- séparation des médias publics et privés ;
- journalisation des actions sensibles ;
- sauvegardes et procédure de restauration ;
- politique de conservation et suppression des données ;
- protection des documents d'identité et de propriété ;
- consentement et transparence sur les données personnelles.

Les conditions générales, la politique de confidentialité, la politique de conservation des documents et les règles de sécurité doivent être documentées et validées avant les phases d'exploitation ET de service plus larges.

---

# 19. Analyse de marché et positionnement

## 19.1. Problème à résoudre

Le marché immobilier au Bénin est marqué par :
- coût élevé du logement et des terrains ;
- manque de confiance ;
- annonces trompeuses ou non sécurisées ;
- problèmes de transparence ;
- difficulté à vérifier les documents ;
- manque de gestion claire et organisée ;
- commissions et frais parfois opaques.

## 19.2. Positionnement stratégique

IMOVIA doit se positionner comme une plateforme qui apporte :
- transparence ;
- sécurité ;
- organisation ;
- clarté sur les responsabilités ;
- modération et vérification ;
- meilleure qualité d'information pour les utilisateurs.

## 19.3. Différenciation décisive

La différenciation la plus forte de IMOVIA ne repose pas uniquement sur le catalogue, mais sur :
- la rigueur du flux de publication ;
- la qualité de la modération ;
- la clarté des statuts ;
- la gestion des données immobilières ;
- la fiabilité des contacts et visites ;
- la crédibilité du produit dans un marché difficile.

---

# 20. Indicateurs de performance et pilotage

Les indicateurs doivent être documentés de manière claire et cohérente. Certaines métriques sont essentielles dès le MVP, d’autres deviennent pertinentes dans la V2 et la V3.

## 20.1. Indicateurs MVP

- utilisateurs actifs ;
- biens publiés ;
- annonces soumises ;
- annonces en attente de modération ;
- taux de publication acceptée ;
- taux de refus ;
- demandes de visite ;
- fiches consultées ;
- favoris ;
- signalements ouverts.

## 20.2. Indicateurs V2

- délais de traitement des annonces ;
- demandes de visite acceptées, refusées, annulées ;
- taux de réponse des annonceurs ;
- demandes de visite confirmées ;
- signalements résolus ;
- vérifications demandées et terminées ;
- taux de conformité des annonces.

## 20.3. Indicateurs V3

- demandes de services ;
- prestataires actifs ;
- services consultés ;
- demandes traitées ;
- performances globales par zone ;
- campagnes sponsorisées ;
- performances commerciales et d'exploitation.

---

# 21. Déploiement et qualité

Prévoir trois environnements :
- développement ;
- préproduction ;
- production.

Le projet doit utiliser :
- Git et GitHub ;
- variables d'environnement ;
- migrations Prisma ;
- pipeline CI/CD ;
- journalisation ;
- monitoring ;
- sauvegardes ;
- gestion des secrets ;
- documentation technique.

Les secrets ne doivent jamais être écrits en dur dans le code ou dans le dépôt. Les migrations doivent être versionnées et testées. Le déploiement doit être reproductible.

---

# 22. Critères généraux d'acceptation par phase

## 22.1. Critères d'acceptation du MVP

Le MVP est considéré comme prêt lorsque :
- un visiteur peut consulter le catalogue ;
- un propriétaire peut publier et gérer plusieurs biens ;
- un agent peut gérer les biens pour lesquels il a déclaré une autorisation ;
- les annonces passent par une modération ;
- les photos et vidéos sont correctement téléversées et affichées ;
- les recherches et filtres essentiels fonctionnent ;
- les fiches détaillées sont partageables ;
- les contacts respectent les préférences de confidentialité ;
- les permissions empêchent les accès non autorisés ;
- les actions sensibles sont journalisées ;
- les statuts de vérification sont compréhensibles ;
- les données privées sont protégées ;
- les parcours principaux ont été testés sur plusieurs appareils ;
- les erreurs critiques de sécurité et de fonctionnement sont corrigées.

## 22.2. Critères d'acceptation de la V2

La V2 est considérée comme prête lorsque :
- les demandes de visite fonctionnent dans leur parcours complet ;
- la messagerie interne est utilisable ;
- les signalements sont gérés ;
- les vérifications et historiques sont fiables ;
- le back-office gère les tâches opérationnelles prévues ;
- les permissions et les règles de traitement sont cohérentes ;
- les délais de traitement peuvent être suivis.

## 22.3. Critères d'acceptation de la V3

La V3 est considérée comme prête lorsque :
- les services immobiliers sont bien intégrés à l'écosystème ;
- la gestion des prestataires est claire et fonctionnelle ;
- les demandes de service sont traçables ;
- le modèle économique est validé et conforme ;
- les services additionnels sont correctement exploités.

---

# 23. Points à valider avant le lancement de chaque phase

## 23.1. Avant le MVP

- Conditions générales d'utilisation ;
- politique de confidentialité ;
- politique de conservation des documents ;
- conditions de publication pour propriétaires et agents ;
- règles de vérification basique de profils ;
- cadrage de la modération ;
- règles de signalement ;
- conditions de publication et contact.

## 23.2. Avant la V2

- cadre de gestion des demandes de visite ;
- conditions d'acceptation des frais et modalités de déplacement ;
- règles de signalement et de modération des échanges ;
- sécurité et contraintes sur les pièces justificatives ;
- politique de conservation des logs et historiques.

## 23.3. Avant la V3

- cadre juridique de la commission ou des frais ;
- règles de référencement et d'activation des prestataires ;
- conditions de service et de facturation ;
- responsabilités dans les prestations proposées ;
- procédures de réclamation et de recours.

---

# 24. Directives de développement

Le cahier des charges constitue la référence permanente du développement.

Les développeurs et assistants de code doivent :
- ne pas inventer de fonctionnalités métier ;
- ne pas modifier les décisions sans validation ;
- respecter l'architecture définie ;
- produire du code typé, maintenable et documenté ;
- séparer les responsabilités ;
- ne pas placer la logique métier dans les widgets Flutter ;
- ne pas placer les règles métier uniquement dans le frontend ;
- valider les données côté backend ;
- gérer les états de chargement, succès, erreur et absence de données ;
- écrire les tests correspondant aux fonctionnalités ;
- éviter les fichiers et modules inutiles ;
- ne pas dupliquer la logique métier ;
- documenter les décisions techniques ;
- utiliser les migrations pour faire évoluer la base ;
- ne jamais exposer les secrets ou les documents privés.

## Méthode de travail par module

1. Relire les exigences correspondantes.
2. Définir les entités et leurs relations.
3. Définir les contrats API.
4. Implémenter le backend.
5. Écrire les tests backend.
6. Implémenter l'interface Flutter ou back-office.
7. Tester le parcours complet.
8. Vérifier les permissions et les erreurs.
9. Documenter le résultat.
10. Passer au module suivant.

Le produit doit être développé module par module, et non généré intégralement en une seule opération.

---

# 25. Conclusion

IMOVIA se développe selon une logique de progression claire et réaliste :

- le MVP construit la confiance, le catalogue et la publication ;
- la V2 transforme le produit en outil d'exploitation et de gestion opérationnelle ;
- la V3 ouvre la plateforme à une dimension plus large d'écosystème immobilier.

Cette logique garantit que le produit reste utile, exploitable, maîtrisable et crédible dès le début, tout en laissant la place à une croissance saine et progressive.

La clé du succès est simple : d'abord donner confiance, ensuite optimiser l'exploitation, puis élargir le service.

**IMOVIA — L'immobilier en toute confiance.**
