module StudentPage exposing (..)

import Accessibility.Styled as Html exposing (Html)
import ActivityType
import Api
import Array
import Assignment exposing (Assignment)
import Css exposing (..)
import Css.Global
import Group exposing (Group)
import Html.Styled.Attributes exposing (css)
import Http
import Json.Decode as Decode
import Nri.Ui.Accordion.V3 as Accordion exposing (AccordionEntry(..))
import Nri.Ui.Colors.Extra as ColorsExtra
import Nri.Ui.Colors.V1 as Colors
import Nri.Ui.DisclosureIndicator.V2 as DisclosureIndicator
import Set
import Student exposing (Student)
import StudentPage.AssignmentContent as AssignmentContent
import StudentPage.AssignmentContent.FilesContent as FilesContent
import StudentPage.AssignmentContent.GroupContent exposing (Msg(..))
import StudentPage.AssignmentContent.Model as ACM
import StudentPage.Model exposing (Model)
import Task
import Time
import Topic exposing (Topic)
import Util exposing (ViewMode(..), dateView)


type Msg
    = CurrentTime Time.Posix
    | AdjustTimeZone Time.Zone
    | LoadedAssignments (Result Http.Error (Array.Array Assignment))
    | Toggle Int Assignment Bool
    | Focus String
    | GotAssignmentContentMsg Int AssignmentContent.Msg
    | LoadedStudents (Result Http.Error (List Student))
    | LoadedGroup (Result Http.Error Group)
    | LoadedTopics (Result Http.Error (List Topic))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AdjustTimeZone zone ->
            ( { model | zone = zone }, Cmd.none )

        CurrentTime posixTime ->
            ( { model | currentTimeSec = Time.posixToMillis posixTime // 1000 }, Cmd.none )

        LoadedAssignments (Ok assignments) ->
            ( { model | loading = False, assignments = assignments, assignmentsModels = AssignmentContent.initModels model assignments }, Cmd.none )

        LoadedAssignments (Err err) ->
            Debug.log (Debug.toString err) <|
                ( { model | loading = False }, Cmd.none )

        Toggle arrIndex assignment expand ->
            let
                ( model_, cmd ) =
                    assignmentInitCmd arrIndex assignment expand model
            in
            ( { model_
                | assignmentsState =
                    if expand then
                        Set.insert assignment.id model.assignmentsState

                    else
                        Set.remove assignment.id model.assignmentsState
              }
            , cmd
            )

        GotAssignmentContentMsg index ((AssignmentContent.GotFilesMsg (FilesContent.UploadedFiles (Ok _))) as assignmentMsg) ->
            let
                ( model_, cmd ) =
                    AssignmentContent.update assignmentMsg index model
            in
            case Array.get index model.assignments of
                Just assignment ->
                    ( { model_ | assignments = Array.set index { assignment | completed = True } model.assignments }
                    , Cmd.map (GotAssignmentContentMsg index) cmd
                    )

                _ ->
                    ( model_, Cmd.map (GotAssignmentContentMsg index) cmd )

        GotAssignmentContentMsg index ((AssignmentContent.GotGroupMsg (GroupCreated (Ok group))) as assignmentMsg) ->
            let
                ( model_, cmd ) =
                    AssignmentContent.update assignmentMsg index model
            in
            ( { model_ | group = Just group, groupId = Just group.id }
            , Cmd.map (GotAssignmentContentMsg index) cmd
            )

        GotAssignmentContentMsg index assignmentMsg ->
            let
                ( model_, cmd ) =
                    AssignmentContent.update assignmentMsg index model
            in
            ( model_, Cmd.map (GotAssignmentContentMsg index) cmd )

        LoadedStudents (Ok students) ->
            ( { model | students = students, loadingStudents = False }, Cmd.none )

        LoadedStudents (Err err) ->
            Debug.log (Debug.toString err) <|
                ( { model | loadingStudents = False }, Cmd.none )

        LoadedGroup (Ok group) ->
            ( { model | group = Just group, loadingGroup = False }, Cmd.none )

        LoadedTopics result ->
            let
                model_ =
                    { model | loadingTopics = False }
            in
            case result of
                Ok topics ->
                    ( { model_ | topics = topics }, Cmd.none )

                Err _ ->
                    ( model_, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    if model.loading then
        Util.loadingSpinner

    else
        assignmentsView model


getAssignments : Model -> Cmd Msg
getAssignments { accessToken, semesterId, studentId, apiBaseUrl } =
    Api.get
        { apiBaseUrl = apiBaseUrl
        , endpoint = Api.endpoints.student semesterId studentId ++ "/assignments"
        , token = accessToken
        , expect = Http.expectJson LoadedAssignments (Decode.field "data" (Decode.array Assignment.decoder))
        }


initCmd : Model -> Cmd Msg
initCmd model =
    Cmd.batch
        [ Task.perform AdjustTimeZone Time.here
        , Task.perform CurrentTime Time.now
        , loadAssignmentsCmd model
        , loadGroup model
        ]


loadAssignmentsCmd : Model -> Cmd Msg
loadAssignmentsCmd model =
    if Array.isEmpty model.assignments then
        getAssignments model

    else
        Cmd.none


assignmentsView : Model -> Html Msg
assignmentsView ({ assignments } as model) =
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
        [ Accordion.view
            { entries = List.indexedMap (toAccordionEntry model) (Array.toList assignments)
            , focus = Focus
            }
        , Accordion.styleAccordion
            { entryStyles =
                [ Css.Global.withClass "fixed-positioning-accordion-example"
                    [ Css.marginLeft (Css.px -20)
                    , Css.position Css.relative
                    , Css.backgroundColor Colors.white
                    ]
                ]
            , entryExpandedStyles =
                [ Css.Global.withClass "fixed-positioning-accordion-example"
                    [ Css.Global.children
                        [ Css.Global.section
                            [ Css.minHeight (Css.px 100)
                            , Css.padding (Css.px 20)
                            ]
                        ]
                    ]
                ]
            , entryClosedStyles = []
            , headerStyles =
                [ Css.Global.withClass "fixed-positioning-accordion-example"
                    [ Css.padding (Css.px 10)
                    , Css.backgroundColor Colors.white
                    ]
                ]
            , headerExpandedStyles =
                [ Css.Global.withClass "fixed-positioning-accordion-example"
                    [ Css.backgroundColor Colors.gray96
                    , Css.backgroundColor Colors.white
                    , Css.borderRadius (Css.px 8)
                    , Css.boxShadow5 Css.zero Css.zero (px 10) zero (ColorsExtra.withAlpha 0.2 Colors.gray20)
                    ]
                ]
            , headerClosedStyles = []
            , contentStyles = []
            }
        ]


toAccordionEntry : Model -> Int -> Assignment -> Accordion.AccordionEntry Msg
toAccordionEntry model arrIndex assignment =
    let
        displayDate =
            dateView DisplayMode model.zone
    in
    AccordionEntry
        { caret = DisclosureIndicator.large [ Css.marginRight (Css.px 8) ]
        , content =
            \_ ->
                contentView arrIndex model
        , entryClass = "fixed-positioning-accordion-example"
        , headerContent =
            Html.div []
                [ Html.h2 []
                    [ Html.text <|
                        assignment.activityType.name
                            ++ (if assignment.activity.isSignup then
                                    " - Prijava"

                                else
                                    ""
                               )
                    ]
                , Html.h4 [] [ Html.text assignment.activityType.description ]
                , Html.div []
                    [ Html.span [] [ Html.text (displayDate assignment.activity.startDate ++ " - " ++ displayDate assignment.activity.endDate) ]
                    , case assignment.grade of
                        Just g ->
                            Html.span [ css [ marginLeft (px 20) ] ] [ Html.text ("Ocena: " ++ String.fromInt g) ]

                        Nothing ->
                            Util.emptyHtmlNode
                    ]
                ]
        , headerId = "accordion-entry-" ++ String.fromInt assignment.id
        , headerLevel = Accordion.H4
        , isExpanded = Set.member assignment.id model.assignmentsState
        , toggle = Just (Toggle arrIndex assignment)
        }
        []


contentView : Int -> Model -> Html Msg
contentView studActIndex model =
    AssignmentContent.view studActIndex model |> Html.map (GotAssignmentContentMsg studActIndex)


assignmentInitCmd : Int -> Assignment -> Bool -> Model -> ( Model, Cmd Msg )
assignmentInitCmd arrIndex ({ activityType } as assignement) expaneded model =
    case ( activityType.code, expaneded, activityType.content ) of
        ( ActivityType.Group, True, _ ) ->
            loadDataForGroupAssignment model

        ( ActivityType.Topic, True, _ ) ->
            loadDataForTopicAssignment model

        ( _, True, ActivityType.Files _ ) ->
            loadFilesForAssignment arrIndex assignement model

        _ ->
            ( model, Cmd.none )


loadDataForGroupAssignment : Model -> ( Model, Cmd Msg )
loadDataForGroupAssignment ({ semesterId, groupId, accessToken, students, apiBaseUrl } as model) =
    case ( groupId, students ) of
        ( Nothing, [] ) ->
            ( { model | loadingStudents = True }
            , Api.get
                { apiBaseUrl = apiBaseUrl
                , endpoint = Api.endpoints.students semesterId
                , token = accessToken
                , expect = Http.expectJson LoadedStudents (Decode.field "data" (Decode.list Student.decoder))
                }
            )

        _ ->
            ( model, Cmd.none )


loadDataForTopicAssignment : Model -> ( Model, Cmd Msg )
loadDataForTopicAssignment ({ semesterId, accessToken, group, apiBaseUrl } as model) =
    let
        topic =
            group |> Maybe.andThen .topic
    in
    case ( model.topics, topic ) of
        ( [], Nothing ) ->
            ( { model | loadingTopics = True }
            , Topic.loadTopics { semesterId = semesterId, token = accessToken, apiBaseUrl = apiBaseUrl, msg = LoadedTopics, onlyAvailable = True }
            )

        _ ->
            ( model, Cmd.none )


loadFilesForAssignment : Int -> Assignment -> Model -> ( Model, Cmd Msg )
loadFilesForAssignment assignmentIndex assignment model =
    let
        fromFilesCmd =
            GotAssignmentContentMsg assignmentIndex << AssignmentContent.GotFilesMsg

        maybeFilesModel =
            Array.get assignmentIndex model.assignmentsModels

        updateFilesModel fm =
            Array.set
                assignmentIndex
                (ACM.Files { fm | loadingFiles = True })
                model.assignmentsModels

        apiParams =
            { apiBaseUrl = model.apiBaseUrl, token = model.accessToken }
    in
    case maybeFilesModel of
        Just (ACM.Files filesModel) ->
            if not filesModel.filesLoaded then
                ( { model | assignmentsModels = updateFilesModel filesModel }
                , FilesContent.loadFiles assignment.id apiParams
                    |> Cmd.map fromFilesCmd
                )

            else
                ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


loadGroup : Model -> Cmd Msg
loadGroup { groupId, accessToken, apiBaseUrl } =
    case groupId of
        Just id ->
            Api.get
                { apiBaseUrl = apiBaseUrl
                , endpoint = Api.endpoints.group id
                , token = accessToken
                , expect = Http.expectJson LoadedGroup (Decode.field "data" Group.decoder)
                }

        Nothing ->
            Cmd.none
