module StudentPage.Model exposing (..)

import Array exposing (Array)
import Assignment exposing (Assignment)
import Dict exposing (Dict)
import FileInfo exposing (FileInfo)
import Group exposing (Group)
import Nri.Ui.TextInput.V7 exposing (email)
import Session exposing (StudentInfo, Token, UserInfo)
import Set exposing (Set)
import Student exposing (Student)
import StudentPage.AssignmentContent.Model as ACM
import Time exposing (Zone)
import Topic exposing (Topic)
import Util


type alias AssignmentsState =
    Set Int


type alias Model =
    { accessToken : Token
    , apiBaseUrl : String
    , email : String
    , firstName : String
    , lastName : String
    , studentId : Int
    , semesterId : Int
    , groupId : Maybe Int
    , loadingGroup : Bool
    , group : Maybe Group
    , indexNumber : String
    , zone : Zone
    , currentTimeSec : Int
    , loading : Bool
    , assignments : Array Assignment
    , assignmentsModels : Array ACM.Model
    , assignmentsState : AssignmentsState
    , loadingStudents : Bool
    , students : List Student
    , loadingTopics : Bool
    , topics : List Topic
    }


init : String -> Token -> UserInfo -> StudentInfo -> Int -> Model
init apiBaseUrl token { id, email, firstName, lastName } { groupId, indexNumber } semesterId =
    { accessToken = token
    , email = email
    , firstName = firstName
    , lastName = lastName
    , studentId = id
    , semesterId = semesterId
    , groupId = groupId
    , loadingGroup = Util.maybeToBool groupId
    , group = Nothing
    , indexNumber = indexNumber
    , zone = Time.utc
    , currentTimeSec = 0
    , loading = True
    , assignments = Array.empty
    , assignmentsModels = Array.empty
    , assignmentsState = Set.empty
    , loadingStudents = False
    , students = []
    , topics = []
    , loadingTopics = False
    , apiBaseUrl = apiBaseUrl
    }
