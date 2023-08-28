module StudentPage.AssignmentContent exposing (..)

import Accessibility.Styled as Html exposing (Html)
import ActivityType as AT
import Array
import Assignment exposing (Assignment)
import Nri.Ui.UiIcon.V1 exposing (activity)
import StudentPage.AssignmentContent.FilesContent as FilesContent
import StudentPage.AssignmentContent.GroupContent as GroupContent
import StudentPage.AssignmentContent.Model as ACM
import StudentPage.AssignmentContent.SignupContent as SignupContent
import StudentPage.AssignmentContent.TopicContent as TopicContent
import StudentPage.Model as SM
import Util


type Msg
    = GotFilesMsg FilesContent.Msg
    | GotGroupMsg GroupContent.Msg
    | GotTopicsMsg TopicContent.Msg
    | GotSignupMsg SignupContent.Msg


view : Int -> SM.Model -> Html Msg
view index model =
    case ( Array.get index model.assignments, Array.get index model.assignmentsModels ) of
        ( Just assignment, Just assignmentModel ) ->
            let
                isActive =
                    Util.isActiveAssignment assignment model.currentTimeSec
            in
            case assignmentModel of
                ACM.Files filesModel ->
                    FilesContent.view assignment isActive filesModel |> Html.map GotFilesMsg

                ACM.Group groupModel ->
                    GroupContent.view assignment model groupModel
                        |> Html.map GotGroupMsg

                ACM.Topic topicModel ->
                    TopicContent.view
                        assignment
                        { loading = model.loadingGroup || model.loadingTopics
                        , topic = model.group |> Maybe.andThen .topic
                        , topics = model.topics
                        , groupId = model.groupId
                        }
                        topicModel
                        |> Html.map GotTopicsMsg

                ACM.Signup signupModel ->
                    SignupContent.view assignment signupModel |> Html.map GotSignupMsg

                _ ->
                    Html.text ""

        _ ->
            Html.text ""


initModels : SM.Model -> Array.Array Assignment -> Array.Array ACM.Model
initModels stModel =
    Array.map
        (\{ activity, activityType, completed } ->
            if activity.isSignup then
                ACM.Signup (SignupContent.init completed)

            else
                case activityType.content of
                    AT.Files files ->
                        ACM.Files (FilesContent.init files)

                    _ ->
                        contentModelByCode stModel activityType.code
        )


contentModelByCode : SM.Model -> AT.TypeCode -> ACM.Model
contentModelByCode stModel code =
    case code of
        AT.Group ->
            ACM.Group (GroupContent.init stModel)

        AT.Topic ->
            ACM.Topic TopicContent.init

        _ ->
            ACM.Empty


update : Msg -> Int -> SM.Model -> ( SM.Model, Cmd Msg )
update msg index ({ assignmentsModels, accessToken, apiBaseUrl } as model) =
    let
        apiParams =
            { token = accessToken, apiBaseUrl = apiBaseUrl }
    in
    case ( msg, Array.get index assignmentsModels ) of
        ( GotFilesMsg filesMsg, Just (ACM.Files filesModel) ) ->
            let
                ( model_, cmd ) =
                    FilesContent.update filesMsg filesModel apiParams
            in
            ( { model | assignmentsModels = Array.set index (ACM.Files model_) assignmentsModels }
            , Cmd.map GotFilesMsg cmd
            )

        ( GotGroupMsg groupMsg, Just (ACM.Group groupModel) ) ->
            let
                ( model_, cmd ) =
                    GroupContent.update groupMsg groupModel apiParams
            in
            ( { model | assignmentsModels = Array.set index (ACM.Group model_) assignmentsModels }
            , Cmd.map GotGroupMsg cmd
            )

        ( GotTopicsMsg topicMsg, Just (ACM.Topic topicModel) ) ->
            let
                ( model_, cmd ) =
                    TopicContent.update topicMsg topicModel apiParams
            in
            ( { model | assignmentsModels = Array.set index (ACM.Topic model_) assignmentsModels }
            , Cmd.map GotTopicsMsg cmd
            )

        ( GotSignupMsg signupMsg, Just (ACM.Signup signupModel) ) ->
            let
                ( model_, cmd ) =
                    SignupContent.update signupMsg signupModel apiParams
            in
            ( { model | assignmentsModels = Array.set index (ACM.Signup model_) assignmentsModels }
            , Cmd.map GotSignupMsg cmd
            )

        _ ->
            ( model, Cmd.none )
