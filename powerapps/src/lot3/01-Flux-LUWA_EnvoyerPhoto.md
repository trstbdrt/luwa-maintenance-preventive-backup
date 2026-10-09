# Flux PAU-06 — LUWA_EnvoyerPhoto

Rôle : recevoir une photo depuis l'application et la déposer dans `PHOTOS_INSPECTIONS/{InspectionGUID}/`
avec ses métadonnées (DEC-15, technical design § 6.6).

À créer **dans la solution « LUWA Maintenance Backup »**, avant de coller les écrans du lot 3
(l'application appelle le flux par son nom : `LUWA_EnvoyerPhoto`).

---

## 1. Création

1. make.powerapps.com > **Solutions** > « LUWA Maintenance Backup » > **+ New** > **Automation** > **Cloud flow** > **Instant**.
2. Nom du flux : `LUWA_EnvoyerPhoto` (exactement, sans espace).
3. Déclencheur : **Power Apps (V2)** > **Create**.

## 2. Déclencheur — 8 entrées de type **Text**, dans cet ordre

L'ordre compte : l'application transmet les valeurs dans cet ordre.

| # | Nom de l'entrée | Contenu envoyé par l'application |
|------|------|------|
| 1 | `InspectionGUID` | GUID de l'inspection |
| 2 | `QuestionCode` | Code de la question (ex. POT_010, SYS_001) |
| 3 | `NomOuvrage` | Nom de l'ouvrage |
| 4 | `NomFichier` | Nom du fichier (ex. `POT_010_20261009_141522_3f2a.jpg`) |
| 5 | `DatePhoto` | Date de prise, ISO UTC (ex. `2026-10-09T12:15:22Z`) |
| 6 | `CompressionVersion` | `COMPRESSEE` |
| 7 | `ContenuDataUri` | Image en `data:image/jpeg;base64,…` |
| 8 | `AuteurEmail` | E-mail de l'utilisateur |

Pour chaque entrée : **+ Add an input** > **Text** > saisir le nom.

## 3. Action « Create file » (SharePoint)

**+ New step** > SharePoint > **Create file** :

| Champ | Valeur |
|------|------|
| Site Address | `https://wavenetbe.sharepoint.com/sites/LuwaMaintenancePreventiveBackup` (ou la variable d'environnement du site si proposée) |
| Folder Path | `/PHOTOS_INSPECTIONS/` puis le contenu dynamique **InspectionGUID** (résultat : `/PHOTOS_INSPECTIONS/<InspectionGUID>`) |
| File Name | contenu dynamique **NomFichier** |
| File Content | Expression : `dataUriToBinary(triggerBody()?['text_6'])` |

Pour **File Content** : onglet **Expression**, coller la formule.
⚠ `text_6` correspond à la 7ᵉ entrée (`ContenuDataUri`) : les entrées texte sont nommées `text`, `text_1`, `text_2`…
Si l'expression est refusée, la remplacer par : choisir **ContenuDataUri** dans le contenu dynamique,
puis entourer de `dataUriToBinary( … )` dans l'onglet Expression.

Le dossier `<InspectionGUID>` est créé automatiquement s'il n'existe pas.

## 4. Action « Update file properties » (SharePoint)

**+ New step** > SharePoint > **Update file properties** :

| Champ | Valeur |
|------|------|
| Site Address | même site |
| Library Name | `PHOTOS_INSPECTIONS` |
| Id | contenu dynamique **ItemId** (de « Create file ») |
| InspectionGUID | **InspectionGUID** (déclencheur) |
| QuestionCode | **QuestionCode** |
| NomOuvrage | **NomOuvrage** |
| Auteur Claims | **AuteurEmail** |
| DatePhoto | **DatePhoto** |
| CompressionVersion Value | **CompressionVersion** |

## 5. Action « Respond to a PowerApp or flow »

**+ New step** > **Respond to a PowerApp or flow** > **+ Add an output** > **Text** :

| Nom | Valeur |
|------|------|
| `resultat` | `OK` |

## 6. Enregistrer et relier à l'application

1. **Save**, puis **Test** > Manually est inutile (les entrées viennent de l'application).
2. Dans Power Apps Studio : panneau **Power Automate** (icône éclair à gauche) > **Add flow** > `LUWA_EnvoyerPhoto`.
3. L'application l'appelle avec : `LUWA_EnvoyerPhoto.Run(InspectionGUID, QuestionCode, NomOuvrage, NomFichier, DatePhoto, CompressionVersion, ContenuDataUri, AuteurEmail)`.

## Points d'attention

- **Connexion** : le flux utilise la connexion SharePoint de son propriétaire. Les métadonnées `Auteur` indiquent bien le technicien (entrée 8).
- **Échec d'envoi** : l'application garde la photo « À envoyer » et la renvoie au prochain enregistrement.
- **Aucune suppression** : le flux ne fait que créer des fichiers.
