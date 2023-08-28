module Student exposing (..)

import Json.Decode as Decode exposing (Decoder)


type alias Student =
    { id : Int
    , email : String
    , firstName : String
    , lastName : String
    , indexNumber : String
    , groupId : Maybe Int
    }


decoder : Decoder Student
decoder =
    Decode.map6 Student
        (Decode.field "id" Decode.int)
        (Decode.field "email" Decode.string)
        (Decode.field "first_name" Decode.string)
        (Decode.field "last_name" Decode.string)
        (Decode.field "index_number" Decode.string)
        (Decode.field "group_id" (Decode.nullable Decode.int))


toString : Bool -> Student -> String
toString withIndex { firstName, lastName, indexNumber } =
    if withIndex then
        firstName ++ " " ++ lastName ++ " " ++ indexNumber

    else
        firstName ++ " " ++ lastName
