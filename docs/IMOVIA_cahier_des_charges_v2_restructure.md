# IMOVIA
## Cahier des charges fonctionnel et technique — Version restructurée

**Slogan :** L'immobilier en toute confiance.  
**Version :** 2.0 — Restructuration fonctionnelle et technique  
**Date :** Novembre 2026  
**Marché de lancement :** République du Bénin  
**Application principale :** Flutter (Android et iOS)  
**Back-office :** Application web d'administration avancée  
**Backend :** API centralisée  
**Statut :** Document de référence pour la conception, le développement, les tests et le déploiement.

---

# 0. Décisions structurantes

Les décisions suivantes constituent le cadre de référence de cette version :

1. IMOVIA lance une application mobile développée avec Flutter pour Android et iOS.
2. IMOVIA dispose d'un back-office web avancé et opérationnel dès le lancement.
3. Les services immobiliers sont intégrés au produit, mais présentés dans un univers distinct des annonces de biens.
4. Le lancement commercial et opérationnel est limité au Bénin.
5. L'application mobile et le back-office utilisent le même backend et les mêmes données, avec des interfaces et des permissions différentes.
6. La plateforme est conçue comme un service numérique immobilier, et non comme un simple site de petites annonces.

Les anciennes mentions présentant la PWA comme application principale, l'application mobile native comme fonctionnalité différée et le back-office avancé comme fonctionnalité reportée sont remplacées par les décisions ci-dessus.

# 1. Présentation générale

## 1.1. Présentation de IMOVIA

IMOVIA est une plateforme numérique immobilière destinée à organiser et faciliter la recherche, la publication, la consultation et la gestion d'offres immobilières au Bénin.

Elle met en relation :
- les personnes qui recherchent un logement, un terrain ou un local ;
- les propriétaires qui souhaitent présenter et gérer leurs biens ;
- les agents immobiliers qui gèrent des biens pour leur compte ou pour celui de propriétaires ;
- les professionnels qui proposent des services liés à l'immobilier ;
- les équipes IMOVIA chargées de l'administration, de la modération et des vérifications.

IMOVIA doit permettre de découvrir des biens, comparer leurs caractéristiques, consulter des informations utiles, contacter les annonceurs, organiser des visites et accéder à des services immobiliers.

## 1.2. Vision

Devenir une plateforme immobilière de référence au Bénin, reconnue pour la richesse de son catalogue, la qualité de ses informations, la simplicité de ses parcours et la confiance accordée aux utilisateurs.

## 1.3. Mission

Rendre le marché immobilier béninois plus accessible, lisible et organisé grâce à des outils numériques adaptés aux pratiques locales.

## 1.4. Objectifs

- Centraliser les offres immobilières dans un catalogue structuré.
- Faciliter la recherche de biens dans les communes et quartiers du Bénin.
- Permettre aux propriétaires de publier et gérer directement leurs biens.
- Donner aux agents des outils adaptés à la gestion de leur portefeuille.
- Permettre aux chercheurs de comparer les biens et de suivre leurs démarches.
- Organiser les contacts et les demandes de visite.
- Rendre les frais et conditions de visite transparents.
- Proposer des services immobiliers complémentaires.
- Réduire les risques d'annonces trompeuses grâce à la modération et à des contrôles clairement décrits.
- Donner aux équipes IMOVIA des outils d'administration et de pilotage.

# 2. Périmètre du produit et plateformes

IMOVIA est composé de trois éléments complémentaires.

## 2.1. Application mobile IMOVIA

L'application mobile est le produit principal destiné au grand public et aux professionnels.

Elle est développée avec Flutter et doit cibler :
- Android ;
- iOS.

Elle regroupe les parcours de recherche, de consultation, de publication, de gestion des biens, de contact, de visite et de découverte des services immobiliers.

L'application doit être conçue pour fonctionner dans des conditions de réseau variables. Les images et vidéos doivent être optimisées, les chargements progressifs et les états hors connexion clairement gérés. Les données privées ne doivent pas être stockées sans protection.

## 2.2. Back-office web avancé

Le back-office est une interface web séparée, réservée aux membres autorisés de l'équipe IMOVIA.

Il doit être opérationnel dès le lancement. Il permet de superviser le fonctionnement de la plateforme, de traiter les opérations et de contrôler les contenus.

Le back-office ne doit pas être une simple page de statistiques. Il doit fournir des outils de travail réels, avec files de traitement, filtres, historiques, affectations, permissions et journalisation.

## 2.3. Backend et API centrale

Le backend centralise les règles métier, les données, les permissions et les traitements.

L'application Flutter et le back-office communiquent avec le backend par une API sécurisée et documentée. Aucune règle métier sensible ne doit dépendre uniquement de l'interface cliente.

## 2.4. Site web public et PWA

La PWA n'est plus l'application principale du produit.

La création d'un site web public ou d'une PWA complémentaire pourra être étudiée dans une phase distincte, notamment pour le référencement des annonces, le partage de fiches publiques et l'acquisition de nouveaux utilisateurs. Elle ne doit pas retarder la livraison de l'application mobile et du back-office.

# 3. Univers fonctionnels de IMOVIA

La navigation et le modèle de données doivent distinguer trois univers.

## 3.1. Univers 1 — Biens immobiliers

Cet univers regroupe les biens proposés à la location ou à la vente.

Catégories initialement prévues :
- chambre ;
- chambre-salon ;
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

Chaque catégorie doit pouvoir disposer de caractéristiques adaptées. Par exemple, un terrain nécessite une superficie et des informations d'accès, tandis qu'un appartement nécessite notamment des informations sur les pièces, l'étage et les équipements.

## 3.2. Univers 2 — Opérations immobilières

Chaque offre de bien doit être rattachée à une opération clairement identifiée :
- location ;
- vente.

Les informations complémentaires doivent dépendre de l'opération et de la catégorie du bien.

Pour une location, les informations peuvent inclure le loyer périodique, la caution éventuelle, l'avance éventuelle, les charges et les conditions particulières.

Pour une vente, les informations peuvent inclure le prix demandé, la superficie, les conditions de vente et les documents déclarés disponibles.

Les champs doivent être explicites. IMOVIA ne doit pas présenter comme obligatoires des frais qui ne le sont pas.

## 3.3. Univers 3 — Services immobiliers

Les services immobiliers sont intégrés à IMOVIA, mais ne doivent pas être mélangés aux annonces de biens.

Le catalogue de services peut notamment accueillir les familles suivantes, sous réserve de validation de l'offre réelle et des prestataires disponibles :

- **Gestion immobilière :** gestion locative, suivi de biens, assistance aux propriétaires.
- **Visites et accompagnement :** organisation ou accompagnement de visites, assistance sur place.
- **Vérification :** contrôle documentaire, contrôle physique, rapport de vérification, dans les limites annoncées.
- **Production média :** photographie immobilière, vidéo, montage et présentation de biens.
- **Travaux et entretien :** entretien, nettoyage, réparation et rénovation.
- **Conception et réalisation :** architecture, construction, aménagement et expertise, lorsque les prestataires compétents sont disponibles.
- **Services associés :** déménagement ou autres prestations immobilières validées.

Chaque service doit avoir sa propre fiche : description, zone couverte, prestataire, conditions, prix ou mode de tarification lorsqu'ils sont connus, modalités de demande et statut de disponibilité.

IMOVIA doit distinguer clairement :
- un service fourni directement par IMOVIA ;
- un service fourni par un prestataire indépendant référencé ;
- une simple mise en relation.

La plateforme ne doit pas promettre une prestation qu'elle n'est pas en mesure d'assurer.

# 4. Utilisateurs, profils et permissions

## 4.1. Visiteur

Peut consulter les biens, effectuer des recherches, consulter les fiches publiques, regarder les médias, consulter les profils publics et découvrir les services.

Un compte est nécessaire pour les fonctionnalités personnelles telles que les favoris synchronisés, la messagerie interne, les demandes de visite et la publication.

## 4.2. Chercheur immobilier

Peut :
- rechercher et filtrer les biens ;
- consulter et comparer les fiches ;
- enregistrer des favoris ;
- contacter un annonceur ;
- échanger par messagerie ;
- demander une visite ;
- consulter les conditions et frais avant confirmation ;
- suivre ses demandes ;
- demander un service immobilier ;
- recevoir des notifications ;
- signaler une annonce ou un comportement.

## 4.3. Propriétaire

Peut :
- créer et gérer son profil ;
- publier plusieurs biens ;
- ajouter des photos et vidéos ;
- modifier ses annonces ;
- gérer la disponibilité ;
- recevoir et traiter les demandes de contact ;
- échanger avec les chercheurs ;
- gérer les demandes de visite ;
- définir les conditions de visite ;
- consulter des statistiques ;
- demander une prestation de vérification ou un autre service disponible.

Le propriétaire doit pouvoir utiliser IMOVIA sans passer obligatoirement par un agent.

## 4.4. Agent immobilier

Peut :
- créer un profil professionnel ;
- présenter son activité et sa zone d'intervention ;
- gérer un portefeuille de biens ;
- publier les biens pour lesquels il dispose d'une autorisation ;
- gérer les médias et les annonces ;
- recevoir des messages ;
- organiser des visites ;
- gérer ses disponibilités et conditions de déplacement ;
- consulter ses statistiques ;
- demander des services immobiliers.

Le système doit enregistrer la déclaration d'autorisation de publication et de mise en relation. Il faut distinguer le propriétaire du bien, le détenteur du mandat ou de l'autorisation et le compte qui gère l'annonce.

## 4.5. Prestataire de services

Un prestataire peut être un professionnel ou une structure proposant un service immobilier référencé sur IMOVIA.

Son profil doit pouvoir présenter :
- son identité ou sa raison sociale ;
- ses coordonnées professionnelles ;
- ses domaines de service ;
- sa zone d'intervention ;
- sa présentation ;
- ses justificatifs éventuels ;
- son statut de validation ;
- les services qu'il est autorisé à proposer.

Les fonctionnalités de gestion des demandes, de disponibilité et de suivi des prestations doivent être définies selon le modèle opérationnel retenu pour chaque service.

## 4.6. Vérificateur IMOVIA

Peut consulter les missions qui lui sont attribuées, enregistrer les éléments examinés, joindre des preuves privées, signaler des anomalies et soumettre un rapport.

Il ne peut pas modifier librement les informations commerciales d'une annonce ni valider seul une décision qui dépasse ses autorisations.

## 4.7. Équipe d'administration

Les rôles internes doivent être séparés :
- administrateur principal ;
- administrateur fonctionnel ;
- responsable de modération ;
- modérateur ;
- responsable des vérifications ;
- vérificateur ;
- support utilisateur ;
- gestionnaire des services et prestataires ;
- analyste ou responsable de reporting.

Les rôles exacts et leurs permissions doivent être configurables. Un utilisateur ne doit accéder qu'aux données nécessaires à sa mission.

# 5. Authentification et gestion des comptes

L'inscription doit être simple et adaptée au contexte béninois.

Informations initiales :
- nom et prénom ;
- numéro de téléphone ;
- mécanisme d'authentification sécurisé ;
- acceptation des conditions générales ;
- acceptation de la politique de confidentialité.

Le numéro de téléphone doit être vérifié par OTP. Les demandes de code doivent être limitées pour prévenir les abus.

Le système doit gérer :
- inscription et connexion ;
- déconnexion ;
- renouvellement sécurisé des sessions ;
- réinitialisation des accès ;
- gestion des appareils et sessions ;
- suspension et réactivation des comptes ;
- journal des événements de sécurité.

Un utilisateur peut commencer comme chercheur puis compléter un profil propriétaire, agent ou prestataire selon les règles d'éligibilité.

# 6. Catalogue, annonces et gestion des biens

## 6.1. Fiche d'un bien

Une fiche peut contenir :
- titre ;
- catégorie ;
- opération ;
- description ;
- département ;
- commune ;
- arrondissement ou quartier ;
- indications complémentaires ;
- prix demandé facultatif ;
- devise ;
- disponibilité ;
- caractéristiques ;
- conditions particulières ;
- photos et vidéos ;
- annonceur responsable ;
- statut de vérification.

Le prix est facultatif. En l'absence de prix, afficher « Prix sur demande ».

Les coordonnées privées ne doivent être révélées que selon les préférences de contact et les règles de consentement.

## 6.2. Caractéristiques configurables

Les caractéristiques doivent être administrables par catégorie depuis le back-office, sans nécessiter une modification du code pour chaque nouvelle option simple.

Exemples :
- maison ou villa : chambres, salons, salles d'eau, cuisine, garage, cour, jardin, clôture, eau, électricité ;
- appartement : pièces, étage, ascenseur, parking, balcon, cuisine, salle d'eau ;
- terrain : superficie, forme, accès routier, viabilisation déclarée, usage prévu, documents déclarés disponibles ;
- local commercial : superficie, emplacement, accessibilité, eau, électricité et usage possible.

## 6.3. Disponibilité

Statuts possibles :
- disponible ;
- en cours de réservation ;
- indisponible ;
- loué ;
- vendu.

Une annonce indisponible ne doit plus apparaître dans les résultats actifs, sauf demande explicite du visiteur.

## 6.4. Relation annonceur — propriétaire — bien

Le modèle de données doit distinguer :
- le bien immobilier ;
- son propriétaire déclaré ;
- l'agent ou le compte qui gère l'annonce ;
- l'autorisation ou le mandat déclaré ;
- l'annonce publiée ;
- l'historique des changements.

Cette séparation est indispensable pour éviter qu'un agent soit automatiquement considéré comme propriétaire d'un bien.

# 7. Publication et modération

Parcours de publication :
1. L'utilisateur se connecte.
2. Il choisit son profil annonceur.
3. Il renseigne les informations du bien.
4. Il ajoute au moins une photo.
5. Il ajoute éventuellement des vidéos.
6. Il définit ses préférences de contact.
7. Il renseigne les conditions de visite.
8. Il confirme son autorisation de publication.
9. Il soumet l'annonce.
10. IMOVIA examine l'annonce.
11. L'annonce est publiée, renvoyée pour complément ou refusée.

Statuts :
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

La modération porte notamment sur la complétude, la cohérence, la qualité des médias, les doublons, les contenus interdits, les signalements antérieurs et les déclarations d'autorisation.

Une modification importante après publication peut déclencher une nouvelle modération.

# 8. Recherche et découverte

La recherche doit permettre de trouver un bien à partir de critères pertinents pour le marché béninois :
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

La fiche détaillée doit être partageable. Les résultats doivent distinguer clairement les annonces sponsorisées des résultats ordinaires.

Les règles de classement doivent être explicites et administrables. Une mise en avant payante ne doit jamais être présentée comme une meilleure vérification ou une garantie de qualité.

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

# 10. Contacts, messagerie et visites

## 10.1. Contacts

Les moyens de contact peuvent inclure :
- messagerie interne ;
- téléphone ;
- WhatsApp, selon les préférences de l'annonceur.

Les coordonnées privées ne sont exposées que selon les paramètres et le consentement de l'utilisateur.

## 10.2. Messagerie

La messagerie doit permettre de retrouver les conversations, d'identifier le bien concerné et de recevoir les notifications essentielles.

Les règles de signalement et de modération doivent également s'appliquer aux abus dans les échanges.

## 10.3. Demandes de visite

Le chercheur peut demander une visite depuis la fiche du bien.

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

# 11. Services immobiliers

## 11.1. Catalogue des services

Un espace dédié permet de découvrir les services immobiliers disponibles au Bénin.

Chaque service doit être décrit avec :
- intitulé et catégorie ;
- description ;
- zone d'intervention ;
- fournisseur responsable ;
- conditions d'accès ;
- prix ou méthode de devis lorsqu'ils sont connus ;
- délai indicatif uniquement s'il est réellement maîtrisé ;
- modalités de demande ;
- statut actif ou indisponible.

## 11.2. Demande de service

Le parcours doit permettre au client de consulter le service, comprendre les conditions, transmettre les informations nécessaires et envoyer une demande.

Le système doit enregistrer le statut de la demande et les échanges associés.

Les statuts opérationnels doivent être définis selon le type de service : par exemple nouvelle demande, à étudier, devis transmis, acceptée, en cours, terminée, annulée ou refusée. Ces statuts ne doivent être activés que si IMOVIA assure réellement le suivi correspondant.

## 11.3. Gestion des prestataires

Le back-office doit permettre d'enregistrer les prestataires, examiner leurs informations, gérer leurs services, contrôler leur statut et traiter les signalements.

La validation d'un prestataire ne constitue pas une garantie absolue sur toutes ses prestations. La portée du contrôle doit être expliquée.

# 12. Vérification et confiance

Les statuts doivent décrire précisément ce qui a été contrôlé.

Exemples de contrôles distincts :
- téléphone vérifié ;
- profil examiné ;
- documents examinés ;
- visite physique effectuée ;
- anomalie signalée ;
- vérification non concluante.

Chaque badge doit préciser :
- le type de contrôle ;
- les éléments examinés ;
- la date ;
- les limites et réserves éventuelles.

Un contrôle physique ne prouve pas à lui seul la propriété juridique. La déclaration de documents disponibles ne constitue pas une preuve de propriété.

Le paiement d'une prestation de vérification ne garantit jamais un résultat positif et ne doit pas influencer le résultat du contrôle.

Les documents et preuves de vérification doivent être protégés, accessibles uniquement aux personnes autorisées et soumis à une politique de conservation.

# 13. Back-office avancé

Le back-office doit être livré comme une composante essentielle de la première version.

## 13.1. Tableau de bord général

Afficher des indicateurs utiles à l'exploitation :
- utilisateurs inscrits et actifs ;
- propriétaires et agents ;
- prestataires référencés ;
- annonces soumises, publiées, refusées ou suspendues ;
- biens disponibles ;
- demandes de visite ;
- signalements ouverts ;
- vérifications en attente ou terminées ;
- demandes de services ;
- activité récente.

Les indicateurs doivent être définis précisément. Un chiffre ne doit pas être affiché si sa méthode de calcul n'est pas définie.

## 13.2. Gestion des utilisateurs

Fonctions :
- recherche et filtres ;
- consultation des profils ;
- consultation de l'historique utile ;
- suspension et réactivation selon permission ;
- traitement des signalements liés à un compte ;
- gestion des statuts de vérification du profil ;
- journalisation des actions sensibles.

## 13.3. Gestion des annonces et des biens

Fonctions :
- file des annonces à examiner ;
- filtres par statut, catégorie, zone et annonceur ;
- consultation des détails et médias ;
- validation, refus ou demande de complément ;
- suspension et réactivation ;
- gestion des doublons et signalements ;
- historique des modifications ;
- gestion des disponibilités lorsque l'équipe est autorisée à intervenir.

## 13.4. Gestion des services et prestataires

Fonctions :
- création et modification des catégories de services ;
- gestion du catalogue ;
- gestion des prestataires ;
- examen des profils et justificatifs ;
- activation ou désactivation d'un service ;
- suivi des demandes ;
- traitement des incidents et signalements.

## 13.5. Vérifications

Fonctions :
- réception des demandes ;
- affectation à un vérificateur ;
- suivi des étapes ;
- consultation sécurisée des pièces ;
- dépôt des rapports ;
- examen et validation du résultat par une personne habilitée ;
- historique des décisions.

## 13.6. Visites et signalements

Le back-office doit permettre de suivre les demandes de visite en cas de litige ou de support, de consulter les conditions acceptées et de traiter les signalements.

Les équipes ne doivent pas pouvoir modifier silencieusement les conditions déjà acceptées.

## 13.7. Gestion des contenus et paramètres

Fonctions :
- catégories de biens ;
- types d'opérations ;
- caractéristiques configurables ;
- localisations administratives ;
- catégories de services ;
- contenus informatifs ;
- règles et textes affichés dans l'application ;
- paramètres fonctionnels autorisés.

## 13.8. Rôles, permissions et audit

Le back-office doit appliquer un contrôle d'accès par rôle et, si nécessaire, par permission.

Les actions sensibles doivent être journalisées : auteur, date, action, ressource concernée et résultat.

Les documents d'identité, pièces de propriété, informations privées et données de paiement éventuelles doivent être protégés par des permissions spécifiques.

# 14. Notifications, favoris et signalements

Les notifications essentielles concernent :
- OTP ;
- annonce soumise, acceptée, refusée ou à compléter ;
- nouveau message ;
- demande de visite ;
- visite acceptée, reportée ou annulée ;
- changement de disponibilité ;
- demande de service ;
- évolution du statut d'une vérification ;
- réponse à un signalement, lorsque cela est approprié.

Un chercheur connecté peut ajouter ou retirer des biens de ses favoris.

Les signalements peuvent concerner une fausse annonce, un prix trompeur, un bien indisponible, une usurpation d'identité, des médias non autorisés, un comportement abusif ou des frais non annoncés.

Les sanctions importantes doivent faire l'objet d'une revue humaine et, si possible, d'une possibilité de recours.

# 15. Modèle économique

La priorité initiale est de construire un catalogue utile et de gagner la confiance des utilisateurs.

Pistes prévues dans le cahier :
- consultation gratuite ;
- publication gratuite au lancement ;
- services de vérification facturables ;
- abonnements professionnels pour des outils et capacités supplémentaires ;
- annonces sponsorisées clairement identifiées ;
- production photo et vidéo ;
- services immobiliers proposés directement ou par des prestataires référencés.

Les abonnements professionnels complexes et les mécanismes de paiement peuvent être introduits progressivement après validation des besoins réels.

Une commission sur une vente ou une location ne doit pas être activée sans étude juridique préalable. La loi béninoise n° 2022-30 du 20 décembre 2022 relative à la profession d'agent immobilier doit notamment être examinée avec un juriste compétent.

Au MVP, IMOVIA ne reçoit pas les loyers ni les prix de vente des biens. Les paiements éventuels liés aux prestations IMOVIA doivent être distingués des transactions entre propriétaires, agents et chercheurs.

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
- Admin;
- Roles and Permissions ;
- Audit Logs ;
- Analytics.

## 17.5. Données et stockage

Les données structurées sont conservées dans PostgreSQL. Les photos, vidéos et documents privés utilisent un stockage adapté, avec des règles d'accès distinctes.

Les migrations Prisma doivent être versionnées et testées. Les documents privés ne doivent pas être accessibles par des URL publiques permanentes.

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

Les conditions générales, la politique de confidentialité, la politique de conservation des documents et les règles de vérification doivent être validées avant le lancement public.

Le cadre juridique des activités d'intermédiation et des services immobiliers doit être examiné avec un professionnel compétent au Bénin.

# 19. MVP — Première version opérationnelle

Le MVP doit permettre de lancer IMOVIA au Bénin avec une application mobile réellement exploitable et un back-office permettant de gérer les opérations.

## 19.1. Obligatoire au lancement

- Application Flutter Android et iOS.
- Inscription, connexion et vérification OTP.
- Profils chercheur, propriétaire et agent.
- Consultation publique du catalogue.
- Publication et gestion des annonces.
- Catégories de biens et opérations location/vente.
- Photos multiples et vidéo rattachée au bien.
- Recherche et filtres essentiels.
- Fiches détaillées et profils publics.
- Favoris.
- Messagerie interne et moyens de contact autorisés.
- Demandes de visite et transparence des frais.
- Notifications essentielles.
- Signalements.
- Statuts de vérification explicites.
- Back-office avancé opérationnel.
- Gestion des utilisateurs, annonces, modération, vérifications, services, prestataires, signalements et paramètres.
- Gestion des rôles, permissions et journaux d'audit.
- Catalogue initial de services immobiliers réellement disponibles.
- Demandes de services et suivi correspondant aux capacités effectivement assurées.

## 19.2. À introduire progressivement

- Abonnements professionnels complexes.
- Paiement intégré des frais de déplacement.
- Paiement en ligne de toutes les prestations.
- Gestion avancée de portefeuilles multi-agents ou multi-agences.
- Chat audio ou vidéo.
- Réseau social immobilier et interactions communautaires.
- Recommandations personnalisées avancées.
- Intelligence artificielle de valorisation immobilière.
- Commission transactionnelle, uniquement après validation juridique et opérationnelle.
- Site web public/SEO complet si cette priorité est confirmée.

Le fait que le back-office soit avancé dès le lancement ne signifie pas que tous les modules commerciaux futurs doivent être développés immédiatement. Les outils indispensables à l'exploitation et au contrôle sont prioritaires.

# 20. Feuille de route proposée

## Phase 1 — Cadrage et conception

- Valider les parcours et les rôles.
- Finaliser les catégories de biens, opérations et services.
- Définir les statuts et les règles métier.
- Définir les permissions du back-office.
- Produire les maquettes et le design system.
- Définir les modèles de données et contrats API.

## Phase 2 — Fondations techniques

- Initialiser les dépôts.
- Configurer les environnements.
- Mettre en place PostgreSQL et Prisma.
- Initialiser NestJS.
- Initialiser Flutter.
- Mettre en place l'authentification et les permissions.
- Documenter l'API.

## Phase 3 — Comptes et profils

- OTP et sessions.
- Profils chercheurs, propriétaires et agents.
- Profils prestataires.
- Rôles et permissions.

## Phase 4 — Biens et annonces

- Modèle de bien.
- Catégories et caractéristiques.
- Localisations béninoises.
- Formulaires de publication.
- Médias.
- Modération et historique.

## Phase 5 — Application mobile de découverte

- Accueil.
- Recherche et filtres.
- Résultats.
- Fiche détaillée.
- Profils publics.
- Favoris.

## Phase 6 — Interactions et visites

- Messagerie.
- Téléphone et WhatsApp selon préférences.
- Demandes de visite.
- Frais, acceptation et historique.
- Notifications.

## Phase 7 — Back-office avancé

- Dashboard.
- Utilisateurs.
- Annonces et modération.
- Vérifications.
- Services et prestataires.
- Signalements et visites.
- Paramètres.
- Permissions et audit.

Le back-office doit être développé en parallèle des modules métier concernés, et non uniquement à la fin du projet.

## Phase 8 — Services immobiliers

- Catalogue de services.
- Profils prestataires.
- Demandes de services.
- Suivi opérationnel adapté aux prestations réellement disponibles.

## Phase 9 — Tests et pilote au Bénin

- Tests fonctionnels de bout en bout.
- Tests sur appareils Android et iOS.
- Tests de réseau variable et de consommation de données.
- Tests de sécurité et de permissions.
- Tests de charge adaptés aux objectifs de lancement.
- Pilote auprès de propriétaires, agents, chercheurs et prestataires.
- Corrections et amélioration.

## Phase 10 — Lancement et amélioration continue

- Publication de l'application.
- Exploitation du back-office.
- Suivi des indicateurs.
- Support et traitement des incidents.
- Amélioration du catalogue et des parcours selon les retours.

# 21. Indicateurs de pilotage

Indicateurs d'offre :
- propriétaires inscrits ;
- agents inscrits ;
- prestataires référencés ;
- annonces soumises et publiées ;
- biens disponibles ;
- répartition par catégorie et zone.

Indicateurs de demande :
- utilisateurs actifs ;
- recherches réalisées ;
- consultations de fiches ;
- favoris ;
- contacts ;
- demandes de visite ;
- visites confirmées comme réalisées.

Indicateurs de confiance et d'exploitation :
- annonces en attente de modération ;
- délais de traitement ;
- signalements ouverts et résolus ;
- vérifications demandées et terminées ;
- demandes de services par statut ;
- incidents et réclamations.

Les définitions de chaque indicateur doivent être documentées pour éviter les chiffres ambigus.

# 22. Déploiement et qualité

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

# 23. Critères généraux d'acceptation

La première version est considérée comme prête lorsque :
- un visiteur peut consulter le catalogue ;
- un propriétaire peut publier et gérer plusieurs biens ;
- un agent peut gérer les biens pour lesquels il a déclaré une autorisation ;
- les annonces passent par une modération ;
- les photos et vidéos sont correctement téléversées et affichées ;
- les recherches et filtres essentiels fonctionnent ;
- les fiches détaillées sont partageables ;
- les contacts respectent les préférences de confidentialité ;
- les demandes de visite fonctionnent ;
- les frais sont affichés et acceptés avant confirmation ;
- les historiques conservent les conditions acceptées ;
- les services disponibles sont consultables et leurs demandes traçables ;
- le back-office permet réellement de traiter les opérations prévues ;
- les permissions empêchent les accès non autorisés ;
- les actions sensibles sont journalisées ;
- les statuts de vérification sont compréhensibles ;
- les données privées sont protégées ;
- les parcours principaux ont été testés sur plusieurs appareils ;
- les erreurs critiques de sécurité et de fonctionnement sont corrigées.

# 24. Points à valider avant le lancement

Les points suivants nécessitent une validation métier, opérationnelle ou juridique :
1. Conditions générales d'utilisation.
2. Politique de confidentialité.
3. Politique de conservation des documents.
4. Conditions de publication pour propriétaires et agents.
5. Vérification des autorisations ou mandats des agents.
6. Règles de frais de visite et d'annulation.
7. Responsabilité de IMOVIA en cas de fausse annonce.
8. Cadre légal de la vérification immobilière.
9. Cadre réglementaire des activités d'intermédiation immobilière.
10. Conditions de référencement et de contrôle des prestataires.
11. Conditions de facturation des services IMOVIA.
12. Modalités d'utilisation des prestataires de paiement.
13. Procédure de traitement des contestations.
14. Durée de conservation des journaux et preuves.

Aucune commission transactionnelle ne doit être activée avant validation juridique de son cadre.

# 25. Directives de développement

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

# 26. Conclusion

IMOVIA doit devenir un environnement numérique immobilier structuré pour le marché béninois. L'application Flutter constitue le point d'accès principal pour les chercheurs, propriétaires, agents et prestataires. Le back-office avancé donne à l'équipe IMOVIA les moyens d'administrer, de modérer, de vérifier et de piloter le service dès son lancement.

La séparation entre les biens immobiliers, les opérations et les services permet d'élargir l'offre sans rendre le catalogue confus. Le backend central garantit une gestion cohérente des données, des permissions et des règles métier.

La priorité est de livrer une première version fiable, utile et exploitable au Bénin, puis de faire évoluer le produit à partir des usages réels.

**IMOVIA — L'immobilier en toute confiance.**
