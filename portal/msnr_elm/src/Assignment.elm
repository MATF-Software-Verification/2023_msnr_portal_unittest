module Assignment exposing (..)

import Activity exposing (Activity)
import ActivityType exposing (ActivityType)
import Json.Decode exposing (Decoder, bool, field, int, map6, map7, nullable, string)
import Json.Encode as Encode


type alias Assignment =
    { id : Int
    , grade : Maybe Int
    , completed : Bool
    , comment : Maybe String
    , activity : Activity
    , activityType : ActivityType
    }


decoder : Decoder Assignment
decoder =
    map6 Assignment
        (field "id" int)
        (field "grade" (nullable int))
        (field "completed" bool)
        (field "comment" (nullable string))
        (field "activity" Activity.decoder)
        (field "activity_type" ActivityType.decoder)


encodeActivity : Assignment -> Encode.Value
encodeActivity { activity } =
    Encode.object
        [ ( "activity"
          , Encode.object
                [ ( "starts_sec", Encode.int activity.startDate )
                , ( "ends_sec", Encode.int activity.endDate )
                ]
          )
        ]


type alias ShallowAssignment =
    { id : Int
    , activityId : Int
    , studentId : Maybe Int
    , groupId : Maybe Int
    , grade : Maybe Int
    , comment : Maybe String
    , completed : Bool
    }


shallowDecoder : Decoder ShallowAssignment
shallowDecoder =
    map7 ShallowAssignment
        (field "id" int)
        (field "activity_id" int)
        (field "student_id" (nullable int))
        (field "group_id" (nullable int))
        (field "grade" (nullable int))
        (field "comment" (nullable string))
        (field "completed" bool)
