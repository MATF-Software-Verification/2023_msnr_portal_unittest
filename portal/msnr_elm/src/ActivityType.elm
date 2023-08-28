module ActivityType exposing (..)

import Json.Decode as Decode exposing (Decoder)


type alias FileUploadInfo =
    { name : String
    , extension : String
    }


type TypeCode
    = Group
    | Topic
    | Other


type Content
    = Files (List FileUploadInfo)
    | Empty


type alias ActivityType =
    { id : Int
    , name : String
    , code : TypeCode
    , description : String
    , isGroup : Bool
    , hasSignup : Bool
    , content : Content
    }


decoder : Decoder ActivityType
decoder =
    Decode.map7 ActivityType
        (Decode.field "id" Decode.int)
        (Decode.field "name" Decode.string)
        (Decode.field "code" codeDecoder)
        (Decode.field "description" Decode.string)
        (Decode.field "is_group" Decode.bool)
        (Decode.field "has_signup" Decode.bool)
        (Decode.field "content" contentDecoder)


fileUploadDecoder : Decoder FileUploadInfo
fileUploadDecoder =
    Decode.map2 FileUploadInfo
        (Decode.field "name" Decode.string)
        (Decode.field "extension" Decode.string)


contentDecoder : Decoder Content
contentDecoder =
    Decode.oneOf
        [ Decode.map Files (Decode.field "files" (Decode.list fileUploadDecoder))
        , Decode.succeed Empty
        ]


codeDecoder : Decoder TypeCode
codeDecoder =
    Decode.string
        |> Decode.andThen
            (\code ->
                case code of
                    "group" ->
                        Decode.succeed Group

                    "topic" ->
                        Decode.succeed Topic

                    _ ->
                        Decode.succeed Other
            )
