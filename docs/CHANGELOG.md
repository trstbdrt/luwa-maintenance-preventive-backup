# Changelog

## Lot 4 (Power Apps)

Date : 2026-10-09

Contenu :

- DEC-29 : clé d'ouvrage `CleOuvrage` (espaces et casse ignorés), orthographe unique, format `E100 511`
- SharePoint : colonnes INSPECTIONS CleOuvrage (indexée, remplie pour l'existant), CheminDossier, RapportHTML, RapportCSV ;
  lien « Dossiers ouvrages » dans le menu ; vue REPONSES « Par inspection »
- Application : identification et historique par clé ; rapport HTML + CSV produit à la soumission et à l'inaccessibilité
- Flux : PAU-06 dépose dans `_EN_COURS/<GUID>` ; nouveau PAU-07 `LUWA_ClasserInspection` (dossier par ouvrage, PDF, CSV, photos déplacées)

## Version 0.2.0

Date : 2026-10-09

Contenu :

- Power Apps Technical Design (powerapps/powerapps-technical-design-v0.2.md) : variables globales et d'écran, collections, navigation, moteur de règles, photos, brouillons et statuts, 7 flux utilisateur
- Power Apps Readiness : verdict final POWER APPS IMPLEMENTATION READY (avec réserves d'exécution)
- Écrans alignés (gblInspectionGUID, gblInspectionID, colHistorique)
- Backlog : ajout PAU-06 (flux d'envoi des photos)
- Question ouverte OQ-12 (réponses d'une question devenue masquée)

## Version 0.1.7

Date : 2026-10-08

Contenu :

- Numérotation définitive des décisions : DEC-13 à DEC-17 (remplace la numérotation provisoire DEC-14 à DEC-17 de la v0.1.6, contenu inchangé)
  - DEC-13 InspectionID temporaire, DEC-14 InspectionID final, DEC-15 dossiers photos, DEC-16 statuts archivables, DEC-17 règle des 183 jours
- Références mises à jour : questions ouvertes, backlog, Build Readiness Review, schéma SharePoint, écrans, guide, fichiers modèles

## Version 0.1.6

Date : 2026-10-08

Contenu :

- Décisions DEC-14 à DEC-17 validées (docs/decisions/technical-decisions-v0.1.5.md)
- Questions ouvertes OQ-01 à OQ-05 clôturées
- Schéma SharePoint : InspectionID temporaire / final, dossiers photos par InspectionGUID, règle d'archivage
- Build Readiness Review révisée : SharePoint, Power Apps et Power Automate READY

## Version 0.1.5

Date : 2026-10-08

Contenu :

- Environnement SharePoint construit (site LuwaMaintenancePreventiveBackup) : 4 listes, bibliothèque PHOTOS_INSPECTIONS, 55 colonnes, 22 index
- Import des catalogues : 34 questions, 29 règles, contenu vérifié identique aux CSV
- Rapport de construction SharePoint (docs/build/sharepoint-build-report.md)

## Version 0.1.4

Date : 2026-10-08

Contenu :

- Décision DEC-11 validée
- Décision DEC-12 validée
- SharePoint Build Checklist ajoutée
- Power Apps Readiness ajoutée
- Questions ouvertes consolidées (docs/build/open-questions.md)
- Build Readiness Review révisée : Power Apps READY

## Version 0.1.3

Date : 2026-10-08

Contenu :

- Décisions techniques figées (docs/decisions/technical-decisions-v0.1.2.md, DEC-01 à DEC-10)
- Schéma SharePoint finalisé
- Fichiers modèles alignés
- Build Readiness Review (docs/reviews/build-readiness-v0.1.3.md)

## Version 0.1.2

Date : 2026-10-08

Contenu :

- Ajout fichiers modèles SharePoint
- Ajout guide de construction SharePoint
- Ajout écrans Power Apps détaillés
- Ajout backlog de build
- Ajout rapport de cohérence du dépôt (docs/reviews/repository-consistency-report.md)

## Version 0.1.1

Date : 2026-10-08

Contenu :

- Ajout du schéma SharePoint (sharepoint/data-model/sharepoint-schema.md)
- REGLES_FORMULAIRE : ajout des valeurs Action manquantes (AFFICHER_IF_MATCH, WAITING_SECOND_CONDITION, OBLIGATOIRE)
- REGLES_FORMULAIRE : ajout des valeurs ConditionType
- REGLES_FORMULAIRE : ajout de la valeur Formulaire ALL
- InspectionGUID utilisé comme clé relationnelle partout (REPONSES, PHOTOS_INSPECTIONS, InspectionPrecedenteGUID)
- Suppression de CommentaireInaccessible de INSPECTIONS (commentaire porté par SYS_001 dans REPONSES)
- Title = InspectionID
- Nom de bibliothèque uniformisé : PHOTOS_INSPECTIONS

## Version 0.1

Date : 2026-10-08

Contenu :

- Catalogue QUESTIONS validé
- Catalogue REGLES_FORMULAIRE validé
- Modèle SharePoint validé
- Architecture App1/App2 validée
