# Flux PAU-01 — LUWA_Export

Rôle : export structuré des inspections soumises sur une période, lancé à la demande (DEC-30).
Relançable à volonté, par toute personne autorisée à exécuter le flux ; chaque lancement crée son propre dossier.

```
05_Exports/
  Export 2026-10-01 au 2026-10-09 - 2026-10-09 17h05/
    Inspections.csv   1 ligne par inspection
    Reponses.csv      1 ligne par question (codes + libellés), copie du CSV figé à la soumission
    Photos.csv        index photo ↔ inspection ↔ question ↔ chemin
    Photos/           (option) copie des photos : <ouvrage>_<fichier>.png
```

ZIP : dans SharePoint, sélectionner le dossier de l'export > **Télécharger** (SharePoint compresse).
CSV : séparateur `;`, UTF-8 avec BOM (accents corrects dans Excel).

Périmètre : statuts TERMINE, INACCESSIBLE, ARCHIVE ; `DateSoumission` comprise entre les deux dates (heure belge).
Les inspections soumises avant le lot 4 n'ont pas de `RapportCSV` : présentes dans Inspections.csv, absentes de Reponses.csv.
Photos : prises au plus 60 jours avant le début de la période (au-delà, ajuster l'étape 11).

Toutes les actions SharePoint utilisent les **variables d'environnement** (⌄ > Enter custom value > Environment variables) :
Site Address = **LUWA Site SharePoint**, liste = **INSPECTIONS**, bibliothèque = **PHOTOS_INSPECTIONS**.

Notation : `CRLF` = `decodeUriComponent('%0D%0A')` ; `BOM` = `decodeUriComponent('%EF%BB%BF')` (déjà écrits en entier dans les formules).

---

## 1. Création

Solutions > LUWA Maintenance Backup > **+ New** > **Automation** > **Cloud flow** > **Instant** ;
nom `LUWA_Export` ; déclencheur **Manually trigger a flow**.

Entrées, dans cet ordre (**+ Add an input**) :

| # | Type | Nom |
|---|---|---|
| 1 | Date | `DateDebut` |
| 2 | Date | `DateFin` |
| 3 | Yes/No | `InclurePhotos` |

(Noms internes utilisés dans les formules : `date`, `date_1`, `boolean`.)

## 2–4. Trois **Compose** (renommer exactement)

| Nom | Inputs (onglet Expression) |
|---|---|
| `Debut` | `convertToUtc(concat(triggerBody()?['date'],'T00:00:00'),'Romance Standard Time','yyyy-MM-ddTHH:mm:ssZ')` |
| `Fin` | `convertToUtc(concat(triggerBody()?['date_1'],'T23:59:59'),'Romance Standard Time','yyyy-MM-ddTHH:mm:ssZ')` |
| `DossierExport` | `concat('/05_Exports/Export ',triggerBody()?['date'],' au ',triggerBody()?['date_1'],' - ',convertFromUtc(utcNow(),'Romance Standard Time','yyyy-MM-dd HH''h''mm'))` |

## 5. SharePoint **Get items** — renommer `InspectionsExport`

| Champ | Valeur |
|---|---|
| Site Address | **LUWA Site SharePoint** |
| List Name | **INSPECTIONS** |
| Filter Query | Expression : `concat('DateSoumission ge ''',outputs('Debut'),''' and DateSoumission le ''',outputs('Fin'),''' and (StatutInspection eq ''TERMINE'' or StatutInspection eq ''INACCESSIBLE'' or StatutInspection eq ''ARCHIVE'')')` |
| Order By | `DateSoumission` |
| Top Count | `5000` |

**…** > **Settings** > **Pagination** : On, Threshold `100000` > Done.

## 6. **Select** (Data Operation) — renommer `LignesInspections`

From : Expression `body('InspectionsExport')?['value']`.
Map : cliquer sur l'icône **Switch Map to text mode** (à droite de Map), puis Expression :

```
concat('"',item()?['InspectionID'],'";"',item()?['InspectionGUID'],'";"',replace(coalesce(item()?['NomOuvrage'],''),'"','""'),'";"',coalesce(item()?['CleOuvrage'],''),'";"',item()?['TypeInspection']?['Value'],'";"',item()?['StatutInspection']?['Value'],'";"',replace(coalesce(item()?['Inspecteur']?['DisplayName'],''),'"','""'),'";"',coalesce(item()?['Inspecteur']?['Email'],''),'";"',if(empty(item()?['DateCreation']),'',convertFromUtc(item()?['DateCreation'],'Romance Standard Time','dd/MM/yyyy HH:mm')),'";"',if(empty(item()?['DateSoumission']),'',convertFromUtc(item()?['DateSoumission'],'Romance Standard Time','dd/MM/yyyy HH:mm')),'";"',if(empty(item()?['GPSLatitude']),'',string(item()?['GPSLatitude'])),'";"',if(empty(item()?['GPSLongitude']),'',string(item()?['GPSLongitude'])),'";"',coalesce(item()?['InspectionPrecedenteGUID'],''),'";"',coalesce(item()?['CheminDossier'],''),'"')
```

## 7. SharePoint **Create file** — Inspections.csv

| Champ | Valeur |
|---|---|
| Site Address | **LUWA Site SharePoint** |
| Folder Path | Expression : `outputs('DossierExport')` |
| File Name | `Inspections.csv` |
| File Content | Expression : `concat(decodeUriComponent('%EF%BB%BF'),'InspectionID;InspectionGUID;Ouvrage;CleOuvrage;Type;Statut;Inspecteur;InspecteurEmail;DateCreation;DateSoumission;GPSLatitude;GPSLongitude;InspectionPrecedenteGUID;Dossier',decodeUriComponent('%0D%0A'),join(body('LignesInspections'),decodeUriComponent('%0D%0A')))` |

## 8. **Filter array** — renommer `AvecReponses`

From : Expression `body('InspectionsExport')?['value']`.
Condition : **Edit in advanced mode**, coller :
```
@not(empty(item()?['RapportCSV']))
```

## 9. **Select** — renommer `LignesReponses`

From : Expression `body('AvecReponses')`. Map en mode texte, Expression (le CSV de chaque inspection sans sa ligne d'en-tête) :
```
substring(item()?['RapportCSV'],add(indexOf(item()?['RapportCSV'],decodeUriComponent('%0A')),1))
```

## 10. SharePoint **Create file** — Reponses.csv

| Champ | Valeur |
|---|---|
| Site Address | **LUWA Site SharePoint** |
| Folder Path | Expression : `outputs('DossierExport')` |
| File Name | `Reponses.csv` |
| File Content | Expression : `concat(decodeUriComponent('%EF%BB%BF'),'InspectionID;Ouvrage;Type;Ordre;Groupe;QuestionCode;Question;ValeurCode;Reponse;Commentaire;NbPhotos',decodeUriComponent('%0D%0A'),join(body('LignesReponses'),decodeUriComponent('%0D%0A')))` |

## 11. Photos de la période

**11a. Select** — renommer `GUIDs` : From `body('InspectionsExport')?['value']` ; Map en mode texte : `item()?['InspectionGUID']`.

**11b. Compose** — renommer `ListeGUID` : `join(body('GUIDs'),';')`.

**11c. SharePoint Get files (properties only)** — renommer `PhotosPeriode` :

| Champ | Valeur |
|---|---|
| Site Address | **LUWA Site SharePoint** |
| Library Name | **PHOTOS_INSPECTIONS** |
| Filter Query | Expression : `concat('DatePhoto ge ''',addDays(outputs('Debut'),-60,'yyyy-MM-ddTHH:mm:ssZ'),''' and DatePhoto le ''',outputs('Fin'),'''')` |

Settings > Pagination : On, `100000`.

**11d. Filter array** — renommer `PhotosExport` : From `body('PhotosPeriode')?['value']` ; advanced mode :
```
@and(not(empty(item()?['InspectionGUID'])),contains(outputs('ListeGUID'),item()?['InspectionGUID']))
```

## 12. **Select** — renommer `LignesPhotos`

From `body('PhotosExport')` ; Map en mode texte :
```
concat('"',item()?['InspectionGUID'],'";"',replace(coalesce(item()?['NomOuvrage'],''),'"','""'),'";"',item()?['QuestionCode'],'";"',item()?['{FilenameWithExtension}'],'";"',if(empty(item()?['DatePhoto']),'',convertFromUtc(item()?['DatePhoto'],'Romance Standard Time','dd/MM/yyyy HH:mm')),'";"',item()?['{Path}'],item()?['{FilenameWithExtension}'],'";"',if(equals(triggerBody()?['boolean'],true),concat('Photos/',item()?['NomOuvrage'],'_',item()?['{FilenameWithExtension}']),''),'"')
```

## 13. SharePoint **Create file** — Photos.csv

| Champ | Valeur |
|---|---|
| Folder Path | Expression : `outputs('DossierExport')` |
| File Name | `Photos.csv` |
| File Content | Expression : `concat(decodeUriComponent('%EF%BB%BF'),'InspectionGUID;Ouvrage;QuestionCode;Fichier;DatePhoto;CheminSharePoint;FichierExport',decodeUriComponent('%0D%0A'),join(body('LignesPhotos'),decodeUriComponent('%0D%0A')))` |

(Site Address : **LUWA Site SharePoint**.)

## 14. **Condition** — copie des photos (option)

Gauche : Expression `triggerBody()?['boolean']` ; **is equal to** ; droite : Expression `true`.

Branche **If yes** : **Apply to each** sur Expression `body('PhotosExport')` (ne pas renommer la boucle) ; dedans :

1. SharePoint **Get file content** — renommer `ContenuPhoto` : Site Address **LUWA Site SharePoint** ;
   File Identifier : Expression `items('Apply_to_each')?['{Identifier}']`.
2. SharePoint **Create file** : Site Address **LUWA Site SharePoint** ;
   Folder Path : Expression `concat(outputs('DossierExport'),'/Photos')` ;
   File Name : Expression `concat(items('Apply_to_each')?['NomOuvrage'],'_',items('Apply_to_each')?['{FilenameWithExtension}'])` ;
   File Content : Dynamic content **File Content** (de ContenuPhoto).

Boucle > **…** > **Settings** > **Concurrency control** : On, degré `10` (copie plus rapide).

Branche **If no** : rien.

## 15. Test

1. Save. En haut : **Test** > Manually > **Run flow** : DateDebut = `2026-10-09`, DateFin = `2026-10-09`, InclurePhotos = Yes.
2. Run history : succès.
3. SharePoint > **05_Exports** > dossier de l'export : 3 CSV + Photos/ ; ouvrir les CSV dans Excel ; sélectionner le dossier > **Télécharger** (ZIP).

## Exécution par d'autres personnes

Détails du flux > **Run only users** > **Edit** : ajouter la personne ; pour chaque connexion, choisir
**Use this connection** (la connexion du propriétaire). La personne lance le flux depuis Power Automate
(Mes flux > Partagés avec moi) ou l'application mobile Power Automate (onglet Boutons).
