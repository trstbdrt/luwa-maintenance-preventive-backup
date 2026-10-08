# LUWA Maintenance Preventive Backup
## Questions ouvertes

Version : 0.2.0

Date : 2026-10-08

Ce document liste les sujets encore ouverts.
Les décisions prises (D001 à D009, DEC-01 à DEC-17) ne sont pas reprises,
à l'exception de la table de clôture ci-dessous.

Priorités :

- **P1** : à trancher avant l'élément de backlog indiqué
- **P2** : à trancher avant usage terrain élargi
- **P3** : amélioration ou version ultérieure

---

# Questions clôturées en v0.1.6 (numérotation définitive v0.1.7)

| ID | Sujet | Clôturée par |
|------|------|------|
| OQ-01 | Format de l'InspectionID temporaire | DEC-13 |
| OQ-02 | Attribution de la valeur finale de l'InspectionID | DEC-14 |
| OQ-03 | Dossier photos tant que l'InspectionID est temporaire | DEC-15 |
| OQ-04 | Statuts concernés par l'archivage | DEC-16 |
| OQ-05 | Calcul du délai, effet de l'archivage, réouverture | DEC-17 |

Détail : `docs/decisions/technical-decisions-v0.1.5.md`.

---

# Questions encore ouvertes

| ID | Sujet | Priorité | Bloque | Bloque SharePoint ? | Bloque Power Apps ? | Bloque Power Automate ? |
|------|------|------|------|------|------|------|
| OQ-06 | Stockage des paramètres de compression | P2 | PA-17 | Non | Non | Non |
| OQ-07 | DateSoumission d'une inspection INACCESSIBLE | P3 | — | Non | Non | Non |
| OQ-08 | Indicateur VisibleParDefaut de SYS_001 | P3 | — | Non | Non | Non |
| OQ-09 | Lien formel des conditions composées (R130 + R131) | P3 | v0.2 | Non | Non | Non |
| OQ-10 | Condition structurée « vide ≠ 0 » pour R150 / R151 | P3 | v0.2 | Non | Non | Non |
| OQ-11 | Documents encore à compléter | P3 | — | Non | Non | Non |
| OQ-12 | Sort des réponses d'une question devenue masquée | P2 | Contenu de REPONSES et des exports | Non | Non | Non |

Aucune question ouverte de priorité P1.

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

---

# OQ-12 — Réponses d'une question devenue masquée

**Contexte** : une réponse peut être saisie sur une question affichée par une règle, puis la question
être masquée par un changement de réponse (ex. POT_004 passe d'AVANCEE à BON : POT_004_1 et POT_004_2_A/B/C
sont masquées). Le moteur de règles ignore les questions masquées (technical design § 5.3, § 5.4),
mais les documents de référence ne précisent pas si leur réponse est conservée ou effacée dans REPONSES.

**À décider** : conservation ou effacement de la réponse d'une question devenue masquée.

**Impact** : contenu de REPONSES, exports, App 2. Ne bloque pas le développement : le moteur fonctionne dans les deux cas.
