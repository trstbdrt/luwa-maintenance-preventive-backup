# LUWA Maintenance Preventive Backup
## Décisions techniques v0.2

Date : 2026-10-09

Statut : Validées (pilotage du projet)

Origine : questions ouvertes OQ-07 et OQ-12 (`docs/build/open-questions.md`) ;
revue de logique avant le premier test du Lot 1 (points P1, P4, P5, P6).

Décisions précédentes : DEC-01 à DEC-17
(`technical-decisions-v0.1.2.md`, `-v0.1.3.md`, `-v0.1.5.md`).

---

# Synthèse

| ID | Sujet | Décision | Question clôturée |
|------|------|------|------|
| DEC-18 | DateSoumission d'une inspection INACCESSIBLE | DateSoumission = date de validation du panneau « Inaccessible » | OQ-07 |
| DEC-19 | Réponse d'une question devenue masquée | Conservée dans REPONSES ; ignorée par le moteur de règles | OQ-12 |
| DEC-20 | Brouillons abandonnés | Nouveau statut ABANDONNE, posé manuellement ; aucune suppression | Revue P1 |
| DEC-21 | Nom d'ouvrage | Comparaison insensible à la casse ; enregistré en majuscules ; espaces conservés | Revue P4 |
| DEC-22 | Dernière inspection d'un ouvrage | Dernière inspection du même type d'inspection | Revue P5 |
| DEC-23 | Date de l'InspectionID final | AAAAMMJJ calculé en heure belge (Europe/Brussels) | Revue P6 |
| DEC-24 | Résolution des photos | Capture par le contrôle Appareil photo (résolution proche de l'écran) ; pas de capture pleine résolution | Revue volumétrie |
| DEC-25 | Protection hors connexion | Copie locale de l'inspection en cours, récupération au démarrage, enregistrement différé ; application mobile Power Apps | Revue couverture réseau |

---

# DEC-18 — DateSoumission d'une inspection INACCESSIBLE

## Décision

`DateSoumission` = date et heure de validation du panneau « Ouvrage inaccessible ».

Une inspection INACCESSIBLE est considérée comme **clôturée** :

- elle possède DateCreation ;
- elle possède DateSoumission ;
- elle est archivable selon DEC-16 et DEC-17.

## Conséquences

- À la validation du panneau, DateCreation, DateDerniereModification et DateSoumission reçoivent la même valeur.
- Technical design § 7.6 : DateSoumission renseignée.

---

# DEC-19 — Réponse d'une question devenue masquée

## Décision

Une réponse saisie sur une question qui devient ensuite masquée **n'est pas supprimée**.

Exemple : POT_004 = AVANCEE, saisie de POT_004_2_A et POT_004_2_B, puis POT_004 = BON.
Les réponses POT_004_2_A et POT_004_2_B restent dans REPONSES.

Le moteur de règles les **ignore** : une question masquée n'est ni affichée, ni obligatoire,
ni contrôlée, et une condition portant sur elle est fausse (technical design § 5.3 et § 5.4).

## Objectifs

- pas de perte d'information ;
- moins de risques d'anomalie ;
- meilleure traçabilité ;
- implémentation simple.

## Conséquences

- Aucune suppression ni effacement de valeur dans REPONSES lors d'un changement de visibilité.
- Si la question redevient visible, sa réponse conservée réapparaît.
- Les exports et App 2 doivent tenir compte de la visibilité pour interpréter une réponse
  (une réponse présente n'implique pas que la question était affichée à la soumission).

---

# DEC-20 — Brouillons abandonnés

## Contexte

Les inspections BROUILLON et EN_COURS ne peuvent être ni supprimées (D007) ni archivées (DEC-16).
Sans autre mécanisme, les brouillons créés par erreur ou jamais terminés s'accumulent sans limite,
encombrent la reprise et déclenchent indéfiniment l'avertissement de concurrence (DEC-08).

## Décision

- Nouvelle valeur de StatutInspection : **ABANDONNE**.
- Posée **manuellement** par l'utilisateur, depuis la liste « Reprendre inspection », après confirmation.
- Uniquement depuis BROUILLON ou EN_COURS.
- Aucune suppression : l'inspection et ses réponses sont conservées.
- DateDerniereModification est mise à jour lors de l'abandon.

## Conséquences

- Une inspection ABANDONNE n'apparaît plus dans « Reprendre inspection » et ne déclenche plus l'avertissement de concurrence.
- Elle reste visible en lecture seule dans l'historique.
- Elle n'est pas concernée par l'archivage (DEC-16 inchangée).
- Colonne SharePoint StatutInspection : valeur ABANDONNE ajoutée le 2026-10-09.

---

# DEC-21 — Nom d'ouvrage

## Décision

- La recherche d'ouvrage est **insensible à la casse** : `e100 511` = `E100 511`.
- Le nom est enregistré **en majuscules**, espaces de début et de fin retirés.
- Les espaces internes sont **conservés tels que saisis** (certains noms d'ouvrage en contiennent, d'autres non).

## Conséquences

- `E100 511` et `E100511` restent deux ouvrages différents.
- Convention de nommage (précisée par le pilotage) : un **poteau** est nommé `E100 511`, ses **luminaires** `E100 511-1`, `E100 511-2`… Poteau et luminaire d'un même mât sont donc deux ouvrages distincts dans l'application.
- Les filtres SharePoint sur une colonne texte sont insensibles à la casse : les éventuelles saisies antérieures en minuscules restent retrouvées.

---

# DEC-22 — Dernière inspection d'un ouvrage

## Décision

Sur l'écran d'identification, la « dernière inspection » affichée est la dernière inspection
**du même type** (POTEAU ou LUMINAIRE) que l'inspection en préparation.

## Conséquences

- Le bouton « Accessible maintenant » n'apparaît que si la dernière inspection **du même type** est INACCESSIBLE.
- InspectionPrecedenteGUID (DEC-04) pointe donc toujours vers une inspection du même type.
- La liste de l'historique de l'ouvrage continue d'afficher tous les types.

---

# DEC-23 — Date de l'InspectionID final

## Décision

Dans `INS-AAAAMMJJ-NNNNNN` (DEC-14), la date `AAAAMMJJ` est la DateCreation **convertie en heure belge** (Europe/Brussels).

## Conséquences

- SharePoint stocke les dates en UTC : le flux PAU-04 convertit DateCreation avant de formater la date.
- Une inspection créée à 00 h 30 heure belge porte la date du jour, et non celle de la veille.

---

# DEC-24 — Résolution des photos

## Contexte

Environ 250 formulaires par jour et 4 à 5 photos minimum par inspection poteau : en pleine résolution (3 à 4 Mo),
plusieurs gigaoctets par jour sur le quota SharePoint de l'organisation (OQ-06 « compression désactivée » réexaminée).

## Décision

- Les photos sont capturées avec le contrôle **Appareil photo** de Power Apps, dont la résolution est proche de celle de l'écran.
- Pas d'import en pleine résolution depuis l'appareil photo natif dans le prototype.
- CompressionVersion = COMPRESSEE pour ces photos.

## Conséquences

- Volume par photo divisé environ par 10.
- Lot 3 : panneau photos construit sur le contrôle Appareil photo ; import depuis la galerie à réévaluer si nécessaire.

---

# DEC-25 — Protection hors connexion

## Contexte

Couverture 4G incomplète en Wallonie : sans protection, une fermeture de l'application ou une perte de réseau fait perdre les réponses non enregistrées.

## Décision

- Après chaque modification, l'inspection en cours (contexte et réponses) est copiée sur l'appareil (SaveData).
- Au démarrage, une inspection non synchronisée est proposée à la reprise (« Reprendre et enregistrer »).
- Enregistrement automatique dès que le réseau est disponible (toutes les 60 s) et avant le retour à l'accueil.
- Les tablettes utilisent l'**application mobile Power Apps** (SaveData / LoadData n'y sont pleinement pris en charge que là).
- Création d'une inspection sans réseau : lot 2b.

## Conséquences

- Tant qu'une inspection locale n'est pas enregistrée, « Nouvelle inspection » est désactivée et la reprise d'une autre inspection est refusée, pour ne pas écraser la copie locale.

