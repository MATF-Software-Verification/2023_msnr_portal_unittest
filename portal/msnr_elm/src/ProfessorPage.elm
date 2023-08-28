module ProfessorPage exposing (..)

import Accessibility.Styled as Html exposing (Html)
import Activity exposing (Activity)
import ActivityType exposing (ActivityType)
import Api
import Assignment exposing (ShallowAssignment)
import Dict exposing (Dict)
import Group exposing (Group)
import Http
import Json.Decode as Decode
import Nri.Ui.AssignmentIcon.V2 as AssignmentIcon
import Nri.Ui.Svg.V1 exposing (Svg)
import Nri.Ui.UiIcon.V1 as UiIcon
import ProfessorPage.ActivitiesPage as Activities
import ProfessorPage.ActivityAssignmentsPage as ActivityAssignments
import ProfessorPage.GroupsPage as GroupsPage
import ProfessorPage.RegistrationRequestsPage as Requests
import ProfessorPage.TopicsPage as TopicsPage
import Route exposing (ProfessorSubRoute(..), Route)
import Session exposing (Token)
import Student exposing (Student)
import Task
import Time exposing (Zone)
import Util exposing (toDict)


type alias Model =
    { zone : Zone
    , accessToken : Token
    , apiBaseUrl : String
    , currentSemesterId : Int
    , requstesModel : Requests.Model
    , activitiesModel : Activities.Model
    , activityAssignmentsModel : ActivityAssignments.Model
    , topicsModel : TopicsPage.Model
    , activities : Dict Int Activity
    , activityTypes : Dict Int ActivityType
    , groups : Dict Int Group
    , students : Dict Int Student
    , assignments : List ShallowAssignment
    , loadingActivities : Bool
    , loadingActivityTypes : Bool
    , loadingGroups : Bool
    , loadingStudents : Bool
    , loadingAssignment : Bool
    , hasLoadingError : Bool
    }


type Msg
    = AdjustTimeZone Time.Zone
    | LoadedActivities (Result Http.Error (List Activity))
    | LoadedActivityTypes (Result Http.Error (List ActivityType))
    | LoadedStudents (Result Http.Error (List Student))
    | LoadedGroups (Result Http.Error (List Group))
    | LoadedAssignments (Result Http.Error (List ShallowAssignment))
    | GotRequestsMsg Requests.Msg
    | GotActivitiesMsg Activities.Msg
    | GotTopicsMsg TopicsPage.Msg
    | GotActivityAssignmentsMsg ActivityAssignments.Msg
    | ExpectWhatever (Result Http.Error ())


view : Model -> Route -> Html Msg
view ({ requstesModel, activitiesModel, activityAssignmentsModel } as model) currentRoute =
    let
        activitiesProjection =
            { zone = model.zone
            , activities = Dict.values model.activities
            , activityTypes = Dict.values model.activityTypes
            , loading = model.loadingActivities || model.loadingActivityTypes
            }
    in
    case currentRoute of
        Route.Professor Route.RegistrationRequests ->
            Requests.view requstesModel |> Html.map GotRequestsMsg

        Route.Professor Route.Activities ->
            Activities.view activitiesProjection activitiesModel |> Html.map GotActivitiesMsg

        Route.Professor (Route.ActivityAssignments activityId) ->
            ActivityAssignments.view activityAssignmentsModel activityId model |> Html.map GotActivityAssignmentsMsg

        Route.Professor Route.Topics ->
            TopicsPage.view model.topicsModel |> Html.map GotTopicsMsg

        Route.Professor Route.Groups ->
            GroupsPage.view (Dict.values model.groups)

        _ ->
            Html.text ""


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AdjustTimeZone zone ->
            ( { model | zone = zone }, Cmd.none )

        GotRequestsMsg reqMsg ->
            let
                ( model_, cmd ) =
                    Requests.update reqMsg model.requstesModel { accessToken = model.accessToken, apiBaseUrl = model.apiBaseUrl }
            in
            ( { model | requstesModel = model_ }, Cmd.map GotRequestsMsg cmd )

        LoadedActivities result ->
            case result of
                Ok activities ->
                    ( { model | activities = toDict activities, loadingActivities = False }, Cmd.none )

                Err err ->
                    Debug.log (Debug.toString err) <|
                        ( model, Cmd.none )

        LoadedStudents result ->
            case result of
                Ok students ->
                    ( { model | students = toDict students, loadingStudents = False }, Cmd.none )

                Err err ->
                    Debug.log (Debug.toString err) <|
                        ( model, Cmd.none )

        LoadedGroups result ->
            case result of
                Ok groups ->
                    ( { model | groups = toDict groups, loadingGroups = False }, Cmd.none )

                Err err ->
                    Debug.log (Debug.toString err) <|
                        ( model, Cmd.none )

        LoadedAssignments result ->
            Debug.log (Debug.toString result) <|
                case result of
                    Ok assignments ->
                        ( { model | assignments = assignments, loadingAssignment = False }, Cmd.none )

                    Err err ->
                        Debug.log (Debug.toString err) <|
                            ( model, Cmd.none )

        LoadedActivityTypes (Ok activityTypes) ->
            ( { model | activityTypes = toDict activityTypes, loadingActivityTypes = False }, Cmd.none )

        GotActivitiesMsg (Activities.SavedActivity (Ok activity)) ->
            let
                activities_ =
                    Dict.insert activity.id activity model.activities
            in
            ( { model | activities = activities_, activitiesModel = Activities.init }, Cmd.none )

        GotActivitiesMsg activitiesMsg ->
            let
                ( model_, cmd ) =
                    Activities.update activitiesMsg model.activitiesModel model
            in
            ( { model | activitiesModel = model_ }, Cmd.map GotActivitiesMsg cmd )

        GotTopicsMsg topicsMsg ->
            let
                ( model_, cmd ) =
                    TopicsPage.update topicsMsg model.topicsModel model
            in
            ( { model | topicsModel = model_ }, Cmd.map GotTopicsMsg cmd )

        GotActivityAssignmentsMsg (ActivityAssignments.UpatedAssignement (Ok assignment)) ->
            let
                ( model_, cmd ) =
                    ActivityAssignments.update (ActivityAssignments.UpatedAssignement (Ok assignment)) model.activityAssignmentsModel model
            in
            ( { model
                | activityAssignmentsModel = model_
                , assignments = assignment :: List.filter (\{ id } -> id /= assignment.id) model.assignments
              }
            , Cmd.map GotActivityAssignmentsMsg cmd
            )

        GotActivityAssignmentsMsg assignementMsg ->
            let
                ( model_, cmd ) =
                    ActivityAssignments.update assignementMsg model.activityAssignmentsModel model
            in
            ( { model | activityAssignmentsModel = model_ }, Cmd.map GotActivityAssignmentsMsg cmd )

        _ ->
            ( model, Cmd.none )


init : String -> Token -> Int -> Model
init apiBaseUrl token semesterId =
    { accessToken = token
    , apiBaseUrl = apiBaseUrl
    , currentSemesterId = semesterId
    , zone = Time.utc
    , requstesModel = Requests.init
    , activitiesModel = Activities.init
    , topicsModel = TopicsPage.init
    , activityAssignmentsModel = ActivityAssignments.init
    , activities = Dict.empty
    , activityTypes = Dict.empty
    , groups = Dict.empty
    , students = Dict.empty
    , assignments = []
    , loadingActivities = True
    , loadingActivityTypes = True
    , loadingGroups = True
    , loadingStudents = True
    , loadingAssignment = True
    , hasLoadingError = False
    }


initCmd : Model -> ProfessorSubRoute -> Cmd Msg
initCmd model route =
    let
        activitiesCmd =
            Cmd.batch
                [ Task.perform AdjustTimeZone Time.here
                , getActivities model
                , getActivityTypes model
                ]
    in
    case route of
        Route.RegistrationRequests ->
            Requests.loadRequests model.requstesModel model |> Cmd.map GotRequestsMsg

        Route.Topics ->
            TopicsPage.loadTopicsIfUnitialized model.topicsModel model |> Cmd.map GotTopicsMsg

        Route.ActivityAssignments _ ->
            Cmd.batch
                [ activitiesCmd
                , getAssignments model
                , getStudents model
                , getGroups model
                ]

        Route.Activities ->
            activitiesCmd

        Route.Groups ->
            getGroups model


navIcons : List { icon : Svg, route : ProfessorSubRoute }
navIcons =
    [ { icon = UiIcon.class, route = Route.RegistrationRequests }
    , { icon = UiIcon.calendar, route = Route.Activities }
    , { icon = UiIcon.couple, route = Route.Groups }
    , { icon = AssignmentIcon.writing, route = Route.Topics }
    , { icon = UiIcon.performance, route = Route.ActivityAssignments 0 }
    ]


getActivities : Model -> Cmd Msg
getActivities { currentSemesterId, apiBaseUrl, accessToken, loadingActivities } =
    if loadingActivities then
        Api.get
            { apiBaseUrl = apiBaseUrl
            , endpoint = Api.endpoints.activities currentSemesterId
            , token = accessToken
            , expect = Http.expectJson LoadedActivities (Decode.field "data" (Decode.list Activity.decoder))
            }

    else
        Cmd.none


getActivityTypes : Model -> Cmd Msg
getActivityTypes { apiBaseUrl, accessToken, loadingActivityTypes } =
    if loadingActivityTypes then
        Api.get
            { apiBaseUrl = apiBaseUrl
            , endpoint = Api.endpoints.activityTypes
            , token = accessToken
            , expect = Http.expectJson LoadedActivityTypes (Decode.field "data" (Decode.list ActivityType.decoder))
            }

    else
        Cmd.none


getStudents : Model -> Cmd Msg
getStudents { apiBaseUrl, accessToken, currentSemesterId, loadingStudents } =
    if loadingStudents then
        Api.get
            { apiBaseUrl = apiBaseUrl
            , endpoint = Api.endpoints.students currentSemesterId
            , token = accessToken
            , expect = Http.expectJson LoadedStudents (Decode.field "data" (Decode.list Student.decoder))
            }

    else
        Cmd.none


getGroups : Model -> Cmd Msg
getGroups { apiBaseUrl, accessToken, currentSemesterId, loadingGroups } =
    if loadingGroups then
        Api.get
            { apiBaseUrl = apiBaseUrl
            , endpoint = Api.endpoints.groups currentSemesterId
            , token = accessToken
            , expect = Http.expectJson LoadedGroups (Decode.field "data" (Decode.list Group.decoder))
            }

    else
        Cmd.none


getAssignments : Model -> Cmd Msg
getAssignments { apiBaseUrl, accessToken, currentSemesterId, loadingAssignment } =
    if loadingAssignment then
        Api.get
            { apiBaseUrl = apiBaseUrl
            , endpoint = Api.endpoints.assignments currentSemesterId
            , token = accessToken
            , expect = Http.expectJson LoadedAssignments (Decode.field "data" (Decode.list Assignment.shallowDecoder))
            }

    else
        Cmd.none
