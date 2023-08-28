module Topic exposing (..)

import Api
import Html.Attributes exposing (title)
import Http
import Json.Decode as Decode exposing (Decoder)


type alias Topic =
    { id : Int
    , title : String
    , number : Int
    }


decoder : Decoder Topic
decoder =
    Decode.map3 Topic
        (Decode.field "id" Decode.int)
        (Decode.field "title" Decode.string)
        (Decode.field "number" Decode.int)


loadTopics :
    { semesterId : Int
    , token : String
    , apiBaseUrl : String
    , msg : Result Http.Error (List Topic) -> msg
    , onlyAvailable : Bool
    }
    -> Cmd msg
loadTopics { semesterId, token, apiBaseUrl, msg, onlyAvailable } =
    let
        endpoint =
            Api.endpoints.topics semesterId
                ++ (if onlyAvailable then
                        "?available=true"

                    else
                        ""
                   )
    in
    Api.get
        { apiBaseUrl = apiBaseUrl
        , endpoint = endpoint
        , token = token
        , expect = Http.expectJson msg (Decode.field "data" (Decode.list decoder))
        }


toString : Topic -> String
toString { number, title } =
    (number
        |> String.fromInt
        |> String.padLeft 2 '0'
    )
        ++ " "
        ++ title
