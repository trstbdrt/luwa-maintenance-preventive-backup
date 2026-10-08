# LUWA Maintenance Preventive Backup
## Architecture Globale v0.1

Version : 0.1

Date : 2026-10-08

Statut : Architecture validée

---

# 1. Objectif

Définir l'architecture cible de l'application de secours destinée aux campagnes de maintenance préventive LUWA.

Cette architecture doit :

- supporter le POC ;
- supporter plusieurs dizaines de milliers d'inspections ;
- supporter plusieurs centaines de milliers de photos ;
- permettre l'évolution vers une application d'analyse (App 2) ;
- permettre les exports structurés ;
- permettre la réintégration future dans l'application officielle.

---

# 2. Principe général

L'architecture est volontairement découpée en deux applications.

## App 1

Inspection terrain.

Mission :

Collecter les données.

Aucune décision métier.

---

## App 2

Analyse et traitement.

Mission :

Transformer les constats en actions.

---

# 3. Architecture cible

Power Apps (App 1)

↓

SharePoint

↓

┌─────────────────────────────┬─────────────────────────────┐
│ Application officielle      │ App 2 (Future)             │
└─────────────────────────────┴─────────────────────────────┘

Les données SharePoint constituent la source commune :

- pour la réintégration éventuelle dans l'application officielle ;
- pour le futur traitement métier réalisé par App 2.

---

# 4. Architecture Applicative

## App 1

### Fonction

Collecte terrain.

---

### Modules

- Accueil
- Nouvelle inspection
- Reprise inspection
- Historique
- Inspection Poteau
- Inspection Luminaire
- Résumé

---

### Responsabilités

- saisie réponses
- saisie commentaires
- capture photos
- sauvegarde brouillons
- soumission

---

### Limitations

Ne réalise jamais :

- création OT
- validation technique
- classification
- décision métier
- affectation de travaux

---

# 5. Architecture App 2

## Fonction

Analyse des constats.

---

## Workflow cible

Inspection

↓

Validation Chef de Projet

↓

Analyse

↓

Création Fiche de Suivi

↓

Intervention terrain

↓

Clôture

---

## Entités futures

App 2 introduira les entités métier suivantes :

- Validation
- Analyse
- Fiche de Suivi
- Intervention

Ces entités sont volontairement absentes du modèle App 1.

---

## Responsabilités futures

- validation
- décision
- création actions
- suivi réalisation
- clôture

---

# 6. Architecture SharePoint

Le stockage principal repose sur SharePoint.

---

## Liste INSPECTIONS

Une ligne = une inspection.

Contient :

- métadonnées
- statut
- ouvrage
- utilisateur

---

## Liste QUESTIONS

Catalogue de configuration.

Les formulaires ne sont jamais codés en dur.

Les questions sont pilotées par données.

La liste QUESTIONS contient également les questions système nécessaires au fonctionnement de l'application.

Exemple :

- SYS_001 : Ouvrage inaccessible

---

## Liste REGLES_FORMULAIRE

Catalogue de règles.

Toutes les dépendances dynamiques sont pilotées par configuration.

---

## Liste REPONSES

Une ligne = une réponse.

---

## Bibliothèque PHOTOS_INSPECTIONS

Stockage physique des photos.

---

## Référentiel documentaire

Le projet maintient également un référentiel documentaire :

- DECISIONS_ARCHITECTURE
- Documentation
- Wireframes
- Catalogues

Cette partie n'est pas utilisée directement par Power Apps.

---

# 7. Modèle de données

INSPECTIONS

│

├── REPONSES

│

└── PHOTOS

---

## Relation

Une inspection possède :

- plusieurs réponses
- plusieurs photos

---

## Relation Photo

Chaque photo possède obligatoirement :

- InspectionGUID
- QuestionCode

Aucune photo ne peut exister sans association explicite à une question.

L'association :

Photo ↔ Question

est obligatoire.

Cette règle est fondamentale pour les exports futurs et App 2.

---

## Cas particulier : ouvrage inaccessible

Une pseudo-question système est prévue :

SYS_001

Libellé :

Ouvrage inaccessible

Cette question n'est jamais affichée à l'utilisateur mais sert de support technique pour :

- le commentaire obligatoire d'inaccessibilité ;
- la photo facultative d'inaccessibilité.

Les photos prises lors d'un constat d'inaccessibilité sont donc rattachées à :

QuestionCode = SYS_001

Le modèle de données reste ainsi homogène sans exception technique.

---

# 8. Identification des inspections

Chaque inspection possède :

## Identifiant technique

InspectionGUID

Format :

GUID

Exemple :

550e8400-e29b-41d4-a716-446655440000

---

## Identifiant lisible

InspectionID

Exemple :

INS-20261008-000123

---

# 9. Historique

Lorsqu'un ouvrage est encodé :

l'application recherche :

- inspections terminées
- inspections en cours
- inspections inaccessibles

---

## Consultation

Les inspections précédentes peuvent être ouvertes.

Mode :

Lecture seule.

---

## Cas particulier

Si la dernière inspection possède le statut :

INACCESSIBLE

l'utilisateur peut démarrer une nouvelle inspection via :

"Accessible maintenant"

sans modifier l'inspection précédente.

---

# 10. Concurrence

Plusieurs inspections simultanées sur un même ouvrage sont autorisées.

L'application :

- affiche un avertissement ;
- ne bloque jamais.

---

# 11. Gestion des brouillons

Une inspection peut être enregistrée à tout moment.

---

## Sauvegarde

Toujours autorisée.

---

## Soumission

Soumise aux validations métier.

---

# 12. Gestion Offline

L'architecture prévoit le support futur du mode déconnecté.

Technologies Power Apps envisagées :

SaveData()

LoadData()

---

## Comportement cible

Saisie locale

↓

Stockage local

↓

Retour réseau

↓

Synchronisation SharePoint

---

# 13. Gestion des photos

## Source

- appareil photo
- galerie

---

## Compression

La compression est configurable.

Les paramètres futurs incluent :

- CompressionEnabled
- CompressionThreshold
- CompressionQuality
- MaxResolution

---

## Règle validée

La compression ne doit pas être systématiquement appliquée.

Une photo de faible taille peut être conservée telle quelle.

Le comportement exact est piloté par configuration.

---

# 14. Gestion des exports

L'architecture doit permettre :

- export manuel
- export Power Automate
- export App 2

---

## Formats

- Excel
- CSV
- ZIP

---

## Format cible

Export.zip

    Export.xlsx

    Photos/

        Photo001.jpg
        Photo002.jpg
        Photo003.jpg

---

## Objectif

Les exports doivent permettre la réintégration future dans l'application officielle.

---

# 15. Gouvernance des données

Source de vérité métier :

QUESTIONS

---

Source de vérité comportementale :

REGLES_FORMULAIRE

---

Les formulaires sont pilotés par configuration.

---

# 16. Pilotage par configuration

Le comportement de l'application ne doit pas dépendre de code spécifique.

Exemples :

- question obligatoire
- photo obligatoire
- affichage conditionnel
- calcul automatique

Tous ces comportements doivent être pilotés par :

- QUESTIONS
- REGLES_FORMULAIRE

---

## Hiérarchie des questions

Le champ :

QuestionParent

permet de gérer :

- les sous-questions
- les dépendances
- les regroupements logiques

---

## Regroupements visuels

Le champ :

DisplayGroup

permet de regrouper visuellement :

- GENERAL
- CORROSION
- SUR_PONT
- SYSTEM

sans modifier le code Power Apps.

---

# 17. Scalabilité

L'architecture doit supporter :

- plus de 30 000 inspections
- plusieurs années d'historique
- plusieurs centaines de milliers de photos

---

## Recommandations SharePoint

Les colonnes suivantes devront être indexées :

### Liste INSPECTIONS

- InspectionID
- InspectionGUID
- NomOuvrage
- StatutInspection
- TypeInspection

### Liste REPONSES

- InspectionGUID
- QuestionCode

Cette indexation est indispensable pour supporter plusieurs centaines de milliers de réponses tout en restant compatible avec les limitations SharePoint et les contraintes de délégation Power Apps.

---

# 18. Evolutivité

L'architecture doit permettre l'ajout futur :

- validation chef de projet
- workflow
- tâches
- interventions
- analyses automatiques

sans modification des inspections historiques.

---

# 19. Référentiel Projet

L'ensemble du projet est géré dans :

Repository GitHub

luwa-maintenance-preventive-backup

---

## Git

Versionnement :

- v0.1
- v0.2
- v0.3
- ...

---

## SharePoint

Stockage opérationnel :

- documentation
- exports
- application
- données

---

# 20. Version de Référence

Version architecture :

v0.1

Date :

2026-10-08

Statut :

Validée
