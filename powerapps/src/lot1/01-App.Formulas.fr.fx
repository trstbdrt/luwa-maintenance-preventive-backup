// LUWA Inspection Backup — Lot 1 — VERSION FRANÇAISE (séparateurs ; et ;;)
// À coller dans : App > propriété Formulas (formules nommées)

// Utilisateur courant au format attendu par une colonne Personne SharePoint (Patch)
nfPersonneCourante = {
    '@odata.type': "#Microsoft.Azure.Connectors.SharePoint.SPListExpandedUser";
    Claims: "i:0#.f|membership|" & Lower(User().Email);
    DisplayName: User().FullName;
    Email: User().Email;
    Department: "";
    JobTitle: "";
    Picture: ""
};;
