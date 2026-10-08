# LUWA Maintenance Preventive Backup
## Questions ouvertes

Version : 0.1.4

Date : 2026-10-08

Ce document liste **uniquement** les sujets encore ouverts à la version v0.1.4.
Les décisions déjà prises (D001 à D009, DEC-01 à DEC-12) ne sont pas reprises ici.

Priorités :

- **P1** : à trancher avant l'élément de backlog indiqué
- **P2** : à trancher avant usage terrain élargi
- **P3** : amélioration ou version ultérieure

---

# Synthèse

| ID | Sujet | Priorité | Bloque | Bloque le démarrage SharePoint ? | Bloque le démarrage Power Apps ? |
|------|------|------|------|------|------|
| OQ-02 | Mécanisme d'attribution de la valeur finale de l'InspectionID | P1 | PAU-04 | Non | Non |
| OQ-01 | Format de l'InspectionID temporaire | P2 | PA-07 (finalisation) | Non | Non |
| OQ-03 | Nom du dossier photos tant que l'InspectionID est temporaire | P2 | PA-16, PAU-05 | Non | Non |
| OQ-04 | Statuts concernés par l'archivage | P2 | PAU-03 | Non | Non |
| OQ-05 | Mode de calcul du délai de 6 mois et effet de l'archivage sur DateDerniereModification | P2 | PAU-03 | Non | Non |
| OQ-06 | Stockage des paramètres de compression | P2 | PA-17 | Non | Non |
| OQ-07 | DateSoumission d'une inspection INACCESSIBLE | P3 | — | Non | Non |
| OQ-08 | Indicateur VisibleParDefaut de SYS_001 | P3 | — | Non | Non |
| OQ-09 | Lien formel des conditions composées (R130 + R131) | P3 | v0.2 | Non | Non |
| OQ-10 | Condition structurée « vide ≠ 0 » pour R150 / R151 | P3 | v0.2 | Non | Non |
| OQ-11 | Documents encore à compléter | P3 | — | Non | Non |

---

# OQ-01 — Format de l'InspectionID temporaire

**Contexte** : DEC-11 autorise un InspectionID temporaire pendant la saisie,
sans en fixer le format. InspectionID et Title sont des colonnes obligatoires.

**À décider** :

- format de la valeur temporaire ;
- distinction visuelle entre un identifiant temporaire et un identifiant final.

**Impact** : affichage des écrans (en-têtes, galeries) ; non bloquant pour l'intégrité,
les relations reposant sur InspectionGUID.

---

# OQ-02 — Attribution de la valeur finale de l'InspectionID

**Contexte** : DEC-11 fixe le moment (synchronisation SharePoint) et le format cible
`INS-AAAAMMJJ-NNNNNN`, pas le mécanisme.

**À décider** :

- composant qui attribue la valeur finale (application ou Power Automate) ;
- date utilisée pour `AAAAMMJJ` (création de l'inspection ou synchronisation) ;
- portée du compteur `NNNNNN` (par jour ou global) ;
- garantie d'unicité en cas de synchronisations simultanées.

**Impact** : PAU-04 ; contenu de Title (= InspectionID).

---

# OQ-03 — Dossier photos et InspectionID temporaire

**Contexte** : la structure recommandée de PHOTOS_INSPECTIONS est `AAAA/MM/InspectionID/`.
Avec DEC-11, des photos peuvent être enregistrées avant l'attribution de l'InspectionID final.

**À décider** :

- nom du dossier tant que l'InspectionID est temporaire ;
- déplacement ou renommage éventuel du dossier après attribution de la valeur finale.

**Impact** : PA-16, PAU-05. Aucun impact sur l'intégrité : la relation photo ↔ inspection
repose sur la métadonnée InspectionGUID.

---

# OQ-04 — Statuts concernés par l'archivage

**Contexte** : DEC-12 fixe la date de référence et le délai, pas les statuts concernés.
La spécification (§ 18, version corrigée) parle d'« inspections anciennes ».

**À décider** : statuts pouvant passer à ARCHIVE (BROUILLON, EN_COURS, TERMINE, INACCESSIBLE).

**Impact** : PAU-03.

---

# OQ-05 — Calcul du délai et effet de l'archivage

**Contexte** : DEC-12 : archivable si `Aujourd'hui - DateDerniereModification > 6 mois`.

**À décider** :

- calcul du délai : 6 mois calendaires ou nombre de jours fixe ;
- le passage au statut ARCHIVE met-il à jour DateDerniereModification ?
- ce qui constitue une « réouverture » : seul un enregistrement modifie DateDerniereModification
  (la consultation en lecture seule ne la modifie pas).

**Impact** : PAU-03.

---

# OQ-06 — Stockage des paramètres de compression

**Contexte** : DEC-07 liste les paramètres (CompressionEnabled, CompressionThreshold,
CompressionQuality, MaxResolution) et reporte leur stockage.

**À décider** : emplacement et format de stockage.

**Impact** : PA-17.

---

# OQ-07 — DateSoumission d'une inspection INACCESSIBLE

**Contexte** : la spécification et le schéma ne précisent pas si DateSoumission est renseignée
lors d'une déclaration d'inaccessibilité.

**À décider** : DateSoumission vide ou renseignée pour le statut INACCESSIBLE.

**Impact** : exports, App 2.

---

# OQ-08 — VisibleParDefaut de SYS_001

**Contexte** : `questions.csv` (gelé) indique `VisibleParDefaut = OUI` pour SYS_001 ;
l'architecture (gelée) indique que cette question « n'est jamais affichée à l'utilisateur ».
Sans effet fonctionnel : SYS_001 appartient au formulaire SYSTEM et n'est utilisée
que par le panneau d'inaccessibilité.

**À décider** : alignement des deux documents lors d'une prochaine révision des fichiers gelés.

---

# OQ-09 — Lien formel des conditions composées

**Contexte** : R130 et R131 sont associées par convention
(WAITING_SECOND_CONDITION + AFFICHER_IF_MATCH sur la même cible).

**À décider** : ajout éventuel d'une colonne de regroupement dans REGLES_FORMULAIRE (v0.2).

---

# OQ-10 — Condition structurée pour R150 / R151

**Contexte** : la restriction « uniquement si POT_004_2_A visible et renseignée (vide différent de 0) »
est portée par la colonne Commentaire, pas par une condition structurée.

**À décider** : structuration éventuelle de cette condition (v0.2).

---

# OQ-11 — Documents à compléter

| Document | État |
|------|------|
| `docs/architecture/modele-donnees-v0.1.md` | « À compléter » |
| `docs/wireframes/wireframes-v0.1.md` | « À compléter » |
| `README.md` (racine) | Indique encore la version 0.1 |
