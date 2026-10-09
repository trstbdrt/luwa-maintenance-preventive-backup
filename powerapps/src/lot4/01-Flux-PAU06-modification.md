# Flux PAU-06 `LUWA_EnvoyerPhoto` — modification du lot 4

Les photos d'une inspection en cours sont désormais déposées dans `PHOTOS_INSPECTIONS/_EN_COURS/<InspectionGUID>/`.
À la soumission, le flux PAU-07 les déplace dans le dossier de l'ouvrage (DEC-29).

## Seule modification

Action **Create file** (SharePoint) > champ **Folder Path** :

| Avant | Après |
|------|------|
| `/PHOTOS_INSPECTIONS/` + **InspectionGUID** | `/PHOTOS_INSPECTIONS/_EN_COURS/` + **InspectionGUID** |

Le dossier `_EN_COURS` est créé automatiquement au premier envoi. Rien d'autre ne change (entrées, propriétés, réponse).

Save. L'application n'a pas besoin d'être modifiée pour ce changement.

## Portabilité (variables d'environnement)

- Create file > Site Address : **LUWA Site SharePoint** (⌄ > Enter custom value > Environment variables).
- Update file properties > Site Address : **LUWA Site SharePoint** ; Library Name : **PHOTOS_INSPECTIONS**.

La variable du site a été renommée « LUWA Site SharePoint » (nom technique `devwvn_shared_sharepointonline_f493…`, inchangé).
