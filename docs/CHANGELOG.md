# Changelog

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
