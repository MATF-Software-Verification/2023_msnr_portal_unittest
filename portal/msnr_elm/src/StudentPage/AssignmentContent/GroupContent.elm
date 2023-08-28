module StudentPage.AssignmentContent.GroupContent exposing (..)

import Accessibility.Styled as Html exposing (Html)
import Api
import Assignment exposing (Assignment)
import Css exposing (displayFlex, justifyContent, margin, px, right, spaceBetween)
import Dict exposing (Dict)
import Group exposing (Group)
import Html.Styled.Attributes exposing (css)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Nri.Ui.Button.V10 as Button
import Nri.Ui.Table.V5 as Table
import Nri.Ui.UiIcon.V1 as UiIcon
import Student exposing (Student)
import Util


type StudentAction
    = Add
    | Remove


type alias Model =
    { selectedStudents : Dict Int Student
    , processingRequest : Bool
    }


type Msg
    = AddStudent Student
    | RemoveStudent Int
    | SubmitGroup Int
    | GroupCreated (Result Http.Error Group)


init :
    { a
        | studentId : Int
        , email : String
        , firstName : String
        , lastName : String
        , indexNumber : String
        , groupId : Maybe Int
    }
    -> Model
init { firstName, lastName, indexNumber, groupId, studentId, email } =
    { selectedStudents =
        Dict.fromList
            [ ( studentId
              , Student studentId email firstName lastName indexNumber groupId
              )
            ]
    , processingRequest = False
    }


update : Msg -> Model -> { token : String, apiBaseUrl : String } -> ( Model, Cmd Msg )
update msg model apiParams =
    case msg of
        AddStudent student ->
            ( { model
                | selectedStudents =
                    Dict.insert student.id student model.selectedStudents
              }
            , Cmd.none
            )

        RemoveStudent id ->
            ( { model
                | selectedStudents =
                    Dict.remove id model.selectedStudents
              }
            , Cmd.none
            )

        SubmitGroup semesterId ->
            ( { model | processingRequest = True }
            , createGroup semesterId model apiParams
            )

        GroupCreated (Ok _) ->
            ( { model | processingRequest = False }, Cmd.none )

        GroupCreated (Err err) ->
            Debug.log (Debug.toString err) <|
                ( { model | processingRequest = False }, Cmd.none )


view :
    Assignment
    ->
        { a
            | groupId : Maybe Int
            , group : Maybe Group
            , studentId : Int
            , students : List Student
            , loadingStudents : Bool
            , loadingGroup : Bool
            , semesterId : Int
            , currentTimeSec : Int
        }
    -> Model
    -> Html Msg
view assignment { loadingStudents, loadingGroup, group, students, studentId, semesterId, currentTimeSec } model =
    let
        mainView =
            case group of
                Just group_ ->
                    Group.view group_

                Nothing ->
                    if Util.isActiveAssignment assignment currentTimeSec then
                        studentSelectionView semesterId studentId students model

                    else
                        Html.text "Jos uvek niste rasporedjeni u grupu"
    in
    if loadingStudents || loadingGroup || model.processingRequest then
        Util.loadingSpinner

    else
        mainView


studentSelectionView : Int -> Int -> List Student -> Model -> Html Msg
studentSelectionView semesterId currStudId allStudents { selectedStudents } =
    let
        tableWrapper =
            Html.div [ css [ margin (px 5) ] ] << List.singleton

        studentsWithouthGroup =
            List.filter
                (\{ id, groupId } -> Maybe.withDefault 0 groupId == 0 && not (Dict.member id selectedStudents))
                allStudents

        sumbitBtn =
            Button.button "Prijavi grupu"
                [ Button.icon UiIcon.class
                , Button.onClick (SubmitGroup semesterId)
                ]
    in
    Html.div []
        [ Html.div [ css [ displayFlex, justifyContent spaceBetween ] ]
            [ tableWrapper <| Table.view (studentColumns currStudId Add) studentsWithouthGroup
            , tableWrapper <| Table.view (studentColumns currStudId Remove) (Dict.values selectedStudents)
            ]
        , Html.div [ css [ displayFlex, justifyContent right ] ] [ sumbitBtn ]
        ]


studentColumns : Int -> StudentAction -> List (Table.Column Student Msg)
studentColumns currStudId action =
    let
        addBtn : Student -> Html Msg
        addBtn =
            \student ->
                Button.button ""
                    [ Button.small
                    , Button.secondary
                    , Button.icon UiIcon.plus
                    , Button.onClick (AddStudent student)
                    ]

        removeBtn : Student -> Html Msg
        removeBtn =
            \{ id } ->
                if id /= currStudId then
                    Button.button ""
                        [ Button.small
                        , Button.secondary
                        , Button.icon UiIcon.x
                        , Button.onClick (RemoveStudent id)
                        ]

                else
                    Html.text ""

        ( tableHeader, actionBtn ) =
            case action of
                Add ->
                    ( "Studenti bez grupe"
                    , [ Table.custom
                            { header = Html.text ""
                            , width = px 100
                            , view = addBtn
                            , cellStyles = always []
                            }
                      ]
                    )

                Remove ->
                    ( "Moja grupa"
                    , [ Table.custom
                            { header = Html.text ""
                            , width = px 100
                            , view = removeBtn
                            , cellStyles = always []
                            }
                      ]
                    )
    in
    Table.string
        { header = tableHeader
        , value = Student.toString True
        , width = px 300
        , cellStyles = always []
        }
        :: actionBtn


createGroup : Int -> Model -> { token : String, apiBaseUrl : String } -> Cmd Msg
createGroup semesterId { selectedStudents } { token, apiBaseUrl } =
    let
        body =
            Encode.object [ ( "students", Encode.list Encode.int (Dict.keys selectedStudents) ) ]
    in
    Api.post
        { apiBaseUrl = apiBaseUrl
        , endpoint = Api.endpoints.groups semesterId
        , token = token
        , body = Http.jsonBody body
        , expect =
            Http.expectJson GroupCreated <|
                Decode.map
                    (\id ->
                        { id = id
                        , students = List.map (\s -> { s | groupId = Just id }) (Dict.values selectedStudents)
                        , topic = Nothing
                        }
                    )
                    (Decode.field "data" (Decode.field "id" Decode.int))
        }
