module LoginPage exposing (Model, Msg, init, update, updateError, view)

import Accessibility.Styled as Html exposing (Html)
import Css exposing (..)
import Http
import Nri.Ui.Button.V10 as Button
import Nri.Ui.Container.V2 as Container
import Nri.Ui.Heading.V2 as Heading
import Nri.Ui.TextInput.V7 as TextInput
import Session as Session exposing (getSession)


type alias Model =
    { apiBaseUrl : String
    , email : String
    , password : String
    , showPassword : Bool
    , error : Maybe Http.Error
    , processing : Bool
    }


type Msg
    = Email String
    | Password String
    | SetShowPassword Bool
    | SubmittedForm


update : Msg -> Model -> ( Model, Cmd Session.Msg )
update msg model =
    case msg of
        Email email ->
            ( { model | email = email }, Cmd.none )

        Password password ->
            ( { model | password = password }, Cmd.none )

        SetShowPassword showPassword ->
            ( { model | showPassword = showPassword }, Cmd.none )

        SubmittedForm ->
            ( { model | error = Nothing, processing = True }
            , getSession { email = model.email, password = model.password, apiBaseUrl = model.apiBaseUrl }
            )


init : String -> Model
init apiBaseUrl =
    Model apiBaseUrl "" "" False Nothing False


view : Model -> Html Msg
view model =
    Container.view
        [ Container.css [ width (pct 33), margin auto ]
        , Container.html
            [ Heading.h3 [ Heading.css [ marginBottom (px 20) ] ] [ Html.text "Prijava korisnika" ]
            , TextInput.view "Email" [ TextInput.email Email, TextInput.value model.email ]
            , TextInput.view "Password" [ TextInput.currentPassword { onInput = Password, showPassword = model.showPassword, setShowPassword = SetShowPassword }, TextInput.value model.password ]
            , Button.button "Prijavi se"
                [ Button.primary
                , Button.onClick SubmittedForm
                , Button.css [ marginTop (px 20) ]
                ]
            ]
        ]


updateError : Model -> Http.Error -> Model
updateError model httpError =
    { model | error = Just httpError, processing = False }
