module RegistrationPage exposing (..)

import Accessibility.Styled as Html exposing (Html)
import Api
import Css exposing (..)
import Html.Styled.Attributes exposing (css)
import Http
import Json.Encode as Encode
import Nri.Ui.Button.V10 as Button
import Nri.Ui.Container.V2 as Container
import Nri.Ui.Heading.V2 as Heading
import Nri.Ui.Message.V3 as Message
import Nri.Ui.TextInput.V7 as TextInput
import Url.Builder
import Util


type FormState
    = Init
    | Loading
    | CreatedRequest String
    | Error String


type alias Model =
    { apiBaseUrl : String
    , firstName : String
    , lastName : String
    , email : String
    , indexNumber : String
    , state : FormState
    , dismissedMsg : Bool
    }


type Msg
    = Email String
    | IndexNumber String
    | FirstName String
    | LastName String
    | SubmittedForm
    | GotRegistrationResult (Result Http.Error ())
    | Dissmis


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FirstName firstName ->
            ( { model | firstName = firstName }, Cmd.none )

        LastName lastName ->
            ( { model | lastName = lastName }, Cmd.none )

        Email email ->
            ( { model | email = email }, Cmd.none )

        IndexNumber indexNumber ->
            ( { model | indexNumber = indexNumber }, Cmd.none )

        SubmittedForm ->
            ( { model | state = Loading }, sendRequest model )

        GotRegistrationResult result ->
            let
                model_ =
                    case result of
                        Ok _ ->
                            Model model.apiBaseUrl "" "" "" "" (CreatedRequest "Uspešno ste podneli prijavu! 👍") False

                        Err _ ->
                            { model | dismissedMsg = False, state = Error "Došlo je do neočekivane greške 😞" }
            in
            ( model_, Cmd.none )

        Dissmis ->
            ( { model | dismissedMsg = True }, Cmd.none )


view : Model -> Html Msg
view { email, firstName, lastName, indexNumber, state, dismissedMsg } =
    let
        addLoadingAttr otherAttrs =
            case state of
                Loading ->
                    TextInput.loading :: otherAttrs

                _ ->
                    otherAttrs

        textInputView label type_ msg val =
            TextInput.view label <| addLoadingAttr [ type_ msg, TextInput.value val ]

        msgViewAttrs text =
            [ Message.large, Message.onDismiss Dissmis, Message.plaintext text ]

        stateView =
            case ( state, dismissedMsg ) of
                ( Loading, _ ) ->
                    Util.loadingSpinner

                ( CreatedRequest msg, False ) ->
                    Message.view <| Message.success :: msgViewAttrs msg

                ( Error msg, False ) ->
                    Message.view <| Message.alert :: msgViewAttrs msg

                _ ->
                    Html.text ""
    in
    Container.view
        [ Container.css [ width (pct 33), margin auto ]
        , Container.html
            [ Heading.h3 [ Heading.css [ marginBottom (px 20) ] ] [ Html.text "Zahtev za registraciju korisnika" ]
            , textInputView "Email" TextInput.email Email email
            , textInputView "Ime" TextInput.text FirstName firstName
            , textInputView "Prezime" TextInput.text LastName lastName
            , textInputView "Broj indeksa" TextInput.text IndexNumber indexNumber
            , Button.button "Podnesi prijavu"
                [ Button.primary
                , Button.onClick SubmittedForm
                , Button.css [ marginTop (px 20) ]
                ]
            , Html.div [ css [ marginTop (px 20) ] ] [ stateView ]
            ]
        ]


init : String -> Model
init apiBaseUrl =
    Model apiBaseUrl "" "" "" "" Init False


sendRequest : Model -> Cmd Msg
sendRequest model =
    let
        body =
            Encode.object
                [ ( "student_registration"
                  , Encode.object
                        [ ( "email", Encode.string model.email )
                        , ( "index_number", Encode.string model.indexNumber )
                        , ( "first_name", Encode.string model.firstName )
                        , ( "last_name", Encode.string model.lastName )
                        ]
                  )
                ]
    in
    Http.post
        { url = Url.Builder.relative [ model.apiBaseUrl, Api.endpoints.registrations ] []
        , body = Http.jsonBody body
        , expect = Http.expectWhatever GotRegistrationResult
        }
