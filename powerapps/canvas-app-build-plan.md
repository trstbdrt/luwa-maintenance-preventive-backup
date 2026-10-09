# LUWA Maintenance Preventive Backup
## Plan de construction de la Canvas App (prototype)

Date : 2026-10-09

Objet : ordre exact de construction dans Power Apps Studio, étape par étape.

Référence technique : `powerapps/powerapps-technical-design-v0.2.md` (noté **TD** ci-dessous).

---

# 0. Hypothèses de build

| Sujet | Hypothèse retenue pour le prototype |
|------|------|
| Compression photo (OQ-06) | Désactivée : CompressionVersion = ORIGINAL partout |
| DateSoumission d'une inspection INACCESSIBLE | Renseignée = date de validation du panneau « Inaccessible » (DEC-18) |
| SYS_001 VisibleParDefaut (OQ-08) | Inchangé ; SYS_001 n'est jamais dans la galerie (formulaire SYSTEM) |
| R130 + R131 (OQ-09), vide ≠ 0 (OQ-10) | Comportement du TD § 5.4 |
| Réponses d'une question devenue masquée | Conservées dans `colReponses` et dans REPONSES, ignorées par le moteur (DEC-19) |
| Envoi des fichiers photo | Flux PAU-06 non disponible au démarrage : photos conservées dans `colPhotos`, envoi branché à l'étape 7.8 |
| Site | `https://wavenetbe.sharepoint.com/sites/LuwaMaintenancePreventiveBackup` uniquement |

---

# 1. Créer l'application

| Élément | Action |
|------|------|
| Où | make.powerapps.com, environnement cible du projet |
| Création | Créer > Application canevas vide |
| Nom | LUWA Inspection Backup |
| Format | À choisir selon l'appareil terrain : **Tablette** (recommandé pour les galeries de questions) ou Téléphone |
| Paramètres > Général | Limite de lignes de données : 2000 |
| Paramètres > Fonctionnalités à venir | Gestion des erreurs au niveau des formules : activée |
| Contrôles | Contrôles classiques pour le prototype (stabilité, compatibilité des galeries) |
| Enregistrement | Enregistrer immédiatement, puis après chaque étape ; publier une version après chaque écran terminé |

**Risques**

- Licence Power Apps absente ou connecteur SharePoint bloqué par une stratégie DLP : à vérifier avant tout (readiness § 4).
- Format écran choisi trop tôt : difficile à changer ensuite. Trancher avant l'étape 4.

---

# 2. Connecter SharePoint

| Source | Type | Usage |
|------|------|------|
| INSPECTIONS | Liste | Lecture, création, mise à jour |
| QUESTIONS | Liste | Lecture (catalogue) |
| REGLES_FORMULAIRE | Liste | Lecture (catalogue) |
| REPONSES | Liste | Lecture, création, mise à jour |
| PHOTOS_INSPECTIONS | Bibliothèque | Lecture des métadonnées et des fichiers |

Données > Ajouter des données > SharePoint > URL du site > cocher les 4 listes et la bibliothèque.

**Contrôles après connexion**

- [ ] Les 5 sources apparaissent avec leur nom exact.
- [ ] Les colonnes Choice (TypeInspection, StatutInspection, StatutTraitement…) sont reconnues comme choix.
- [ ] Les colonnes Personne (Inspecteur, UtilisateurEncodage, Auteur) sont reconnues.

**Risques**

- Avertissements de délégation sur les filtres : à surveiller à chaque écran (TD § 9, PA-2), surtout sur la colonne Personne `Inspecteur`.
- Création de fichiers dans PHOTOS_INSPECTIONS impossible par le connecteur standard : flux PAU-06 (étape 7.8).

---

# 3. Charger les collections et variables globales

Propriété : **App.OnStart** (ou formules nommées pour les valeurs fixes).

| Élément | Contenu | Référence |
|------|------|------|
| `gblUtilisateur` | E-mail et nom de l'utilisateur connecté | TD § 2.1 |
| `colQuestions` | Toutes les lignes de QUESTIONS (34) | TD § 4.1 |
| `colRegles` | REGLES_FORMULAIRE, Actif = Oui, triées par Priorite (29) | TD § 4.2 |
| Variables de contexte | Initialisées vides (TD § 2.3) | TD § 2.3 |

**Contrôles**

- [ ] `colQuestions` = 34 lignes, `colRegles` = 29 lignes (vue Collections de Studio).
- [ ] Les colonnes Oui/Non arrivent en booléens ; les colonnes Choice en valeurs texte exploitables.

**Risques**

- Colonnes Choice lues comme enregistrements (`.Value`) : normaliser en texte dès le chargement pour simplifier le moteur de règles.
- Temps de démarrage : négligeable avec 63 lignes.

---

# 4. Construire Screen_Home

| Composants | Contrôles |
|------|------|
| En-tête | Label (nom de l'application), Label (utilisateur) |
| Actions | Bouton « Nouvelle inspection », Bouton « Reprendre inspection », Bouton « Historique » |
| Reprise | Galerie verticale `galReprise` : InspectionID, NomOuvrage, TypeInspection, StatutInspection, DateDerniereModification |

| Sources | Collections / variables |
|------|------|
| INSPECTIONS (StatutInspection ∈ BROUILLON / EN_COURS, Inspecteur = utilisateur courant — DEC-09) | `colInspectionsAReprendre`, `locAfficherReprise` |

Navigation : Nouvelle → réinitialisation du contexte (TD § 2.3) → Screen_Type ; sélection d'une reprise → chargement (TD § 7.4) → Screen_Inspection ; Historique → Screen_History.

**Risques**

- Délégation du filtre sur `Inspecteur` (colonne Personne) : vérifier l'avertissement ; si présent, filtrer d'abord sur StatutInspection (indexé) puis sur l'utilisateur.

---

# 5. Construire Screen_Type

| Composants | Contrôles |
|------|------|
| Choix | Bouton « Poteau », Bouton « Luminaire » |
| Retour | Icône ou bouton « Retour » |

| Sources | Collections / variables |
|------|------|
| Aucune | `gblTypeInspection` |

**Risques** : aucun.

---

# 6. Construire Screen_Identification

| Composants | Contrôles |
|------|------|
| Rappel du type | Label |
| Ouvrage | Zone de texte `txtNomOuvrage`, Bouton « Rechercher » |
| Dernière inspection | Label bandeau (Terminée / En cours / Inaccessible) |
| Concurrence | Label d'avertissement, visible si `locInspectionEnCoursExiste` (DEC-08) |
| Historique de l'ouvrage | Galerie `galHistoriqueOuvrage` ; clic → Screen_History en lecture seule |
| Actions | Bouton « Commencer l'inspection » (libellé « Accessible maintenant » si dernière = INACCESSIBLE), Bouton « Inspection inaccessible » |
| Panneau inaccessible | Conteneur visible si `locAfficherPanneauInaccessible` : zone de texte multiligne (commentaire obligatoire), contrôle « Ajouter une image » (appareil photo ou galerie), galerie des photos, Bouton « Valider », Bouton « Annuler » |

| Sources | Collections / variables |
|------|------|
| INSPECTIONS (filtre NomOuvrage — indexé ; création) ; REPONSES (création SYS_001) | `colHistoriqueOuvrage`, `colPhotosInaccessible`, `gblNomOuvrage`, `gblInspectionGUID`, `gblInspectionID`, `gblInspection`, `locDerniereInspection`, `locInspectionEnCoursExiste`, `locAfficherPanneauInaccessible`, `locCommentaireInaccessible` |

Séquences : création TD § 7.2 ; inaccessibilité TD § 7.6, avec DateSoumission = date de validation (DEC-18).

**Risques**

- Saisie d'ouvrage libre : espaces ou casse différents donnent un historique vide (« E100 511 » / « e100  511 »). Normaliser l'affichage, pas la donnée (pas de validation patrimoine dans le POC).
- Double clic sur « Commencer » : désactiver le bouton pendant la création pour éviter deux inspections.
- Photos SYS_001 : envoi dépendant de PAU-06 (étape 7.8).

---

# 7. Construire Screen_Inspection

Écran le plus complexe : à construire en sous-étapes, en testant après chacune.

## 7.1 Structure

| Composants | Contrôles |
|------|------|
| En-tête | Labels InspectionID, NomOuvrage, TypeInspection, StatutInspection ; Label avertissement concurrence |
| Questions | Galerie externe `galGroupes` (un élément par DisplayGroup, dans l'ordre de première apparition) contenant une galerie interne `galQuestions` (questions visibles du groupe, triées par OrdreAffichage) |
| Pied de page | Bouton « Enregistrer », Bouton « Résumé », Bouton « Accueil » |

Sources : `colQuestionsFormulaire` + `colEtatQuestions` (Visible = Vrai).

## 7.2 Modèle de ligne de question (dans `galQuestions`)

| Élément | Contrôle | Visible si |
|------|------|------|
| Libellé + indicateur obligatoire | Label | Toujours ; « * » si Obligatoire (colEtatQuestions) |
| Réponse RADIO | Radio, éléments = ValeursPossibles découpées sur `\|` | TypeQuestion = RADIO |
| Réponse CHECKBOX | Case à cocher (cochée = valeur de ValeursPossibles, ex. FAIT) | TypeQuestion = CHECKBOX |
| Réponse NUMERIQUE | Zone de texte numérique | TypeQuestion = NUMERIQUE |
| Valeur CALCUL | Label lecture seule (arrondi à l'affichage uniquement, TD PA-5) | TypeQuestion = CALCUL |
| Réponse TEXTE | Zone de texte multiligne | TypeQuestion = TEXTE |
| Icône 💬 | Icône, couleur d'alerte si commentaire obligatoire et vide | CommentaireAutorise = OUI |
| Icône 📷 + compteur | Icône + Label « n/min » (✅ si atteint) | PhotoAutorisee = OUI |
| Sous-question | Retrait visuel | QuestionParent renseigné |

Chaque modification de réponse : mise à jour de la ligne de `colReponses` (TD § 4.7), `locModificationsNonEnregistrees` = Vrai, réévaluation des règles (7.4).

## 7.3 Panneaux

| Panneau | Contrôles |
|------|------|
| Commentaire | Conteneur, zone de texte multiligne, Bouton « OK » |
| Photos | Conteneur, contrôle « Ajouter une image » (appareil photo ou galerie), galerie des photos de `locQuestionActive`, compteur, Bouton « Fermer » ; ajout bloqué si NbPhotos = PhotosMax |

## 7.4 Moteur de règles

Algorithme : TD § 5.3 à 5.5.

Implémentation recommandée pour le prototype : un **bouton masqué** `btnEvaluerRegles` dont l'action
recalcule entièrement `colEtatQuestions` (base, calcul, règles par Priorite, deuxième passe, neutralisation),
déclenché après chaque modification de réponse, commentaire ou photo, et à l'entrée de l'écran.

Validation pas à pas (dans cet ordre) :

1. visibilité par défaut seule (12 questions POTEAU visibles, 13 LUMINAIRE) ;
2. AFFICHER (R100–R103, R110, R400) ;
3. calcul POT_004_2_C ;
4. R120 (≥ 30) et condition composée R130 + R131 ;
5. PHOTO_MIN (R140, R200–R202, R300–R303) ;
6. R002 (MASQUER_FORMULAIRE) ;
7. R150 / R151 (vide ≠ 0).

## 7.5 Enregistrement

Séquence TD § 7.3 : écriture des lignes NOUVELLE / MODIFIEE de `colReponses` dans REPONSES (Title = ReponseID = GUID),
mise à jour de DateDerniereModification, passage BROUILLON → EN_COURS, relecture de l'inspection.

## 7.6 PHOTO_CAPTURED

Ajout automatique de la ligne Valeur = PHOTO_CAPTURED à la première photo d'une question PHOTO (TD § 6.8).

## 7.7 Variables et collections

`gblInspection`, `gblInspectionGUID`, `gblInspectionID`, `colQuestionsFormulaire`, `colReponses`, `colPhotos`,
`colEtatQuestions`, `locQuestionActive`, `locAfficherPanneauCommentaire`, `locAfficherPanneauPhotos`,
`locModificationsNonEnregistrees`.

## 7.8 Branchement de l'envoi des photos (quand PAU-06 existe)

Ajouter le flux à l'application, puis l'appeler pour chaque photo EN_ATTENTE à l'enregistrement (TD § 6.9).
En attendant, les photos restent EN_ATTENTE dans `colPhotos` et un message l'indique.

**Risques de l'étape 7**

- Galeries imbriquées : les contrôles d'une galerie interne ne conservent pas leur état si les éléments sont recalculés ; lire la valeur affichée depuis `colReponses`, pas depuis le contrôle.
- Recalcul trop fréquent du moteur : acceptable avec 20 questions et 29 règles ; à surveiller sur appareil d'entrée de gamme.
- Images en mémoire dans `colPhotos` : limiter la résolution affichée ; tester avec 15 photos.
- Fermeture de l'application avant enregistrement : données perdues (pas de mode hors connexion en v0.1) ; avertir via `locModificationsNonEnregistrees`.

---

# 8. Construire Screen_Resume

| Composants | Contrôles |
|------|------|
| En-tête | Labels InspectionID, NomOuvrage, TypeInspection |
| Synthèse | Labels : questions visibles / répondues ; photos présentes / exigées |
| Anomalies | Galerie `galAnomalies` (TypeAnomalie, Libelle, Detail) ; clic → retour à la question |
| Actions | Bouton « Soumettre » (actif si `locSoumissionPossible`), Bouton « Enregistrer comme brouillon », Bouton « Retour à l'inspection » |

| Sources | Collections / variables |
|------|------|
| INSPECTIONS, REPONSES (écriture à la soumission) | `colAnomalies`, `colEtatQuestions`, `colReponses`, `colPhotos`, `locSoumissionPossible` |

Contrôles R500–R503 : TD § 5.6. Soumission : TD § 7.5.

**Risques**

- Soumission avec photos EN_ATTENTE (PAU-06 absent) : bloquer la soumission tant qu'une photo n'est pas envoyée, sinon une inspection TERMINE n'aurait pas ses photos.
- Double clic sur « Soumettre » : désactiver le bouton pendant l'opération.

---

# 9. Construire Screen_History

| Composants | Contrôles |
|------|------|
| Recherche | Zone de texte `txtRechercheOuvrage`, Bouton « Rechercher » (visible depuis l'accueil) |
| Résultats | Galerie `galHistorique` : InspectionID, TypeInspection, StatutInspection, dates |
| Détail | Labels d'en-tête ; galerie des réponses (libellé, réponse, commentaire) ; galerie des photos ; visionneuse d'image |
| Retour | Bouton « Retour » vers `gblEcranRetourHistorique` |

| Sources | Collections / variables |
|------|------|
| INSPECTIONS (NomOuvrage), REPONSES et PHOTOS_INSPECTIONS (InspectionGUID) — lecture seule | `colHistorique`, `colReponsesConsultees`, `colPhotosConsultees`, `gblInspectionConsultee`, `gblEcranRetourHistorique`, `locRechercheOuvrage` |

**Risques**

- Aucun contrôle de saisie ne doit être modifiable (lecture seule, D005) : utiliser des Labels, pas des zones de texte.
- Affichage des images de la bibliothèque : vérifier l'accès aux miniatures avec un compte technicien.

---

# 10. Tests unitaires

Données de test : inspections créées pendant les tests. Aucune suppression n'étant possible (D007),
utiliser des noms d'ouvrage clairement fictifs (ex. `TEST-001`) ; un site de test reste préférable.

| # | Test | Résultat attendu | Réf. backlog |
|------|------|------|------|
| T01 | Démarrage | colQuestions = 34, colRegles = 29 | TST-01 |
| T02 | Nouvelle inspection | INSPECTIONS créée : TMP-…, BROUILLON, NON_ANALYSE, InspectionGUID renseigné | PA-07 |
| T03 | Concurrence | Avertissement si BROUILLON / EN_COURS même ouvrage, même type ; aucun blocage | TST-15 |
| T04 | LUMINAIRE complet | 13 questions ; soumission possible ; TERMINE | TST-03 |
| T05 | LUM_001 = NON_PRESENT | Commentaire obligatoire ; seule LUM_001 visible | TST-04 |
| T06 | POT_004 = AVANCEE | POT_004_1, POT_004_2_A/B/C visibles | TST-05 |
| T07 | POT_004 = SEVERE | POT_004_4 seule visible dans le groupe CORROSION | TST-06 |
| T08 | Perte 29 / 30 / 31 % | Test marteau à partir de 30 ; POT_004_5 sous 30 si POT_004_1 = OUI | TST-07, TST-08 |
| T09 | POT_004_2_A = 0 ; puis vide | Calcul et soumission bloqués ; vide : aucun blocage | TST-09 |
| T10 | Photos minimales | POT_001, POT_003 (1), POT_010 (2), POT_002 selon valeur, POT_005–008 si NON_VALIDE, POT_004_5 | TST-10 |
| T11 | POT_010B = OUI | POT_010B_A visible et obligatoire | TST-11 |
| T12 | Brouillon | Enregistrement incomplet accepté ; reprise depuis l'accueil ; EN_COURS après la 1re réponse | TST-12, TST-13 |
| T13 | Inaccessible | Commentaire obligatoire ; INACCESSIBLE ; DateSoumission renseignée (DEC-18) ; REPONSES SYS_001 | TST-14 |
| T14 | Accessible maintenant | Nouvelle inspection avec InspectionPrecedenteGUID ; ancienne inchangée | PA-09 |
| T15 | Historique | Lecture seule ; aucune écriture ; DateDerniereModification inchangée | TST-16 |
| T16 | PHOTO_CAPTURED | Ligne REPONSES créée à la 1re photo de POT_010 | DEC-10 |

---

# Ordre de travail résumé

| # | Étape | Livrable vérifiable |
|------|------|------|
| 1 | Créer l'application | Application vide enregistrée |
| 2 | Connecter SharePoint | 5 sources visibles |
| 3 | Charger les collections | 34 questions, 29 règles en mémoire |
| 4 | Screen_Home | Navigation et liste de reprise |
| 5 | Screen_Type | Choix du type |
| 6 | Screen_Identification | Création d'inspection TMP-… et inspection inaccessible |
| 7 | Screen_Inspection | Formulaire dynamique, règles, enregistrement |
| 8 | Screen_Resume | Anomalies et soumission |
| 9 | Screen_History | Consultation en lecture seule |
| 10 | Tests unitaires | T01 à T16 passés |
