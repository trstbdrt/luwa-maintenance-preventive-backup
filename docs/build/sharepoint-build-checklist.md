# LUWA Maintenance Preventive Backup
## Checklist de construction SharePoint

Version : 0.1.4

Date : 2026-10-08

Références :

- `sharepoint/data-model/sharepoint-schema.md` (v0.1.4) — source de vérité des colonnes
- `sharepoint/build/sharepoint-build-guide.md` — procédures détaillées (§ entre parenthèses)
- `docs/decisions/technical-decisions-v0.1.2.md`, `docs/decisions/technical-decisions-v0.1.3.md`

Mode d'emploi : cocher chaque case dans l'ordre. Ne pas passer à l'étape suivante
tant qu'une case de l'étape en cours n'est pas cochée.

Réalisé par : ____________________  Date : ____________  Site : ______________________________

---

# Étape 0 — Prérequis

- [ ] Site SharePoint Online dédié créé
- [ ] Droits Propriétaire du site disponibles
- [ ] Dépôt récupéré à la version `v0.1.4` (ou ultérieure)
- [ ] Fichiers disponibles : `sharepoint/questions/questions.csv`, `sharepoint/regles/regles_formulaire.csv`
- [ ] Langue du site notée (FR / EN) : ________ — détermine les valeurs Oui/Non à l'import (guide § 7.1)
- [ ] Règle comprise : chaque colonne est créée **avec son nom exact** (nom interne définitif) (guide § 0)
- [ ] Règle comprise : les index sont créés **avant** tout import (guide § 0)

---

# Étape 1 — Création des listes et de la bibliothèque

Pour chaque liste : **Nouveau > Liste > Liste vide**, puis dans les paramètres :
historique des versions activé, pièces jointes désactivées.

- [ ] Liste `INSPECTIONS` créée
- [ ] Liste `QUESTIONS` créée
- [ ] Liste `REGLES_FORMULAIRE` créée
- [ ] Liste `REPONSES` créée
- [ ] Bibliothèque de documents `PHOTOS_INSPECTIONS` créée (**Nouveau > Bibliothèque de documents**), historique des versions activé
- [ ] Les 5 noms sont exactement ceux ci-dessus (majuscules, underscore, sans accent)

---

# Étape 2 — Colonnes

Légende : **Obl.** = « Exiger que cette colonne contienne des informations ».
Texte multiligne = **texte brut**. Choice = liste déroulante, **sans** valeur de remplissage.

## 2.1 INSPECTIONS

- [ ] `Title` (native) : Obl. Oui — contiendra InspectionID
- [ ] `InspectionID` : Une ligne de texte — Obl. Oui
- [ ] `InspectionGUID` : Une ligne de texte — Obl. Oui
- [ ] `TypeInspection` : Choix — Obl. Oui — valeurs : `POTEAU`, `LUMINAIRE`
- [ ] `NomOuvrage` : Une ligne de texte — Obl. Oui
- [ ] `Inspecteur` : Personne — Obl. Oui — personnes uniquement
- [ ] `DateCreation` : Date et heure — Obl. Oui
- [ ] `DateDerniereModification` : Date et heure — Obl. Oui
- [ ] `DateSoumission` : Date et heure — Obl. Non
- [ ] `StatutInspection` : Choix — Obl. Oui — valeurs : `BROUILLON`, `EN_COURS`, `TERMINE`, `INACCESSIBLE`, `ARCHIVE`
- [ ] `StatutTraitement` : Choix — Obl. Oui — valeurs : `NON_ANALYSE`, `ANALYSE_EN_COURS`, `VALIDE`, `ACTION_REQUISE`, `CLOTURE` — **valeur par défaut `NON_ANALYSE`** (DEC-02)
- [ ] `GPSLatitude` : Nombre — Obl. Non — 6 décimales
- [ ] `GPSLongitude` : Nombre — Obl. Non — 6 décimales
- [ ] `InspectionPrecedenteGUID` : Une ligne de texte — Obl. Non
- [ ] Aucune colonne `CommentaireInaccessible` (supprimée en v0.1.1)

## 2.2 QUESTIONS

- [ ] `Title` (native) : Obl. Oui — contiendra QuestionCode (DEC-01)
- [ ] `QuestionCode` : Une ligne de texte — Obl. Oui
- [ ] `QuestionParent` : Une ligne de texte — Obl. Non
- [ ] `DisplayGroup` : Choix — Obl. Oui — valeurs : `GENERAL`, `CORROSION`, `SUR_PONT`, `SYSTEM`
- [ ] `Formulaire` : Choix — Obl. Oui — valeurs : `POTEAU`, `LUMINAIRE`, `SYSTEM`
- [ ] `OrdreAffichage` : Nombre — Obl. Oui — 0 décimale
- [ ] `Libelle` : Une ligne de texte — Obl. Oui
- [ ] `TypeQuestion` : Choix — Obl. Oui — valeurs : `RADIO`, `CHECKBOX`, `NUMERIQUE`, `PHOTO`, `TEXTE`, `CALCUL`, `SYSTEM`
- [ ] `Obligatoire` : Oui/Non
- [ ] `CommentaireAutorise` : Oui/Non
- [ ] `CommentaireObligatoire` : Oui/Non
- [ ] `PhotoAutorisee` : Oui/Non
- [ ] `NbPhotosMin` : Nombre — Obl. Oui — 0 décimale
- [ ] `NbPhotosMax` : Nombre — Obl. Oui — 0 décimale
- [ ] `VisibleParDefaut` : Oui/Non
- [ ] `ValeursPossibles` : Plusieurs lignes de texte — texte brut — Obl. Non
- [ ] `FormuleCalcul` : Plusieurs lignes de texte — texte brut — Obl. Non

## 2.3 REGLES_FORMULAIRE

- [ ] `Title` (native) : Obl. Oui — contiendra RuleID (DEC-01)
- [ ] `RuleID` : Une ligne de texte — Obl. Oui
- [ ] `Priorite` : Nombre — Obl. Oui — 0 décimale
- [ ] `Formulaire` : Choix — Obl. Oui — valeurs : `POTEAU`, `LUMINAIRE`, `SYSTEM`, `ALL`
- [ ] `QuestionSource` : Une ligne de texte — Obl. Oui
- [ ] `ConditionType` : Choix — Obl. Oui — valeurs : `EQUALS`, `GREATER_OR_EQUAL`, `LESS_THAN`, `VISIBLE`, `VALIDATION`, `SAVE`, `PRESENCE`
- [ ] `ConditionValeur` : Une ligne de texte — Obl. Oui
- [ ] `Action` : Choix — Obl. Oui — valeurs : `AFFICHER`, `AFFICHER_IF_MATCH`, `WAITING_SECOND_CONDITION`, `MASQUER_FORMULAIRE`, `PHOTO_MIN`, `RENDRE_OBLIGATOIRE`, `OBLIGATOIRE`, `COMMENT_OBLIGATOIRE`, `BLOQUER_CALCUL`, `BLOQUER_SOUMISSION`, `VERIFIER`, `AUTORISER`
- [ ] `QuestionCible` : Une ligne de texte — Obl. Oui
- [ ] `Parametre` : Une ligne de texte — Obl. Non
- [ ] `Actif` : Oui/Non
- [ ] `Commentaire` : Plusieurs lignes de texte — texte brut — Obl. Non

## 2.4 REPONSES

- [ ] `Title` (native) : Obl. Oui — contiendra ReponseID (DEC-01)
- [ ] `ReponseID` : Une ligne de texte — Obl. Oui — GUID (DEC-03)
- [ ] `InspectionGUID` : Une ligne de texte — Obl. Oui
- [ ] `QuestionCode` : Une ligne de texte — Obl. Oui
- [ ] `Valeur` : **Plusieurs lignes de texte** — texte brut — Obl. Non (DEC-05)
- [ ] `ValeurNumerique` : Nombre — Obl. Non — décimales automatiques
- [ ] `Commentaire` : Plusieurs lignes de texte — texte brut — Obl. Non
- [ ] `DateEncodage` : Date et heure — Obl. Oui
- [ ] `UtilisateurEncodage` : Personne — Obl. Oui — personnes uniquement

## 2.5 PHOTOS_INSPECTIONS (métadonnées)

- [ ] `InspectionGUID` : Une ligne de texte — Obl. Oui
- [ ] `QuestionCode` : Une ligne de texte — Obl. Oui
- [ ] `NomOuvrage` : Une ligne de texte — Obl. Oui
- [ ] `Auteur` : Personne — Obl. Oui — personnes uniquement
- [ ] `DatePhoto` : Date et heure — Obl. Oui
- [ ] `CompressionVersion` : Choix — Obl. Non — valeurs : `ORIGINAL`, `COMPRESSEE`

## 2.6 Vérification des noms internes

Pour chaque colonne créée : **Paramètres de la colonne**, l'URL contient `Field=<NomInterne>`.

- [ ] INSPECTIONS : noms internes identiques au schéma
- [ ] QUESTIONS : noms internes identiques au schéma
- [ ] REGLES_FORMULAIRE : noms internes identiques au schéma
- [ ] REPONSES : noms internes identiques au schéma
- [ ] PHOTOS_INSPECTIONS : noms internes identiques au schéma, `Auteur` distinct de la colonne native « Créé par » (guide § 3.5)

---

# Étape 3 — Index

**Paramètres de la liste > Colonnes indexées > Créer un nouvel index** (guide § 5).

## INSPECTIONS

- [ ] `Title`
- [ ] `InspectionID`
- [ ] `InspectionGUID`
- [ ] `TypeInspection`
- [ ] `NomOuvrage`
- [ ] `StatutInspection`
- [ ] `StatutTraitement`

## QUESTIONS

- [ ] `QuestionCode`
- [ ] `QuestionParent`
- [ ] `Formulaire`

## REGLES_FORMULAIRE

- [ ] `RuleID`
- [ ] `Priorite`
- [ ] `Formulaire`
- [ ] `QuestionSource`

## REPONSES

- [ ] `ReponseID`
- [ ] `InspectionGUID`
- [ ] `QuestionCode`
- [ ] `DateEncodage`

## PHOTOS_INSPECTIONS

- [ ] `InspectionGUID`
- [ ] `QuestionCode`
- [ ] `NomOuvrage`
- [ ] `DatePhoto`

## Contrôle

- [ ] Chaque liste a moins de 20 index
- [ ] Les 22 index ci-dessus apparaissent dans « Colonnes indexées »

---

# Étape 4 — Import de questions.csv

Procédure détaillée : guide § 7.

- [ ] Fichier ouvert dans Excel via **Données > À partir d'un fichier texte/CSV**, encodage UTF-8 (65001), délimiteur virgule
- [ ] Toutes les colonnes forcées en type **Texte**
- [ ] Colonne `Title` ajoutée = `QuestionCode` (DEC-01)
- [ ] `Obligatoire`, `CommentaireAutorise`, `CommentaireObligatoire`, `PhotoAutorisee`, `VisibleParDefaut` convertis de OUI/NON vers les valeurs Oui/Non du site
- [ ] Conversion testée sur une seule ligne avant import complet
- [ ] `ValeursPossibles` (séparateur `|`) et `FormuleCalcul` conservés tels quels
- [ ] Vue « Import » créée avec les colonnes dans l'ordre de la feuille Excel
- [ ] Données collées en **mode grille** (sans l'en-tête), enregistrement terminé

## Contrôles post-import QUESTIONS (guide § 9.1)

- [ ] 34 éléments
- [ ] Formulaire : POTEAU 20, LUMINAIRE 13, SYSTEM 1
- [ ] Aucun QuestionCode en double
- [ ] Title = QuestionCode sur toutes les lignes
- [ ] Obligatoire = Oui : 30
- [ ] VisibleParDefaut = Non : 8
- [ ] CommentaireObligatoire = Oui : 1 (SYS_001)
- [ ] PhotoAutorisee = Non : 5
- [ ] QuestionParent renseigné : 8
- [ ] ValeursPossibles renseigné : 26
- [ ] FormuleCalcul renseigné : 1 — POT_004_2_C = `((POT_004_2_A-POT_004_2_B)/POT_004_2_A)*100`, sans balise HTML
- [ ] DisplayGroup : GENERAL 23, CORROSION 8, SUR_PONT 2, SYSTEM 1
- [ ] TypeQuestion : RADIO 22, CHECKBOX 4, PHOTO 2, TEXTE 2, NUMERIQUE 2, CALCUL 1, SYSTEM 1

---

# Étape 5 — Import de regles_formulaire.csv

Procédure détaillée : guide § 8. Prérequis : étape 4 entièrement cochée.

- [ ] Fichier ouvert dans Excel en UTF-8, toutes les colonnes en type **Texte**
- [ ] Colonne `Title` ajoutée = `RuleID` (DEC-01)
- [ ] `Actif` converti de OUI/NON vers les valeurs Oui/Non du site
- [ ] `QuestionSource` = `FORMULAIRE` conservé (R500 à R600)
- [ ] `QuestionCible` = `*` conservé (R002, R151, R500 à R600)
- [ ] `ConditionValeur` numériques (`30`, `0`) conservées en texte
- [ ] Données collées en **mode grille**, enregistrement terminé

## Contrôles post-import REGLES_FORMULAIRE (guide § 9.2)

- [ ] 29 éléments
- [ ] Formulaire : POTEAU 20, ALL 5, LUMINAIRE 2, SYSTEM 2
- [ ] Actif = Oui : 29
- [ ] Aucun RuleID en double
- [ ] Title = RuleID sur toutes les lignes
- [ ] Action : PHOTO_MIN 8, AFFICHER 7, VERIFIER 3, BLOQUER_SOUMISSION 2, AUTORISER 2, et 1 pour chacune des 7 autres
- [ ] ConditionType : EQUALS 19, VALIDATION 4, PRESENCE 2, GREATER_OR_EQUAL 1, LESS_THAN 1, VISIBLE 1, SAVE 1
- [ ] Parametre renseigné : 8 (R140, R200, R201, R202, R300, R301, R302, R303)
- [ ] R120 : ConditionType = GREATER_OR_EQUAL, ConditionValeur = 30
- [ ] R600 : Action = AUTORISER

## Cohérence croisée (guide § 9.3)

- [ ] Chaque QuestionSource et QuestionCible (hors `FORMULAIRE` et `*`) existe dans QUESTIONS

---

# Étape 6 — Permissions (guide § 10)

- [ ] Niveau d'autorisation « Contribution sans suppression » créé
- [ ] Attribué aux techniciens sur INSPECTIONS, REPONSES, PHOTOS_INSPECTIONS
- [ ] Techniciens en **Lecture** sur QUESTIONS et REGLES_FORMULAIRE
- [ ] Modification des catalogues réservée aux administrateurs fonctionnels

---

# Validation finale

- [ ] Étapes 0 à 6 entièrement cochées
- [ ] Aucun fichier `sharepoint/data-model/*.csv` importé en production
- [ ] Checklist transmise pour la suite : `docs/build/powerapps-readiness.md`

Validé par : ____________________  Date : ____________
