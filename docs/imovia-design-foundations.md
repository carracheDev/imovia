# IMOVIA — Maquette de référence et fondations visuelles v0.8

## Objectif

La planche de référence et sa base de composants réutilisables sont dans un seul fichier HTML. Elle sert de support aux prochaines maquettes de parcours MVP ; ce n'est pas l'interface Flutter ni une application connectée aux données réelles.

La référence fonctionnelle des écrans par utilisateur est [`IMOVIA_ecrans_MVP_par_utilisateur.md`](./IMOVIA_ecrans_MVP_par_utilisateur.md). Concevoir les maquettes depuis ce document, une par une, plutôt que d'ajouter des écrans sans parcours validé.

La maquette interactive est disponible dans [`../design-system/src/index.html`](../design-system/src/index.html).

La page conserve la composition de la planche validée, adaptée à l'identité IMOVIA. Les photos immobilières proviennent du dossier [`../design-system/images/`](../design-system/images/) : façade au coucher du soleil, villa avec piscine, séjour et villa contemporaine. Les avatars de conversation utilisent des initiales, car le dossier ne contient pas de portraits.

La planche reprend les badges de la référence — « Disponible », « Vérifié », « Nouveau » et « En vedette » — et les compteurs d'aperçu du tableau de bord. Les contrôles interactifs prévisualisent leurs états localement et ne modifient aucune donnée réelle. La section « Écrans MVP » commence par l'accueil / découverte du chercheur ; les prochains écrans seront ajoutés un par un selon les priorités documentées. Le périmètre et les phases de chaque interface sont définis dans la cartographie liée ci-dessus ; seuls les écrans MVP sont présentés comme faisant partie du lancement.

Les métriques et annonces sont fictives ; les photographies servent uniquement à la présentation visuelle.

## Palette de marque

| Token | Valeur | Usage |
|---|---|---|
| Noir principal | `#0B0B0B` | Texte principal, actions et éléments forts |
| Gris foncé | `#1F1F1F` | Surfaces et composants foncés présents dans la référence |
| Gris moyen | `#6B7280` | Texte secondaire et icônes discrètes |
| Gris clair | `#E5E7EB` | Bordures et surfaces neutres |
| Blanc | `#FFFFFF` | Fond et surfaces principales |
| Accent | `#101114` | Accent monochrome de la planche |

Le monochrome constitue l'identité de marque. Le vert, le rouge, l'ambre, le bleu et le gris ne sont employés que pour les états fonctionnels.

## Couleurs fonctionnelles

Le vert, le rouge, l'ambre et le bleu sont réservés aux états fonctionnels (disponibilité, vérification, erreur ou information). Chaque état est accompagné d'un libellé ; la couleur seule ne porte pas l'information.

| État | Texte / fond / bordure |
|---|---|---|
| Succès | `#166534` / `#DCFCE7` / `#86EFAC` |
| Erreur | `#B42318` / `#FEE4E2` / `#FDA29B` |
| Avertissement | `#92400E` / `#FEF0C7` / `#FEDF89` |
| Information | `#175CD3` / `#EFF8FF` / `#B2DDFF` |
| Neutre | `#475467` / `#F2F4F7` / `#D0D5DD` |

## Thème actuel

- **Clair uniquement** pour les maquettes de parcours MVP : fond clair, surfaces blanches, texte noir, bordures gris clair et actions primaires noires.
- La planche de référence conserve son aperçu de tableau de bord sombre tel qu'il apparaît sur l'image approuvée ; aucun sélecteur de thème n'est proposé dans le parcours produit.

## Typographie et échelles

- Titres : Manrope, avec fallback Inter / sans-serif.
- Texte et interface : Inter, avec fallback Segoe UI / sans-serif.
- Échelle typographique de départ : 12, 14, 16, 22 et 30 px.
- Espacements de départ : 2, 4, 8, 12, 16 et 24 px.
- Rayons : 8 px pour les contrôles, 12 px pour les champs, 16 px pour les cartes et pilule pour certains boutons.
- Bordures fines ; ombres limitées aux surfaces nécessitant une séparation.

## Statut de validation

Ces choix reprennent la palette monochrome et la direction visuelle approuvées pour IMOVIA. Les maquettes HTML servent à valider les parcours et les composants avant leur réalisation native en Flutter.

## Commandes

Depuis `design-system/` :

- `npm install` installe Tailwind CSS et son CLI.
- `npm run build` génère `dist/styles.css`.
- `npm test` vérifie les composants et les références d'images de la maquette.
- Ouvrir `src/index.html` dans un navigateur pour consulter la maquette interactive.
