module ProfessorPage.ActivitiesPage exposing (..)

import Accessibility.Styled as Html exposing (Html)
import Activity exposing (Activity)
import ActivityType exposing (ActivityType)
import Api
import Css exposing (..)
import Html.Styled.Attributes exposing (css)
import Http
import Json.Decode exposing (field)
import Json.Encode as Encode
import Nri.Ui.Button.V10 as Button
import Nri.Ui.Colors.V1 as Colors
import Nri.Ui.Heading.V2 as Heading
import Nri.Ui.Modal.V11 as Modal
import Nri.Ui.Select.V8 as Select
import Nri.Ui.Switch.V1 as Switch
import Nri.Ui.Table.V5 as Table
import Nri.Ui.TextInput.V7 as TextInput
import Nri.Ui.UiIcon.V1 as UiIcon
import Session exposing (Token)
import Time exposing (Month(..), Zone)
import Util exposing (ViewMode(..), dateFromString, dateView, inputDate, secsFromDate)


type ModalAction
    = New
    | Edit Activity


type alias Model =
    { processingActivity : Bool
    , hasProcessingError : Bool
    , modalState : Modal.Model
    , modalAction : ModalAction
    , selectedActivityTypeId : Maybe Int
    , isSignup : Bool
    , startDate : String
    , endDate : String
    , points : Int
    }


init : Model
init =
    { startDate = ""
    , endDate = ""
    , points = 0
    , processingActivity = False
    , modalState = Modal.init
    , modalAction = New
    , hasProcessingError = False
    , isSignup = False
    , selectedActivityTypeId = Nothing
    }


type Msg
    = StartDate String
    | EndDate String
    | ActivityTypeSelected Int
    | SwitchSingup Bool
    | Points (Maybe Int)
    | SaveActivity
    | SavedActivity (Result Http.Error Activity)
    | OpenModal ModalAction { startFocusOn : String, returnFocusTo : String }
    | ModalMsg Modal.Msg
    | Focus String
    | Dismiss


update : Msg -> Model -> { a | accessToken : Token, zone : Zone, currentSemesterId : Int, apiBaseUrl : String } -> ( Model, Cmd Msg )
update msg model ({ zone } as params) =
    case msg of
        OpenModal action config ->
            let
                ( modalState, cmd ) =
                    Modal.open config

                dateEdit =
                    dateView EditMode zone

                { startDate, endDate, points, selectedTypeId } =
                    case action of
                        New ->
                            { startDate = "", endDate = "", points = 0, selectedTypeId = Nothing }

                        Edit activity ->
                            { startDate = dateEdit activity.startDate
                            , endDate = dateEdit activity.endDate
                            , points = activity.points
                            , selectedTypeId = Just activity.activityTypeId
                            }
            in
            ( { model
                | modalAction = action
                , modalState = modalState
                , startDate = startDate
                , endDate = endDate
                , points = points
                , selectedActivityTypeId = selectedTypeId
              }
            , Cmd.map ModalMsg cmd
            )

        ModalMsg modalMsg ->
            let
                ( modalState, cmd ) =
                    Modal.update { dismissOnEscAndOverlayClick = False } modalMsg model.modalState
            in
            ( { model | modalState = modalState }, Cmd.map ModalMsg cmd )

        Dismiss ->
            ( { model | hasProcessingError = False }, Cmd.none )

        ActivityTypeSelected typeId ->
            ( { model | selectedActivityTypeId = Just typeId }, Cmd.none )

        StartDate value ->
            ( { model | startDate = value }, Cmd.none )

        EndDate value ->
            ( { model | endDate = value }, Cmd.none )

        Points maybePoints ->
            case maybePoints of
                Just points ->
                    ( { model | points = points }, Cmd.none )

                Nothing ->
                    ( { model | points = 0 }, Cmd.none )

        SaveActivity ->
            ( { model | processingActivity = True, hasProcessingError = False }
            , saveActivity model params
            )

        SwitchSingup isSignup ->
            ( { model | isSignup = isSignup }, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : { zone : Zone, activities : List Activity, activityTypes : List ActivityType, loading : Bool } -> Model -> Html Msg
view { activities, activityTypes, zone, loading } model =
    let
        addActivityButtonId =
            "add-activity-btn"

        startDateId =
            "start-date-activity"

        displayDate =
            dateView DisplayMode zone

        editActivityId id =
            "edit-activity-" ++ String.fromInt id

        editButton activity =
            Button.button ""
                [ Button.small
                , Button.id (editActivityId activity.id)
                , Button.icon UiIcon.edit
                , Button.onClick (OpenModal (Edit activity) { startFocusOn = Modal.closeButtonId, returnFocusTo = addActivityButtonId })
                ]

        columns =
            [ Table.string
                { header = "Od"
                , value = displayDate << .startDate
                , width = px 100 -- calc (pct 50) minus (px 250)
                , cellStyles = always []
                }
            , Table.string
                { header = "Do"
                , value = displayDate << .endDate
                , width = px 100 -- calc (pct 50) minus (px 250)
                , cellStyles = always []
                }
            , Table.string
                { header = "Tip aktivnosti"
                , value =
                    .activityTypeId
                        >> (\x ->
                                case List.filter (\{ id } -> x == id) activityTypes of
                                    [ activityType ] ->
                                        activityType.name

                                    _ ->
                                        ""
                           )
                , width = px 100 -- calc (pct 50) minus (px 250)
                , cellStyles = always []
                }
            , Table.string
                { header = "Prijava"
                , value =
                    .isSignup
                        >> (\isSignup ->
                                if isSignup then
                                    "Da"

                                else
                                    "Ne"
                           )
                , width = px 100 -- calc (pct 50) minus (px 250)
                , cellStyles = always []
                }
            , Table.string
                { header = "Br. poena"
                , value = String.fromInt << .points
                , width = px 100 -- calc (pct 50) minus (px 250)
                , cellStyles = always []
                }
            , Table.custom
                { header = Html.text "Izmeni"
                , width = px 250
                , view = editButton
                , cellStyles = always []
                }
            ]

        ( loadingButtonAttrs, table ) =
            if loading then
                ( [ Button.loading ], Table.viewLoadingWithoutHeader columns )

            else
                ( [], Table.view columns activities )

        addButtonAttrs =
            [ Button.id addActivityButtonId
            , Button.icon UiIcon.plus
            , Button.small
            , Button.onClick (OpenModal New { startFocusOn = Modal.closeButtonId, returnFocusTo = addActivityButtonId })
            ]
                ++ loadingButtonAttrs

        modalTitle =
            case model.modalAction of
                New ->
                    "Nova akitvnost"

                Edit _ ->
                    "Izmena aktivnosti"

        saveButtonId =
            "save-btn"

        footer =
            if model.processingActivity then
                Util.loadingSpinner

            else if model.hasProcessingError then
                Util.errorMessage Dismiss

            else
                Html.div [] [ Button.button "Sačuvaj" [ Button.id saveButtonId, Button.primary, Button.onClick SaveActivity ] ]

        modalContent =
            [ Html.div [ css [ displayFlex, justifyContent spaceBetween ] ]
                [ inputDate { label_ = "Od", id_ = Just startDateId, msg = StartDate, value = model.startDate }
                , inputDate { label_ = "Do", id_ = Nothing, msg = EndDate, value = model.endDate }
                ]
            , Html.div [ css [ margin2 (px 10) (px 0) ] ]
                [ Select.view "Tip aktivnosti"
                    [ Select.defaultDisplayText "Izaberi tip aktivnosti"
                    , Select.value model.selectedActivityTypeId
                    , Select.choices String.fromInt
                        (List.map (\{ id, name } -> { label = name, value = id }) activityTypes)
                    ]
                    |> Html.map ActivityTypeSelected
                ]
            , Html.div [ css [ displayFlex, justifyContent spaceBetween ] ] <|
                Switch.view
                    [ Switch.onSwitch SwitchSingup
                    , Switch.label <|
                        Html.text
                            (if model.isSignup then
                                "Prijava"

                             else
                                "Nije prijava"
                            )
                    ]
                    model.isSignup
                    :: (if model.isSignup then
                            []

                        else
                            [ TextInput.view "Broj poena" [ TextInput.number Points, TextInput.value (Just model.points) ] ]
                       )
            ]
    in
    Html.div
        [ css
            [ displayFlex
            , flexDirection column
            , margin auto
            , height (pct 100)
            , width (pct 75)
            , maxWidth (rem 70)
            , minWidth (rem 30)
            ]
        ]
        [ Html.div [ css [ displayFlex, justifyContent spaceBetween, alignItems center, marginBottom (px 10) ] ]
            [ Heading.h2 [ Heading.css [ marginRight (px 10), color Colors.highlightBlueDark ] ] [ Html.text "Trenutne aktivnosti" ]
            , Button.button "Dodaj aktivnost" addButtonAttrs
            ]
        , table
        , Modal.view
            { title = modalTitle
            , wrapMsg = ModalMsg
            , content = modalContent
            , footer = [ footer ]
            , focusTrap = { focus = Focus, firstId = Modal.closeButtonId, lastId = saveButtonId }
            }
            [ Modal.closeButton ]
            model.modalState
        ]


saveActivity : Model -> { a | accessToken : Token, currentSemesterId : Int, apiBaseUrl : String } -> Cmd Msg
saveActivity model { accessToken, currentSemesterId, apiBaseUrl } =
    let
        ( apiCall, endpoint ) =
            case model.modalAction of
                New ->
                    ( Api.post, Api.endpoints.activities currentSemesterId )

                Edit { id } ->
                    ( Api.put, Api.endpoints.activity id )

        dates =
            List.filterMap dateFromString [ model.startDate, model.endDate ]
                |> List.map secsFromDate
    in
    case ( dates, model.selectedActivityTypeId ) of
        ( [ sd, ed ], Just typeId ) ->
            apiCall
                { apiBaseUrl = apiBaseUrl
                , endpoint = endpoint
                , token = accessToken
                , body =
                    Http.jsonBody <|
                        Encode.object
                            [ ( "activity"
                              , Activity.encode
                                    { startDate = sd
                                    , endDate = ed
                                    , activityTypeId = typeId
                                    , points = model.points
                                    , isSignup = model.isSignup
                                    }
                              )
                            ]
                , expect = Http.expectJson SavedActivity (field "data" Activity.decoder)
                }

        _ ->
            Cmd.none
