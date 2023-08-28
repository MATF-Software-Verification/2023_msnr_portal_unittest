module StudentPage.AssignmentContent.TopicContent exposing (..)

import Accessibility.Styled as Html exposing (Html)
import ActivityType exposing (TypeCode(..))
import Api
import Assignment exposing (Assignment)
import Css exposing (alignItems, center, column, displayFlex, flexDirection, justifyContent, marginBottom, px, spaceBetween)
import Html.Styled.Attributes exposing (css)
import Http
import Json.Encode as Encode
import Nri.Ui.Button.V10 as Button
import Nri.Ui.Container.V2 as Container
import Nri.Ui.Heading.V2 as Heading
import Nri.Ui.Message.V3 as Message
import Nri.Ui.UiIcon.V1 as UiIcon
import Topic exposing (Topic)
import Util


type ProcessingError
    = ReservedTopic
    | UnexpectedErr


type alias Model =
    { selectedTopic : Maybe Topic
    , processingRequest : Bool
    , processingError : Maybe ProcessingError
    , dismissedMsg : Bool
    }


init : Model
init =
    Model Nothing False Nothing False


type Msg
    = SelectTopic Topic Int
    | TopicSelected (Result Http.Error ())
    | Dismiss


update : Msg -> Model -> { token : String, apiBaseUrl : String } -> ( Model, Cmd Msg )
update msg model apiParams =
    case msg of
        SelectTopic topic groupId ->
            ( { model
                | processingRequest = True
                , selectedTopic = Just topic
                , processingError = Nothing
              }
            , selectTopic topic.id groupId apiParams
            )

        TopicSelected result ->
            case result of
                Ok _ ->
                    ( { model | processingRequest = False }, Cmd.none )

                --Unprocessable Entity
                Err (Http.BadStatus 422) ->
                    ( { model | processingRequest = False, processingError = Just ReservedTopic }, Cmd.none )

                _ ->
                    ( { model | processingRequest = False, processingError = Just UnexpectedErr }, Cmd.none )

        Dismiss ->
            ( { model | dismissedMsg = True, processingError = Nothing }, Cmd.none )


view : Assignment -> { loading : Bool, topic : Maybe Topic, topics : List Topic, groupId : Maybe Int } -> Model -> Html Msg
view _ { loading, topic, topics, groupId } model =
    let
        topicView groupId_ t =
            Container.view
                [ Container.css [ marginBottom (px 2) ]
                , Container.html
                    [ Html.div [ css [ displayFlex, justifyContent spaceBetween, alignItems center ] ]
                        [ Heading.h5 [] [ Html.text t.title ]
                        , Button.button "Odaberi" [ Button.onClick (SelectTopic t groupId_), Button.small, Button.secondary, Button.icon UiIcon.archive ]
                        ]
                    ]
                ]

        errorMsgView textMsg =
            Message.view [ Message.alert, Message.css [ marginBottom (px 10) ], Message.large, Message.onDismiss Dismiss, Message.plaintext textMsg ]

        errorView =
            case model.processingError of
                Just ReservedTopic ->
                    errorMsgView "Temu je u međuvremenu uzeo drugi tim 😞. Probajte sa nekom drugom..."

                Just UnexpectedErr ->
                    errorMsgView "Došlo je do neočekivane greške 😞"

                _ ->
                    Html.text ""
    in
    case groupId of
        Just id ->
            if loading || model.processingRequest then
                Html.div [] [ Util.loadingSpinner ]

            else
                case topic of
                    Just { title } ->
                        Html.text title

                    Nothing ->
                        Html.div []
                            [ Heading.h3 [ Heading.css [ marginBottom (px 20) ] ] [ Html.text "Dostupne teme" ]
                            , errorView
                            , Html.div
                                [ css [ displayFlex, flexDirection column ] ]
                                (List.map (topicView id) topics)
                            ]

        Nothing ->
            Html.text "Ne možete izabrati temu ukoliko nemate grupu"


selectTopic : Int -> Int -> { token : String, apiBaseUrl : String } -> Cmd Msg
selectTopic topicId groupId { token, apiBaseUrl } =
    Api.put
        { apiBaseUrl = apiBaseUrl
        , endpoint = Api.endpoints.group groupId
        , token = token
        , body = Http.jsonBody <| Encode.object [ ( "group", Encode.object [ ( "topic_id", Encode.int topicId ) ] ) ]
        , expect = Http.expectWhatever TopicSelected
        }
