# LUWA Maintenance Preventive Backup
## Build Readiness Review v0.1.3

Version : 0.1.3

Date : 2026-10-08

Périmètre de la revue : **Sprint SharePoint** (construction des listes, de la bibliothèque et import des catalogues).

Référentiel : tag `v0.1.3`.

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

`docs/decisions/technical-decisions-v0.1.2.md`

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

Documents alignés sur ces décisions : schéma SharePoint, guide de construction,
`powerapps/screens.md`, README des fichiers modèles, backlog (Sprint 0 clôturé).

---

# 5. Points encore ouverts

| ID | Point | Bloque le sprint SharePoint ? | Bloque |
|------|------|------|------|
| DEC-11 | Mécanisme de génération du compteur NNNNNN de l'InspectionID | Non | PA-07, PAU-04 |
| DEC-12 | Date de référence et statuts concernés par l'archivage à 6 mois | Non | PAU-03 |
| DEC-07 (suite) | Emplacement de stockage des paramètres de compression | Non | PA-17 |
| — | DateSoumission non définie pour une inspection INACCESSIBLE | Non | — |
| — | SYS_001 a VisibleParDefaut = OUI alors que l'architecture la dit « jamais affichée » (sans effet : formulaire SYSTEM) | Non | — |
| — | `modele-donnees-v0.1.md`, `wireframes-v0.1.md` à l'état « À compléter » ; README racine en version 0.1 | Non | — |

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
| RR7 | Doublon d'InspectionID tant que DEC-11 n'est pas décidée | Sans effet sur l'intégrité (relations par InspectionGUID) ; nom de dossier photos potentiellement partagé |
| RR8 | Colonne « Auteur » de PHOTOS_INSPECTIONS proche du libellé de la colonne native « Créé par » sur un site en français | Vérification du nom interne (guide § 3.5) |

---

# 7. Conclusion

| Périmètre | Verdict |
|------|------|
| **Sprint SharePoint** | **READY** |
| Sprint Power Apps | NOT READY — DEC-11 à trancher avant PA-07 |
| Sprint Power Automate | NOT READY pour PAU-03 (DEC-12) ; READY pour PAU-01 |

Le Sprint SharePoint peut démarrer : le schéma, les catalogues, les décisions techniques
et le guide de construction sont complets et cohérents. Aucun point ouvert ne bloque
la création des listes, de la bibliothèque, des index ni l'import des catalogues.
