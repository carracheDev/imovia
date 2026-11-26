# Inventaire des composants mobile MVP

Document de validation avant la création de la première page. Les variantes ci-dessous sont des composants partagés, pas des écrans supplémentaires. Les libellés et messages visibles seront décidés page par page avec le propriétaire du produit.

## 1. Socle et navigation

- Safe area et conteneur de page adaptable (petit téléphone, grand téléphone, tablette)
- En-tête de page avec retour, titre, sous-titre et action contextuelle
- Barre de navigation basse chercheur : Accueil, Recherche, Publier, Favoris, Profil
- Shell annonceur avec accès Tableau de bord, Annonces, Notifications et Profil
- Indicateur d’étape pour les formulaires multi-sections
- En-tête d’annonce repliable et navigation retour
- Fil d’Ariane uniquement dans les formulaires annonceur si la page l’exige

## 2. Actions

- Bouton principal plein : action principale, chargement, désactivé
- Bouton secondaire contour : action alternative
- Bouton texte discret : lien ou action tertiaire
- Bouton icône : retour, filtre, favori, partager, fermer, menu
- Bouton destructif : supprimer média, retirer compte/action irréversible
- Bouton flottant publier, réservé à la navigation basse si le gabarit le permet
- Action collée en bas pour soumission ou contact, avec marge safe-area
- Tous les contrôles tactiles ont une zone interactive minimale de 48 dp

## 3. Saisie et sélection

- Champ texte une ligne et champ multiligne
- Champ recherche avec effacement et état chargement
- Champ nombre/prix FCFA, clavier numérique et format séparant les milliers
- Champ téléphone avec préfixe pays et validation
- Champ OTP à six chiffres avec collage, compte à rebours et renvoi désactivé pendant le délai
- Sélecteur déroulant ou feuille de choix pour catégorie, opération et statut
- Segmented control pour Vente/Location lorsque la page le demande
- Chips sélectionnables : type de bien, attributs et filtres actifs
- Sélection simple radio et sélection multiple checkbox/toggle
- Curseur min/max budget, stepper de nombre et interrupteur de consentement
- Champ de localisation avec suggestions, sélection administrative en cascade et effacement
- Upload média par galerie/appareil photo avec permission et progression

## 4. Résultats et biens

- Carte bien compacte (image, prix, opération, zone, caractéristiques essentielles)
- Carte bien vedette pour l’accueil ; même contenu et mêmes règles de disponibilité que la carte compacte
- Carte annonceur/profil avec niveau de vérification explicite
- Carte résumé du bien dans les étapes de contact et de soumission
- Tuile catégorie et tuile raccourci de recherche
- Galerie média/carrousel, compteur de photos, média indisponible et couverture
- Carte mini-lieu et aperçu cartographique approximatif
- Liste paginée/infinie avec bouton relancer/charger suivant selon le comportement retenu
- Aucun résultat, liste vide, squelette de chargement et erreur avec action réessayer

## 5. État et confiance

- Badge disponibilité : Disponible, Réservé, Loué/Vendu ou Indisponible
- Badge statut annonce : Brouillon, Soumise, En examen, À compléter, Publiée, Refusée, Suspendue
- Badge profil : statut de vérification explicite, sans présenter un agent non vérifié comme vérifié
- Badge opération : Vente ou Location
- Badge filtre actif et compteur quand le serveur renvoie un nombre réel
- Bandeau hors connexion/erreur réseau non bloquant quand une reprise est possible
- Alerte confidentialité/contact indiquant les canaux activés
- État vide avec action suivante et état d’erreur avec réessai
- Bannière notification non lue et pastille de compteur uniquement si le serveur retourne ce total

## 6. Listes personnelles

- Ligne/carte notification (titre, date, bien associé, lu/non lu)
- Carte favori avec disponibilité courante et retrait
- Ligne annonceur avec statut, date de mise à jour et actions disponibles selon permission
- Résumé KPI minimal annonceur, seulement à partir de données API réelles
- Avatar/initiales et panneau de profil

## 7. Fenêtres et retours

- Feuille basse pour filtres, localisation, tri et sélections longues
- Dialogue de confirmation : retirer un favori, supprimer un média, quitter un formulaire, se déconnecter
- Dialogue signalement avec catégorie et description
- Snackbar succès/erreur avec formulation courte
- Indicateur inline de validation, progression et retry
- Aperçu confirmation soumission et résumé des erreurs bloquantes

## 8. Formulaire d’annonce

- Section d’informations du bien, section caractéristiques adaptées à la catégorie
- Section localisation
- Galerie d’édition, ajout, suppression, ordre et désignation de la couverture
- Section contact : téléphone/WhatsApp et choix explicite des canaux publics
- Conditions de visite informatives, sans planification de rendez-vous (V2)
- Confirmation d’autorisation/mandat et version des conditions
- Carte aperçu public et récapitulatif avant soumission
- Sauvegarde brouillon, progression, reprise, erreurs par champ et blocage de soumission

## Principes visuels communs

- Palette clair IMOVIA : toile `#E5E7EB`, surfaces `#FFFFFF`, encre `#0B0B0B`, secondaire `#1F1F1F`, texte atténué `#6B7280`, accent `#101114`.
- États sémantiques : succès, erreur, avertissement et information, avec texte + icône (jamais la couleur seule).
- Échelle d’espacement 4/8/12/16/24/32/40 dp ; rayons 16 dp pour contrôles, 20 dp pour cartes, 24 dp pour feuilles ; ombres faibles.
- Fond clair uni : les photos sont du contenu de carte ou de galerie, pas un fond d’écran.
- Un composant ne révèle ni donnée privée, ni statut, ni chiffre que l’API n’a pas réellement fourni.
