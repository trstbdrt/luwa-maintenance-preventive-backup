# LUWA Maintenance Preventive Backup
## Spécification Fonctionnelle v0.1

Version : 0.1

Date : 2026-10-08

Statut : Architecture validée

---

# 1. Contexte

L'application LUWA Maintenance Preventive Backup est une application de secours destinée à être utilisée lorsque l'application officielle de maintenance préventive est indisponible.

Son objectif principal est de permettre aux équipes terrain de poursuivre les campagnes de maintenance préventive sans interruption opérationnelle.

Les données collectées doivent ensuite pouvoir être :

- consultées ;
- exportées ;
- réintégrées dans l'application officielle.

---

# 2. Objectifs

Permettre à des techniciens terrain de :

- réaliser une inspection poteau ;
- réaliser une inspection luminaire ;
- ajouter des commentaires ;
- prendre ou importer des photos ;
- sauvegarder une inspection partiellement complétée ;
- reprendre une inspection plus tard ;
- soumettre une inspection complétée ;
- consulter les inspections précédentes.

---

# 3. Technologies cibles

## Front-end

Power Apps

---

## Stockage

SharePoint

---

## Automatisation

Power Automate

---

## Reporting

Excel

CSV

ZIP

---

# 4. Périmètre App 1

L'application App 1 est exclusivement une application de collecte terrain.

Elle ne prend aucune décision métier.

---

## App 1 permet

- collecte des données
- collecte des photos
- collecte des mesures
- gestion des brouillons
- gestion de l'historique
- export structuré

---

## App 1 ne permet pas

- création OT
- création tâche corrective
- validation métier
- classification inspection
- décision technique

---

# 5. Périmètre App 2 (future phase)

App 2 sera développée ultérieurement.

## Objectifs App 2

- validation chef de projet
- analyse technique
- génération d'actions
- création fiche de suivi
- suivi des interventions
- clôture

## Workflow cible

Inspection

↓

Validation Chef de Projet

↓

Analyse

↓

Création fiche de suivi

↓

Intervention terrain

↓

Clôture

---

# 6. Types d'inspection

Deux formulaires indépendants sont prévus.

## Inspection Poteau

Réalisée par les équipes travaillant au niveau du sol.

## Inspection Luminaire

Réalisée par les équipes équipées de nacelles.

## Décision validée

Les deux formulaires restent totalement séparés.

---

# 7. Identification ouvrage

L'utilisateur encode manuellement l'ouvrage.

Exemples :

- E100 511
- E100 511-1
- K024 318-2

Aucune validation patrimoine n'est réalisée dans le POC.

---

# 8. Historique

Lorsqu'un ouvrage est encodé, l'application affiche l'état de la dernière inspection connue.

Exemples :

- Terminée
- En cours
- Inaccessible

## Consultation historique

Les inspections précédentes peuvent être ouvertes.

Mode :

Lecture seule.

Aucune modification n'est autorisée.

---

# 9. Inspections simultanées

Plusieurs utilisateurs peuvent ouvrir simultanément le même ouvrage.

L'application affiche un avertissement informatif.

Exemple :

"Une inspection est actuellement en cours sur cet ouvrage."

## Comportement

Aucun blocage.

La poursuite est autorisée.

---

# 10. Ouvrage inaccessible

L'utilisateur peut déclarer l'ouvrage inaccessible.

## Données requises

Commentaire obligatoire.

Photo facultative.

## Statut créé

INACCESSIBLE

---

# 11. Brouillons

Une inspection peut être sauvegardée à tout moment.

## Sauvegarde autorisée même si

- questions obligatoires incomplètes
- photos obligatoires absentes
- calculs non réalisés
- formulaire partiellement complété

## Statuts

BROUILLON

Inspection créée mais aucune réponse encore encodée.

Exemples :

- type sélectionné
- ouvrage sélectionné
- aucune question répondue

EN_COURS

Inspection contenant au moins une réponse mais non soumise.

Exemples :

- 1 question complétée sur 15
- formulaire partiellement rempli

---

# 12. Soumission

La soumission est autorisée uniquement si :

- toutes les questions visibles obligatoires sont complétées ;
- toutes les photos obligatoires sont présentes ;
- toutes les règles conditionnelles sont satisfaites.

---

# 13. Questions

Chaque question peut contenir :

- une réponse ;
- un commentaire ;
- des photos.

## Commentaires

Les commentaires sont accessibles via l'icône :

💬

## Photos

Les photos sont accessibles via l'icône :

📷

---

# 14. Photos obligatoires

Certaines questions imposent des photos.

Exemples :

0/1

1/1 ✅

0/2

1/2

2/2 ✅

## Comportement

La soumission est bloquée si le minimum requis n'est pas atteint.

---

# 15. Compression photos

Compression configurable.

Les paramètres ne sont pas figés dans la conception.

Ils pourront être adaptés après le POC.

---

# 16. Mode hors connexion

La conception doit permettre ultérieurement :

- sauvegarde locale
- synchronisation différée

Technologies envisagées :

SaveData()

LoadData()

---

# 17. Statuts inspection

Valeurs possibles :

- BROUILLON
- EN_COURS
- TERMINE
- INACCESSIBLE
- ARCHIVE

---

# 18. Archivage

Les inspections anciennes peuvent être archivées.

Durée cible :

6 mois.

## Archivage

L'archivage consiste uniquement à retirer l'élément des vues principales de travail.

Les données restent :

- stockées
- consultables
- exportables

Archivage ≠ suppression.

---

# 19. Suppression

Aucune suppression n'est autorisée.

Cela s'applique à tous les statuts :

- BROUILLON
- EN_COURS
- TERMINE
- INACCESSIBLE
- ARCHIVE

Toutes les inspections restent conservées.

Les anciennes inspections peuvent être archivées mais jamais supprimées.

---

# 20. Export

L'application doit produire des exports structurés.

Formats :

- Excel
- CSV
- ZIP

## Export photos

Les photos sont exportées séparément.

Structure :

Export.xlsx

Photos/

photo001.jpg

photo002.jpg

---

# 21. Réintégration application officielle

Les données doivent pouvoir être :

- réencodées manuellement ;
- exportées automatiquement ;
- analysées par App 2.

---

# 22. Gouvernance

Source de vérité projet :

Repository GitHub

luwa-maintenance-preventive-backup

---

# 23. Version

Version fonctionnelle de référence :

v0.1

Date :

2026-10-08
