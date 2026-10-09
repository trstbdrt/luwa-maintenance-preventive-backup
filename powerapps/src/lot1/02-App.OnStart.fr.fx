// LUWA Inspection Backup — Lot 1 — VERSION FRANÇAISE (séparateurs ; et ;;)
// À coller dans : App > propriété OnStart
// Technical design : § 2 (variables globales), § 4 (collections)

// --- Variables globales -------------------------------------------------
Set(gblUtilisateur; {Email: User().Email; NomAffiche: User().FullName});;
Set(gblTypeInspection; "");;
Set(gblNomOuvrage; "");;
Set(gblInspectionGUID; "");;
Set(gblInspectionID; "");;
Set(gblInspection; Blank());;
Set(gblInspectionConsultee; Blank());;
Set(gblEcranRetourHistorique; Screen_Home);;

// --- Catalogues (lus une fois, choix convertis en texte) -----------------
ClearCollect(
    colQuestions;
    ForAll(
        QUESTIONS;
        {
            QuestionCode: QuestionCode;
            QuestionParent: QuestionParent;
            DisplayGroup: DisplayGroup.Value;
            Formulaire: Formulaire.Value;
            OrdreAffichage: OrdreAffichage;
            Libelle: Libelle;
            TypeQuestion: TypeQuestion.Value;
            Obligatoire: Obligatoire;
            CommentaireAutorise: CommentaireAutorise;
            CommentaireObligatoire: CommentaireObligatoire;
            PhotoAutorisee: PhotoAutorisee;
            NbPhotosMin: NbPhotosMin;
            NbPhotosMax: NbPhotosMax;
            VisibleParDefaut: VisibleParDefaut;
            ValeursPossibles: ValeursPossibles;
            FormuleCalcul: FormuleCalcul
        }
    )
);;

ClearCollect(
    colRegles;
    ForAll(
        Sort(Filter(REGLES_FORMULAIRE; Actif = true); Priorite; SortOrder.Ascending);
        {
            RuleID: RuleID;
            Priorite: Priorite;
            Formulaire: Formulaire.Value;
            QuestionSource: QuestionSource;
            ConditionType: ConditionType.Value;
            ConditionValeur: ConditionValeur;
            Action: Action.Value;
            QuestionCible: QuestionCible;
            Parametre: Parametre;
            Commentaire: Commentaire
        }
    )
);;

// --- Collections vides (déclaration de leur structure) -------------------
ClearCollect(colInspectionsAReprendre; FirstN(INSPECTIONS; 0));;
ClearCollect(colHistoriqueOuvrage; FirstN(INSPECTIONS; 0));;
ClearCollect(colHistorique; FirstN(INSPECTIONS; 0));;
ClearCollect(colReponsesConsultees; FirstN(REPONSES; 0));;
ClearCollect(colPhotosConsultees; FirstN(PHOTOS_INSPECTIONS; 0));;
