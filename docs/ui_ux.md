# MISSION — CONCEPTION DU DESIGN SYSTEM COMPLET D'IMOVIA

Tu es un Senior Product Designer, Design System Architect et Frontend Engineer spécialisé dans les plateformes SaaS modernes, les marketplaces immobilières et les interfaces professionnelles haut de gamme.

Ta mission est de concevoir le **design system complet d'IMOVIA**, une plateforme immobilière destinée au marché béninois, avec une ambition de devenir une référence dans le secteur immobilier.

## 1. CONTEXTE DU PROJET

IMOVIA est une plateforme immobilière qui met en relation :

- Les personnes qui recherchent des logements, terrains, bureaux et autres biens immobiliers.
- Les propriétaires qui souhaitent publier et gérer leurs biens.
- Les agents immobiliers qui gèrent des annonces et accompagnent leurs clients.
- Les prestataires de services immobiliers.
- Les équipes internes chargées de la vérification, de la modération et de l'administration de la plateforme.

Architecture cible :

- Application mobile : Flutter (Android et iOS).
- Back-office professionnel : Next.js.
- Backend central : API commune aux applications.
- Design system : première implémentation de référence en HTML et Tailwind CSS.
- Nom de marque : IMOVIA.

Le design system HTML/Tailwind doit être conçu avant le développement des interfaces définitives en Flutter et Next.js.

**Important :** le laboratoire HTML/Tailwind est une référence visuelle et interactive. Il ne remplace pas les composants natifs Flutter ou Next.js de production.

## 2. RÉFÉRENCE VISUELLE OBLIGATOIRE

Utilise l'image de référence IMOVIA fournie dans cette conversation comme inspiration principale.

Respecte particulièrement :

- L'identité noire et blanche.
- Le minimalisme.
- Les grands espaces blancs.
- Les cartes propres et élégantes.
- Les bordures fines.
- Les arrondis maîtrisés.
- Les typographies modernes et affirmées.
- Les boutons noirs très visibles.
- Les interfaces sombres profondes.
- La hiérarchie visuelle claire.
- Les interfaces immobilières mettant les photographies au premier plan.

Ne reproduis pas simplement l'image. Transforme cette direction artistique en un système cohérent, réutilisable, documenté et complet.

L'ensemble doit évoquer un produit SaaS premium, moderne, professionnel et fiable.

## 3. IDENTITÉ VISUELLE ET PALETTE

### 3.1. Palette monochrome principale

Utilise cette base, avec IMOVIA comme marque premium et tech :

| Token | Couleur | Code |
|---|---|---|
| Noir principal | Noir profond | #0B0B0B |
| Gris foncé | Charbon | #1F1F1F |
| Gris moyen | Gris moyen | #6B7280 |
| Gris clair | Gris clair | #E5E7EB |
| Blanc | Blanc pur | #FFFFFF |
| Accent | Noir accent | #101114 |

Le noir, le blanc et les nuances de gris doivent représenter l'identité dominante de IMOVIA.

Ne pas introduire de jaune, de doré, de vert forêt ou d'orange comme couleur de marque principale.

### 3.2. Couleurs fonctionnelles et statuts

Les couleurs fonctionnelles sont autorisées, mais elles doivent rester discrètes et servir uniquement à communiquer une information.

Prévoir des couleurs sémantiques cohérentes :

- Vert : vérifié, disponible, validé, opération réussie.
- Rouge : refusé, erreur, bloqué, annonce signalée, action destructive.
- Orange ou ambre : en attente, avertissement, action nécessitant une attention.
- Bleu : information, traitement en cours, notification informative.
- Gris : brouillon, inactif, archivé, état neutre.

Créer pour chacune :
- Une couleur de texte.
- Une couleur de fond très légère.
- Une bordure adaptée.
- Un contraste accessible.

Pour le MVP, les variantes fonctionnelles sont conçues pour le thème clair uniquement.

Exemples de badges :

- Vérifié.
- Téléphone vérifié.
- Documents examinés.
- Visite physique effectuée.
- Disponible.
- Loué.
- Vendu.
- En attente de vérification.
- Refusé.
- Suspendu.
- Brouillon.
- Archivé.
- Nouveau.
- En vedette.

Attention : un badge « Vérifié » ne doit jamais laisser croire que tous les aspects juridiques d'un bien sont garantis. Les libellés doivent préciser la nature réelle de la vérification.

## 4. THÈME DU MVP

Pour les maquettes et le MVP, construire uniquement le thème clair :

- Fond général blanc.
- Cartes blanches.
- Texte noir.
- Bordures gris très clair.
- Boutons principaux noirs.
- Boutons secondaires blancs avec bordure.
- Surfaces secondaires gris très clair.

La variante sombre est reportée après la validation du MVP. Le tableau de bord sombre de la planche de référence reste un aperçu visuel de cette image, pas un thème alternatif activable dans les parcours du produit.

## 5. TYPOGRAPHIE ET FONDATIONS

Créer une base typographique professionnelle :

- Police principale : Inter ou une alternative moderne équivalente.
- Hiérarchie des titres.
- Titres de page.
- Sous-titres.
- Corps de texte.
- Texte secondaire.
- Libellés.
- Texte d'aide.
- Texte des boutons.
- Prix et données numériques.

Définir également :

- Échelle d'espacement.
- Échelle des tailles.
- Rayons des bordures.
- Ombres.
- Élévations.
- Largeurs de conteneurs.
- Grilles.
- Points de rupture responsive.
- Transitions.
- Focus clavier.
- États désactivés.
- États de survol.
- États de chargement.

Créer des variables CSS et des tokens Tailwind réutilisables.

Éviter les valeurs arbitraires répétées dans les composants.

## 6. INVENTAIRE COMPLET DES COMPOSANTS

Créer une bibliothèque organisée par familles.

### A. Composants fondamentaux

- Logo IMOVIA.
- Icônes.
- Avatar.
- Badge.
- Séparateur.
- Tooltip.
- Spinner.
- Skeleton.
- Indicateur de progression.
- Étiquette.
- Pastille de notification.
- Indicateur de statut.
- Breadcrumb.
- Pagination.
- Menu contextuel.

### B. Boutons

- Bouton principal.
- Bouton secondaire.
- Bouton tertiaire.
- Bouton noir.
- Bouton blanc.
- Bouton avec icône.
- Bouton circulaire.
- Bouton flottant.
- Bouton destructif.
- Bouton texte.
- Bouton de chargement.
- Bouton désactivé.
- Groupe de boutons.

Chaque bouton doit disposer de ses états : normal, hover, focus, active, disabled et loading.

### C. Formulaires et saisie

- Input texte.
- Input numérique.
- Input prix FCFA.
- Input téléphone.
- Input email.
- Textarea.
- Select.
- Multi-select.
- Combobox.
- Recherche avec suggestions.
- Checkbox.
- Radio.
- Switch.
- Slider.
- Sélecteur de date.
- Sélecteur d'heure.
- Sélecteur de plage de dates.
- Upload de fichiers.
- Upload multiple de photos.
- Zone de glisser-déposer.
- Prévisualisation de fichiers.
- Champ avec validation.
- Messages d'erreur et d'aide.

### D. Navigation

- Navbar desktop.
- Sidebar.
- Sidebar réduite.
- Navigation mobile.
- Barre de navigation inférieure.
- Menu utilisateur.
- Menu de notifications.
- Onglets.
- Sous-navigation.
- Breadcrumb.
- Menu déroulant.
- Navigation par étapes.

### E. Cartes et données

- Carte standard.
- Carte avec image.
- Carte de statistique KPI.
- Carte de profil.
- Carte de service.
- Carte de prestataire.
- Carte d'annonce.
- Carte de notification.
- Carte de visite.
- Carte de message.
- Carte d'activité.
- Carte de tableau de bord.
- Carte de résultat de recherche.

### F. Composants immobiliers

Créer des composants adaptés aux biens immobiliers.

- Carte logement à louer.
- Carte logement à vendre.
- Carte terrain.
- Carte appartement.
- Carte villa.
- Carte chambre.
- Carte bureau.
- Carte commerce.
- Galerie de photos.
- Visionneuse d'images.
- Galerie plein écran.
- Lecteur vidéo.
- Badge de prix.
- Badge de disponibilité.
- Badge de vérification.
- Badge de mise en vedette.
- Informations de localisation.
- Nombre de chambres.
- Nombre de salles de bain.
- Surface en m².
- Informations sur le propriétaire.
- Informations sur l'agent.
- Actions favoris et partage.
- Bouton contacter.
- Bouton demander une visite.

### G. Recherche et filtres

- Barre de recherche principale.
- Recherche par ville.
- Recherche par quartier.
- Recherche par type de bien.
- Filtre location/vente.
- Filtre par budget.
- Filtre par surface.
- Filtre par nombre de chambres.
- Filtre par disponibilité.
- Filtre par vérification.
- Filtres avancés.
- Filtres actifs sous forme de badges.
- Tri des résultats.
- Résultats en grille.
- Résultats en liste.
- État sans résultat.

### H. Détails d'un bien

- En-tête du bien.
- Galerie principale.
- Prix et conditions.
- Caractéristiques.
- Description.
- Localisation.
- Informations de confiance.
- Profil du propriétaire ou agent.
- Informations de vérification.
- Services associés.
- Annonces similaires.
- Contact et demande de visite.

### I. Messagerie et visites

- Liste des conversations.
- Bulle de message.
- Conversation complète.
- Champ d'envoi.
- Pièce jointe.
- Indicateur de message non lu.
- Profil du correspondant.
- Demande de visite.
- Calendrier des visites.
- Détail d'une visite.
- Statuts des visites.
- Confirmation et annulation.

### J. Services immobiliers

Les services doivent constituer un univers distinct des annonces immobilières.

Créer :

- Carte de service.
- Carte de prestataire.
- Liste de catégories.
- Fiche prestataire.
- Note et avis.
- Demande de prestation.
- Détail d'une demande.
- Statut de prestation.
- Formulaire de contact.

Prévoir des catégories de démonstration telles que photographie immobilière, entretien, rénovation, gestion locative et expertise, sans inventer de fonctionnalités métier non validées.

### K. Modales et fenêtres

- Modal de confirmation.
- Modal de suppression.
- Modal de validation.
- Modal de connexion.
- Modal de filtres.
- Modal de partage.
- Modal de signalement.
- Drawer latéral.
- Bottom sheet mobile.
- Menu contextuel.

### L. Feedback et états système

- Toast de succès.
- Toast d'erreur.
- Toast d'avertissement.
- Notification informative.
- État vide.
- État de chargement.
- État d'erreur.
- État hors connexion.
- État d'accès refusé.
- État de page introuvable.
- État de maintenance.

### M. Tableaux et composants de gestion

Pour le back-office Next.js :

- Tableau de données.
- Tableau avec sélection multiple.
- En-têtes triables.
- Pagination.
- Barre de recherche.
- Filtres avancés.
- Colonnes configurables.
- Menu d'actions.
- Ligne expandable.
- Indicateur de statut.
- Graphiques.
- Graphique linéaire.
- Graphique en barres.
- Graphique circulaire.
- Activité récente.
- Journal d'audit.
- Timeline.
- Liste d'opérations.
- Indicateur KPI.
- Widgets de tableau de bord.

## 7. COMPOSITIONS DE PAGES À DÉMONTRER

Ne pas se limiter à afficher les composants isolément. Construire également des écrans complets.

### A. Univers application mobile

La maison de marque IMOVIA doit se ressentir dans le produit mobile à travers une identité premium, sobre et rassurante.

Présenter des maquettes responsive pour :

1. Accueil.
2. Découverte des biens.
3. Recherche.
4. Filtres avancés.
5. Résultats de recherche.
6. Détail d'un bien.
7. Galerie plein écran.
8. Favoris.
9. Messagerie.
10. Détail d'une conversation.
11. Demande de visite.
12. Calendrier des visites.
13. Services immobiliers.
14. Détail d'un service.
15. Profil utilisateur.
16. Profil propriétaire.
17. Profil agent immobilier.
18. Mes annonces.
19. Publier une annonce.
20. Modifier une annonce.
21. Notifications.
22. Paramètres.
23. Centre d'aide.

### B. Univers back-office professionnel

Le back-office IMOVIA conserve l'identité premium avec une logique plus opérationnelle et plus orientée dashboard.

Présenter des maquettes desktop complètes pour :

1. Connexion.
2. Tableau de bord général.
3. Gestion des utilisateurs.
4. Détail d'un utilisateur.
5. Gestion des propriétaires.
6. Gestion des agents.
7. Gestion des prestataires.
8. Gestion des annonces.
9. Détail d'une annonce.
10. Vérification des annonces.
11. Gestion des documents.
12. Gestion des visites.
13. Gestion des signalements.
14. Gestion des services.
15. Gestion des catégories.
16. Gestion des localités.
17. Gestion des abonnements.
18. Gestion financière.
19. Notifications.
20. Journal d'audit.
21. Gestion des rôles et permissions.
22. Paramètres de la plateforme.

Le back-office doit avoir une vraie structure professionnelle : sidebar, en-tête, recherche, filtres, tableaux, cartes KPI, graphiques et espaces de travail.

## 8. GALERIE DE DÉMONSTRATION

Créer une galerie HTML/Tailwind complète et navigable.

La galerie doit permettre de :

- Consulter les fondations.
- Visualiser les couleurs.
- Changer de thème.
- Comparer les composants.
- Tester les interactions.
- Visualiser les variantes.
- Consulter les états des composants.
- Parcourir les compositions de pages.
- Voir les versions desktop et mobile.

Prévoir une navigation par familles de composants.

Chaque composant doit afficher :

- Son nom.
- Sa description.
- Ses variantes.
- Ses états.
- Son rendu en thème clair.
- Son rendu sur les surfaces claires du MVP.
- Un exemple d'utilisation.

Utiliser des données fictives réalistes adaptées au marché béninois : Cotonou, Abomey-Calavi, Porto-Novo, Parakou, etc. Les annonces et utilisateurs sont uniquement des données de démonstration.

## 9. EXIGENCES TECHNIQUES

- HTML sémantique.
- Tailwind CSS.
- JavaScript léger pour les interactions.
- Responsive design.
- Code lisible et organisé.
- Composants réutilisables.
- Accessibilité clavier.
- Contrastes suffisants.
- Icônes cohérentes provenant d'une bibliothèque reconnue.
- Pas d'emoji utilisés comme substituts aux icônes d'interface.
- Pas de backend.
- Pas de fausses connexions API.
- Pas de données réelles.
- Pas de logique métier inventée.

Les interactions doivent fonctionner réellement dans la galerie : changement de thème, onglets, menus, filtres de démonstration, modales et états interactifs.

## 10. ORGANISATION DU PROJET

Avant de créer des fichiers :

1. Inspecter le dépôt existant.
2. Lire les instructions du projet, notamment AGENTS.md, README et les conventions existantes.
3. Identifier les outils déjà installés.
4. Vérifier s'il existe déjà une galerie de composants ou un système de prévisualisation.
5. Réutiliser l'existant lorsqu'il est pertinent.
6. Ne pas créer un second système concurrent.
7. Proposer une organisation de fichiers claire.

Ne pas modifier les fonctionnalités métier, le backend ou les applications de production dans cette mission.

## 11. QUALITÉ ATTENDUE

Le résultat doit avoir le niveau visuel d'un produit SaaS commercial moderne.

Éviter absolument :

- Les interfaces génériques.
- Les cartes trop chargées.
- Les ombres lourdes.
- Les bordures excessives.
- Les couleurs criardes.
- Les dégradés décoratifs inutiles.
- Les composants incohérents entre eux.
- Les boutons de tailles aléatoires.
- Les espacements irréguliers.
- Les interfaces trop compactes.
- Les faux badges de vérification.
- Les éléments décoratifs qui gênent la lecture.

Privilégier la simplicité, la précision, la cohérence et la qualité d'exécution.

## 12. MÉTHODE DE TRAVAIL OBLIGATOIRE

Ne construis pas tout en une seule fois sans contrôle.

Procède par étapes :

**Étape 1 — Audit**
Analyse le dépôt et présente la structure existante, les contraintes et le plan d'implémentation.

**Étape 2 — Foundations**
Construis les couleurs, les thèmes, la typographie, les espacements, les rayons, les ombres et les tokens.

**Étape 3 — Composants fondamentaux**
Construis les boutons, badges, champs, cartes, menus, modales et éléments de navigation.

**Étape 4 — Composants métier**
Construis les composants immobiliers, de recherche, de messagerie, de visites, de services et du back-office.

**Étape 5 — Écrans complets**
Assemble les composants dans les écrans mobiles et les pages du back-office.

**Étape 6 — Audit final**
Vérifie la cohérence visuelle du thème clair, le responsive, les interactions et l'accessibilité.

À chaque étape, indique les fichiers créés ou modifiés, les décisions prises et les éventuels points bloquants.

Ne prétends jamais qu'une étape est terminée si elle n'a pas été testée.

## 12.1. Organisation recommandée pour le design system IMOVIA

L'organisation la plus saine est une construction progressive par besoin réel, et non une création massive de toutes les pages d'un coup.

### 12.1.1. Principe directeur

Le design system doit être créé de manière incrémentale :
- on commence par les éléments réutilisables et indispensables ;
- on ajoute les composants quand le besoin apparaît ;
- on ne crée pas une page complète juste pour la beauté de la galerie ;
- on n'ajoute pas de module sans lien avec un parcours métier validé.

### 12.1.2. Pyramide de priorisation

**Niveau 1 — Fondations**
- palette ;
- fondations typographiques ;
- spacing et dimensions ;
- rayons ;
- ombres ;
- thème clair du MVP (thème sombre reporté) ;
- tokens CSS/Tailwind.

**Niveau 2 — Composants fondamentaux**
- boutons ;
- inputs ;
- cartes ;
- badges ;
- modales ;
- navbars ;
- menus ;
- tables ;
- notifications.

**Niveau 3 — Composants immobiliers**
- cartes de biens ;
- galerie de biens ;
- filtres de recherche ;
- fiches d'annonces ;
- cartes de visites ;
- composants de signalement.

**Niveau 4 — Écrans pilotes du MVP**
- accueil / recherche ;
- résultats ;
- fiche bien ;
- publier une annonce ;
- espace annonceur ;
- tableau de bord admin ;
- modération d'annonce.

**Niveau 5 — Extension V2/V3**
- messagerie ;
- visites détaillées ;
- services immobiliers ;
- gestion avancée ;
- back-office complet ;
- site public / canal de visibilité.

### 12.1.3. Règle de travail recommandée

On construit le design system au fur et à mesure du besoin réel, conformément à la logique suivante :

- un composant n'est créé qu'une fois qu'il est utile à un vrai écran ou un vrai parcours ;
- une page complète n'est ajoutée que lorsqu'elle correspond à un cas d'usage validé ;
- les variantes thème clair/sombre sont ajoutées quand le composant est prêt et validé ;
- la documentation vient après le composant, et non avant.

Cela évite de créer un système théorique trop large, trop abstrait et peu exploitable.

### 12.1.4. Organisation logique des fichiers

Le design system doit être structuré comme un vrai produit, mais sans sur-construction inutile. La meilleure logique est :

- foundations/
- components/
- patterns/
- screens/
- pages/
- themes/
- documentation/

Les fichiers et dossiers doivent correspondre à des usages réels, pas à une planification artificielle à 100 écrans.

### 12.1.5. Validation de la méthode

La méthode recommandée est celle-ci :

1. Créer les fondations.
2. Construire les composants fondamentaux.
3. Valider 3 à 5 parcours utilisateurs représentatifs.
4. Créer les écrans du MVP.
5. Ajouter les composants nécessaires à la demande.
6. Étendre le système uniquement si un besoin métier le justifie.

Cette méthodologie est plus saine qu'un “design system complet en une fois”, car elle maintient la cohérence sans produire un sur-ensemble inutile.

## 13. LIVRABLE FINAL

Je veux obtenir :

1. Une identité visuelle IMOVIA cohérente.
2. Un système de tokens documenté.
3. Deux thèmes complets.
4. Une bibliothèque complète de composants.
5. Une galerie HTML/Tailwind navigable.
6. Des exemples d'interactions fonctionnelles.
7. Des compositions mobiles.
8. Des compositions de back-office.
9. Une documentation facilitant la future traduction du design system en Flutter et Next.js.

**RÈGLE FINALE :** la priorité est la qualité du design system, pas la vitesse à laquelle tu écris des fichiers. Il faut d'abord obtenir une référence visuelle solide, cohérente et validable avant de commencer le développement complet des interfaces de production.