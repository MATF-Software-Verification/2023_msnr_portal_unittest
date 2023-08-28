module Session exposing (..)

import Api
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Token =
    String


type Msg
    = GotSessionResult (Result Http.Error Session)
    | GotTokenResult (Result Http.Error Session)
    | DeleteSessionResult (Result Http.Error ())


type alias Session =
    { accessToken : String
    , expiresIn : Float
    , userInfo : UserInfo
    , semesterId : Int
    , studentInfo : Maybe StudentInfo
    }


type alias UserInfo =
    { id : Int
    , email : String
    , firstName : String
    , lastName : String
    , role : String
    }


type alias StudentInfo =
    { groupId : Maybe Int
    , indexNumber : String
    }


decodeSession : Decoder Session
decodeSession =
    Decode.map5 Session
        (Decode.field "access_token" Decode.string)
        (Decode.field "expires_in" Decode.float)
        (Decode.field "user" decodeUser)
        (Decode.field "semester_id" Decode.int)
        (Decode.maybe (Decode.field "student_info" decodeStudentInfo))


decodeUser : Decoder UserInfo
decodeUser =
    Decode.map5 UserInfo
        (Decode.field "id" Decode.int)
        (Decode.field "email" Decode.string)
        (Decode.field "first_name" Decode.string)
        (Decode.field "last_name" Decode.string)
        (Decode.field "role" Decode.string)


decodeStudentInfo : Decoder StudentInfo
decodeStudentInfo =
    Decode.map2 StudentInfo
        (Decode.field "group_id" (Decode.nullable Decode.int))
        (Decode.field "index_number" Decode.string)


silentTokenRefresh : String -> Cmd Msg
silentTokenRefresh apiBaseUrl =
    Api.getWithCredentials
        { apiBaseUrl = apiBaseUrl
        , endpoint = Api.endpoints.refreshToken
        , expect = Http.expectJson GotTokenResult decodeSession
        }


getSession : { email : String, password : String, apiBaseUrl : String } -> Cmd Msg
getSession { email, password, apiBaseUrl } =
    let
        body =
            Encode.object
                [ ( "email", Encode.string email )
                , ( "password", Encode.string password )
                ]
    in
    Api.postWithCredentials
        { apiBaseUrl = apiBaseUrl
        , endpoint = Api.endpoints.login
        , body = Http.jsonBody body
        , expect = Http.expectJson GotSessionResult decodeSession
        }


logout : String -> Cmd Msg
logout apiBaseUrl =
    Api.getWithCredentials
        { apiBaseUrl = apiBaseUrl
        , endpoint = Api.endpoints.logout
        , expect = Http.expectWhatever DeleteSessionResult
        }
