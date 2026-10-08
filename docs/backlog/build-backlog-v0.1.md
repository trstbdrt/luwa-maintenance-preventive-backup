# LUWA Maintenance Preventive Backup
## Backlog de build v0.1

Version : 0.1.2

Date : 2026-10-08

Références :

- `sharepoint/build/sharepoint-build-guide.md`
- `powerapps/screens.md`
- `docs/reviews/repository-consistency-report.md`

Priorités :

- **P1** : indispensable au POC
- **P2** : nécessaire avant usage terrain élargi
- **P3** : phase ultérieure

Les éléments marqués **[À SPÉCIFIER]** dépendent d'un point ouvert du rapport de cohérence
et ne peuvent pas être réalisés avant décision.

---

# Sprint 0 — Décisions préalables

**Statut : clôturé en v0.1.3.** Décisions DEC-01 à DEC-10 documentées dans
`docs/decisions/technical-decisions-v0.1.2.md`. Les points restant ouverts sont repris
en DEC-11 et DEC-12 et dans `docs/reviews/build-readiness-v0.1.3.md`.

| ID | Description | Priorité | Dépendances |
|------|------|------|------|
| DEC-11 | **Décidée en v0.1.4** (`technical-decisions-v0.1.3.md`), complétée en v0.1.7 par DEC-13 (TMP-), DEC-14 (InspectionID final) et DEC-15 (dossiers photos) | P1 | — |
| DEC-12 | **Décidée en v0.1.4** (`technical-decisions-v0.1.3.md`), complétée en v0.1.7 par DEC-16 (statuts archivables) et DEC-17 (183 jours) | P2 | — |
| DEC-01 | Décider de l'usage de la colonne Title dans QUESTIONS, REGLES_FORMULAIRE et REPONSES | P1 | — |
| DEC-02 | Fixer la valeur initiale de StatutTraitement à la création d'une inspection | P1 | — |
| DEC-03 | Fixer le mécanisme de génération de l'InspectionID (`INS-AAAAMMJJ-NNNNNN`) et du ReponseID | P1 | — |
| DEC-04 | Confirmer la sémantique d'InspectionPrecedenteGUID (« Accessible maintenant ») | P2 | — |
| DEC-05 | Fixer le stockage des réponses TEXTE de plus de 255 caractères (colonne Valeur limitée) | P1 | — |
| DEC-06 | Fixer la combinaison NbPhotosMin du catalogue / PHOTO_MIN des règles | P1 | — |
| DEC-07 | Définir l'emplacement des paramètres de compression photo | P2 | — |
| DEC-08 | Préciser l'avertissement de concurrence (statuts BROUILLON et/ou EN_COURS, même type ou tous types) | P2 | — |
| DEC-09 | Préciser le périmètre de « Reprendre inspection » (utilisateur courant ou tous) | P2 | — |
| DEC-10 | Fixer la représentation des réponses aux questions de type PHOTO dans REPONSES | P1 | — |

---

# Sprint SharePoint

| ID | Description | Priorité | Dépendances |
|------|------|------|------|
| SP-01 | Créer le site SharePoint dédié et définir les propriétaires | P1 | — |
| SP-02 | Créer la liste QUESTIONS, ses colonnes et ses index (guide § 3.2, § 5) | P1 | SP-01, DEC-01 |
| SP-03 | Importer `questions.csv` (guide § 7) | P1 | SP-02 |
| SP-04 | Contrôles post-import QUESTIONS (guide § 9.1) | P1 | SP-03 |
| SP-05 | Créer la liste REGLES_FORMULAIRE, ses colonnes et ses index (guide § 3.3, § 5) | P1 | SP-01, DEC-01 |
| SP-06 | Importer `regles_formulaire.csv` (guide § 8) | P1 | SP-05, SP-04 |
| SP-07 | Contrôles post-import REGLES_FORMULAIRE et cohérence croisée (guide § 9.2, § 9.3) | P1 | SP-06 |
| SP-08 | Créer la liste INSPECTIONS, ses colonnes et ses index (guide § 3.1, § 5) | P1 | SP-01, DEC-02 |
| SP-09 | Créer la liste REPONSES, ses colonnes et ses index (guide § 3.4, § 5) | P1 | SP-01, DEC-01, DEC-05 |
| SP-10 | Créer la bibliothèque PHOTOS_INSPECTIONS, ses métadonnées et ses index (guide § 2, § 3.5, § 5) | P1 | SP-01 |
| SP-11 | Créer le niveau d'autorisation « Contribution sans suppression » et l'appliquer (guide § 10) | P1 | SP-08, SP-09, SP-10 |
| SP-12 | Mettre QUESTIONS et REGLES_FORMULAIRE en lecture seule pour les techniciens | P1 | SP-04, SP-07 |
| SP-13 | Site de test : importer les exemples `sharepoint/data-model/*.csv` | P2 | SP-08, SP-09, SP-10 |
| SP-14 | Créer les vues de travail (inspections actives, hors ARCHIVE) et la vue d'archives | P2 | SP-08 |

---

# Sprint Power Apps

| ID | Description | Priorité | Dépendances |
|------|------|------|------|
| PA-01 | Créer l'application canevas (format tablette / téléphone) et connecter les 5 sources | P1 | SP-04, SP-07, SP-08, SP-09, SP-10 |
| PA-02 | Chargement des catalogues au démarrage (`colQuestions`, `colRegles` actives triées par Priorite) | P1 | PA-01 |
| PA-03 | Screen_Home : boutons et galerie de reprise | P1 | PA-01, DEC-09 |
| PA-04 | Screen_Type : choix POTEAU / LUMINAIRE | P1 | PA-01 |
| PA-05 | Screen_Identification : saisie ouvrage, recherche historique, dernier statut | P1 | PA-04 |
| PA-06 | Screen_Identification : avertissement de concurrence non bloquant | P1 | PA-05, DEC-08 |
| PA-07 | Création d'inspection (GUID, InspectionID = Title = TMP-…, statut BROUILLON, GPS si disponible) | P1 | PA-05, DEC-02, DEC-03, DEC-11, DEC-13 |
| PA-08 | Parcours « Ouvrage inaccessible » (SYS_001 : commentaire obligatoire, photo facultative, statut INACCESSIBLE) | P1 | PA-07 |
| PA-09 | « Accessible maintenant » lorsque la dernière inspection est INACCESSIBLE | P2 | PA-07, DEC-04 |
| PA-10 | Screen_Inspection : galerie dynamique par Formulaire, OrdreAffichage, DisplayGroup, QuestionParent | P1 | PA-02, PA-07 |
| PA-11 | Contrôles de réponse par TypeQuestion (RADIO, CHECKBOX, NUMERIQUE, CALCUL, PHOTO, TEXTE) | P1 | PA-10 |
| PA-12 | Moteur d'évaluation des règles (AFFICHER, condition composée, MASQUER_FORMULAIRE, RENDRE_OBLIGATOIRE, COMMENT_OBLIGATOIRE, PHOTO_MIN, BLOQUER_CALCUL, BLOQUER_SOUMISSION) | P1 | PA-10, DEC-06 |
| PA-13 | Calcul POT_004_2_C depuis FormuleCalcul, avec blocage R150 | P1 | PA-12 |
| PA-14 | Panneau commentaire (icône 💬) | P1 | PA-10 |
| PA-15 | Panneau photos (icône 📷) : appareil / galerie, compteur n/min, maximum NbPhotosMax | P1 | PA-10, DEC-06 |
| PA-16 | Enregistrement (REPONSES, PHOTOS_INSPECTIONS dans `{InspectionGUID}/`, statut BROUILLON → EN_COURS, DateDerniereModification) | P1 | PA-11, PA-15, DEC-10, DEC-15, DEC-17, PAU-06 |
| PA-17 | Compression photo configurable et non systématique | P2 | PA-15, DEC-07 |
| PA-18 | Screen_Resume : contrôles R500 à R503, commentaires obligatoires, blocage R151 | P1 | PA-12, PA-16 |
| PA-19 | Soumission (TERMINE, DateSoumission) | P1 | PA-18 |
| PA-20 | Screen_History : recherche et consultation en lecture seule, y compris INACCESSIBLE et ARCHIVE | P1 | PA-05 |
| PA-21 | Préparation hors connexion (SaveData / LoadData sur les collections de travail) | P3 | PA-16 |

---

# Sprint Power Automate

| ID | Description | Priorité | Dépendances |
|------|------|------|------|
| PAU-01 | Export structuré : Export.zip contenant Export.xlsx et le dossier Photos/ | P1 | SP-08, SP-09, SP-10 |
| PAU-02 | Export CSV des listes INSPECTIONS et REPONSES | P2 | PAU-01 |
| PAU-03 | Archivage : statut ARCHIVE pour TERMINE / INACCESSIBLE si Aujourd'hui - DateDerniereModification > 183 jours, sans modifier DateDerniereModification, sans suppression | P2 | SP-08, DEC-16, DEC-17 |
| PAU-04 | Attribution de l'InspectionID final `INS-{DateCreation AAAAMMJJ}-{ID SharePoint sur 6 chiffres}` et de Title | P1 | SP-08, DEC-14 |
| PAU-05 | Création des dossiers photos `{InspectionGUID}/` (si non fait par Power Apps) | P2 | SP-10, DEC-15 |
| PAU-06 | Flux d'envoi des photos appelé depuis Power Apps : création du dossier `{InspectionGUID}` si absent, du fichier et de ses métadonnées (technical design § 6.6) | P1 | SP-10, DEC-15 |

---

# Sprint Tests

| ID | Description | Priorité | Dépendances |
|------|------|------|------|
| TST-01 | Contrôles post-import des catalogues (guide § 9) | P1 | SP-04, SP-07 |
| TST-02 | Parcours POTEAU complet et soumission (scénario INS-20261008-000001 des exemples) | P1 | PA-19 |
| TST-03 | Parcours LUMINAIRE complet et soumission | P1 | PA-19 |
| TST-04 | LUM_001 = NON_PRESENT : commentaire obligatoire (R001) et masquage du formulaire (R002) | P1 | PA-12 |
| TST-05 | POT_004 = AVANCEE : affichage POT_004_1, POT_004_2_A/B/C (R100 à R103) | P1 | PA-12 |
| TST-06 | POT_004 = SEVERE : affichage POT_004_4 (R110) | P1 | PA-12 |
| TST-07 | Perte d'épaisseur = 29, 30 et 31 % : test marteau affiché à partir de 30 (R120), POT_004_5 sous 30 (R131) | P1 | PA-13 |
| TST-08 | Condition composée R130 + R131 : POT_004_5 visible seulement si POT_004_1 = OUI et perte < 30 | P1 | PA-12 |
| TST-09 | POT_004_2_A = 0 : calcul bloqué (R150), soumission bloquée (R151) ; POT_004_2_A vide ou masquée : aucun blocage | P1 | PA-13, PA-18 |
| TST-10 | Photos minimales : POT_001, POT_003 (1), POT_010 (2), POT_002 selon la valeur (R200 à R202), POT_005 à POT_008 si NON_VALIDE (R300 à R303), POT_004_5 (R140) | P1 | PA-15, PA-18 |
| TST-11 | POT_010B = OUI : POT_010B_A affichée et obligatoire (R400, R401) | P1 | PA-12 |
| TST-12 | Sauvegarde d'un formulaire incomplet (R600) et reprise depuis l'accueil | P1 | PA-16, PA-03 |
| TST-13 | Statuts : BROUILLON à la création, EN_COURS après la première réponse, TERMINE à la soumission | P1 | PA-19 |
| TST-14 | Ouvrage inaccessible : commentaire obligatoire, photo facultative rattachée à SYS_001 | P1 | PA-08 |
| TST-15 | Inspections simultanées sur un même ouvrage : avertissement sans blocage | P1 | PA-06 |
| TST-16 | Historique en lecture seule : aucune modification possible | P1 | PA-20 |
| TST-17 | Aucune suppression possible pour un technicien (tous statuts) | P1 | SP-11 |
| TST-18 | Volumétrie : requêtes filtrées sur colonnes indexées au-delà de 5 000 éléments (REPONSES) | P2 | SP-09, PA-16 |
| TST-19 | Export : contenu de Export.zip, rattachement photo ↔ question | P1 | PAU-01 |

---

# Sprint App2

Phase future. Aucune spécification détaillée n'existe dans le dépôt :
chaque élément est **[À SPÉCIFIER]**.

| ID | Description | Priorité | Dépendances |
|------|------|------|------|
| A2-01 | [À SPÉCIFIER] Spécification fonctionnelle App 2 | P3 | Clôture du POC App 1 |
| A2-02 | [À SPÉCIFIER] Validation chef de projet (décision D008) | P3 | A2-01 |
| A2-03 | [À SPÉCIFIER] Analyse technique des constats | P3 | A2-02 |
| A2-04 | [À SPÉCIFIER] Création des fiches de suivi | P3 | A2-03 |
| A2-05 | [À SPÉCIFIER] Suivi des interventions terrain | P3 | A2-04 |
| A2-06 | [À SPÉCIFIER] Clôture | P3 | A2-05 |
| A2-07 | [À SPÉCIFIER] Modèle de données des entités Validation, Analyse, Fiche de Suivi, Intervention, sans modification des inspections historiques | P3 | A2-01 |
| A2-08 | [À SPÉCIFIER] Utilisation de StatutTraitement (NON_ANALYSE à CLOTURE) | P3 | A2-01 |
