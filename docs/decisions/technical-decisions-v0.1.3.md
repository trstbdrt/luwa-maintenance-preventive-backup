# LUWA Maintenance Preventive Backup
## Décisions techniques v0.1.3

Version : 0.1.3 (figées en v0.1.4)

Date : 2026-10-08

Statut : Validées

Origine : points restés ouverts après le Sprint 0
(`docs/reviews/build-readiness-v0.1.3.md`, backlog DEC-11 et DEC-12).

Ces décisions sont **techniques**. Elles n'introduisent aucune nouvelle règle métier
et ne modifient ni les catalogues, ni la spécification fonctionnelle, ni l'architecture.

Décisions précédentes : `docs/decisions/technical-decisions-v0.1.2.md` (DEC-01 à DEC-10).

---

# Synthèse

| ID | Sujet | Décision | Appliquée dans le schéma |
|------|------|------|------|
| DEC-11 | InspectionID | InspectionGUID = clé technique unique, générée immédiatement ; InspectionID = identifiant métier lisible, éventuellement temporaire pendant la saisie, définitif à la synchronisation SharePoint | Oui (règles de remplissage) |
| DEC-12 | Archivage | Date de référence = DateDerniereModification ; archivable uniquement si plus de 6 mois se sont écoulés depuis | Oui (règles de remplissage) |

---

# DEC-11 — InspectionID

## Contexte

DEC-03 a fixé InspectionGUID comme clé principale et InspectionID comme identifiant d'affichage,
sans fixer le moment ni le mode d'attribution de l'InspectionID.
Le mode hors connexion futur (SaveData / LoadData) rend impossible l'attribution fiable
d'un numéro séquentiel au moment de la saisie.

## Décision

| Identifiant | Rôle | Attribution |
|------|------|------|
| InspectionGUID | Clé technique unique | Générée **immédiatement** à la création de l'inspection, via GUID |
| InspectionID | Identifiant métier lisible | Peut être **temporaire** pendant la saisie ; reçoit sa **valeur finale lors de la synchronisation SharePoint** |

Format cible de la valeur finale :

`INS-AAAAMMJJ-NNNNNN`

## Conséquences

- Toutes les relations restent basées sur InspectionGUID (REPONSES, PHOTOS_INSPECTIONS, InspectionPrecedenteGUID).
- **Aucune relation ne peut dépendre de InspectionID.**
- Title = InspectionID (DEC-01) : Title suit la même valeur, temporaire puis finale.
- Une inspection peut afficher un InspectionID temporaire tant qu'elle n'est pas synchronisée.
- Le format de la valeur temporaire et le mécanisme d'attribution du compteur `NNNNNN`
  ne sont pas fixés par cette décision (voir `docs/build/open-questions.md`).

---

# DEC-12 — Archivage

## Contexte

La spécification (§ 18) fixe une durée cible de 6 mois pour l'archivage, sans date de référence.

## Décision

La date de référence de l'archivage est **DateDerniereModification**,
et non DateCreation ni DateSoumission.

Règle :

Une inspection est archivable **uniquement si** :

`Aujourd'hui - DateDerniereModification > 6 mois`

## Conséquences

- Un brouillon rouvert repart à zéro : toute modification enregistrée met à jour
  DateDerniereModification et relance le délai de 6 mois.
- L'archivage reste un changement de statut vers ARCHIVE : aucune suppression (décision D007, spécification § 19).
- Les données archivées restent stockées, consultables et exportables (spécification § 18).
