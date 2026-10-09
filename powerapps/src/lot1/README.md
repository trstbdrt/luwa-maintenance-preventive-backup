# Lot 1 — Home, Type, Identification, création d'inspection, historique, inaccessible

Format : **tablette** (1366 × 768). Plan général : `powerapps/canvas-app-build-plan.md`.

## Contenu

| Fichier | Où le coller |
|------|------|
| `01-App.Formulas.fx` | App > propriété **Formulas** |
| `02-App.OnStart.fx` | App > propriété **OnStart** |
| `03-Screen_Type.pa.yaml` | Arborescence > coller (écran) |
| `04-Screen_Home.pa.yaml` | Arborescence > coller (écran) |
| `05-Screen_Identification.pa.yaml` | Arborescence > coller (écran) |
| `06-Screen_Inspection.pa.yaml` | Arborescence > coller (écran provisoire, remplacé au lot 2) |
| `07-Screen_History.pa.yaml` | Arborescence > coller (écran) |
| `*.fr.fx` | Variante des fichiers `.fx` si Power Apps Studio utilise les séparateurs français (`;` entre arguments, `;;` entre instructions) |

## Étapes

1. **Créer l'application dans une solution** (portabilité vers un autre site, voir plus bas) :
   make.powerapps.com > **Solutions** > Nouvelle solution « LUWA Maintenance Backup » ;
   dans la solution : Nouveau > Application > Application canevas, format **Tablette**,
   nom « LUWA Inspection Backup ».
   Avant d'ajouter les données : ⚙ Paramètres > Mises à jour > activer
   « Créer automatiquement des variables d'environnement lors de l'ajout de sources de données ».
2. **Paramètres** : limite de lignes de données = 2000 ; activer « Gestion des erreurs au niveau des formules »
   et les « Formules nommées » si elles ne le sont pas.
3. **Données** : Ajouter des données > SharePoint > `https://wavenetbe.sharepoint.com/sites/LuwaMaintenancePreventiveBackup`
   > cocher INSPECTIONS, QUESTIONS, REGLES_FORMULAIRE, REPONSES, PHOTOS_INSPECTIONS.
4. **Langue des formules** : ouvrir la barre de formule d'un contrôle quelconque.
   Si les exemples utilisent `;` entre arguments, utiliser les fichiers `.fr.fx` ; sinon les fichiers `.fx`.
   Les fichiers `.pa.yaml` sont collés tels quels dans les deux cas.
5. **Coller les écrans dans cet ordre** : Screen_Type (le plus simple, sert de test de collage),
   puis Screen_Home, Screen_Identification, Screen_Inspection, Screen_History.
   Pour chacun : copier tout le contenu du fichier, puis clic droit dans l'arborescence des écrans > **Coller**.
6. **Supprimer l'écran vide** créé par défaut (Screen1) et définir **App.StartScreen** = `Screen_Home`.
7. **Coller** `Formulas` puis `OnStart`, puis exécuter OnStart (… à côté de App > Exécuter OnStart).
8. Enregistrer, puis lancer les tests ci-dessous.

## Si le collage d'un écran échoue

Les versions de contrôles (`Label@2.5.1`, `Classic/Button@2.2.0`, `Gallery@2.15.0`…) peuvent différer
selon la version de Studio. Dans ce cas :

1. insérer manuellement un bouton, une étiquette et une galerie verticale sur un écran ;
2. clic droit sur chacun > **Copier le code** ;
3. me transmettre le texte copié et le message d'erreur : j'aligne les fichiers.

## Limites volontaires du lot 1

- Pas de photo dans le panneau « Ouvrage inaccessible » : l'envoi des fichiers dépend du flux PAU-06 (lot 3).
  Le commentaire suffit pour valider (photo facultative).
- Screen_Inspection est provisoire : en-tête de l'inspection seulement (questionnaire au lot 2).
- InspectionID reste `TMP-…` tant que le flux PAU-04 n'est pas construit.

## Tests du lot 1

Utiliser des ouvrages fictifs au format réel : poteau `TEST 101`, luminaire `TEST 101-1` : aucune suppression n'est possible (D007).

| # | Test | Attendu | Vérification |
|------|------|------|------|
| T01 | Démarrage, vue Variables > Collections | `colQuestions` = 34, `colRegles` = 29 | Studio |
| T02 | Nouvelle inspection > Poteau > `TEST-001` > Rechercher > Commencer | Écran Inspection affiche `TMP-xxxxxxxx` | Liste INSPECTIONS : Title = InspectionID = TMP-…, InspectionGUID renseigné, BROUILLON, NON_ANALYSE, Inspecteur = vous, DateCreation renseignée |
| T03 | Nouvelle inspection > Poteau > `TEST-001` > Rechercher | Bandeau « Brouillon », avertissement de concurrence affiché, bouton « Commencer » actif | — |
| T03b | Luminaire sur `TEST-001-1` (convention : poteau `TEST-001`, luminaire `TEST-001-1`) | Pas d'avertissement : ouvrage différent | — |
| T04 | Accueil > Reprendre inspection | L'inspection de T02 apparaît ; clic → écran Inspection avec le même `TMP-…` | — |
| T13 | Nouvelle inspection > Poteau > `TEST-002` > Rechercher > Inspection inaccessible ; Valider sans commentaire puis avec | Valider désactivé sans commentaire ; retour à l'accueil avec confirmation | INSPECTIONS : INACCESSIBLE, DateSoumission renseignée (DEC-18) ; REPONSES : SYS_001 avec le commentaire, Title = ReponseID |
| T14 | `TEST-002` > Rechercher | Bandeau « Inaccessible », bouton « Accessible maintenant » ; clic → nouvelle inspection | INSPECTIONS : InspectionPrecedenteGUID = GUID de l'inspection de T13 ; celle-ci inchangée |
| T15 | Accueil > Historique > `TEST-002` > sélection de l'inspection inaccessible | Détail + commentaire SYS_001 ; aucun champ modifiable | DateDerniereModification inchangée |
| T16 | Accueil > Reprendre > « Abandonner » sur l'inspection de T02, confirmer | Elle disparaît de la liste ; `TEST-001` en Poteau n'affiche plus l'avertissement | INSPECTIONS : ABANDONNE, DateDerniereModification mise à jour (DEC-20) |
| T17 | Identification `test-001` (minuscules) | Mêmes inspections que `TEST-001` ; nouvelle inspection enregistrée `TEST-001` | DEC-21 |
| T18 | `TEST-002` déclaré inaccessible en Poteau, puis Luminaire sur `TEST-002` (cas d'erreur de saisie) | Pas de « Accessible maintenant » en Luminaire | DEC-22 |
| T19 | Luminaire sur `TEST-001` (sans -N) ; puis Poteau sur `TEST-001-1` | Message orange « Vérifiez le nom… » ; création toujours possible (non bloquant) | — |
| T20 | Luminaire sur `TEST-002-1` après T13 | Ligne « Poteau TEST-002 : dernière inspection INACCESSIBLE le … » | — |
| T15b | Identification `TEST-001` > clic sur une inspection de la liste | Historique ouvert directement sur l'inspection ; Retour → Identification | — |

Points à observer pendant les tests :

- **Avertissements de délégation** (triangle jaune) : surtout le filtre `Inspecteur.Email` de « Reprendre inspection ».
- **Colonne Personne** : si le Patch d'`Inspecteur` échoue, me transmettre le message d'erreur.
- **Localisation** : Power Apps demande l'autorisation de position ; GPS vide si refusée (colonnes facultatives).

## Portabilité vers un autre site SharePoint

| Élément | Comment le déplacer |
|------|------|
| Structure SharePoint (listes, colonnes, index, bibliothèque) | Rejouer la construction sur le nouveau site (même schéma, mêmes noms internes) puis réimporter `questions.csv` et `regles_formulaire.csv` |
| Application et flux | Exporter la **solution** (make.powerapps.com > Solutions > Exporter) et l'importer dans l'environnement cible ; à l'import, renseigner les **variables d'environnement** (adresse du site, listes) |
| Données (inspections, réponses, photos) | Copie des listes et de la bibliothèque (outil de migration SharePoint ou flux dédié), en conservant InspectionGUID |

Sans solution ni variables d'environnement, il faudrait supprimer et rajouter chaque source de données
dans Studio après déplacement : c'est pourquoi l'application doit être créée **dans une solution** dès le départ.
