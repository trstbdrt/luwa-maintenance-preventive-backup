// LUWA Inspection Backup — Lot 3
// À coller dans : App > propriété OnStart (remplace intégralement la version du lot 1)
// Technical design : § 2 (variables globales), § 4 (collections)

// --- Variables globales -------------------------------------------------
Set(gblUtilisateur, {Email: User().Email, NomAffiche: User().FullName});
Set(gblTypeInspection, "");
Set(gblNomOuvrage, "");
Set(gblInspectionGUID, "");
Set(gblInspectionID, "");
Set(gblInspection, Blank());
Set(gblInspectionConsultee, Blank());
Set(gblEcranRetourHistorique, Screen_Home);
Set(gblRepriseLocale, false);
Set(gblSoumissionBloquee, false);
Set(gblResteObligatoires, 0);
Set(gblResteCommentaires, 0);
Set(gblRestePhotos, 0);
Set(gblQuestionCible, "");
Set(gblInspectionChargee, "");
Set(gblClesAffichees, "");

// --- Catalogues (lus une fois, choix convertis en texte) -----------------
ClearCollect(
    colQuestions,
    ForAll(
        QUESTIONS,
        {
            QuestionCode: QuestionCode,
            QuestionParent: QuestionParent,
            DisplayGroup: DisplayGroup.Value,
            Formulaire: Formulaire.Value,
            OrdreAffichage: OrdreAffichage,
            Libelle: Libelle,
            TypeQuestion: TypeQuestion.Value,
            Obligatoire: Obligatoire,
            CommentaireAutorise: CommentaireAutorise,
            CommentaireObligatoire: CommentaireObligatoire,
            PhotoAutorisee: PhotoAutorisee,
            NbPhotosMin: NbPhotosMin,
            NbPhotosMax: NbPhotosMax,
            VisibleParDefaut: VisibleParDefaut,
            ValeursPossibles: ValeursPossibles,
            FormuleCalcul: FormuleCalcul,
            LibellesValeurs: LibellesValeurs
        }
    )
);

ClearCollect(
    colRegles,
    ForAll(
        Sort(Filter(REGLES_FORMULAIRE, Actif = true), Priorite, SortOrder.Ascending),
        {
            RuleID: RuleID,
            Priorite: Priorite,
            Formulaire: Formulaire.Value,
            QuestionSource: QuestionSource,
            ConditionType: ConditionType.Value,
            ConditionValeur: ConditionValeur,
            Action: Action.Value,
            QuestionCible: QuestionCible,
            Parametre: Parametre,
            Commentaire: Commentaire
        }
    )
);

// --- Collections de lecture (structure) ----------------------------------
ClearCollect(colInspectionsAReprendre, FirstN(INSPECTIONS, 0));
ClearCollect(colHistoriqueOuvrage, FirstN(INSPECTIONS, 0));
ClearCollect(colHistorique, FirstN(INSPECTIONS, 0));
ClearCollect(colReponsesConsultees, FirstN(REPONSES, 0));
ClearCollect(colPhotosConsultees, FirstN(PHOTOS_INSPECTIONS, 0));

// --- Collections de saisie (structure) — lot 2 ---------------------------
// colReponses : copie de travail des réponses de l'inspection en cours (TD § 4.7)
ClearCollect(
    colReponses,
    {
        ReponseID: "",
        QuestionCode: "",
        Valeur: "",
        ValeurNumerique: 0,
        Commentaire: "",
        SharePointID: 0,
        EtatSynchro: ""
    }
);
Clear(colReponses);
ClearCollect(colReponsesLocales, colReponses);
ClearCollect(colContexteLocal, {InspectionGUID: "", InspectionID: "", TypeInspection: "", NomOuvrage: ""});
Clear(colContexteLocal);
// colPhotos : photos de l'inspection en cours ; Source = image en data URI (prise) ou miniature SharePoint (envoyée)
ClearCollect(
    colPhotos,
    {PhotoLocaleID: "", QuestionCode: "", Source: "", NomFichier: "", DatePhoto: Now(), EtatSynchro: ""}
);
Clear(colPhotos);
ClearCollect(colPhotosLocales, colPhotos);
