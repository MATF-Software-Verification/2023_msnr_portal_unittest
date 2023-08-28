module FileInfo exposing (..)

import Json.Decode as Decode exposing (Decoder)


type alias FileInfo =
    { id : Int
    , attached : Bool
    , fileName : String
    }


decoder : Decoder FileInfo
decoder =
    Decode.map3 FileInfo
        (Decode.field "id" Decode.int)
        (Decode.field "attached" Decode.bool)
        (Decode.field "file_name" Decode.string)
