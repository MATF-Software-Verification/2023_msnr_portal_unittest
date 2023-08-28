module ProfessorPage.RegistrationRequestsPage exposing (Model, Msg, init, loadRequests, update, view)

import Accessibility.Styled as Html exposing (Html)
import Api
import Css exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Nri.Ui.Button.V10 as Button
import Nri.Ui.Colors.V1 as Colors
import Nri.Ui.Container.V2 as Container
import Nri.Ui.Heading.V2 as Heading
import Nri.Ui.Message.V3 as Message
import Nri.Ui.Modal.V11 as Modal
import Nri.Ui.SegmentedControl.V14 as SegmentedControl
import Nri.Ui.Svg.V1 as Svg
import Nri.Ui.UiIcon.V1 as UiIcon
import RegistrationPage exposing (Msg(..))
import Util
import Svg.Styled.Attributes exposing (css)


statusAccepted : String
statusAccepted =
    "accepted"


statusRejected : String
statusRejected =
    "rejected"


statusPending : String
statusPending =
    "pending"


type Tab
    = Pending
    | Accepted
    | Rejected


type alias Model =
    { acceptedRequests : List RegistrationRequest
    , rejectedRequests : List RegistrationRequest
    , pendingRequests : List RegistrationRequest
    , hasProcessingError : Bool
    , tab : Tab
    , isInitialized : Bool
    , modalAction : ModalAction
    , modalState : Modal.Model
    , updatingRequest : Bool
    , dismissedMsg : Bool
    }


type alias RegistrationRequest =
    { id : Int
    , firstName : String
    , lastName : String
    , email : String
    , index : String
    , status : String
    }


type ModalAction
    = Accept RegistrationRequest
    | Reject RegistrationRequest
    | None


type Msg
    = GotLoadingResult (Result Http.Error (List RegistrationRequest))
    | OpenModal ModalAction { startFocusOn : String, returnFocusTo : String }
    | ModalMsg Modal.Msg
    | CloseModal
    | Focus String
    | UpdateRequest
    | StatusChanged (Result Http.Error RegistrationRequest)
    | FocusAndSelectTab { select : Tab, focus : Maybe String }
    | Dismiss


requestsListDecoder : Decoder (List RegistrationRequest)
requestsListDecoder =
    Decode.field "data" (Decode.list requestDecoder)


requestDecoder : Decoder RegistrationRequest
requestDecoder =
    Decode.map6 RegistrationRequest
        (Decode.field "id" Decode.int)
        (Decode.field "first_name" Decode.string)
        (Decode.field "last_name" Decode.string)
        (Decode.field "email" Decode.string)
        (Decode.field "index_number" Decode.string)
        (Decode.field "status" Decode.string)


loadRequests : Model -> { a | accessToken : String, currentSemesterId : Int, apiBaseUrl : String } -> Cmd Msg
loadRequests model { currentSemesterId, apiBaseUrl, accessToken } =
    if model.isInitialized then
        Cmd.none

    else
        Api.get
            { apiBaseUrl = apiBaseUrl
            , endpoint = Api.endpoints.registrationsPerSemester currentSemesterId
            , token = accessToken
            , expect = Http.expectJson GotLoadingResult requestsListDecoder
            }


update : Msg -> Model -> { a | accessToken : String, apiBaseUrl : String } -> ( Model, Cmd Msg )
update msg model apiParams =
    case msg of
        GotLoadingResult result ->
            case result of
                Ok data ->
                    ( processData model data, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        UpdateRequest ->
            ( { model | updatingRequest = True }, updateRequestStatus model.modalAction apiParams )

        StatusChanged result ->
            case result of
                Ok req ->
                    let
                        ( modalState, cmd ) =
                            Modal.close model.modalState

                        model_ =
                            { model
                                | pendingRequests = List.filter (\x -> x.id /= req.id) model.pendingRequests
                                , modalState = modalState
                                , updatingRequest = False
                            }
                    in
                    ( if req.status == statusAccepted then
                        { model_ | acceptedRequests = req :: model.acceptedRequests }

                      else
                        { model_ | rejectedRequests = req :: model.rejectedRequests }
                    , Cmd.map ModalMsg cmd
                    )

                Err _ ->
                    ( { model | hasProcessingError = True, updatingRequest = False }, Cmd.none )

        FocusAndSelectTab { select } ->
            ( { model | tab = select }, Cmd.none )

        OpenModal action config ->
            let
                ( modalState, cmd ) =
                    Modal.open config
            in
            ( { model | modalAction = action, modalState = modalState }, Cmd.map ModalMsg cmd )

        ModalMsg modalMsg ->
            let
                ( modalState, cmd ) =
                    Modal.update { dismissOnEscAndOverlayClick = False } modalMsg model.modalState
            in
            ( { model | modalState = modalState }, Cmd.map ModalMsg cmd )

        CloseModal ->
            let
                ( modalState, cmd ) =
                    Modal.close model.modalState
            in
            ( { model | modalState = modalState }, Cmd.map ModalMsg cmd )

        Dismiss ->
            ( { model | dismissedMsg = True, hasProcessingError = False }, Cmd.none )

        _ ->
            ( model, Cmd.none )


processData : Model -> List RegistrationRequest -> Model
processData model data =
    let
        ( pendingRequests, nonPendingRequests ) =
            List.partition (\x -> x.status == statusPending) data

        ( acceptedRequests, rejectedRequests ) =
            List.partition (\x -> x.status == statusAccepted) nonPendingRequests
    in
    { model
        | pendingRequests = pendingRequests
        , acceptedRequests = acceptedRequests
        , rejectedRequests = rejectedRequests
        , isInitialized = True
    }


view : Model -> Html Msg
view model =
    let
        confirmModalButtonId =
            "confirm-modal-button"

        cancelModalButtonId =
            "cancel-modal-button"

        acceptButtonId id =
            "accept-btn-" ++ String.fromInt id

        rejectButtonId id =
            "reject-btn-" ++ String.fromInt id

        controlView tab request =
            if tab == Pending then
                [ Html.div []
                    [ Button.button "Prihvati"
                        [ Button.primary
                        , Button.icon UiIcon.checkmark
                        , Button.id (acceptButtonId request.id)
                        , Button.onClick (OpenModal (Accept request) { startFocusOn = confirmModalButtonId, returnFocusTo = acceptButtonId request.id })
                        ]
                    , Button.button "Odbaci"
                        [ Button.secondary
                        , Button.icon UiIcon.x
                        , Button.css [ marginLeft (px 5) ]
                        , Button.id (rejectButtonId request.id)
                        , Button.onClick (OpenModal (Reject request) { startFocusOn = cancelModalButtonId, returnFocusTo = rejectButtonId request.id })
                        ]
                    ]
                ]

            else
                []

        requestView : Tab -> RegistrationRequest -> Html Msg
        requestView tab ({ email, firstName, lastName, index } as request) =
            Container.view
                [ Container.css [ displayFlex, justifyContent spaceBetween, margin2 (px 0) (px 20) ]
                , Container.html <|
                    Html.div
                        []
                        [ Heading.h4 [] [ Html.text (firstName ++ " " ++ lastName ++ " " ++ index) ]
                        , Heading.h5 [] [ Html.text email ]
                        ]
                        :: controlView tab request
                ]

        requestsView : Tab -> List RegistrationRequest -> Html Msg
        requestsView tab requests =
            Html.div [] (List.map (requestView tab) requests)

        options : List (SegmentedControl.Option Tab Msg)
        options =
            [ { value = Pending
              , label = Html.text "Novi zahtevi"
              , icon = Just (Svg.withColor Colors.yellow UiIcon.plus)
              , attributes = []
              , tabTooltip = []
              , content = requestsView Pending model.pendingRequests
              , idString = statusPending
              }
            , { value = Accepted
              , label = Html.text "Prihvaćeni"
              , icon = Just (Svg.withColor Colors.greenDark UiIcon.checkmark)
              , attributes = []
              , tabTooltip = []
              , content = requestsView Accepted model.acceptedRequests
              , idString = statusAccepted
              }
            , { value = Rejected
              , label = Html.text "Odbijeni"
              , icon = Just (Svg.withColor Colors.redDark UiIcon.x)
              , attributes = []
              , tabTooltip = []
              , content = requestsView Rejected model.rejectedRequests
              , idString = statusRejected
              }
            ]

        modalContent =
            case model.modalAction of
                Accept { firstName, lastName, index } ->
                    [ Heading.h5 [] [ Html.text "Potvrdite da prihvatate zahtev za registraciju studenta:" ]
                    , Heading.h4 [] [ Html.text (firstName ++ " " ++ lastName ++ " " ++ index) ]
                    ]

                Reject { firstName, lastName, index } ->
                    [ Heading.h5 [] [ Html.text "Potvrdite da odbijate zahtev za registraciju studenta:" ]
                    , Heading.h4 [] [ Html.text (firstName ++ " " ++ lastName ++ " " ++ index) ]
                    ]

                _ ->
                    [ Html.text "" ]

        footer =
            if model.updatingRequest then
                Util.loadingSpinner

            else if model.hasProcessingError then
                Message.view [ Message.alert, Message.large, Message.onDismiss Dismiss, Message.plaintext "Došlo je do neočekivane greške 😞" ]

            else
                Html.div []
                    [ Button.button "Potvrdi" [ Button.primary, Button.onClick UpdateRequest ]
                    , Button.button "Odusani" [ Button.secondary, Button.onClick CloseModal ]
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
        [ SegmentedControl.view
            { focusAndSelect = FocusAndSelectTab
            , selected = model.tab
            , positioning = SegmentedControl.Center
            , toUrl = Nothing
            , options = options
            }
        , Modal.view
            { title = ""
            , wrapMsg = ModalMsg
            , content = modalContent
            , footer = [ footer ]
            , focusTrap = { focus = Focus, firstId = confirmModalButtonId, lastId = cancelModalButtonId }
            }
            [ Modal.hideTitle ]
            model.modalState
        ]


init : Model
init =
    { acceptedRequests = []
    , rejectedRequests = []
    , pendingRequests = []
    , hasProcessingError = False
    , tab = Pending
    , isInitialized = False
    , modalAction = None
    , modalState = Modal.init
    , updatingRequest = False
    , dismissedMsg = False
    }


updateRequestStatus : ModalAction -> { a | accessToken : String, apiBaseUrl : String } -> Cmd Msg
updateRequestStatus modalAction { accessToken, apiBaseUrl } =
    let
        updateRequest id status =
            Api.put
                { apiBaseUrl = apiBaseUrl
                , endpoint = Api.endpoints.registration id
                , body = Http.jsonBody (Encode.object [ ( "student_registration", Encode.object [ ( "status", Encode.string status ) ] ) ])
                , expect = Http.expectJson StatusChanged (Decode.field "data" requestDecoder)
                , token = accessToken
                }
    in
    case modalAction of
        None ->
            Cmd.none

        Accept { id } ->
            updateRequest id statusAccepted

        Reject { id } ->
            updateRequest id statusRejected
