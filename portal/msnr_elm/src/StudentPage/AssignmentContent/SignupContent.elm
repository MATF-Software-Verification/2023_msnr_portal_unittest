module StudentPage.AssignmentContent.SignupContent exposing (..)

import Accessibility.Styled as Html exposing (Html)
import Api
import Assignment exposing (Assignment)
import Css exposing (displayFlex, justifyContent, spaceAround)
import Http
import Json.Encode as Encode
import Nri.Ui.Button.V10 as Button
import Nri.Ui.Heading.V2 as Heading
import Svg.Styled.Attributes exposing (css)
import Util


type alias Model =
    { isSignedUp : Bool
    , processingRequest : Bool
    , hasProcessingError : Bool
    , dismissedMsg : Bool
    }


type Msg
    = UpdateSignup Int Bool
    | SignupUpdated (Result Http.Error ())
    | Dismiss


init : Bool -> Model
init isSignedUp =
    Model isSignedUp False False False


update : Msg -> Model -> { token : String, apiBaseUrl : String } -> ( Model, Cmd Msg )
update msg model apiParams =
    case msg of
        UpdateSignup id val ->
            ( { model | processingRequest = True, hasProcessingError = False }, updateSignup id val apiParams )

        SignupUpdated result ->
            case result of
                Ok _ ->
                    ( { model | processingRequest = False, isSignedUp = not model.isSignedUp }, Cmd.none )

                Err _ ->
                    ( { model | processingRequest = False, hasProcessingError = True }, Cmd.none )

        Dismiss ->
            ( { model | dismissedMsg = True, hasProcessingError = False }, Cmd.none )


view : Assignment -> Model -> Html Msg
view { id } model =
    let
        ( headingText, buttonText, buttonArgs ) =
            if model.isSignedUp then
                ( "Prijavljani ste za ovu aktivnost"
                , "Odjavi se"
                , [ Button.danger, Button.onClick (UpdateSignup id False) ]
                )

            else
                ( "Trenutno niste prijavljeni za ovu aktivnost"
                , "Prijavi se"
                , [ Button.primary, Button.onClick (UpdateSignup id True) ]
                )
    in
    if model.processingRequest then
        Util.loadingSpinner

    else
        Html.div [ css [ displayFlex, justifyContent spaceAround ] ]
            [ Heading.h5 [] [ Html.text headingText ]
            , Button.button buttonText buttonArgs
            ]


updateSignup : Int -> Bool -> { token : String, apiBaseUrl : String } -> Cmd Msg
updateSignup id val { token, apiBaseUrl } =
    Api.put
        { apiBaseUrl = apiBaseUrl
        , endpoint = Api.endpoints.signup id
        , token = token
        , body = Http.jsonBody <| Encode.object [ ( "signed_up", Encode.bool val ) ]
        , expect = Http.expectWhatever SignupUpdated
        }
