module UserType exposing (..)

import Session exposing (Session, UserInfo)


type UserType
    = Guest
    | Student UserInfo
    | Professor UserInfo


fromSession : Session -> UserType
fromSession { userInfo } =
    case userInfo.role of
        "student" ->
            Student userInfo

        "professor" ->
            Professor userInfo

        _ ->
            Guest
