# LUWA Maintenance Preventive Backup
## Build Readiness Review v0.1.3

Version : 0.1.3 — révisée en v0.1.4, v0.1.6 et v0.1.7

Date : 2026-10-08

Périmètre de la revue : **Sprint SharePoint** (construction des listes, de la bibliothèque et import des catalogues) et, depuis la révision v0.1.4, **démarrage du Sprint Power Apps**.

Référentiel : tag `v0.1.3`, révisions aux tags `v0.1.4` (DEC-11, DEC-12), `v0.1.6` et `v0.1.7` (DEC-13 à DEC-17).

---

# 1. Architecture

| Élément | Référence | Statut |
|------|------|------|
| Découpage App 1 (collecte) / App 2 (analyse, future) | architecture § 2, § 4, § 5 | Validé |
| Stockage SharePoint : INSPECTIONS, QUESTIONS, REGLES_FORMULAIRE, REPONSES, PHOTOS_INSPECTIONS | architecture § 6 | Validé |
| Relation Photo ↔ Question obligatoire, y compris SYS_001 | architecture § 7 | Validé |
| Clé relationnelle InspectionGUID | architecture § 7, schéma, DEC-03 | Validé |
| Pilotage par configuration (QUESTIONS, REGLES_FORMULAIRE) | architecture § 15, § 16 | Validé |
| Index de volumétrie | architecture § 17, schéma | Validé |

Aucune incohérence démontrée avec les décisions DEC-01 à DEC-10 :
`architecture-globale-v0.1.md` n'est pas modifié.

---

# 2. Données

| Élément | Référence | Statut |
|------|------|------|
| Schéma SharePoint complet (colonnes, types, obligatoire, index, valeurs Choice, règles de remplissage) | `sharepoint/data-model/sharepoint-schema.md` v0.1.3 | Validé |
| Title défini pour les quatre listes | DEC-01 | Validé |
| Valeur par défaut de StatutTraitement | DEC-02 | Validé |
| ReponseID = GUID | DEC-03 | Validé |
| REPONSES.Valeur en texte multiligne | DEC-05 | Validé |
| Représentation des questions PHOTO (PHOTO_CAPTURED) | DEC-10 | Validé |
| Fichiers modèles alignés sur le schéma | `sharepoint/data-model/*.csv` | Validé |

Contrôles automatiques réalisés sur les fichiers modèles :

| Contrôle | Résultat |
|------|------|
| inspections.csv : colonnes identiques au schéma | Conforme |
| reponses.csv : colonnes identiques au schéma (dont Title) | Conforme |
| photos.csv : métadonnées du schéma + colonnes natives Name, FolderPath | Conforme |
| Title = InspectionID ; Title = ReponseID | Conforme |
| GUID valides ; InspectionPrecedenteGUID pointe vers une inspection INACCESSIBLE existante | Conforme |
| Références InspectionGUID et QuestionCode existantes ; valeurs dans ValeursPossibles | Conforme |
| Question PHOTO POT_010 : ligne REPONSES PHOTO_CAPTURED et 2 photos | Conforme |
| ASCII uniquement, aucune ligne vide | Conforme |

`questions-model.csv` reste au format du fichier d'import (sans Title) :
la colonne Title est ajoutée lors de l'import, conformément au guide de construction.

---

# 3. Catalogues

| Catalogue | Contenu | Statut |
|------|------|------|
| `questions.csv` | 34 questions (POTEAU 20, LUMINAIRE 13, SYSTEM 1) | Validé, non modifié depuis v0.1 |
| `regles_formulaire.csv` | 29 règles, toutes actives | Validé, non modifié depuis v0.1 |
| Cohérence questions ↔ règles | Codes, formulaires, valeurs | Conforme |
| Cohérence catalogues ↔ schéma | Valeurs Choice (DisplayGroup, Formulaire, TypeQuestion, Action, ConditionType) | Conforme |

---

# 4. Décisions techniques

`docs/decisions/technical-decisions-v0.1.2.md`, `docs/decisions/technical-decisions-v0.1.3.md` et `docs/decisions/technical-decisions-v0.1.5.md`

| ID | Sujet | Statut | Impact SharePoint |
|------|------|------|------|
| DEC-01 | Title = clé de la ligne | Validée | Appliquée (schéma, guide) |
| DEC-02 | StatutTraitement initial NON_ANALYSE | Validée | Appliquée (valeur par défaut) |
| DEC-03 | InspectionGUID principale, InspectionID affichage, ReponseID GUID | Validée | Appliquée |
| DEC-04 | InspectionPrecedenteGUID et « Accessible maintenant » | Validée | Règle de remplissage documentée |
| DEC-05 | REPONSES.Valeur multiligne | Validée | Appliquée (type de colonne) |
| DEC-06 | PHOTO_MIN remplace NbPhotosMin | Validée | Aucun (comportement applicatif) |
| DEC-07 | Paramètres de compression | Validée (stockage reporté) | Aucun en v0.1.3 |
| DEC-08 | Concurrence : BROUILLON / EN_COURS, même type | Validée | Aucun (comportement applicatif) |
| DEC-09 | Reprise : utilisateur courant | Validée | Aucun (comportement applicatif) |
| DEC-10 | Questions PHOTO : PHOTO_CAPTURED | Validée | Appliquée (usage de Valeur) |
| DEC-11 | InspectionGUID immédiat ; InspectionID temporaire puis définitif à la synchronisation | Validée (v0.1.4) | Règle de remplissage documentée |
| DEC-12 | Archivage : référence DateDerniereModification, plus de 6 mois | Validée (v0.1.4) | Règle de remplissage documentée |
| DEC-13 | InspectionID temporaire TMP-{8 premiers caractères du GUID} | Validée (v0.1.7) | Règle de remplissage documentée |
| DEC-14 | InspectionID final par Power Automate : INS-{DateCreation}-{ID SharePoint} | Validée (v0.1.7) | Règle de remplissage documentée |
| DEC-15 | Dossiers photos nommés par InspectionGUID, sans renommage | Validée (v0.1.7) | Structure de PHOTOS_INSPECTIONS mise à jour |
| DEC-16 | Statuts archivables : TERMINE, INACCESSIBLE | Validée (v0.1.7) | Règle de remplissage documentée |
| DEC-17 | Archivage : 183 jours depuis DateDerniereModification, non modifiée par l'archivage ; seule une modification métier la réactive | Validée (v0.1.7) | Règle de remplissage documentée |

Documents alignés sur ces décisions : schéma SharePoint, guide de construction,
`powerapps/screens.md`, README des fichiers modèles, backlog (Sprint 0 clôturé).

---

# 5. Points encore ouverts

Liste détaillée : `docs/build/open-questions.md`.

Questions clôturées : OQ-01 (DEC-13), OQ-02 (DEC-14), OQ-03 (DEC-15), OQ-04 (DEC-16), OQ-05 (DEC-17).

| ID | Point | Priorité | Bloque SharePoint ? | Bloque Power Apps ? | Bloque Power Automate ? |
|------|------|------|------|------|------|
| OQ-06 | Stockage des paramètres de compression | P2 | Non | Non (PA-17 uniquement) | Non |
| OQ-07 | DateSoumission d'une inspection INACCESSIBLE | P3 | Non | Non | Non |
| OQ-08 | VisibleParDefaut de SYS_001 (fichiers gelés) | P3 | Non | Non | Non |
| OQ-09, OQ-10 | Structuration des conditions R130 + R131 et R150 / R151 | P3 | Non | Non | Non |
| OQ-11 | Documents à compléter | P3 | Non | Non | Non |

Aucun point ouvert de priorité P1.

---

# 6. Risques résiduels

| ID | Risque | Mesure |
|------|------|------|
| RR1 | Condition composée R130 + R131 associée par convention | Test TST-08 ; colonne de regroupement envisagée en v0.2 |
| RR2 | Précision R150 / R151 (vide ≠ 0) portée par la colonne Commentaire | Exigence dans `screens.md` ; test TST-09 |
| RR3 | Redondances R140, R401, R700 avec le catalogue | Contrôle à chaque évolution des catalogues |
| RR4 | Oubli de la conversion OUI/NON → Oui/Non ou de la colonne Title lors de l'import | Guide § 7, § 8 ; contrôles § 9 |
| RR5 | Index créés après dépassement de 5 000 éléments | Création des index avant tout import (guide § 0, § 5) |
| RR6 | REPONSES.Valeur multiligne : non indexable, filtre non délégable | Valeur n'est jamais un critère de recherche (DEC-05) |
| RR7 | InspectionID temporaire `TMP-…` affiché tant que Power Automate n'a pas attribué la valeur finale | Sans effet sur l'intégrité (relations par InspectionGUID) ; valeur finale unique par construction (DEC-14) |
| RR9 | Tous les dossiers d'inspection sont à la racine de PHOTOS_INSPECTIONS (DEC-15) : au-delà de 5 000 dossiers, la navigation dans la vue par défaut de la bibliothèque est limitée | Sans effet pour l'application (accès par chemin et par métadonnées indexées) ; prévoir des vues filtrées sur les colonnes indexées |
| RR8 | Colonne « Auteur » de PHOTOS_INSPECTIONS proche du libellé de la colonne native « Créé par » sur un site en français | Vérification du nom interne (guide § 3.5) |

---

# 7. Conclusion

| Périmètre | Verdict |
|------|------|
| **Sprint SharePoint** | **READY** — construit et vérifié en v0.1.5 (`docs/build/sharepoint-build-report.md`) |
| **Sprint Power Apps** | **READY** |
| **Sprint Power Automate** | **READY** |

Plus aucune décision de conception ne bloque le build :

- SharePoint : listes, bibliothèque, colonnes, index et catalogues en place et conformes.
- Power Apps : InspectionID temporaire (DEC-13) et dossiers photos (DEC-15) décidés ; seul OQ-06 (P2) reste à trancher avant PA-17.
- Power Automate : attribution de l'InspectionID final (DEC-14, PAU-04) et archivage (DEC-16, DEC-17, PAU-03) décidés.

Pré-requis opérationnels à exécuter avant l'ouverture de Power Apps Studio
(`docs/build/powerapps-readiness.md`, constatés non réalisés dans `docs/build/sharepoint-build-report.md` § 8) :

1. permissions des techniciens (soumises à l'accord explicite du propriétaire du site) ;
2. tests d'écriture SharePoint ;
3. contrôles d'environnement Power Platform (licences, stratégies DLP, comptes de test).

Ces pré-requis sont des étapes d'exécution, pas des décisions de conception.
