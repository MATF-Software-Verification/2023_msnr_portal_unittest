module ProfessorPage.ActivityAssignmentsPage exposing (..)

import Accessibility.Styled as Html exposing (Html)
import Activity exposing (Activity)
import ActivityType exposing (ActivityType)
import Api
import Assignment exposing (ShallowAssignment)
import Bytes
import Css exposing (backgroundColor, column, displayFlex, fitContent, flexDirection, height, justifyContent, marginLeft, marginTop, maxWidth, minWidth, pct, px, rem, width)
import Dict exposing (Dict)
import File exposing (File)
import FileInfo exposing (FileInfo)
import Group exposing (Group)
import Html.Styled.Attributes exposing (css)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Nri.Ui.Button.V10 as Button
import Nri.Ui.Colors.V1 as Colors
import Nri.Ui.Heading.V2 as Heading
import Nri.Ui.Modal.V11 as Modal
import Nri.Ui.SideNav.V3 as SideNav
import Nri.Ui.Table.V5 as Table
import Nri.Ui.TextInput.V7 as TextInput
import Nri.Ui.UiIcon.V1 as UiIcon
import Route exposing (Route)
import Student exposing (Student)
import StudentPage.AssignmentContent.FilesContent exposing (Msg(..))
import Util


type ModalType
    = DocumentModal
    | EditModal


type alias Model =
    { processingModal : Bool
    , hasProcessingError : Bool
    , selectedAssignment : ShallowAssignment
    , modalState : Modal.Model
    , modalType : ModalType
    , loadingFiles : Bool
    , files : Dict Int (List FileInfo)
    , editFile : Maybe FileInfo
    , selectedFile : Maybe File
    , grade : Maybe Int
    , comment : String
    }


init : Model
init =
    { processingModal = False
    , hasProcessingError = False
    , selectedAssignment = emptyAssignment
    , modalState = Modal.init
    , modalType = EditModal
    , loadingFiles = False
    , files = Dict.empty
    , editFile = Nothing
    , selectedFile = Nothing
    , grade = Nothing
    , comment = ""
    }


type Msg
    = SkipNav
    | LoadedFiles Int (Result Http.Error (List FileInfo))
    | DownloadedFile String (Result Http.Error Bytes.Bytes)
    | DownloadFile FileInfo
    | Comment String
    | Grade (Maybe Int)
    | EditFile FileInfo
    | SelectedFile (List File)
    | OpenModal ModalType ShallowAssignment { startFocusOn : String, returnFocusTo : String }
    | ModalMsg Modal.Msg
    | UpateAssignement Int
    | UpatedAssignement (Result Http.Error ShallowAssignment)
    | UploadFile File
    | UploadedFile Int (Result Http.Error FileInfo)
    | Focus String
    | Dismiss


update : Msg -> Model -> { a | accessToken : String, currentSemesterId : Int, apiBaseUrl : String } -> ( Model, Cmd Msg )
update msg model { accessToken, apiBaseUrl } =
    case msg of
        OpenModal modalType assignment config ->
            let
                ( modalState, modalCmd ) =
                    Modal.open config

                documents =
                    Dict.get assignment.id model.files

                ( cmd, loadingFiles ) =
                    case ( modalType, documents ) of
                        ( DocumentModal, Nothing ) ->
                            ( Cmd.batch
                                [ Cmd.map ModalMsg modalCmd
                                , loadFiles assignment.id { token = accessToken, apiBaseUrl = apiBaseUrl }
                                ]
                            , True
                            )

                        _ ->
                            ( Cmd.map ModalMsg modalCmd, model.loadingFiles )
            in
            ( { model | modalType = modalType, modalState = modalState, selectedAssignment = assignment, loadingFiles = loadingFiles, comment = Maybe.withDefault "" assignment.comment, grade = assignment.grade }, cmd )

        ModalMsg modalMsg ->
            let
                ( modalState, cmd ) =
                    Modal.update { dismissOnEscAndOverlayClick = False } modalMsg model.modalState
            in
            ( { model | modalState = modalState }, Cmd.map ModalMsg cmd )

        LoadedFiles assignmentId result ->
            case result of
                Ok files ->
                    ( { model | files = Dict.insert assignmentId files model.files, loadingFiles = False }, Cmd.none )

                Err err ->
                    Debug.log (Debug.toString err) <|
                        ( { model | loadingFiles = False }, Cmd.none )

        DownloadFile { id, fileName } ->
            ( { model | processingModal = True }
            , Util.downlaodFile id { token = accessToken, apiBaseUrl = apiBaseUrl } (DownloadedFile fileName)
            )

        DownloadedFile fileName result ->
            let
                model_ =
                    { model | processingModal = False }
            in
            case result of
                Ok data ->
                    ( model_, Util.saveData fileName data )

                Err _ ->
                    ( { model_ | hasProcessingError = True }, Cmd.none )

        SelectedFile [ file ] ->
            ( { model | selectedFile = Just file }, Cmd.none )

        UploadFile file ->
            ( { model | processingModal = True, hasProcessingError = False }
            , uploadFile model.selectedAssignment.id file { token = accessToken, apiBaseUrl = apiBaseUrl }
            )

        UploadedFile assignmentId result ->
            let
                model_ =
                    { model | processingModal = False }

                ( modalState, cmd ) =
                    Modal.close model.modalState

                docs =
                    Dict.get assignmentId model.files
            in
            case result of
                Ok file ->
                    ( { model_
                        | modalState = modalState
                        , selectedFile = Nothing
                      }
                    , Cmd.map ModalMsg cmd
                    )

                Err err ->
                    Debug.log (Debug.toString err) <|
                        ( { model_ | hasProcessingError = True }, Cmd.none )

        Comment comment ->
            ( { model | comment = comment }, Cmd.none )

        Grade grade ->
            ( { model | grade = grade }, Cmd.none )

        UpateAssignement grade ->
            ( { model | processingModal = True, hasProcessingError = False }
            , updateAssignement model.selectedAssignment.id model.comment grade { token = accessToken, apiBaseUrl = apiBaseUrl }
            )

        UpatedAssignement result ->
            let
                model_ =
                    { model | processingModal = False }

                ( modalState, cmd ) =
                    Modal.close model.modalState
            in
            case result of
                Ok _ ->
                    ( { model_ | modalState = modalState }, Cmd.map ModalMsg cmd )

                Err err ->
                    Debug.log (Debug.toString err) <|
                        ( { model_ | hasProcessingError = True }, Cmd.none )

        Dismiss ->
            ( { model | hasProcessingError = False }, Cmd.none )

        _ ->
            ( model, Cmd.none )


view :
    Model
    -> Int
    ->
        { a
            | activities : Dict Int Activity
            , activityTypes : Dict Int ActivityType
            , assignments : List ShallowAssignment
            , groups : Dict Int Group
            , students : Dict Int Student
        }
    -> Html Msg
view model activityId ({ activities, activityTypes } as params) =
    Html.div [ css [ height (pct 100) ] ]
        [ Html.div [ css [ height (pct 100), displayFlex, justifyContent Css.center ] ]
            [ navigation (Dict.values activities) activityTypes activityId
            , assignmentView model activityId params
            ]
        ]


assignmentView :
    Model
    -> Int
    ->
        { a
            | activities : Dict Int Activity
            , activityTypes : Dict Int ActivityType
            , assignments : List ShallowAssignment
            , groups : Dict Int Group
            , students : Dict Int Student
        }
    -> Html Msg
assignmentView model activityId params =
    Html.div
        [ css
            [ displayFlex
            , flexDirection column
            , height (pct 100)
            , width (pct 75)
            , width (rem 70)
            , minWidth (rem 30)
            , backgroundColor Colors.white
            ]
        ]
        [ tableView activityId params
        , modalView model params
        ]


navigation : List Activity -> Dict Int ActivityType -> Int -> Html Msg
navigation activities activityTypes activityId =
    let
        activityTypeName typeId =
            Dict.get typeId activityTypes
                |> Maybe.map .name
                |> Maybe.withDefault ""

        activityName activity =
            activityTypeName activity.activityTypeId
                ++ (if activity.isSignup then
                        " - Prijava"

                    else
                        ""
                   )

        activityNavLinks : List (SideNav.Entry Route Msg)
        activityNavLinks =
            List.map
                (\activity ->
                    SideNav.entry (activityName activity)
                        [ SideNav.linkSpa (activityAssignmentsRoute activity.id) ]
                )
                activities
    in
    SideNav.view
        { isCurrentRoute = (==) (activityAssignmentsRoute activityId)
        , routeToString = Route.toString
        , onSkipNav = SkipNav
        }
        [ SideNav.navCss [ backgroundColor Colors.white, marginLeft (px 5), maxWidth fitContent ] ]
        activityNavLinks


activityAssignmentsRoute : Int -> Route
activityAssignmentsRoute =
    Route.Professor << Route.ActivityAssignments


tableView :
    Int
    ->
        { a
            | groups : Dict Int Group
            , students : Dict Int Student
            , assignments : List ShallowAssignment
            , activities : Dict Int Activity
            , activityTypes : Dict Int ActivityType
        }
    -> Html Msg
tableView activityId { assignments, students, groups, activities, activityTypes } =
    let
        activityAssignments =
            List.filter (\x -> x.activityId == activityId) assignments

        activity =
            Dict.get activityId activities

        signup =
            activity
                |> Maybe.map (\{ isSignup } -> isSignup)
                |> Maybe.withDefault False

        hasFiles =
            not signup
                && (activity
                        |> Maybe.andThen (\{ activityTypeId } -> Dict.get activityTypeId activityTypes)
                        |> Maybe.map
                            (\{ content } ->
                                case content of
                                    ActivityType.Files _ ->
                                        True

                                    _ ->
                                        False
                            )
                        |> Maybe.withDefault False
                   )

        documentBtn assignment =
            if hasFiles then
                Button.button "Dokumenti"
                    [ Button.small
                    , Button.icon UiIcon.documents
                    , Button.onClick (OpenModal DocumentModal assignment { startFocusOn = Modal.closeButtonId, returnFocusTo = docuemntsButtonId assignment.id })
                    , Button.css [ marginLeft (px 5) ]
                    ]

            else
                Util.emptyHtmlNode

        columns =
            [ Table.string
                { header = "Izvršena"
                , value =
                    .completed
                        >> (\completed ->
                                if completed then
                                    "Da"

                                else
                                    "Ne"
                           )
                , width = px 100 -- calc (pct 50) minus (px 250)
                , cellStyles = always []
                }
            , Table.string
                { header = "Ocena"
                , value = Maybe.withDefault "" << Maybe.map String.fromInt << .grade
                , width = px 100 -- calc (pct 50) minus (px 250)
                , cellStyles = always []
                }
            , Table.string
                { header = "Komentar"
                , value = Maybe.withDefault "" << .comment
                , width = px 100 -- calc (pct 50) minus (px 250)
                , cellStyles = always []
                }
            , Table.custom
                { header = Html.text ""
                , width = px 250
                , view =
                    \a ->
                        Html.div [ css [ displayFlex ] ]
                            [ Button.button ""
                                [ Button.small
                                , Button.id (editButtonId a.id)
                                , Button.onClick (OpenModal EditModal a { startFocusOn = Modal.closeButtonId, returnFocusTo = editButtonId a.id })
                                , Button.icon UiIcon.edit
                                ]
                            , documentBtn a
                            ]
                , cellStyles = always []
                }
            ]

        getGroup id =
            Dict.get id groups

        groupColumns =
            Table.string
                { header = "Grupa"
                , value = Maybe.withDefault "" << Maybe.map Group.toString << Maybe.andThen getGroup << .groupId
                , width = px 100 -- calc (pct 50) minus (px 250)
                , cellStyles = always []
                }
                :: columns

        getStudent id =
            Dict.get id students

        studentColumns =
            Table.string
                { header = "Student"
                , value = Maybe.withDefault "" << Maybe.map (Student.toString False) << Maybe.andThen getStudent << .studentId
                , width = px 100 -- calc (pct 50) minus (px 250)
                , cellStyles = always []
                }
                :: columns

        table { groupId, studentId } =
            case ( groupId, studentId ) of
                ( Just _, _ ) ->
                    Table.view groupColumns activityAssignments

                ( _, Just _ ) ->
                    Table.view studentColumns activityAssignments

                _ ->
                    Util.emptyHtmlNode
    in
    case activityAssignments of
        h :: _ ->
            table h

        _ ->
            Util.emptyHtmlNode


modalView : Model -> { a | groups : Dict Int Group, students : Dict Int Student } -> Html Msg
modalView model { groups, students } =
    let
        { studentId, groupId } =
            model.selectedAssignment

        modalTitle =
            case ( studentId, groupId ) of
                ( Just id, _ ) ->
                    Dict.get id students
                        |> Maybe.map (Student.toString True)
                        |> Maybe.withDefault ""

                ( _, Just id ) ->
                    Dict.get id groups
                        |> Maybe.map Group.toString
                        |> Maybe.withDefault ""

                _ ->
                    ""

        saveButtonId =
            "save-btn"

        editContent =
            [ TextInput.view "Komentar" [ TextInput.text Comment, TextInput.value model.comment ]
            , TextInput.view "Broj poena" [ TextInput.number Grade, TextInput.value model.grade ]
            ]

        uploadFilesView files =
            case files of
                [] ->
                    Html.div [] [ Html.text "Student nije priložio nijedan dokument" ]

                files_ ->
                    Util.filesView
                        { isActive = True
                        , editAttached = True
                        , downloadMsg = DownloadFile
                        , editMsg = EditFile
                        }
                        files_

        fileName =
            Maybe.map File.name

        documentsContent =
            case Dict.get model.selectedAssignment.id model.files of
                Just files ->
                    [ uploadFilesView files
                    , Html.div [ css [ marginTop (px 20) ] ]
                        [ Heading.h5 [] [ Html.text "Otpremanje datoteka" ]
                        , Html.div [ css [ displayFlex, justifyContent Css.center ] ]
                            [ Util.fileInpuView (fileName model.selectedFile) "" (Decode.map SelectedFile Util.filesDecoder) ]
                        ]
                    ]

                _ ->
                    [ Util.loadingSpinner ]

        savaBtnAttrs =
            [ Button.id saveButtonId, Button.primary ]

        editBtn =
            Button.button "Oceni"
                [ case ( model.grade, model.comment ) of
                    ( Nothing, _ ) ->
                        Button.disabled

                    ( _, "" ) ->
                        Button.disabled

                    ( Just g, _ ) ->
                        Button.onClick (UpateAssignement g)
                , Button.id saveButtonId
                , Button.primary
                ]

        uploadBtn =
            Button.button "Otpremi"
                [ case model.selectedFile of
                    Nothing ->
                        Button.disabled

                    Just f ->
                        Button.onClick (UploadFile f)
                , Button.id saveButtonId
                , Button.primary
                ]

        ( content, saveBtn ) =
            case model.modalType of
                EditModal ->
                    ( editContent, editBtn )

                DocumentModal ->
                    ( documentsContent, uploadBtn )

        loading =
            case ( model.processingModal, model.modalType, model.loadingFiles ) of
                ( True, _, _ ) ->
                    True

                ( False, DocumentModal, True ) ->
                    True

                _ ->
                    False

        footer =
            if loading then
                Util.loadingSpinner

            else if model.hasProcessingError then
                Util.errorMessage Dismiss

            else
                Html.div [] [ saveBtn ]
    in
    Modal.view
        { title = modalTitle
        , wrapMsg = ModalMsg
        , content = content
        , footer = [ footer ]
        , focusTrap = { focus = Focus, firstId = Modal.closeButtonId, lastId = saveButtonId }
        }
        [ Modal.closeButton ]
        model.modalState


editButtonId : Int -> String
editButtonId =
    (++) "edit-assignment-" << String.fromInt


docuemntsButtonId : Int -> String
docuemntsButtonId =
    (++) "docuemnts-assignment-" << String.fromInt


emptyAssignment : ShallowAssignment
emptyAssignment =
    { id = 0
    , groupId = Nothing
    , studentId = Nothing
    , comment = Nothing
    , grade = Nothing
    , activityId = 0
    , completed = False
    }


loadFiles : Int -> { token : String, apiBaseUrl : String } -> Cmd Msg
loadFiles assignmentId apiParams =
    Util.loadFiles assignmentId apiParams (LoadedFiles assignmentId)


updateAssignement : Int -> String -> Int -> { token : String, apiBaseUrl : String } -> Cmd Msg
updateAssignement assignmentId comment grade { token, apiBaseUrl } =
    let
        body =
            Encode.object
                [ ( "assignment"
                  , Encode.object
                        [ ( "comment", Encode.string comment )
                        , ( "grade", Encode.int grade )
                        ]
                  )
                ]
    in
    Api.put
        { apiBaseUrl = apiBaseUrl
        , endpoint = Api.endpoints.assignment assignmentId
        , body = Http.jsonBody body
        , token = token
        , expect = Http.expectJson UpatedAssignement (Decode.field "data" Assignment.shallowDecoder)
        }


uploadFile : Int -> File.File -> { token : String, apiBaseUrl : String } -> Cmd Msg
uploadFile assignmentId file { token, apiBaseUrl } =
    let
        body =
            Http.multipartBody
                [ Http.filePart "document" file
                ]
    in
    Api.post
        { apiBaseUrl = apiBaseUrl
        , endpoint = Api.endpoints.documents assignmentId
        , body = body
        , token = token
        , expect = Http.expectJson (UploadedFile assignmentId) (Decode.field "data" FileInfo.decoder)
        }
