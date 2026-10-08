# LUWA Maintenance Preventive Backup
## Rapport de cohérence du dépôt

Version auditée : v0.1.1 (commit `bcb8948`)

Version produite : v0.1.2

Date : 2026-10-08

---

# 1. Périmètre

Documents audités :

- `docs/specification/specification-fonctionnelle-v0.1.md`
- `docs/architecture/architecture-globale-v0.1.md`
- `sharepoint/data-model/sharepoint-schema.md`
- `sharepoint/questions/questions.csv`
- `sharepoint/regles/regles_formulaire.csv`

Documents consultés en complément :

- `docs/decisions/decision-log.csv`
- `sharepoint/data-model/*.csv`
- `powerapps/screens.md`

Principe appliqué : aucune modification sans incohérence démontrée,
aucune nouvelle règle métier, aucune simplification du modèle.

---

# 2. Contrôles automatiques réalisés

| Contrôle | Résultat |
|------|------|
| questions.csv : 34 lignes, 16 colonnes, aucune ligne vide, ASCII uniquement | Conforme |
| questions.csv : QuestionCode uniques, QuestionParent existants, OrdreAffichage uniques par formulaire | Conforme |
| questions.csv : PhotoAutorisee = NON ⇒ NbPhotosMax = 0 ; NbPhotosMin ≤ NbPhotosMax | Conforme |
| questions.csv : RADIO et CHECKBOX ont des ValeursPossibles ; CALCUL a une FormuleCalcul | Conforme |
| questions.csv : FormuleCalcul de POT_004_2_C ne référence que des codes existants | Conforme |
| regles_formulaire.csv : 29 lignes, 11 colonnes, aucune ligne vide, ASCII uniquement, RuleID uniques | Conforme |
| Règles → questions : chaque QuestionSource / QuestionCible (hors `FORMULAIRE` et `*`) existe et appartient au bon formulaire | Conforme |
| Règles → valeurs : chaque ConditionValeur d'une règle EQUALS appartient aux ValeursPossibles de la question source | Conforme |
| Schéma → règles : toutes les valeurs Action, ConditionType et Formulaire utilisées existent dans les listes Choice du schéma | Conforme |
| Schéma → questions : toutes les valeurs DisplayGroup, Formulaire et TypeQuestion utilisées existent dans les listes Choice du schéma | Conforme |
| Schéma ↔ architecture : index INSPECTIONS identiques ; clé relationnelle InspectionGUID | Conforme |
| Spécification ↔ schéma : statuts d'inspection identiques (BROUILLON, EN_COURS, TERMINE, INACCESSIBLE, ARCHIVE) | Conforme |
| Spécification ↔ décisions : D003, D004, D005, D006, D007, D009 | Conforme |

**Conclusion : aucune incohérence démontrée ne justifie de modifier `questions.csv` ou `regles_formulaire.csv`.
Ces deux fichiers ne sont pas modifiés en v0.1.2.**

---

# 3. Incohérences corrigées en v0.1.2

| ID | Fichier | Constat | Correction | Justification |
|------|------|------|------|------|
| C1 | `sharepoint/data-model/inspections.csv` | Format « définition de colonnes » antérieur au schéma : il manquait Title, DateDerniereModification, InspectionPrecedenteGUID | Régénéré au format « données modèles » : en-tête complet aligné sur le schéma + 4 inspections fictives | Le schéma v0.1.1 est la source de vérité des colonnes ; la tâche demande des données modèles |
| C2 | `sharepoint/data-model/reponses.csv` | En-tête de définition uniquement, sans les colonnes du schéma | Généré : en-tête du schéma (clé InspectionGUID) + 20 réponses fictives | Alignement sur le schéma v0.1.1 |
| C3 | `sharepoint/data-model/photos.csv` | En-tête de définition uniquement | Généré : métadonnées du schéma + colonnes natives Name et FolderPath + 8 photos fictives | Alignement sur le schéma v0.1.1 |
| C4 | `sharepoint/data-model/questions-model.csv` | En-tête de définition uniquement | Généré : en-tête identique à `questions.csv` + exemples `EX_*` par type de question | Gabarit de la liste QUESTIONS |
| C5 | `powerapps/screens.md` | Ne mentionnait ni « Accessible maintenant » (architecture § 9), ni le parcours SYS_001, ni l'avertissement de concurrence | Réécrit : 6 écrans détaillés conformes à la spécification, à l'architecture et au schéma | Alignement sur architecture § 7 et § 9, spécification § 9 et § 10 |

Les exemples de données ont été vérifiés automatiquement :
colonnes identiques au schéma, GUID valides, références InspectionGUID et QuestionCode existantes,
valeurs prises dans ValeursPossibles, photos uniquement sur des questions autorisant les photos.
L'inspection d'exemple TERMINE respecte toutes les règles de soumission (voir `sharepoint/data-model/README.md`).

---

# 4. Incohérences détectées non corrigées

Ces points ne sont pas corrigés car leur résolution demande une décision métier ou technique
qui n'existe pas dans le dépôt. Chacun est repris dans le backlog (Sprint 0, éléments DEC-xx).

| ID | Gravité | Fichiers | Constat | Backlog |
|------|------|------|------|------|
| I1 | Haute | schéma | La colonne native `Title` existe dans toutes les listes SharePoint, mais son contenu n'est défini que pour INSPECTIONS. QUESTIONS, REGLES_FORMULAIRE et REPONSES ne précisent rien ; Title est obligatoire par défaut | DEC-01 |
| I2 | Haute | schéma, questions.csv | `REPONSES.Valeur` est une Single line text (255 caractères maximum) alors que les questions TEXTE (LUM_013, POT_011 « Commentaires generaux ») peuvent dépasser cette longueur | DEC-05 |
| I3 | Haute | schéma, architecture | Le mécanisme de génération de l'`InspectionID` séquentiel (`INS-AAAAMMJJ-NNNNNN`) n'est pas défini ; en mode hors connexion futur, deux appareils peuvent produire le même numéro. Le nom du dossier photos utilise l'InspectionID | DEC-03 |
| I4 | Haute | schéma | Le format et la génération de `ReponseID` ne sont pas définis (GUID utilisé dans les exemples) | DEC-03 |
| I5 | Haute | questions.csv, regles_formulaire.csv | La combinaison entre `NbPhotosMin` du catalogue et l'action `PHOTO_MIN` des règles n'est pas définie (remplacement ou maximum des deux). Cas concernés : POT_002 (catalogue 0, règles 1 ou 2), POT_005 à POT_008 (catalogue 0, règle 1), POT_004_5 (1 et 1) | DEC-06 |
| I6 | Haute | schéma, questions.csv | La représentation d'une réponse à une question de type PHOTO (POT_010, LUM_012) dans REPONSES n'est pas définie : ligne sans valeur, ou aucune ligne | DEC-10 |
| I7 | Moyenne | schéma, architecture | La valeur initiale de `StatutTraitement` (colonne obligatoire) à la création d'une inspection n'est pas définie. Les exemples utilisent NON_ANALYSE, seule valeur compatible avec « App 1 ne prend aucune décision métier » | DEC-02 |
| I8 | Moyenne | schéma, architecture | La sémantique d'`InspectionPrecedenteGUID` n'est pas définie. Interprétation retenue dans les exemples et les écrans : lien vers l'inspection INACCESSIBLE lors d'un « Accessible maintenant » | DEC-04 |
| I9 | Moyenne | questions.csv, architecture | SYS_001 a `VisibleParDefaut = OUI` alors que l'architecture (§ 7) indique que cette question « n'est jamais affichée à l'utilisateur ». Pas de conflit fonctionnel : SYS_001 appartient au formulaire SYSTEM et n'est utilisée que via le panneau d'inaccessibilité | — |
| I10 | Moyenne | spécification, architecture | Les paramètres de compression (CompressionEnabled, CompressionThreshold, CompressionQuality, MaxResolution) sont nommés, mais aucun emplacement de stockage n'est défini dans le schéma | DEC-07 |
| I11 | Moyenne | spécification | L'avertissement de concurrence (« inspection en cours ») ne précise pas les statuts concernés (BROUILLON, EN_COURS) ni s'il dépend du type d'inspection | DEC-08 |
| I12 | Moyenne | spécification | L'archivage (« durée cible 6 mois ») ne précise ni la date de référence (création, modification, soumission) ni les statuts concernés | PAU-03 |
| I13 | Basse | spécification | `DateSoumission` n'est pas définie pour une inspection déclarée INACCESSIBLE (laissée vide dans les exemples) | — |
| I14 | Basse | spécification | Le périmètre de « Reprendre inspection » (inspections de l'utilisateur courant ou de tous) n'est pas défini | DEC-09 |
| I15 | Basse | architecture | Le référentiel documentaire cite `DECISIONS_ARCHITECTURE` alors que le dépôt utilise `docs/decisions/decision-log.csv` | — |
| I16 | Basse | architecture, schéma | L'architecture (§ 17) liste les index REPONSES InspectionGUID et QuestionCode ; le schéma ajoute DateEncodage. Le schéma est plus complet ; pas de contradiction | — |

---

# 5. Risques résiduels

| ID | Risque | Impact | Mesure |
|------|------|------|------|
| RR1 | Condition composée R130 + R131 sans lien formel (association par convention : WAITING_SECOND_CONDITION + AFFICHER_IF_MATCH sur la même cible) | Ajout futur d'une autre condition composée ambigu | Colonne de regroupement à prévoir en v0.2 ; test TST-08 |
| RR2 | R150 / R151 : la précision « uniquement si POT_004_2_A visible et renseignée » est portée par la colonne Commentaire, pas par une condition structurée | Mauvaise implémentation possible (vide traité comme 0) bloquant toutes les soumissions POTEAU | Exigence reprise dans `powerapps/screens.md` ; test TST-09 |
| RR3 | Redondances : R140 (= NbPhotosMin de POT_004_5), R401 (= Obligatoire de POT_010B_A), R700 (= CommentaireObligatoire de SYS_001) | Aucun impact fonctionnel tant que les deux sources restent alignées | Contrôle à chaque évolution des catalogues |
| RR4 | R002 (MASQUER_FORMULAIRE sur `*`) : « questions restantes » — LUM_001 reste visible ; LUM_012 et LUM_013 sont masquées | Interprétation à confirmer en test | TST-04 |
| RR5 | Cases à cocher obligatoires à valeur unique FAIT (LUM_002, LUM_003, LUM_010, LUM_011) : impossibilité de déclarer « non réalisé » autrement qu'en commentaire | Choix métier confirmé lors de la v0.1 | Aucune ; à réévaluer après le POC |
| RR6 | Import des colonnes Oui/Non : les CSV contiennent OUI/NON | Import incorrect si la conversion est oubliée | Procédure dans le guide de construction § 7 et § 8 ; contrôles § 9 |
| RR7 | Volumétrie REPONSES (environ 450 000 lignes) | Requêtes bloquées au-delà de 5 000 éléments sans index | Index créés avant tout import (guide § 0 et § 5) ; test TST-18 |
| RR8 | `decision-log.csv` contient des caractères accentués (UTF-8 sans BOM) | Affichage incorrect à l'ouverture directe dans Excel ; aucun impact Power Apps | Ouvrir via « Données > À partir d'un fichier texte/CSV » en UTF-8 |
| RR9 | `docs/architecture/modele-donnees-v0.1.md` et `docs/wireframes/wireframes-v0.1.md` restent à l'état « À compléter » ; le README racine indique encore la version 0.1 | Documentation incomplète | À traiter dans une version ultérieure |
| RR10 | App 2 n'a pas de spécification détaillée | Aucun impact sur App 1 | Backlog Sprint App2 marqué [À SPÉCIFIER] |

---

# 6. Synthèse

- Les catalogues QUESTIONS et REGLES_FORMULAIRE sont cohérents entre eux et avec le schéma SharePoint.
- Les fichiers de données modèles et la description des écrans ont été alignés sur le schéma v0.1.1.
- Dix décisions (DEC-01 à DEC-10) sont nécessaires avant ou pendant la construction ;
  les décisions P1 (DEC-01, DEC-02, DEC-03, DEC-05, DEC-06, DEC-10) bloquent le sprint SharePoint ou Power Apps.
