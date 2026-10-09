// LUWA Inspection Backup — Lot 2
// À coller dans : Screen_Inspection > btnInspEvaluer > propriété OnSelect
// Moteur de règles en une seule formule (TD § 5.3) — pas de Select entre boutons (cycle interdit par Power Apps)
// Étape 2 : calculs. Format pris en charge : ((A-B)/C)*100 avec A, B, C des codes de questions
ForAll(
    Filter(colQuestionsFormulaire, TypeQuestion = "CALCUL") As wQ,
    With(
        {wM: Match(wQ.FormuleCalcul, "^\(\((?<a>[A-Z0-9_]+)-(?<b>[A-Z0-9_]+)\)/(?<c>[A-Z0-9_]+)\)\*100$")},
        With(
            {
                wA: LookUp(colReponses, QuestionCode = wM.a).ValeurNumerique,
                wB: LookUp(colReponses, QuestionCode = wM.b).ValeurNumerique,
                wC: LookUp(colReponses, QuestionCode = wM.c).ValeurNumerique,
                wEx: LookUp(colReponses, QuestionCode = wQ.QuestionCode)
            },
            With(
                {wRes: If(IsBlank(wA) || IsBlank(wB) || IsBlank(wC) || wC = 0, Blank(), (wA - wB) / wC * 100)},
                If(
                    IsBlank(wEx),
                    If(
                        !IsBlank(wRes),
                        Collect(colReponses, {ReponseID: Text(GUID()), QuestionCode: wQ.QuestionCode, Valeur: Blank(), ValeurNumerique: wRes, Commentaire: Blank(), SharePointID: Blank(), EtatSynchro: "NOUVELLE"})
                    ),
                    If(
                        IsBlank(wEx.ValeurNumerique) <> IsBlank(wRes) || wEx.ValeurNumerique <> wRes,
                        Patch(colReponses, wEx, {ValeurNumerique: wRes, EtatSynchro: If(wEx.EtatSynchro = "NOUVELLE", "NOUVELLE", "MODIFIEE")})
                    )
                )
            )
        )
    )
);
ClearCollect(colEtatQuestions, ForAll(colQuestionsFormulaire, {QuestionCode: QuestionCode, Visible: VisibleParDefaut}));
// Étape 3 — passe 1/3 : conditions (source masquée ou vide = fausse), puis visibilité
ClearCollect(
    colReglesEval,
    AddColumns(
        colReglesFormulaire,
        Vraie,
        With(
            {
                wVis: Coalesce(LookUp(colEtatQuestions, QuestionCode = QuestionSource).Visible, false),
                wRep: LookUp(colReponses, QuestionCode = QuestionSource)
            },
            Switch(
                ConditionType,
                "EQUALS",
                wVis && If(
                    !IsBlank(wRep.ValeurNumerique),
                    wRep.ValeurNumerique = Value(ConditionValeur),
                    !IsBlank(wRep.Valeur) && wRep.Valeur = ConditionValeur
                ),
                "GREATER_OR_EQUAL",
                wVis && !IsBlank(wRep.ValeurNumerique) && wRep.ValeurNumerique >= Value(ConditionValeur),
                "LESS_THAN",
                wVis && !IsBlank(wRep.ValeurNumerique) && wRep.ValeurNumerique < Value(ConditionValeur),
                "VISIBLE",
                wVis = (Upper(ConditionValeur) = "TRUE"),
                false
            )
        )
    )
);
With(
    {
        wMasque: !IsEmpty(Filter(colReglesEval, Vraie && Action = "MASQUER_FORMULAIRE")),
        wSourceMasque: LookUp(colReglesEval, Vraie && Action = "MASQUER_FORMULAIRE").QuestionSource
    },
    ClearCollect(
        colEtatQuestions,
        ForAll(
            colQuestionsFormulaire As wQ,
            {
                QuestionCode: wQ.QuestionCode,
                Visible: If(
                    wMasque && wQ.QuestionCode <> wSourceMasque,
                    false,
                    wQ.VisibleParDefaut
                        || !IsEmpty(Filter(colReglesEval, Vraie && Action = "AFFICHER" && QuestionCible = wQ.QuestionCode))
                        || (
                            !IsEmpty(Filter(colReglesEval, Vraie && Action = "AFFICHER_IF_MATCH" && QuestionCible = wQ.QuestionCode))
                            && !IsEmpty(Filter(colReglesEval, Vraie && Action = "WAITING_SECOND_CONDITION" && QuestionCible = wQ.QuestionCode))
                        )
                )
            }
        )
    )
);
// Étape 3 — passe 2/3 : conditions (source masquée ou vide = fausse), puis visibilité
ClearCollect(
    colReglesEval,
    AddColumns(
        colReglesFormulaire,
        Vraie,
        With(
            {
                wVis: Coalesce(LookUp(colEtatQuestions, QuestionCode = QuestionSource).Visible, false),
                wRep: LookUp(colReponses, QuestionCode = QuestionSource)
            },
            Switch(
                ConditionType,
                "EQUALS",
                wVis && If(
                    !IsBlank(wRep.ValeurNumerique),
                    wRep.ValeurNumerique = Value(ConditionValeur),
                    !IsBlank(wRep.Valeur) && wRep.Valeur = ConditionValeur
                ),
                "GREATER_OR_EQUAL",
                wVis && !IsBlank(wRep.ValeurNumerique) && wRep.ValeurNumerique >= Value(ConditionValeur),
                "LESS_THAN",
                wVis && !IsBlank(wRep.ValeurNumerique) && wRep.ValeurNumerique < Value(ConditionValeur),
                "VISIBLE",
                wVis = (Upper(ConditionValeur) = "TRUE"),
                false
            )
        )
    )
);
With(
    {
        wMasque: !IsEmpty(Filter(colReglesEval, Vraie && Action = "MASQUER_FORMULAIRE")),
        wSourceMasque: LookUp(colReglesEval, Vraie && Action = "MASQUER_FORMULAIRE").QuestionSource
    },
    ClearCollect(
        colEtatQuestions,
        ForAll(
            colQuestionsFormulaire As wQ,
            {
                QuestionCode: wQ.QuestionCode,
                Visible: If(
                    wMasque && wQ.QuestionCode <> wSourceMasque,
                    false,
                    wQ.VisibleParDefaut
                        || !IsEmpty(Filter(colReglesEval, Vraie && Action = "AFFICHER" && QuestionCible = wQ.QuestionCode))
                        || (
                            !IsEmpty(Filter(colReglesEval, Vraie && Action = "AFFICHER_IF_MATCH" && QuestionCible = wQ.QuestionCode))
                            && !IsEmpty(Filter(colReglesEval, Vraie && Action = "WAITING_SECOND_CONDITION" && QuestionCible = wQ.QuestionCode))
                        )
                )
            }
        )
    )
);
// Étape 3 — passe 3/3 : conditions (source masquée ou vide = fausse), puis visibilité
ClearCollect(
    colReglesEval,
    AddColumns(
        colReglesFormulaire,
        Vraie,
        With(
            {
                wVis: Coalesce(LookUp(colEtatQuestions, QuestionCode = QuestionSource).Visible, false),
                wRep: LookUp(colReponses, QuestionCode = QuestionSource)
            },
            Switch(
                ConditionType,
                "EQUALS",
                wVis && If(
                    !IsBlank(wRep.ValeurNumerique),
                    wRep.ValeurNumerique = Value(ConditionValeur),
                    !IsBlank(wRep.Valeur) && wRep.Valeur = ConditionValeur
                ),
                "GREATER_OR_EQUAL",
                wVis && !IsBlank(wRep.ValeurNumerique) && wRep.ValeurNumerique >= Value(ConditionValeur),
                "LESS_THAN",
                wVis && !IsBlank(wRep.ValeurNumerique) && wRep.ValeurNumerique < Value(ConditionValeur),
                "VISIBLE",
                wVis = (Upper(ConditionValeur) = "TRUE"),
                false
            )
        )
    )
);
With(
    {
        wMasque: !IsEmpty(Filter(colReglesEval, Vraie && Action = "MASQUER_FORMULAIRE")),
        wSourceMasque: LookUp(colReglesEval, Vraie && Action = "MASQUER_FORMULAIRE").QuestionSource
    },
    ClearCollect(
        colEtatQuestions,
        ForAll(
            colQuestionsFormulaire As wQ,
            {
                QuestionCode: wQ.QuestionCode,
                Visible: If(
                    wMasque && wQ.QuestionCode <> wSourceMasque,
                    false,
                    wQ.VisibleParDefaut
                        || !IsEmpty(Filter(colReglesEval, Vraie && Action = "AFFICHER" && QuestionCible = wQ.QuestionCode))
                        || (
                            !IsEmpty(Filter(colReglesEval, Vraie && Action = "AFFICHER_IF_MATCH" && QuestionCible = wQ.QuestionCode))
                            && !IsEmpty(Filter(colReglesEval, Vraie && Action = "WAITING_SECOND_CONDITION" && QuestionCible = wQ.QuestionCode))
                        )
                )
            }
        )
    )
);
// Étape 4 : évaluation finale des règles sur la visibilité stabilisée
// (profondeur des dépendances du catalogue v0.1 : 2 niveaux de visibilité ; 3 passes laissent une marge)
ClearCollect(
    colReglesEval,
    AddColumns(
        colReglesFormulaire,
        Vraie,
        With(
            {
                wVis: Coalesce(LookUp(colEtatQuestions, QuestionCode = QuestionSource).Visible, false),
                wRep: LookUp(colReponses, QuestionCode = QuestionSource)
            },
            Switch(
                ConditionType,
                "EQUALS",
                wVis && If(
                    !IsBlank(wRep.ValeurNumerique),
                    wRep.ValeurNumerique = Value(ConditionValeur),
                    !IsBlank(wRep.Valeur) && wRep.Valeur = ConditionValeur
                ),
                "GREATER_OR_EQUAL",
                wVis && !IsBlank(wRep.ValeurNumerique) && wRep.ValeurNumerique >= Value(ConditionValeur),
                "LESS_THAN",
                wVis && !IsBlank(wRep.ValeurNumerique) && wRep.ValeurNumerique < Value(ConditionValeur),
                "VISIBLE",
                wVis = (Upper(ConditionValeur) = "TRUE"),
                false
            )
        )
    )
);
// Étape 5 : état complet ; une question masquée n'est ni obligatoire ni contrôlée
ClearCollect(
    colEtatComplet,
    ForAll(
        colQuestionsFormulaire As wQ,
        With(
            {
                wVis: LookUp(colEtatQuestions, QuestionCode = wQ.QuestionCode).Visible,
                wPhotoMin: LookUp(colReglesEval, Vraie && Action = "PHOTO_MIN" && QuestionCible = wQ.QuestionCode)
            },
            Patch(
                wQ,
                {
                    Visible: wVis,
                    ObligatoireEff: wVis && (wQ.Obligatoire || !IsEmpty(Filter(colReglesEval, Vraie && Action = "RENDRE_OBLIGATOIRE" && QuestionCible = wQ.QuestionCode))),
                    CommentaireObligatoireEff: wVis && (wQ.CommentaireObligatoire || !IsEmpty(Filter(colReglesEval, Vraie && Action = "COMMENT_OBLIGATOIRE" && QuestionCible = wQ.QuestionCode))),
                    PhotosMin: If(!wVis, 0, IsBlank(wPhotoMin), wQ.NbPhotosMin, Value(wPhotoMin.Parametre)),
                    CalculBloque: !IsEmpty(Filter(colReglesEval, Vraie && Action = "BLOQUER_CALCUL" && QuestionCible = wQ.QuestionCode))
                }
            )
        )
    )
);
Set(gblSoumissionBloquee, !IsEmpty(Filter(colReglesEval, Vraie && Action = "BLOQUER_SOUMISSION")));
// Photos manquantes : question visible avec moins de photos que le minimum (PHOTO_MIN ou NbPhotosMin ; au moins 1 pour une question PHOTO obligatoire)
Set(
    gblRestePhotos,
    CountRows(
        Filter(
            colEtatComplet As wE,
            wE.Visible
                && CountRows(Filter(colPhotos, QuestionCode = wE.QuestionCode))
                    < If(wE.TypeQuestion = "PHOTO" && wE.ObligatoireEff, Max(1, wE.PhotosMin), wE.PhotosMin)
        )
    )
);
// Compteurs « reste à compléter » (les questions PHOTO sont comptées dans les photos)
Set(
    gblResteObligatoires,
    CountRows(
        Filter(
            colEtatComplet As wE,
            wE.ObligatoireEff && wE.TypeQuestion <> "PHOTO"
                && With({wR: LookUp(colReponses, QuestionCode = wE.QuestionCode)}, IsBlank(wR.Valeur) && IsBlank(wR.ValeurNumerique))
        )
    )
);
Set(
    gblResteCommentaires,
    CountRows(
        Filter(
            colEtatComplet As wE,
            wE.CommentaireObligatoireEff && IsBlank(LookUp(colReponses, QuestionCode = wE.QuestionCode).Commentaire)
        )
    )
);
// Lignes affichées, avec en-tête de groupe à chaque changement de DisplayGroup
ClearCollect(colQV, Sort(Filter(colEtatComplet, Visible), OrdreAffichage));
ClearCollect(
    colQuestionsAffichees,
    ForAll(
        Sequence(CountRows(colQV)) As wI,
        Patch(
            Index(colQV, wI.Value),
            {DebutGroupe: wI.Value = 1 || Index(colQV, wI.Value - 1).DisplayGroup <> Index(colQV, wI.Value).DisplayGroup}
        )
    )
);
// Protection locale (hors connexion) : copie de l'inspection en cours sur l'appareil
ClearCollect(
    colContexteLocal,
    {InspectionGUID: gblInspectionGUID, InspectionID: gblInspectionID, TypeInspection: gblTypeInspection, NomOuvrage: gblNomOuvrage}
);
IfError(SaveData(colContexteLocal, "luwa_contexte"); true, false);
IfError(SaveData(colReponses, "luwa_reponses"); true, false);
IfError(SaveData(colPhotos, "luwa_photos"); true, false)
