module SetPasswordPage exposing (..)

import Accessibility.Styled exposing (Html, form, text)
import Api
import Css exposing (..)
import Http
import Json.Encode as Encode
import Nri.Ui.Button.V10 as Button
import Nri.Ui.Container.V2 as Container
import Nri.Ui.Heading.V2 as Heading
import Nri.Ui.TextInput.V7 as TextInput
import Session as Session
import Url exposing (Url)
import Url.Builder
import Util exposing (..)


type alias Model =
    { apiBaseUrl : String
    , uuid : String
    , email : String
    , password : String
    , confirmPassword : String
    , processing : Bool
    , showPassword1 : Bool
    , showPassword2 : Bool
    }


type Msg
    = Email String
    | Password String
    | ConfirmPassword String
    | SubmittedForm
    | GotSetPasswordResult (Result Http.Error ())
    | SessionMsg Session.Msg
    | SetShowPassword1 Bool
    | SetShowPassword2 Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Email email ->
            ( { model | email = email }, Cmd.none )

        Password password ->
            ( { model | password = password }, Cmd.none )

        ConfirmPassword password ->
            ( { model | confirmPassword = password }, Cmd.none )

        SubmittedForm ->
            ( { model | processing = True }, setPassword model )

        GotSetPasswordResult result ->
            case result of
                Ok () ->
                    ( model
                    , Session.getSession { email = model.email, password = model.password, apiBaseUrl = model.apiBaseUrl }
                        |> Cmd.map SessionMsg
                    )

                Err _ ->
                    ( model, Cmd.none )

        SetShowPassword1 showPassword ->
            ( { model | showPassword1 = showPassword }, Cmd.none )

        SetShowPassword2 showPassword ->
            ( { model | showPassword2 = showPassword }, Cmd.none )

        _ ->
            ( { model | processing = False }, Cmd.none )


view : Model -> Html Msg
view model =
    formView model


formView : Model -> Html Msg
formView model =
    let
        --  TO DO : loading i error message
        notValid =
            String.isEmpty model.email
                || String.isEmpty model.password
                || String.isEmpty model.confirmPassword
                || model.password
                /= model.confirmPassword
    in
    Container.view
        [ Container.css [ width (pct 33), margin auto ]
        , Container.html
            [ form []
                [ Heading.h3 [ Heading.css [ marginBottom (px 20) ] ] [ text "Podešavanje lozinke" ]
                , TextInput.view "Email" [ TextInput.email Email, TextInput.value model.email ]
                , TextInput.view "Lozinka" [ TextInput.newPassword { onInput = Password, showPassword = model.showPassword1, setShowPassword = SetShowPassword1 }, TextInput.value model.password ]
                , TextInput.view "Potvrda lozinke" [ TextInput.newPassword { onInput = ConfirmPassword, showPassword = model.showPassword2, setShowPassword = SetShowPassword2 }, TextInput.value model.confirmPassword ]
                , Button.button "Potvrdi" <|
                    [ if notValid then
                        Button.disabled

                      else
                        Button.enabled
                    , Button.primary
                    , Button.onClick SubmittedForm
                    , Button.css [ marginTop (px 20) ]
                    ]
                ]
            ]
        ]


init : String -> String -> Model
init apiBaseUrl uuid =
    Model apiBaseUrl uuid "" "" "" False False False


setPassword : Model -> Cmd Msg
setPassword { email, password, uuid, apiBaseUrl } =
    let
        body =
            Encode.object
                [ ( "email", Encode.string email )
                , ( "password", Encode.string password )
                ]
    in
    Http.request
        { method = "PATCH"
        , headers = []
        , url = Url.Builder.relative [ apiBaseUrl, Api.endpoints.password uuid ] []
        , body = Http.jsonBody body
        , expect = Http.expectWhatever GotSetPasswordResult
        , timeout = Nothing
        , tracker = Nothing
        }
