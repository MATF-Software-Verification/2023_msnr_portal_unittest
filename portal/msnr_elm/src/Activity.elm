module Activity exposing (..)

import Json.Decode exposing (Decoder, bool, field, int, map6)
import Json.Encode as Encode


type alias Activity =
    { id : Int
    , activityTypeId : Int
    , startDate : Int
    , endDate : Int
    , isSignup : Bool
    , points : Int
    }


decoder : Decoder Activity
decoder =
    map6 Activity
        (field "id" int)
        (field "activity_type_id" int)
        (field "start_date" int)
        (field "end_date" int)
        (field "is_signup" bool)
        (field "points" int)


encode : { startDate : Int, endDate : Int, points : Int, activityTypeId : Int, isSignup : Bool } -> Encode.Value
encode { startDate, endDate, points, activityTypeId, isSignup } =
    Encode.object
        [ ( "start_date", Encode.int startDate )
        , ( "end_date", Encode.int endDate )
        , ( "points", Encode.int points )
        , ( "activity_type_id", Encode.int activityTypeId )
        , ( "is_signup", Encode.bool isSignup )
        ]
