# IMOVIA — Cartographie des écrans par utilisateur et par phase

## 1. Objet du document

Ce document est la référence fonctionnelle et UX qui guide la conception des interfaces IMOVIA. Il distingue le MVP, la V2 et la V3 et décrit, pour chaque profil, les écrans, leur objectif, leur contenu, leurs composants, leurs actions, leur navigation, leurs états et leurs permissions.

Les maquettes sont conçues à partir de cette référence, **un écran à la fois**, dans la planche existante [`../design-system/src/index.html`](../design-system/src/index.html). Une maquette ne doit pas introduire un rôle, une fonctionnalité ou un parcours qui n'est pas défini ici ou dans les documents produit cités.

Ce document décrit les écrans et leurs responsabilités ; il ne remplace ni les spécifications métier détaillées ni les contrats API. Un écran n'est compté qu'une fois, même s'il est partagé entre des profils. Un formulaire multi-étapes, une fenêtre ou un état ne devient pas automatiquement un écran de navigation distinct.

## 2. Sources produit

Les parcours ci-dessous reprennent les décisions MVP des documents suivants :

- [`mvp_imovia_lancement.md`](./mvp_imovia_lancement.md) — publics, périmètre, parcours critiques et écrans prioritaires ;
- [`IMOVIA_cahier_des_charges_v3_MVP_V2_V3.md`](./IMOVIA_cahier_des_charges_v3_MVP_V2_V3.md) — rôles, recherche, localisation, publication et modération ;
- [`plan_fondations_imovia.md`](./plan_fondations_imovia.md) — périmètre MVP et liste initiale des écrans ;
- [`imovia-design-foundations.md`](./imovia-design-foundations.md) — base visuelle et palette de référence.

En cas d'écart visuel, conserver la palette monochrome IMOVIA déjà approuvée et le thème clair des parcours MVP. La capture de référence fournie pour l'accueil du chercheur fixe la composition de cet écran, décrite en section 6.1.

## 3. Répartition fonctionnelle par phase

| Phase | Objectif | Interfaces et fonctions retenues |
|---|---|---|
| **MVP** | Mettre en ligne un catalogue fiable et publier/modérer des annonces. | Application mobile chercheur et annonceur (propriétaire/agent avec permissions distinctes) ; back-office admin pour modération et gestion de base ; contact simple, signalement basique, favoris, notifications essentielles et audit de base. |
| **V2** | Faire d'IMOVIA un outil d'exploitation des demandes et vérifications. | Parcours complet des visites et créneaux, messagerie interne, traitement avancé des signalements, vérification documentaire avec dossiers affectés, permissions plus fines, reporting opérationnel et back-office renforcé. |
| **V3** | Étendre le produit aux services immobiliers et aux acteurs professionnels. | Espace prestataire, profils/catalogue de services, demandes et suivi des prestations, gestion des prestataires et outils professionnels additionnels validés. |

**Règle de portée :** une fonctionnalité mentionnée dans la vision globale n'est pas automatiquement disponible au MVP. Les écrans ci-dessous portent une phase explicite ; les fonctions hors phase ne doivent pas apparaître comme actives dans les maquettes.

### 3.1. Interfaces et technologies

- **Application mobile : Flutter**, pour chercheurs, propriétaires, agents et, en V3, prestataires.
- **Back-office : interface web** pour l'équipe IMOVIA, notamment vérificateurs et administrateurs.
- **Next.js :** le texte proposé le cite, mais le cahier des charges consulté définit un back-office web sans confirmer définitivement son framework. À ne pas traiter comme décision technique validée avant confirmation.

### 3.2. Profils et disponibilité

| Profil | Phase | Espace |
|---|---|---|
| Chercheur immobilier | MVP | Flutter |
| Propriétaire | MVP | Flutter, espace annonceur |
| Agent immobilier | MVP | Flutter, espace annonceur avec droits limités aux biens autorisés |
| Administrateur / modérateur | MVP | Back-office web |
| Vérificateur | V2 pour l'espace dédié ; contrôles de base par personnel habilité au MVP | Back-office web, permissions ciblées |
| Prestataire de services | V3 | Flutter, après validation de l'offre et des règles |

## 4. Utilisateurs et frontières de rôle

### 4.1. Visiteur / chercheur

Le visiteur peut découvrir les biens, rechercher, filtrer, consulter les fiches et signaler une annonce. Les actions qui exigent un compte (par exemple enregistrer des favoris ou envoyer une demande) doivent demander une connexion sans faire disparaître le contexte du bien.

### 4.2. Chercheur connecté

Le chercheur connecté conserve les capacités de consultation du visiteur et peut gérer ses favoris, ses préférences de contact, ses demandes et ses notifications essentielles.

### 4.3. Propriétaire

Le propriétaire gère ses biens et ses annonces. Il demeure distinct de l'agent et du compte qui gère une annonce ; l'interface ne doit jamais présenter automatiquement un agent comme propriétaire.

### 4.4. Agent immobilier

L'agent gère uniquement les biens et annonces qui lui sont attribués avec une autorisation ou un mandat déclaré. Les actions et listes visibles sont limitées à ses permissions.

### 4.5. Vérificateur

Le vérificateur est un rôle interne à permissions ciblées, pas nécessairement un profil produit autonome. Au MVP, un membre de l'équipe habilité effectue les contrôles de base dans le flux de modération. La file et le dossier dédiés à la vérification documentaire sont prévus en V2.

### 4.6. Administrateur IMOVIA

L'administrateur travaille dans le back-office. Il examine les annonces, traite les signalements et gère les comptes et permissions selon son niveau d'accès. Les décisions sensibles sont historisées.

### 4.7. Prestataire et hors périmètre

Le prestataire et les services immobiliers relèvent de la V3, pas des parcours de lancement MVP. La messagerie intégrée, le parcours complet des visites et la vérification documentaire dédiée relèvent de la V2. Les paiements immobiliers, les abonnements, les finances et les analytics avancés ne sont pas à représenter comme des fonctions planifiées tant que leur modèle et leur phase ne sont pas validés.

## 5. Règles communes de conception

- Utiliser la base de composants et la palette IMOVIA validées ; thème clair pour les parcours produit.
- Adapter les écrans mobiles au chercheur et à l'annonceur ; le back-office admin est une interface web.
- Rendre les actions principales évidentes et les statuts toujours accompagnés d'un libellé.
- Distinguer annonce, bien, propriétaire et gestionnaire/agent.
- Montrer publiquement une localisation approximative seulement ; ne pas exposer les coordonnées exactes du bien.
- Prévoir chargement, liste vide, erreur, validation, refus et absence de réseau lorsque ces états affectent l'écran.
- Distinguer les données réelles de toute donnée fictive utilisée dans les maquettes.
- Les données, compteurs, annonces et actions de démonstration d'une maquette ne doivent pas faire croire à une connexion au service.
- Une action non disponible au rôle courant est cachée ou désactivée avec une explication ; elle n'est pas simulée comme si elle avait réussi.

### Fiche obligatoire avant de maqueter un écran

Chaque écran retenu doit être détaillé avec les champs suivants avant sa maquette complète : **identifiant et phase ; utilisateur/rôle et permissions ; nom ; objectif ; contenu ; composants ; actions et résultats ; navigation (entrée, sorties et retour) ; états (chargement, vide, erreur, succès/attente si pertinents).** Les descriptions résumées de cette cartographie cadrent la portée ; si un champ n'est pas précisé pour un écran, il reste à décider dans sa fiche avant de le maqueter, et ne doit pas être inventé à l'implémentation.

## 6. Parcours chercheur — application mobile

### 6.1. CH-01 — Accueil / découverte (MVP)

**Utilisateur :** visiteur ou chercheur connecté.  
**Objectif :** commencer rapidement une recherche et voir une annonce intéressante.

**Composition de référence :**

1. Une grande photo immobilière remplit le haut de l'écran mobile.
2. L'heure et les indicateurs système sont superposés en haut.
3. Le logo IMOVIA blanc et l'icône de notifications apparaissent sur la photo.
4. Le titre « Trouvez votre bien idéal au Bénin » et le texte d'introduction sont posés sur la partie basse de la photo, avec un voile garantissant le contraste.
5. Un champ blanc arrondi « Rechercher un bien, une ville… » termine le visuel.
6. Sous la photo, quatre tuiles de catégorie : « À vendre », « À louer », « Terrains » et « Services ». La tuile Services est conservée pour correspondre à la capture visuelle, mais son parcours fonctionnel est hors périmètre MVP et doit être indiqué comme tel.
7. Le titre « Nos biens en vedette » et l'action « Voir tout → » précèdent une carte immobilière.
8. La carte présente une grande photo, un badge « Vérifié », un bouton favori, le prix, le titre et les caractéristiques synthétiques.

**Actions :** lancer une recherche, choisir une catégorie, ouvrir les annonces mises en avant, ajouter le bien aux favoris (compte requis), ouvrir les notifications.

**États :** contenu d'accueil, aucune annonce mise en avant, chargement, erreur de chargement. Les annonces et le prix de la maquette restent explicitement des exemples.

**Acceptation maquette :** la hiérarchie et l'ordre des éléments correspondent à la capture de référence fournie ; le visuel héroïque, les tuiles, le titre de section et la carte sont lisibles sur un écran mobile étroit.

### 6.2. CH-02 — Recherche et filtres (MVP)

**Utilisateur :** visiteur ou chercheur connecté.  
**Objectif :** définir des critères de recherche compréhensibles et combinables.

**Contenu :** opération (vente/location), catégorie/type de bien, département/commune/arrondissement/quartier, budget, disponibilité et filtres pertinents au type de bien. Choix d'un lieu de référence et rayon lorsque la recherche géographique est utilisée.

**Actions :** modifier les critères, effacer ou réinitialiser les filtres, afficher les résultats. Le nombre de résultats est affiché seulement s'il est fourni par la recherche.

**États :** critères initiaux, critères actifs, suggestions de lieux, aucun résultat, chargement et erreur. Les filtres doivent pouvoir être combinés.

### 6.3. CH-03 — Résultats de recherche (MVP)

**Utilisateur :** visiteur ou chercheur connecté.  
**Objectif :** comparer les annonces répondant aux critères.

**Contenu :** critères/résumé de recherche, accès aux filtres, liste paginée de cartes cohérentes avec CH-01, prix ou « Prix sur demande », lieu administratif, caractéristiques utiles et statuts de confiance explicites. Une annonce sponsorisée, si elle existe, est différenciée des résultats ordinaires sans être présentée comme mieux vérifiée.

**Actions :** ouvrir une fiche, changer les filtres, trier selon les options effectivement définies, enregistrer un favori si connecté.

**États :** résultats, aucun résultat avec moyen de modifier les filtres, chargement, erreur et pagination.

### 6.4. CH-04 — Détail d'un bien (MVP)

**Utilisateur :** visiteur ou chercheur connecté.  
**Objectif :** comprendre le bien, la fiabilité des informations et les moyens de poursuivre.

**Contenu :** photos et vidéos publiques, prix ou prix sur demande, type d'opération et disponibilité, caractéristiques, description, localisation approximative sur carte, annonceur responsable et statuts de vérification clairement expliqués. Le prix de location indique sa périodicité (par exemple, par mois) ; la caution, l'avance, les charges et les frais éventuels sont présentés séparément et uniquement s'ils sont déclarés par l'annonceur. Une information non renseignée n'est ni calculée ni supposée. Les coordonnées précises et les médias privés de vérification ne sont jamais montrés dans la fiche publique.

**Aperçu de la maquette :** le contrôle Vente / Location dans le panneau de présentation permet de vérifier les deux variantes de la fiche. Les montants affichés sont fictifs ; la variante Location utilise un exemple mensuel et des conditions explicitement indiquées comme non précisées.

**Actions :** parcourir les médias, ajouter/retirer un favori, contacter l'annonceur selon ses préférences, partager la fiche et signaler une annonce suspecte. La demande et la coordination de créneaux de visite complètes sont en V2 (CH-11).

**États :** annonce disponible, indisponible, suspendue/retirée, média en chargement ou indisponible, connexion requise pour une action et erreur.

### 6.5. CH-05 — Favoris (MVP, chercheur connecté)

**Utilisateur :** chercheur connecté.  
**Objectif :** retrouver les biens enregistrés.

**Contenu :** liste des favoris avec les informations essentielles de chaque carte et indication si le bien n'est plus disponible.

**Actions :** ouvrir un bien, retirer un favori, relancer une recherche si la liste est vide.

**États :** liste remplie, liste vide, chargement, erreur et bien devenu indisponible. Pour un visiteur, montrer une invite de connexion contextualisée.

### 6.6. CH-06 — Contact simple depuis un bien (MVP)

**Utilisateur :** chercheur, annonceur destinataire.  
**Objectif :** permettre au chercheur de contacter l'annonceur depuis la fiche du bien selon les préférences définies par celui-ci.

**Contenu :** référence au bien et moyen de contact autorisé ; conserver le contexte du bien si une connexion est nécessaire.

**Actions :** initier le moyen de contact disponible ; signaler le bien si nécessaire.

**Hors écran MVP :** messagerie interne avec liste de conversations, échange persistant et gestion des créneaux de visite. Ces parcours sont prévus en V2.

**États :** contact disponible, connexion requise, moyen de contact non configuré et erreur.

### 6.7. CH-07 — Profil et préférences du chercheur (MVP)

**Utilisateur :** chercheur connecté.  
**Objectif :** consulter et modifier ses informations et préférences utiles au MVP.

**Contenu :** données de profil disponibles, coordonnées et préférences de contact/notification.

**Actions :** modifier et enregistrer les champs autorisés, accéder aux paramètres, se déconnecter.

**États :** consultation, modification, sauvegarde réussie, validation nécessaire et erreur.

### 6.8. CH-08 — Notifications essentielles (écran partagé MVP)

**Utilisateur :** chercheur, propriétaire ou agent connecté.  
**Objectif :** comprendre les événements importants concernant ses annonces ou demandes.

**Contenu :** notification, date, objet lié et statut lu/non lu ; exemples : changement de statut d'une annonce ou réponse à une demande.

**Actions :** ouvrir l'objet lié, marquer comme lue. Ne pas inventer des événements qui ne sont pas reliés au périmètre fonctionnel.

**États :** liste, vide, non lu, chargement et erreur.

### 6.9. CH-09 — Paramètres et accès au compte (écran partagé MVP)

**Utilisateur :** utilisateur connecté.  
**Objectif :** gérer les paramètres simples prévus pour le MVP et l'accès au compte.

**Contenu/actions :** préférences de notification et de contact effectivement disponibles, informations de compte, déconnexion et accès aux fonctions de sécurité confirmées dans le produit.

**États :** consultation, édition, confirmation et erreur. Ne pas ajouter de paramètres fictifs.

### 6.10. CH-10 — Messagerie interne (V2, écran partagé)

**Utilisateur :** chercheur connecté, propriétaire ou agent autorisé.  
**Objectif :** retrouver et poursuivre les échanges liés à un bien dans IMOVIA.

**Contenu :** liste de conversations et écran de conversation associé à un bien. Le nombre exact de routes (liste et détail) sera arrêté au moment de la fiche UI ; les deux vues ne sont pas fusionnées artificiellement si la navigation les distingue.

**Actions :** ouvrir une conversation, envoyer et consulter des messages, revenir à la fiche du bien. Les règles de signalement et de modération des échanges doivent être définies avant la maquette détaillée.

**États et permissions :** vide, nouveau message, chargement, erreur, compte requis ; seules les personnes autorisées à participer à la conversation y ont accès.

### 6.11. CH-11 — Demande et gestion complète d'une visite (V2)

**Utilisateur :** chercheur et annonceur du bien.  
**Objectif :** proposer, traiter et suivre une visite avec des conditions explicites.

**Contenu et composants :** bien concerné, proposition/sélection de créneau, conditions et éventuels frais visibles avant acceptation, statut et historique.

**Actions :** proposer, accepter, refuser, reporter ou annuler selon le rôle et l'état. Aucune acceptation de frais n'est implicite.

**États et permissions :** demande en attente, confirmée, refusée, reportée, annulée, erreur/conflit ; le chercheur et l'annonceur ne voient que les demandes auxquelles ils participent.

## 7. Parcours annonceur — propriétaire et agent

L'interface peut partager des composants entre propriétaire et agent, mais elle doit identifier le rôle actif et appliquer les permissions du compte. Pour un agent, chaque bien doit rester associé à l'autorisation/le mandat et au propriétaire déclaré lorsqu'ils sont connus.

### 7.1. AN-01 — Accueil / tableau de bord annonceur minimal (MVP)

**Utilisateur :** propriétaire ou agent connecté.  
**Objectif :** atteindre ses annonces et les actions de gestion autorisées.

**Contenu :** identité et rôle annonceur, accès à la création, aperçu des annonces et états importants. Afficher les annonces autorisées au compte courant uniquement.

**Actions :** créer une annonce, ouvrir une annonce gérée, consulter ses notifications.

**États :** espace vide, espace renseigné, chargement, erreur et accès restreint.

### 7.2. AN-02 — Mes annonces (MVP)

**Utilisateur :** propriétaire ou agent connecté.  
**Objectif :** suivre ses annonces et leurs statuts.

**Contenu :** liste filtrable par statut : brouillon, soumise/en examen, à compléter, publiée, refusée, suspendue, expirée ou indisponible, selon les états applicables.

**Actions :** créer, reprendre un brouillon, ouvrir le détail, modifier une annonce autorisée, mettre à jour la disponibilité lorsque permis.

**États :** liste, aucun bien, chargement, erreur et action non autorisée.

### 7.3. AN-03 — Créer / modifier une annonce : informations du bien (MVP)

**Utilisateur :** propriétaire ou agent autorisé.  
**Objectif :** décrire le bien et l'opération.

**Contenu :** titre, catégorie/type, vente ou location, description, prix facultatif/devise, disponibilité et caractéristiques adaptées au type de bien.

**Actions :** compléter, enregistrer en brouillon, poursuivre, revenir sans perdre les données déjà saisies.

**États :** vide, incomplet, invalide, sauvegardé et brouillon restauré.

### 7.4. AN-04 — Localisation du bien (MVP)

**Utilisateur :** propriétaire ou agent autorisé.  
**Objectif :** choisir et vérifier la localisation administrative et géographique.

**Contenu :** département, commune, arrondissement/quartier, suggestions de lieu et aperçu cartographique. Les coordonnées précises peuvent être conservées pour les personnes autorisées, mais ne deviennent pas publiques.

**Actions :** rechercher et choisir une suggestion, vérifier la zone, corriger la sélection.

**États :** saisie, suggestions, lieu sélectionné, aucune coordonnée précise et erreur.

### 7.5. AN-05 — Photos et vidéos (MVP)

**Utilisateur :** propriétaire ou agent autorisé.  
**Objectif :** ajouter les médias publics de présentation du bien.

**Contenu :** galerie ordonnée, prévisualisation, photos obligatoires selon les règles de publication et vidéos facultatives. Distinguer clairement les médias publics des éventuels justificatifs privés de vérification.

**Actions :** ajouter, réordonner, remplacer ou supprimer un média ; poursuivre après validation.

**États :** transfert, progression, format/taille refusé, erreur, galerie prête. Une annonce doit inclure au moins une photo avant soumission.

### 7.6. AN-06 — Contact, conditions et autorisation (MVP)

**Utilisateur :** propriétaire ou agent autorisé.  
**Objectif :** définir comment les chercheurs peuvent joindre l'annonceur et confirmer son autorisation de publier.

**Contenu :** préférences de contact, conditions de visite publiées à titre informatif et déclaration d'autorisation/mandat pertinente pour le rôle.

**Actions :** choisir les préférences, préciser les conditions, confirmer l'autorisation. Le traitement de créneaux, réponses, reports et annulations relève de AN-10 en V2.

**États :** incomplet, vérifiable, validé, erreur. Les coordonnées privées ne sont pas exposées sans consentement.

### 7.7. AN-07 — Récapitulatif et soumission (MVP)

**Utilisateur :** propriétaire ou agent autorisé.  
**Objectif :** relire l'annonce avant transmission à la modération.

**Contenu :** résumé du bien, localisation, médias, prix, disponibilité, contact, aperçu public, rôle gestionnaire/propriétaire déclaré et confirmation des règles.

**Actions :** retourner corriger une section, enregistrer en brouillon, soumettre.

**États :** prêt à soumettre, champ requis manquant, soumission confirmée, annonce en modération et erreur.

### 7.8. AN-08 — Détail / suivi d'une annonce (MVP)

**Utilisateur :** propriétaire ou agent autorisé.  
**Objectif :** comprendre l'état courant et les actions disponibles.

**Contenu :** fiche, statut explicite, historique des changements et retours de modération.

**Actions :** corriger une annonce à compléter, modifier les champs permis, mettre à jour la disponibilité si permis. La gestion opérationnelle des demandes de visite relève de AN-10 en V2.

**États :** brouillon, en modération, à compléter, publiée, refusée, suspendue, expirée et indisponible. Chaque changement de statut est expliqué et historisé.

### 7.9. AN-09 — Profil annonceur (MVP)

**Utilisateur :** propriétaire ou agent connecté.  
**Objectif :** consulter le profil et les informations de contact utilisés dans ses annonces.

**Contenu/actions :** informations autorisées du profil, coordonnées et rôle. L'agent voit ses informations de gestion séparées de l'identité du propriétaire déclaré.

**États :** consultation, modification autorisée, validation de profil, erreur.

### 7.10. AN-10 — Gestion des demandes et visites (V2)

**Utilisateur :** propriétaire ou agent autorisé sur le bien.  
**Objectif :** répondre aux demandes reçues et coordonner les visites.

**Contenu :** demandes liées aux biens gérés, créneaux proposés, conditions acceptées et état de chaque demande.

**Actions :** consulter, accepter, refuser, proposer un autre créneau, reporter ou annuler selon les règles V2.

**Navigation et états :** accès depuis le détail du bien et les notifications ; en attente, confirmée, refusée, reportée, annulée, vide, chargement et erreur. Un agent est limité à son portefeuille autorisé.

### 7.11. AN-11 — Portefeuille et reporting opérationnel (V2)

**Utilisateur :** propriétaire ou agent selon permissions.  
**Objectif :** suivre les biens et demandes de manière plus opérationnelle.

**Contenu :** portefeuille, statuts et indicateurs liés aux annonces/demandes, sans outils premium avancés.

**Actions :** filtrer et ouvrir les biens/demandes accessibles.

**États :** données disponibles, portefeuille vide, chargement, erreur et accès restreint. Les indicateurs ne sont affichés que s'ils reposent sur des données définies.

## 8. Parcours administrateur et vérificateur — back-office web

### 8.1. AD-01 — Tableau de bord de modération minimal (MVP)

**Utilisateur :** admin IMOVIA autorisé.  
**Objectif :** repérer les tâches opérationnelles prioritaires.

**Contenu :** volumes et indicateurs utiles issus du système, annonces à examiner, signalements en attente et activités récentes. Dans une maquette, tout indicateur fictif est identifié comme démonstration.

**Actions :** accéder aux files et aux détails concernés.

**États :** données disponibles, file vide, chargement, erreur et accès restreint.

### 8.2. AD-02 — Gestion / file des annonces (MVP)

**Utilisateur :** admin autorisé à gérer les annonces.  
**Objectif :** trouver les annonces à examiner ou à gérer.

**Contenu :** liste avec statut, catégorie, zone, annonceur/gestionnaire et date ; filtres correspondants.

**Actions :** filtrer, ouvrir un détail, rechercher une annonce.

**États :** file remplie/vide, chargement, erreur et droits insuffisants.

### 8.3. AD-03 — Détail d'annonce et du bien (MVP)

**Utilisateur :** admin autorisé.  
**Objectif :** examiner les informations et les preuves nécessaires à la décision.

**Contenu :** données du bien, propriétaire déclaré, gestionnaire/agent et autorisation déclarée, médias publics, statut et historique. Les pièces privées et coordonnées exactes ne sont visibles qu'à une personne explicitement habilitée.

**Actions :** consulter, annoter/décider selon le workflow, accéder à la décision de modération.

**États :** informations complètes/incomplètes, médias indisponibles, données restreintes et signalement lié.

### 8.4. AD-04 — Modération et décision de base (MVP)

**Utilisateur :** modérateur/admin ayant la permission correspondante.  
**Objectif :** décider avec une trace exploitable.

**Actions :** publier/valider, demander un complément ou refuser ; suspendre/réactiver seulement si le workflow et la permission MVP correspondants sont activés.

**Contenu :** contrôles de complétude, cohérence, médias, doublons, autorisation et signalements. Toute décision doit inclure le motif requis, l'auteur et la date.

**États :** en examen, décision à confirmer, décision enregistrée, erreur/conflit de statut. Le changement et son motif alimentent l'historique.

### 8.5. AD-05 — Utilisateurs et profils (gestion de base MVP)

**Utilisateur :** admin autorisé à gérer les comptes.  
**Objectif :** examiner et administrer les profils selon les règles.

**Contenu :** identité de compte, rôle(s), statut de vérification, annonces et signalements associés, actions d'administration accessibles.

**Actions :** consulter, suspendre/réactiver ou examiner le profil selon permission.

**États :** actif, à vérifier, suspendu, introuvable, accès restreint.

### 8.6. AD-06 — Signalements basiques (MVP)

**Utilisateur :** admin/modérateur autorisé.  
**Objectif :** traiter les signalements d'annonce ou de compte.

**Contenu :** objet signalé, catégorie/motif, date, contexte et statut de traitement.

**Actions :** ouvrir l'objet concerné, examiner, enregistrer une décision et clôturer selon le workflow.

**États :** à traiter, en cours, traité, aucun signalement, erreur.

### 8.7. AD-07 — Rôles et permissions de base (MVP)

**Utilisateur :** administrateur doté de la permission de sécurité correspondante.  
**Objectif :** contrôler l'accès aux actions sensibles.

**Contenu :** rôles, permissions et comptes concernés, avec avertissement avant modification.

**Actions :** consulter et modifier uniquement les droits autorisés, confirmer la modification.

**États :** droits existants, modification en attente, modification confirmée, refusée/erreur. L'interface ne remplace jamais le contrôle d'accès du backend.

### 8.8. AD-08 — Historique et audit de base (MVP)

**Utilisateur :** admin disposant du droit de lecture des audits.  
**Objectif :** retrouver les décisions et actions sensibles.

**Contenu :** acteur, action, objet concerné, date, changement de statut et motif lorsqu'il existe.

**Actions :** filtrer et consulter les entrées ; aucune modification ou suppression d'audit n'est proposée dans la maquette MVP.

**États :** historique, aucun événement, chargement, erreur, accès restreint.

### 8.9. VE-01 — File et dossiers de vérification documentaire (V2)

**Utilisateur :** vérificateur interne doté de permissions ciblées.  
**Objectif :** traiter séparément les vérifications documentaires du flux de modération des annonces.

**Contenu :** demandes affectées, étapes, informations nécessaires, pièces privées protégées, résultat de vérification et historique.

**Actions :** ouvrir un dossier affecté, examiner les pièces autorisées, consigner les contrôles et transmettre une conclusion selon le workflow.

**États et permissions :** à traiter, en cours, complément requis, terminé, indisponible, accès refusé. L'accès aux documents est limité, journalisé et soumis aux règles de conservation.

### 8.10. AD-09 — Opérations et modération avancées (V2)

**Utilisateur :** administrateur/modérateur autorisé.  
**Objectif :** traiter les signalements détaillés, les plaintes, les vérifications et les demandes opérationnelles.

**Contenu/actions :** files spécialisées, affectations, filtres, motifs, historiques et délais de traitement définis pour la V2. Inclure au besoin la gestion opérationnelle des catégories, sous-catégories, caractéristiques et doublons prévue au cahier des charges.

**États et permissions :** à affecter, en cours, en attente, traité, accès restreint, chargement et erreur.

### 8.11. AD-10 — Reporting interne (V2)

**Utilisateur :** membre d'équipe autorisé.  
**Objectif :** suivre les annonces, demandes et délais opérationnels.

**Contenu :** indicateurs définis et sourcés ; pas d'analytics commerciaux avancés non validés.

**États et permissions :** période sans données, données disponibles, chargement, erreur et accès restreint.

### 8.12. AD-11 — Services et prestataires (V3)

**Utilisateur :** administrateur ayant les permissions correspondantes.  
**Objectif :** gérer l'offre et les professionnels lorsque le catalogue de services est ouvert.

**Contenu/actions :** demandes d'activation, profils prestataires, catégories/services, zones et statuts selon les règles juridiques et commerciales validées avant V3.

**États :** à examiner, actif, suspendu, vide, chargement et erreur. Cet écran n'est pas à concevoir comme une fonction MVP.

## 9. Parcours prestataire — application mobile (V3)

Le parcours prestataire est différé jusqu'à la validation de l'offre réelle, des critères de référencement, des responsabilités et des conditions de service.

### 9.1. PR-01 — Inscription et demande de référencement

**Objectif :** recueillir les informations professionnelles nécessaires à une demande d'accès.

**Contenu/actions :** identité professionnelle, contact, activité et zone ; envoyer puis suivre la demande. Les pièces nécessaires restent à définir avant maquettage détaillé.

**États et permissions :** brouillon, soumis, à compléter, accepté, refusé ; compte en attente sans accès aux outils prestataire.

### 9.2. PR-02 — Profil et services proposés

**Objectif :** présenter les services activés du prestataire.

**Contenu/actions :** profil, description, catégories, zones, conditions et tarification lorsqu'elles sont validées ; modifier les données autorisées.

**États et permissions :** en préparation, à valider, actif, suspendu ; seules les offres approuvées sont visibles publiquement.

### 9.3. PR-03 — Demandes et suivi des prestations

**Objectif :** consulter et suivre les demandes de service affectées au prestataire.

**Contenu/actions :** demandes, informations utiles du client, état et échanges selon le workflow V3 défini.

**États et permissions :** nouvelle, en cours, complétée, refusée, annulée, vide, chargement et erreur ; accès limité au prestataire concerné.

## 10. Écrans partagés et comptage

| Écran partagé | Utilisateurs | Phase |
|---|---|---|
| Authentification / connexion et récupération d'accès | Tous les profils qui nécessitent un compte ; droits post-connexion selon rôle | MVP |
| Notifications essentielles | Chercheur, propriétaire, agent et équipe selon permissions | MVP |
| Profil/compte et paramètres simples | Profils connectés, avec champs distincts selon rôle | MVP |
| Messagerie : liste et conversation | Chercheur, propriétaire et agent participant | V2 |

Ces écrans sont décrits une fois dans la cartographie, même s'ils sont accessibles depuis plusieurs espaces. L'authentification doit préserver l'action et l'objet d'origine après connexion lorsque c'est pertinent.

**Comptage :** ne pas annoncer un total par profil tant que les fiches écran n'ont pas été validées. Le total de phase sera le nombre de routes/vues de navigation distinctes après déduplication des écrans partagés ; les étapes d'un formulaire, modales, états de chargement/vide/erreur et variantes de permission seront comptés séparément comme étapes ou états, pas automatiquement comme écrans.

## 11. Ordre de conception des maquettes

Chaque maquette est réalisée et validée avant de passer à la suivante ; les écrans d'un même parcours doivent préserver une navigation cohérente.

1. **MVP chercheur :** CH-01 à CH-09 ; CH-01 est l'accueil calé sur la capture de référence.
2. **MVP annonceur :** AN-01 à AN-09 ; un seul parcours commun propriétaire/agent avec permissions distinctes.
3. **MVP équipe IMOVIA :** AD-01 à AD-08 ; contrôle basique dans le flux de modération, sans espace vérificateur indépendant.
4. **V2 :** CH-10/CH-11, AN-10/AN-11, VE-01, AD-09/AD-10.
5. **V3 :** PR-01 à PR-03 et AD-11.

Chaque écran est conçu et validé avant le suivant. Ne pas créer une page autonome par écran : la planche HTML existante reste le support réutilisable. Les écrans V2/V3 ne doivent pas être présentés comme livrés dans le MVP.

## 12. Critères de validation d'un écran

Avant de considérer un écran comme prêt, vérifier :

- son profil utilisateur et ses permissions sont explicites ;
- son objectif, son point d'entrée et sa sortie dans le parcours sont compréhensibles ;
- toutes les actions visibles ont un résultat ou un état de démonstration honnête ;
- les états vide, chargement, erreur et refus d'accès pertinents sont considérés ;
- les statuts de confiance ne promettent pas une vérification supérieure à celle réellement faite ;
- les données privées et la localisation exacte ne sont pas exposées par erreur ;
- l'écran reste lisible sur mobile ou desktop selon son espace ;
- sa composition réutilise la base IMOVIA et n'introduit pas une palette ou marque différente.
