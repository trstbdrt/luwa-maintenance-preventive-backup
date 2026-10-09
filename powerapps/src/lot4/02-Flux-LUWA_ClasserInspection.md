# Flux PAU-07 — LUWA_ClasserInspection

Rôle : quand une inspection est soumise (TERMINE) ou déclarée inaccessible (INACCESSIBLE), ranger ses fichiers dans un
dossier lisible par ouvrage, côté serveur, sans rien faire attendre à la tablette (DEC-29) :

```
PHOTOS_INSPECTIONS/
  E100 511/                                   ← poteau
    2026-10-09 POTEAU TMP-f0041151/
      Rapport E100 511 2026-10-09 POTEAU TMP-f0041151.pdf
      Reponses E100 511 2026-10-09 POTEAU TMP-f0041151.csv
      POT_001_20261009_145215_ab12.png …
    E100 511-1/                               ← luminaire, rangé dans le dossier du poteau
      2026-10-09 LUMINAIRE TMP-…/
  _EN_COURS/                                  ← photos des inspections non soumises
```

Le rapport et le CSV sont produits par l'application à la soumission (colonnes `RapportHTML` et `RapportCSV`
d'INSPECTIONS). Le flux se contente de créer les fichiers, de déplacer les photos et de noter le chemin (`CheminDossier`).

Connecteurs : SharePoint et OneDrive for Business (standard, pas de licence premium).
Le compte qui crée le flux doit avoir un OneDrive (fichier HTML temporaire pour la conversion en PDF).

---

## 1. Création

1. make.powerapps.com > **Solutions** > « LUWA Maintenance Backup » > **+ New** > **Automation** > **Cloud flow** > **Automated**.
2. Nom : `LUWA_ClasserInspection`.
3. Déclencheur : SharePoint **When an item is created or modified**.
   - Site Address : `https://wavenetbe.sharepoint.com/sites/LuwaMaintenancePreventiveBackup`
   - List Name : `INSPECTIONS`
4. Déclencheur > **…** > **Settings** > **Trigger conditions** > **+ Add**, coller :

```
@and(or(equals(triggerOutputs()?['body/StatutInspection/Value'],'TERMINE'),equals(triggerOutputs()?['body/StatutInspection/Value'],'INACCESSIBLE')),empty(triggerOutputs()?['body/CheminDossier']))
```

Le flux ne démarre que pour une inspection soumise ou inaccessible **pas encore rangée**. Les enregistrements de
brouillon ne le déclenchent pas, et la mise à jour finale de `CheminDossier` ne le relance pas.

## 2. Noms de dossier — 3 actions **Compose** (Data Operation > Compose)

Renommer chaque action exactement comme indiqué (… > **Rename**) : les expressions suivantes y font référence.
Pour chaque **Inputs** : onglet **Expression**, coller la formule.

**`DossierOuvrage`** — le luminaire `E100 511-1` est rangé dans `E100 511/E100 511-1` :
```
if(and(equals(triggerBody()?['TypeInspection']?['Value'],'LUMINAIRE'),greater(lastIndexOf(triggerBody()?['NomOuvrage'],'-'),0)),concat(substring(triggerBody()?['NomOuvrage'],0,lastIndexOf(triggerBody()?['NomOuvrage'],'-')),'/',triggerBody()?['NomOuvrage']),triggerBody()?['NomOuvrage'])
```

**`NomInspection`** — date (heure belge), type, identifiant :
```
concat(convertFromUtc(coalesce(triggerBody()?['DateSoumission'],triggerBody()?['Modified']),'Romance Standard Time','yyyy-MM-dd'),' ',triggerBody()?['TypeInspection']?['Value'],' ',triggerBody()?['InspectionID'])
```

**`DossierRelatif`** :
```
concat(outputs('DossierOuvrage'),'/',outputs('NomInspection'))
```

## 3. SharePoint **Create new folder**

| Champ | Valeur |
|------|------|
| Site Address | même site |
| List or Library | `PHOTOS_INSPECTIONS` |
| Folder Path | Expression : `outputs('DossierRelatif')` |

Les dossiers manquants (ouvrage, poteau parent) sont créés en même temps.

## 4. SharePoint **Get files (properties only)** — renommer en `PhotosInspection`

| Champ | Valeur |
|------|------|
| Site Address | même site |
| Library Name | `PHOTOS_INSPECTIONS` |
| Filter Query | `InspectionGUID eq '` + contenu dynamique **InspectionGUID** (du déclencheur) + `'` |

(Paramètres avancés : **Include Nested Items** = Yes, valeur par défaut.)

## 5. **Apply to each** sur `value` de `PhotosInspection`, contenant SharePoint **Move file**

| Champ | Valeur |
|------|------|
| Current Site Address | même site |
| File to Move | Expression : `items('Apply_to_each')?['{Identifier}']` |
| Destination Site Address | même site |
| Destination Folder | Expression : `concat('/PHOTOS_INSPECTIONS/',outputs('DossierRelatif'))` |
| If another file is already there | **Fail this action** |

Déplacement dans la même bibliothèque : pas de copie, les métadonnées (InspectionGUID, QuestionCode…) sont conservées et
l'historique de l'application retrouve toujours les photos.

## 6. Rapport PDF

**6a. OneDrive for Business > Create file** — renommer en `HtmlTemporaire` :

| Champ | Valeur |
|------|------|
| Folder Path | `/` (racine du OneDrive ; le fichier est supprimé à l'étape 6d) |
| File Name | Expression : `concat(triggerBody()?['InspectionGUID'],'.html')` |
| File Content | Expression : `coalesce(triggerBody()?['RapportHTML'],concat('<html><head><meta charset="utf-8"></head><body><h1>',triggerBody()?['NomOuvrage'],'</h1><p>Rapport non disponible (inspection antérieure au lot 4).</p></body></html>'))` |

**6b. OneDrive for Business > Convert file (preview)** — renommer en `ConversionPDF` :
File = **Id** de `HtmlTemporaire`, Target type = **PDF**.

**6c. SharePoint > Create file** :

| Champ | Valeur |
|------|------|
| Folder Path | Expression : `concat('/PHOTOS_INSPECTIONS/',outputs('DossierRelatif'))` |
| File Name | Expression : `concat('Rapport ',triggerBody()?['NomOuvrage'],' ',outputs('NomInspection'),'.pdf')` |
| File Content | contenu dynamique **File content** de `ConversionPDF` |

**6d. OneDrive for Business > Delete file** : File = **Id** de `HtmlTemporaire`.

## 7. SharePoint **Create file** — réponses CSV

| Champ | Valeur |
|------|------|
| Folder Path | Expression : `concat('/PHOTOS_INSPECTIONS/',outputs('DossierRelatif'))` |
| File Name | Expression : `concat('Reponses ',triggerBody()?['NomOuvrage'],' ',outputs('NomInspection'),'.csv')` |
| File Content | Expression : `concat(decodeUriComponent('%EF%BB%BF'),coalesce(triggerBody()?['RapportCSV'],''))` |

Le préfixe `%EF%BB%BF` (BOM UTF-8) permet à Excel d'afficher correctement les accents ; séparateur `;`.

## 8. Suppression du dossier d'origine vide — **Condition**

Condition : expression `length(body('PhotosInspection')?['value'])` **is greater than** `0`.

Branche **If yes** : SharePoint **Send an HTTP request to SharePoint** :

| Champ | Valeur |
|------|------|
| Site Address | même site |
| Method | `POST` |
| Uri | Expression : `concat('_api/web/GetFolderByServerRelativeUrl(''/sites/LuwaMaintenancePreventiveBackup/',first(body('PhotosInspection')?['value'])?['{Path}'],''')')` |

(`{Path}` = dossier d'origine de la première photo, ex. `PHOTOS_INSPECTIONS/_EN_COURS/<GUID>/` — nom sans espace.)
| Headers | `X-HTTP-Method` : `DELETE` — `IF-MATCH` : `*` |

Branche **If no** : rien (inspection sans photo).

## 9. Chemin du dossier — SharePoint **Send an HTTP request to SharePoint**

Après la condition (au même niveau) :

| Champ | Valeur |
|------|------|
| Method | `POST` |
| Uri | Expression : `concat('_api/web/lists/getbytitle(''INSPECTIONS'')/items(',triggerBody()?['ID'],')/validateUpdateListItem')` |
| Headers | `Accept` : `application/json;odata=nometadata` — `Content-Type` : `application/json;odata=nometadata` |
| Body | Expression : `concat('{"formValues":[{"FieldName":"CheminDossier","FieldValue":"PHOTOS_INSPECTIONS/',outputs('DossierRelatif'),'"}],"bNewDocumentUpdate":true}')` |

## 10. Test

1. Save.
2. Dans l'app : soumettre une inspection (ex. `E900 001` avec 1 ou 2 photos).
3. Power Automate > LUWA_ClasserInspection > **Run history** : exécution réussie (vert) en moins d'une minute.
4. SharePoint > **Dossiers ouvrages** (menu de gauche) > `E900 001` > dossier de l'inspection : PDF, CSV et photos ;
   `_EN_COURS` ne contient plus le dossier GUID de cette inspection.
5. INSPECTIONS : la colonne `CheminDossier` est remplie.

En cas d'échec, le **Run history** indique l'action fautive : envoyer une capture.
