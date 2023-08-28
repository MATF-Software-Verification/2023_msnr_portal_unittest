module Group exposing (..)

import Accessibility.Styled as Html exposing (Html)
import ActivityType exposing (TypeCode(..))
import Json.Decode as Decode exposing (Decoder)
import Nri.Ui.Heading.V2 as Heading
import Student exposing (Student)
import Topic exposing (Topic)
import Util


type alias Group =
    { id : Int
    , students : List Student
    , topic : Maybe Topic
    }


decoder : Decoder Group
decoder =
    Decode.map3 Group
        (Decode.field "id" Decode.int)
        (Decode.field "students" (Decode.list Student.decoder))
        (Decode.field "topic" (Decode.nullable Topic.decoder))


toString : Group -> String
toString { topic, students } =
    case topic of
        Just t ->
            Topic.toString t

        Nothing ->
            List.map .lastName students
                |> String.join ", "


view : Group -> Html msg
view { topic, students } =
    let
        topicView =
            case topic of
                Just t ->
                    Heading.h4 [] [ Html.text (Topic.toString t) ]

                Nothing ->
                    Util.emptyHtmlNode

        studentsView =
            List.map (Student.toString False) students
                |> String.join ", "
                |> List.singleton
                << Html.text
                |> Heading.h5 []
    in
    Html.div [] [ topicView, studentsView ]


