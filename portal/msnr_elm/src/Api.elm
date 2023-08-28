module Api exposing (delete, endpoints, get, getWithCredentials, post, postWithCredentials, put)

import Html.Attributes exposing (headers)
import Http exposing (Body, Expect, Header)
import String exposing (fromInt)
import Url.Builder


relativeUrl : List String -> String
relativeUrl pathList =
    Url.Builder.relative pathList []


type alias Endpoints =
    { registrations : String
    , registration : Int -> String
    , registrationsPerSemester : Int -> String
    , refreshToken : String
    , login : String
    , logout : String
    , password : String -> String
    , groups : Int -> String
    , group : Int -> String
    , activityTypes : String
    , activities : Int -> String
    , assignments : Int -> String
    , assignment : Int -> String
    , activity : Int -> String
    , students : Int -> String
    , student : Int -> Int -> String
    , documents : Int -> String
    , document : Int -> String
    , topics : Int -> String
    , signup : Int -> String
    }


endpoints : Endpoints
endpoints =
    { registrations = "registrations"
    , registration = \id -> relativeUrl [ "registrations", fromInt id ]
    , registrationsPerSemester = \id -> relativeUrl [ "semesters", fromInt id, "registrations" ]
    , refreshToken = relativeUrl [ "auth", "refresh" ]
    , login = relativeUrl [ "auth", "login" ]
    , logout = relativeUrl [ "auth", "logout" ]
    , password = \uuid -> relativeUrl [ "passwords", uuid ]
    , groups = \semId -> relativeUrl [ "semesters", fromInt semId, "groups" ]
    , group = \groupId -> relativeUrl [ "groups", fromInt groupId ]
    , activityTypes = relativeUrl [ "activity-types" ]
    , activities = \semId -> relativeUrl [ "semesters", fromInt semId, "activities" ]
    , activity = \id -> relativeUrl [ "activities", fromInt id ]
    , students = \id -> relativeUrl [ "semesters", fromInt id, "students" ]
    , student = \semId studId -> relativeUrl [ "semesters", fromInt semId, "students", fromInt studId ]
    , document = \id -> relativeUrl [ "documents", fromInt id ]
    , documents = \actId -> relativeUrl [ "assignments", fromInt actId, "documents" ]
    , topics = \semId -> relativeUrl [ "semesters", fromInt semId, "topics" ]
    , signup = \id -> relativeUrl [ "signups", fromInt id ]
    , assignments = \semId -> relativeUrl [ "semesters", fromInt semId, "assignments" ]
    , assignment = \id -> relativeUrl [ "assignments", fromInt id ]
    }


authHeader : String -> Header
authHeader token =
    Http.header "Authorization" ("Bearer " ++ token)


get :
    { apiBaseUrl : String
    , endpoint : String
    , token : String
    , expect : Http.Expect msg
    }
    -> Cmd msg
get { apiBaseUrl, endpoint, token, expect } =
    let
        url =
            relativeUrl [ apiBaseUrl, endpoint ]
    in
    Http.request (requestParams "GET" [ authHeader token ] url Http.emptyBody expect)


post :
    { apiBaseUrl : String
    , endpoint : String
    , body : Http.Body
    , token : String
    , expect : Http.Expect msg
    }
    -> Cmd msg
post { apiBaseUrl, endpoint, body, token, expect } =
    let
        url =
            relativeUrl [ apiBaseUrl, endpoint ]
    in
    Http.request (requestParams "POST" [ authHeader token ] url body expect)


put :
    { apiBaseUrl : String
    , endpoint : String
    , body : Http.Body
    , token : String
    , expect : Http.Expect msg
    }
    -> Cmd msg
put { apiBaseUrl, endpoint, body, token, expect } =
    let
        url =
            relativeUrl [ apiBaseUrl, endpoint ]
    in
    Http.request (requestParams "PUT" [ authHeader token ] url body expect)


delete :
    { apiBaseUrl : String
    , endpoint : String
    , token : String
    , expect : Http.Expect msg
    }
    -> Cmd msg
delete { apiBaseUrl, endpoint, token, expect } =
    let
        url =
            relativeUrl [ apiBaseUrl, endpoint ]
    in
    Http.request (requestParams "DELETE" [ authHeader token ] url Http.emptyBody expect)


requestParams :
    String
    -> List Header
    -> String
    -> Body
    -> Expect msg
    ->
        { method : String
        , headers : List Header
        , url : String
        , body : Body
        , expect : Expect msg
        , timeout : Maybe Float
        , tracker : Maybe String
        }
requestParams method headers url body expect =
    { method = method
    , headers = headers
    , url = url
    , body = body
    , expect = expect
    , timeout = Nothing
    , tracker = Nothing
    }


getWithCredentials :
    { apiBaseUrl : String
    , endpoint : String
    , expect : Http.Expect msg
    }
    -> Cmd msg
getWithCredentials { apiBaseUrl, endpoint, expect } =
    let
        url =
            relativeUrl [ apiBaseUrl, endpoint ]
    in
    Http.riskyRequest (requestParams "GET" [] url Http.emptyBody expect)


postWithCredentials :
    { apiBaseUrl : String
    , endpoint : String
    , body : Http.Body
    , expect : Http.Expect msg
    }
    -> Cmd msg
postWithCredentials { apiBaseUrl, endpoint, body, expect } =
    let
        url =
            relativeUrl [ apiBaseUrl, endpoint ]
    in
    Http.riskyRequest (requestParams "POST" [] url body expect)
