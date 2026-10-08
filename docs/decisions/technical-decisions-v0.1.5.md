# LUWA Maintenance Preventive Backup
## Décisions techniques v0.1.5

Version : 0.1.5 (adoptées en v0.1.6, numérotation définitive en v0.1.7)

Date : 2026-10-08

Statut : Validées (revue d'architecture)

Origine : questions ouvertes OQ-01 à OQ-05 (`docs/build/open-questions.md`, version 0.1.4).

Ces décisions sont **techniques**. Elles n'introduisent aucune nouvelle règle métier
et ne modifient ni les catalogues, ni la spécification fonctionnelle, ni l'architecture.

Décisions précédentes :

- `docs/decisions/technical-decisions-v0.1.2.md` (DEC-01 à DEC-10)
- `docs/decisions/technical-decisions-v0.1.3.md` (DEC-11, DEC-12)

Note de numérotation : en v0.1.6, ces décisions étaient provisoirement numérotées DEC-14 à DEC-17.
La numérotation définitive DEC-13 à DEC-17 est appliquée en v0.1.7 ; le contenu est inchangé.

---

# Synthèse

| ID | Sujet | Décision | Question ouverte clôturée |
|------|------|------|------|
| DEC-13 | InspectionID temporaire | `TMP-{8 premiers caractères du GUID}` | OQ-01 |
| DEC-14 | InspectionID final | Attribué par Power Automate : `INS-AAAAMMJJ-NNNNNN`, AAAAMMJJ = DateCreation, NNNNNN = ID SharePoint | OQ-02 |
| DEC-15 | Dossiers photos | `PHOTOS_INSPECTIONS/{InspectionGUID}`, jamais InspectionID, aucun renommage | OQ-03 |
| DEC-16 | Statuts archivables | TERMINE et INACCESSIBLE uniquement | OQ-04 |
| DEC-17 | Règle des 6 mois | 183 jours depuis DateDerniereModification ; l'archivage ne modifie pas cette date ; seule une modification métier la réactive | OQ-05 |

---

# DEC-13 — InspectionID temporaire

## Contexte

DEC-11 autorise un InspectionID temporaire pendant la saisie, sans en fixer le format.

## Décision

Pendant la phase de saisie, l'identifiant affiché est :

`TMP-{8 premiers caractères du GUID}`

Exemple : InspectionGUID `3f2a9c4e-7b1d-4e8a-9c2f-1a5b6d7e8f90` → `TMP-3f2a9c4e`

## Objectifs

- lisible pour l'utilisateur ;
- identifiable rapidement ;
- différent du format final.

## Conséquences

- InspectionID et Title (DEC-01) valent `TMP-…` jusqu'à l'attribution de la valeur finale (DEC-14).
- Le préfixe `TMP-` distingue un identifiant temporaire d'un identifiant final (`INS-`).
- L'identifiant temporaire n'est jamais utilisé comme clé (DEC-03, DEC-11).
- Élément de backlog concerné : PA-07.

---

# DEC-14 — InspectionID final

## Contexte

DEC-11 fixe le moment d'attribution de l'InspectionID final (synchronisation SharePoint)
sans en fixer le mécanisme.

## Décision

**Power Automate** attribue toujours l'InspectionID final.

Format : `INS-AAAAMMJJ-NNNNNN`

| Partie | Source |
|------|------|
| `AAAAMMJJ` | **DateCreation** de l'inspection — jamais la date de synchronisation |
| `NNNNNN` | **ID SharePoint** de l'élément INSPECTIONS, sur 6 chiffres complétés par des zéros |

Exemple : DateCreation 2026-10-08, ID SharePoint 123 → `INS-20261008-000123`

## Objectifs

- unicité garantie ;
- aucun risque de collision ;
- pas de table compteur ;
- compatible mode hors connexion.

## Conséquences

- Aucune gestion de concurrence n'est nécessaire : l'ID SharePoint est unique dans la liste.
- Le compteur n'est pas remis à zéro chaque jour : il suit l'ID SharePoint.
- Title est mis à jour en même temps qu'InspectionID (DEC-01).
- Élément de backlog concerné : PAU-04.

---

# DEC-15 — Nommage des dossiers photos

## Décision

Les dossiers photos utilisent **toujours InspectionGUID** et **jamais InspectionID**.

Exemple : `PHOTOS_INSPECTIONS/550e8400-e29b-41d4-a716-446655440000`

**Aucun renommage** n'est effectué lorsque l'InspectionID final est attribué.

## Objectifs

- pas de collision ;
- pas de dépendance au numéro métier ;
- compatible hors connexion.

## Conséquences

- Un dossier par inspection, nommé par son InspectionGUID, à la racine de PHOTOS_INSPECTIONS.
  Cette structure remplace la structure `AAAA/MM/InspectionID/` du schéma v0.1.4.
- La relation photo ↔ inspection reste portée par la métadonnée InspectionGUID (DEC-03).
- Éléments de backlog concernés : PA-16, PAU-05.

---

# DEC-16 — Statuts archivables

## Décision

| Statut | Archivable |
|------|------|
| TERMINE | Oui |
| INACCESSIBLE | Oui |
| BROUILLON | **Non** |
| EN_COURS | **Non** |

## Objectif

Ne jamais masquer une inspection encore exploitable.

## Conséquences

- Une inspection BROUILLON ou EN_COURS reste visible quelle que soit son ancienneté.
- La conséquence de DEC-12 « un brouillon rouvert repart à zéro » est sans objet :
  un brouillon n'est jamais archivé.
- Élément de backlog concerné : PAU-03.

---

# DEC-17 — Règle des 6 mois

## Décision

| Élément | Décision |
|------|------|
| Date de référence | **DateDerniereModification** (et non DateCreation ni DateSoumission) — confirme DEC-12 |
| Durée | **183 jours** |
| Effet de l'archivage | Le passage en ARCHIVE **ne modifie pas** DateDerniereModification |
| Réouverture | Une **modification réelle** : ajout de photo, modification de réponse, ajout de commentaire |
| Consultation | Une simple consultation n'est **pas** une réouverture |

Règle complète (DEC-12, DEC-16, DEC-17) :

Une inspection est archivable si et seulement si :

- son statut est TERMINE ou INACCESSIBLE ;
- et Aujourd'hui - DateDerniereModification > 183 jours.

## Conséquences

- Toute modification métier met à jour DateDerniereModification.
- La consultation en lecture seule (Screen_History) ne modifie jamais DateDerniereModification.
- Les inspections TERMINE et INACCESSIBLE étant en lecture seule (décision D005),
  leur DateDerniereModification est en pratique celle de la soumission ou de la déclaration d'inaccessibilité.
- Élément de backlog concerné : PAU-03.
