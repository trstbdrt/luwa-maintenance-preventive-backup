# LUWA Maintenance Preventive Backup
## Power Apps Readiness

Version : 0.2.0

Date : 2026-10-08

Objet : contrôles à réaliser **avant d'ouvrir Power Apps Studio** pour démarrer le Sprint Power Apps.

Références :

- `docs/build/sharepoint-build-checklist.md`
- `sharepoint/data-model/sharepoint-schema.md` (v0.1.4)
- `powerapps/screens.md` (v0.1.4)
- `docs/decisions/technical-decisions-v0.1.2.md`, `docs/decisions/technical-decisions-v0.1.3.md`
- `docs/build/open-questions.md`

Réalisé par : ____________________  Date : ____________

---

# 1. Pré-requis

Les quatre pré-requis doivent être cochés avant l'ouverture de Power Apps.

- [ ] **Listes créées** : `docs/build/sharepoint-build-checklist.md`, étapes 1 et 2 entièrement cochées
- [ ] **Index vérifiés** : checklist SharePoint, étape 3 entièrement cochée
- [ ] **Catalogues importés** : checklist SharePoint, étapes 4 et 5 entièrement cochées
- [ ] **Tests SharePoint passés** : section 3 du présent document entièrement cochée

---

# 2. Contrôles de structure SharePoint

## 2.1 Listes et bibliothèque

- [ ] INSPECTIONS, QUESTIONS, REGLES_FORMULAIRE, REPONSES existent avec ces noms exacts
- [ ] PHOTOS_INSPECTIONS existe et est une **bibliothèque de documents**
- [ ] Historique des versions activé sur les 5 éléments
- [ ] Pièces jointes désactivées sur les 4 listes

## 2.2 Colonnes

- [ ] Noms internes de toutes les colonnes identiques au schéma (aucun suffixe `0`, aucun `_x0020_`)
- [ ] Title obligatoire sur les 4 listes (DEC-01)
- [ ] `StatutTraitement` : valeur par défaut `NON_ANALYSE` (DEC-02)
- [ ] `REPONSES.Valeur` : Plusieurs lignes de texte, texte brut (DEC-05)
- [ ] Toutes les colonnes multilignes en **texte brut** (ValeursPossibles, FormuleCalcul, Commentaire de REGLES_FORMULAIRE, Valeur et Commentaire de REPONSES)
- [ ] Aucune colonne Choice n'autorise de valeur de remplissage
- [ ] Valeurs des colonnes Choice identiques au schéma (majuscules, underscore, sans accent)
- [ ] Aucune colonne `CommentaireInaccessible` dans INSPECTIONS

## 2.3 Index

- [ ] 22 index présents (INSPECTIONS 7, QUESTIONS 3, REGLES_FORMULAIRE 4, REPONSES 4, PHOTOS_INSPECTIONS 4)
- [ ] Index créés **avant** l'import des catalogues

## 2.4 Permissions

- [ ] Compte technicien de test : ne peut **pas** supprimer un élément de INSPECTIONS, REPONSES ou PHOTOS_INSPECTIONS (D007)
- [ ] Compte technicien de test : **lecture seule** sur QUESTIONS et REGLES_FORMULAIRE
- [ ] Compte administrateur fonctionnel : peut modifier QUESTIONS et REGLES_FORMULAIRE

---

# 3. Tests SharePoint

## 3.1 Catalogues (TST-01)

- [ ] QUESTIONS : 34 éléments, contrôles post-import de la checklist SharePoint (étape 4) tous conformes
- [ ] REGLES_FORMULAIRE : 29 éléments, contrôles post-import de la checklist SharePoint (étape 5) tous conformes
- [ ] Cohérence croisée règles ↔ questions conforme
- [ ] Ouverture d'un élément QUESTIONS : `ValeursPossibles` et `FormuleCalcul` affichés sans balise HTML

## 3.2 Écriture des données (site de test uniquement — SP-13)

Utiliser les fichiers `sharepoint/data-model/*.csv` sur un **site de test**, jamais en production.

- [ ] Création manuelle d'une inspection d'exemple dans INSPECTIONS : enregistrement accepté, `StatutTraitement` prend `NON_ANALYSE` par défaut
- [ ] Création d'une réponse dans REPONSES avec une `Valeur` de plus de 255 caractères : enregistrement accepté (DEC-05)
- [ ] Création d'une réponse `Valeur = PHOTO_CAPTURED` (DEC-10) : enregistrement accepté
- [ ] Dépôt d'une photo dans PHOTOS_INSPECTIONS, dossier `<InspectionGUID>/` (DEC-15), avec les 5 métadonnées obligatoires : enregistrement accepté
- [ ] Champ Choice : une valeur hors liste est refusée
- [ ] Les éléments de test sont conservés sur le site de test (aucune suppression)

## 3.3 Requêtes indexées (préparation délégation)

- [ ] Vue filtrée sur INSPECTIONS par `NomOuvrage` : fonctionne
- [ ] Vue filtrée sur INSPECTIONS par `StatutInspection` : fonctionne
- [ ] Vue filtrée sur REPONSES par `InspectionGUID` : fonctionne
- [ ] Vue filtrée sur PHOTOS_INSPECTIONS par `InspectionGUID` : fonctionne

---

# 4. Contrôles d'environnement Power Apps

- [ ] Environnement Power Platform cible identifié : ______________________
- [ ] Licence Power Apps disponible pour le concepteur et pour les techniciens de test
- [ ] Connecteur SharePoint autorisé dans l'environnement (stratégies DLP)
- [ ] Comptes de test disponibles : au moins 2 techniciens (test de concurrence DEC-08 et de reprise DEC-09) et 1 administrateur fonctionnel
- [ ] Appareil de test avec appareil photo disponible (tablette ou téléphone)

---

# 5. Contrôles documentaires

Le concepteur Power Apps a pris connaissance de :

- [ ] `powerapps/powerapps-technical-design-v0.2.md` (variables, collections, moteur de règles, photos, statuts, flux)
- [ ] `powerapps/screens.md` (6 écrans, principes communs)
- [ ] `sharepoint/data-model/sharepoint-schema.md` (règles de remplissage, utilisation des colonnes de valeur selon TypeQuestion)
- [ ] DEC-01 à DEC-10 (`technical-decisions-v0.1.2.md`)
- [ ] DEC-11 et DEC-12 (`technical-decisions-v0.1.3.md`)
- [ ] DEC-13 à DEC-17 (`technical-decisions-v0.1.5.md`)
- [ ] `docs/build/open-questions.md`, en particulier :
  - [ ] OQ-06 (stockage des paramètres de compression) — à trancher avant PA-17
- [ ] Exigences sensibles rappelées dans `screens.md` :
  - [ ] relations uniquement par InspectionGUID (DEC-03, DEC-11)
  - [ ] R150 / R151 uniquement si POT_004_2_A visible et renseignée (vide ≠ 0)
  - [ ] PHOTO_MIN remplace NbPhotosMin lorsque la règle est vérifiée (DEC-06)
  - [ ] aucune suppression possible

---

# 6. Décision d'ouverture

| Contrôle | Résultat |
|------|------|
| Section 1 — Pré-requis | ☐ Conforme ☐ Non conforme |
| Section 2 — Structure SharePoint | ☐ Conforme ☐ Non conforme |
| Section 3 — Tests SharePoint | ☐ Conforme ☐ Non conforme |
| Section 4 — Environnement | ☐ Conforme ☐ Non conforme |
| Section 5 — Documentation | ☐ Conforme ☐ Non conforme |

- [ ] **Ouverture de Power Apps autorisée** (toutes les sections conformes)

Validé par : ____________________  Date : ____________

---

# 7. Verdict final (v0.2.0)

État au 2026-10-09 :

| Domaine | État | Bloque l'implémentation ? |
|------|------|------|
| Conception technique | Complète : `powerapps/powerapps-technical-design-v0.2.md` | — |
| Décisions | DEC-01 à DEC-17 prises ; aucune question ouverte P1 | Non |
| SharePoint | Construit et vérifié (`docs/build/sharepoint-build-report.md`) : listes, bibliothèque, 55 colonnes, 22 index, 34 questions, 29 règles | Non |
| Envoi des fichiers photo | Dépend du flux PAU-06 (technical design § 6.6) | Non : bloque seulement l'envoi effectif des photos (PA-16), pas le développement des écrans |
| Permissions des techniciens (§ 2.4) | Non configurées ; soumises à l'accord explicite du propriétaire du site | Non : nécessaires avant les tests avec des comptes techniciens (TST-17) |
| Tests d'écriture (§ 3.2) | Non exécutés ; site de test requis | Non : nécessaires avant les tests d'intégration |
| Environnement Power Platform (§ 4) | Non vérifié par l'équipe projet | À contrôler par le développeur à l'ouverture de Studio (licence, DLP) |
| Questions ouvertes | OQ-06 (P2, compression), OQ-12 (P2, réponses masquées), OQ-07 à OQ-11 (P3) | Non |

Aucun blocage de conception ne subsiste. Les éléments non réalisés sont des étapes d'exécution
qui n'empêchent pas de démarrer le développement dans Power Apps Studio.

## Verdict

**POWER APPS IMPLEMENTATION READY**

Réserves d'exécution à lever avant les tests utilisateurs : permissions (§ 2.4, avec accord du propriétaire),
tests d'écriture (§ 3.2), flux d'envoi des photos (PAU-06).
