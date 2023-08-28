module StudentPage.AssignmentContent.FilesContent exposing (..)

import Accessibility.Styled as Html exposing (Html)
import ActivityType exposing (FileUploadInfo)
import Api
import Assignment exposing (Assignment)
import Bytes
import Css
import Dict exposing (Dict)
import File exposing (File)
import FileInfo exposing (FileInfo)
import Html.Styled.Attributes exposing (css)
import Http
import Json.Decode as Decode exposing (Decoder)
import Nri.Ui.Button.V10 as Button
import Nri.Ui.Heading.V2 as Heading
import Nri.Ui.Modal.V11 as Modal
import Nri.Ui.UiIcon.V1 as UiIcon
import Util


type alias Model =
    { selectedFiles : Dict String File
    , fileUploadInfoList : List FileUploadInfo
    , loadingFiles : Bool
    , files : List FileInfo
    , modalState : Modal.Model
    , modalFileInfo : Maybe FileInfo
    , modalSelectedFile : Maybe File
    , updatingFile : Bool
    , processingFiles : Bool
    , hasProcessingError : Bool
    , hasProcessingErrorModal : Bool
    , filesLoaded : Bool
    }


init : List FileUploadInfo -> Model
init fileUploadInfoList =
    { selectedFiles = Dict.empty
    , fileUploadInfoList = fileUploadInfoList
    , loadingFiles = False
    , files = []
    , modalState = Modal.init
    , modalFileInfo = Nothing
    , modalSelectedFile = Nothing
    , updatingFile = False
    , processingFiles = False
    , hasProcessingError = False
    , hasProcessingErrorModal = False
    , filesLoaded = False
    }


type Msg
    = SelectedFiles String (List File)
    | Upload Int
    | UploadedFiles (Result Http.Error (List FileInfo))
    | DownloadedFile String (Result Http.Error Bytes.Bytes)
    | DownloadFile FileInfo
    | LoadedFiles (Result Http.Error (List FileInfo))
    | OpenModal { startFocusOn : String, returnFocusTo : String } FileInfo
    | ModalMsg Modal.Msg
    | Focus String
    | Dismiss
    | DismissModal
    | SelectModalFile (List File)
    | UpdateFile
    | UpdatedFile (Result Http.Error FileInfo)


update : Msg -> Model -> { token : String, apiBaseUrl : String } -> ( Model, Cmd Msg )
update msg model apiParams =
    case msg of
        SelectedFiles key [ file ] ->
            ( { model | selectedFiles = Dict.insert key file model.selectedFiles }, Cmd.none )

        Upload id ->
            ( { model | processingFiles = True, hasProcessingError = False }, upload id model.selectedFiles apiParams )

        UploadedFiles result ->
            let
                model_ =
                    { model | processingFiles = False }
            in
            case result of
                Ok files ->
                    ( { model_ | files = files }, Cmd.none )

                Err _ ->
                    ( { model_ | hasProcessingError = True }, Cmd.none )

        DownloadFile { id, fileName } ->
            ( { model | processingFiles = True }
            , Util.downlaodFile id apiParams (DownloadedFile fileName)
            )

        DownloadedFile fileName result ->
            let
                model_ =
                    { model | processingFiles = False }
            in
            case result of
                Ok data ->
                    ( model_, Util.saveData fileName data )

                Err _ ->
                    ( { model_ | hasProcessingError = True }, Cmd.none )

        LoadedFiles result ->
            let
                model_ =
                    { model | loadingFiles = False, filesLoaded = True }
            in
            case result of
                Ok files ->
                    ( { model_ | files = files }, Cmd.none )

                _ ->
                    ( { model_ | hasProcessingError = True }, Cmd.none )

        OpenModal config fileInfo ->
            let
                ( modalState, cmd ) =
                    Modal.open config
            in
            ( { model | modalState = modalState, modalFileInfo = Just fileInfo }, Cmd.map ModalMsg cmd )

        ModalMsg modalMsg ->
            let
                ( modalState, cmd ) =
                    Modal.update { dismissOnEscAndOverlayClick = False } modalMsg model.modalState
            in
            ( { model | modalState = modalState }, Cmd.map ModalMsg cmd )

        SelectModalFile [ file ] ->
            ( { model | modalSelectedFile = Just file }, Cmd.none )

        UpdateFile ->
            case ( model.modalFileInfo, model.modalSelectedFile ) of
                ( Just { id }, Just file ) ->
                    ( { model | updatingFile = True, hasProcessingErrorModal = False }
                    , Util.updateFile id file apiParams UpdatedFile
                    )

                _ ->
                    ( model, Cmd.none )

        UpdatedFile result ->
            let
                model_ =
                    { model | updatingFile = False }

                ( modalState, cmd ) =
                    Modal.close model.modalState
            in
            case result of
                Ok _ ->
                    ( { model_
                        | modalState = modalState
                        , modalSelectedFile = Nothing
                        , modalFileInfo = Nothing
                      }
                    , Cmd.map ModalMsg cmd
                    )

                Err _ ->
                    ( { model_ | hasProcessingErrorModal = True }, Cmd.none )

        Dismiss ->
            ( { model | hasProcessingError = False }, Cmd.none )

        DismissModal ->
            ( { model | hasProcessingErrorModal = False }, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : Assignment -> Bool -> Model -> Html Msg
view { id, completed } isActive model =
    let
        uploadButtonId =
            "modal-upload-btn"

        fileExtensionFrom fileName =
            case String.split "." fileName of
                [ _, extension ] ->
                    "." ++ extension

                _ ->
                    "*"

        ( modalTitle, modalContent ) =
            case model.modalFileInfo of
                Nothing ->
                    ( "", Html.text "" )

                Just { fileName } ->
                    ( "Ponovno otpremanje - " ++ fileName
                    , Html.div [ css [ Css.displayFlex, Css.justifyContent Css.spaceAround ] ]
                        [ Util.fileInpuView
                            (Maybe.map File.name model.modalSelectedFile)
                            (fileExtensionFrom fileName)
                            (Decode.map SelectModalFile Util.filesDecoder)
                        ]
                    )

        modalFooter =
            if model.updatingFile then
                Util.loadingSpinner

            else if model.hasProcessingErrorModal then
                Util.errorMessage DismissModal

            else
                Button.button "Otpremi"
                    [ Button.id uploadButtonId
                    , Button.primary
                    , Button.icon UiIcon.documents
                    , Button.onClick UpdateFile
                    , case model.modalSelectedFile of
                        Nothing ->
                            Button.disabled

                        _ ->
                            Button.enabled
                    ]
    in
    Html.div
        [ css [ Css.displayFlex, Css.justifyContent Css.spaceAround ] ]
        (if model.loadingFiles || model.processingFiles then
            [ Util.loadingSpinner ]

         else
            [ uploadFilesView id model |> Util.displayIf (isActive && not completed)
            , Util.filesView
                { isActive = isActive
                , editAttached = False
                , downloadMsg = DownloadFile
                , editMsg = OpenModal { startFocusOn = Modal.closeButtonId, returnFocusTo = "" }
                }
                model.files
                |> (Util.displayIf << not) (List.isEmpty model.files)
            , Modal.view
                { title = modalTitle
                , wrapMsg = ModalMsg
                , content = [ modalContent ]
                , footer = [ modalFooter ]
                , focusTrap = { focus = Focus, firstId = Modal.closeButtonId, lastId = uploadButtonId }
                }
                [ Modal.closeButton ]
                model.modalState
            ]
        )


uploadFilesView : Int -> Model -> Html Msg
uploadFilesView id model =
    Html.div
        [ css [ Css.displayFlex, Css.flexDirection Css.column, Css.property "gap" "10px" ] ]
        [ Heading.h4 [] [ Html.text "Otpremanje datoteka" ]
        , Html.div
            [ css
                [ Css.displayFlex
                , Css.justifyContent Css.spaceAround
                ]
            ]
            (List.map
                (\{ name, extension } ->
                    Util.fileInpuView
                        (Maybe.map File.name (Dict.get (name ++ extension) model.selectedFiles))
                        extension
                        (Decode.map (SelectedFiles <| name ++ extension) Util.filesDecoder)
                )
                model.fileUploadInfoList
            )
        , Button.button "Otpremi"
            [ Button.small
            , Button.icon UiIcon.documents
            , Button.onClick (Upload id)
            , Button.css [ Css.width (Css.px 150), Css.alignSelf Css.center ]
            , if Dict.size model.selectedFiles == List.length model.fileUploadInfoList then
                Button.enabled

              else
                Button.disabled
            ]
        ]


upload : Int -> Dict String File -> { token : String, apiBaseUrl : String } -> Cmd Msg
upload assignmentId selectedFiles { token, apiBaseUrl } =
    let
        body =
            Http.multipartBody <|
                Dict.foldl
                    (\k v l -> Http.stringPart "documentsIds[]" k :: Http.filePart "documents[]" v :: l)
                    []
                    selectedFiles
    in
    Api.post
        { apiBaseUrl = apiBaseUrl
        , endpoint = Api.endpoints.documents assignmentId
        , body = body
        , token = token
        , expect = Http.expectJson UploadedFiles (Decode.field "data" (Decode.list FileInfo.decoder))
        }


loadFiles : Int -> { token : String, apiBaseUrl : String } -> Cmd Msg
loadFiles assignmentId apiParams =
    Util.loadFiles assignmentId apiParams LoadedFiles
