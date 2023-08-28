module ProfessorPage.TopicsPage exposing (..)

import Accessibility.Styled as Html exposing (Html)
import Api
import Css exposing (alignItems, alignSelf, auto, center, column, displayFlex, end, flexDirection, flexGrow, height, justifyContent, margin, marginBottom, marginRight, maxWidth, minWidth, pct, px, rem, spaceBetween, width)
import Html.Styled.Attributes exposing (css)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Nri.Ui.Button.V10 as Button
import Nri.Ui.Container.V2 as Container
import Nri.Ui.Heading.V2 as Heading
import Nri.Ui.Message.V3 as Message
import Nri.Ui.TextInput.V7 as TextInput
import Nri.Ui.UiIcon.V1 as UiIcon
import Session exposing (Token)
import Topic exposing (Topic)
import Url exposing (Protocol(..))
import Util


type alias Model =
    { topics : List Topic
    , loadingTopics : Bool
    , topicTitle : String
    , hasProcessingError : Bool
    , isInitialized : Bool
    , dismissedMsg : Bool
    }


init : Model
init =
    { topics = []
    , loadingTopics = True
    , topicTitle = ""
    , hasProcessingError = False
    , isInitialized = False
    , dismissedMsg = False
    }


type Msg
    = TopicsLoaded (Result Http.Error (List Topic))
    | AddTopic
    | AddedTopic (Result Http.Error Topic)
    | DeleteTopic Int
    | DeletedTopic (Result Http.Error ())
    | Title String
    | Dismiss


update : Msg -> Model -> { a | accessToken : Token, currentSemesterId : Int, apiBaseUrl : String } -> ( Model, Cmd Msg )
update msg model params =
    case msg of
        Title title ->
            ( { model | topicTitle = title }, Cmd.none )

        AddTopic ->
            ( { model | loadingTopics = True }, addTopic model.topicTitle params )

        AddedTopic result ->
            let
                model_ =
                    { model | loadingTopics = False }
            in
            case result of
                Ok topic ->
                    ( { model_ | topics = topic :: model.topics, topicTitle = "" }, Cmd.none )

                Err _ ->
                    ( { model_ | hasProcessingError = True }, Cmd.none )

        TopicsLoaded result ->
            let
                model_ =
                    { model | loadingTopics = False }
            in
            case result of
                Ok topics ->
                    ( { model_ | topics = topics, isInitialized = True }, Cmd.none )

                Err _ ->
                    ( { model_ | hasProcessingError = True }, Cmd.none )

        DeleteTopic id ->
            ( { model
                | topics = List.filter (\t -> t.id /= id) model.topics
                , loadingTopics = True
              }
            , deleteTopic id params
            )

        DeletedTopic result ->
            let
                model_ =
                    { model | loadingTopics = False }
            in
            case result of
                Ok _ ->
                    ( model_, Cmd.none )

                Err _ ->
                    ( { model_ | hasProcessingError = True, isInitialized = False }
                    , Topic.loadTopics
                        { semesterId = params.currentSemesterId
                        , token = params.accessToken
                        , apiBaseUrl = params.apiBaseUrl
                        , msg = TopicsLoaded
                        , onlyAvailable = False
                        }
                    )

        Dismiss ->
            ( { model | dismissedMsg = True, hasProcessingError = False }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        newTopicView =
            Container.view
                [ Container.css [ marginBottom (px 10) ]
                , Container.html
                    [ Heading.h3 [ Heading.css [ marginBottom (px 20) ] ] [ Html.text "Nova tema" ]
                    , Html.div [ css [ displayFlex ] ]
                        [ Html.div
                            [ css [ flexGrow (Css.int 1), marginRight (px 10) ] ]
                            [ TextInput.view "Naslov teme" [ TextInput.text Title, TextInput.value model.topicTitle ] ]
                        , Html.div
                            [ css [ alignSelf end ] ]
                            [ Button.button "Dodaj temu" <|
                                [ Button.onClick AddTopic, Button.secondary, Button.icon UiIcon.plus ]
                                    ++ (if String.isEmpty model.topicTitle || model.loadingTopics then
                                            [ Button.disabled ]

                                        else
                                            []
                                       )
                            ]
                        ]
                    ]
                ]

        topicView { id, title } =
            Container.view
                [ Container.gray
                , Container.css [ marginBottom (px 2) ]
                , Container.html
                    [ Html.div [ css [ displayFlex, justifyContent spaceBetween, alignItems center ] ]
                        [ Heading.h5 [] [ Html.text title ]
                        , Button.button "" [ Button.onClick (DeleteTopic id), Button.small, Button.danger, Button.icon UiIcon.x ]
                        ]
                    ]
                ]

        topicsView =
            Container.view
                [ Container.css [ flexGrow (Css.int 1) ]
                , Container.html <|
                    if model.loadingTopics then
                        [ Util.loadingSpinner ]

                    else
                        [ Heading.h3 [ Heading.css [ marginBottom (px 20) ] ] [ Html.text "Trenutne teme" ]
                        , Html.div
                            [ css [ displayFlex, flexDirection column ] ]
                            (List.map topicView model.topics)
                        ]
                ]

        errorView =
            if model.hasProcessingError then
                Message.view [ Message.alert, Message.css [ marginBottom (px 10) ], Message.large, Message.onDismiss Dismiss, Message.plaintext "Došlo je do neočekivane greške 😞" ]

            else
                Html.text ""
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
        [ newTopicView, errorView, topicsView ]


addTopic : String -> { a | accessToken : Token, currentSemesterId : Int, apiBaseUrl : String } -> Cmd Msg
addTopic topicTitle { currentSemesterId, apiBaseUrl, accessToken } =
    Api.post
        { apiBaseUrl = apiBaseUrl
        , endpoint = Api.endpoints.topics currentSemesterId
        , token = accessToken
        , body =
            Http.jsonBody <|
                Encode.object
                    [ ( "topic"
                      , Encode.object [ ( "title", Encode.string topicTitle ) ]
                      )
                    ]
        , expect = Http.expectJson AddedTopic (Decode.field "data" Topic.decoder)
        }


loadTopicsIfUnitialized : Model -> { a | accessToken : String, currentSemesterId : Int, apiBaseUrl : String } -> Cmd Msg
loadTopicsIfUnitialized model { accessToken, currentSemesterId, apiBaseUrl } =
    if model.isInitialized then
        Cmd.none

    else
        Topic.loadTopics { semesterId = currentSemesterId, token = accessToken, apiBaseUrl = apiBaseUrl, msg = TopicsLoaded, onlyAvailable = False }


deleteTopic : Int -> { a | accessToken : String, currentSemesterId : Int, apiBaseUrl : String } -> Cmd Msg
deleteTopic id { accessToken, currentSemesterId, apiBaseUrl } =
    Api.delete
        { apiBaseUrl = apiBaseUrl
        , endpoint = Api.endpoints.topics currentSemesterId ++ "/" ++ String.fromInt id
        , token = accessToken
        , expect = Http.expectWhatever DeletedTopic
        }
