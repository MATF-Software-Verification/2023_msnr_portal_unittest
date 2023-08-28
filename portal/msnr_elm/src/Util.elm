module Util exposing (..)

import Accessibility.Styled as Styled
import Api
import Assignment exposing (Assignment)
import Bytes
import Calendar
import Css exposing (alignItems, backgroundColor, border3, borderRadius, boxShadow4, center, color, displayFlex, fontSize, fontWeight, height, inset, int, justifyContent, pct, px, rgb, solid, width)
import Css.Global
import Dict exposing (Dict)
import File exposing (File)
import File.Download as Download
import FileInfo exposing (FileInfo)
import Html exposing (input)
import Html.Attributes as Attrs
import Html.Events exposing (on, onInput)
import Html.Styled.Attributes exposing (css)
import Http
import Json.Decode as Decode exposing (Decoder)
import Nri.Ui.Button.V10 as Button
import Nri.Ui.Colors.V1 as Colors
import Nri.Ui.Container.V2 as Container
import Nri.Ui.Fonts.V1 as Fonts
import Nri.Ui.Heading.V2 as Heading
import Nri.Ui.Loading.V1 as LoadingSpinner
import Nri.Ui.Message.V3 as Message
import Nri.Ui.Svg.V1 as Svg
import Nri.Ui.UiIcon.V1 as UiIcon
import Time exposing (Month(..), Zone)


type ViewMode
    = DisplayMode
    | EditMode


dateView : ViewMode -> Zone -> Int -> String
dateView mode zone timeInSecs =
    let
        time =
            Time.millisToPosix (timeInSecs * 1000)

        day =
            String.padLeft 2 '0' <| String.fromInt (Time.toDay zone time)

        month =
            toTwoDigitMonth (Time.toMonth zone time)

        year =
            String.fromInt (Time.toYear zone time)
    in
    case mode of
        DisplayMode ->
            day ++ "." ++ month ++ "." ++ year ++ "."

        EditMode ->
            year ++ "-" ++ month ++ "-" ++ day


toTwoDigitMonth : Month -> String
toTwoDigitMonth month =
    case month of
        Jan ->
            "01"

        Feb ->
            "02"

        Mar ->
            "03"

        Apr ->
            "04"

        May ->
            "05"

        Jun ->
            "06"

        Jul ->
            "07"

        Aug ->
            "08"

        Sep ->
            "09"

        Oct ->
            "10"

        Nov ->
            "11"

        Dec ->
            "12"


intToMonth : Int -> Maybe Month
intToMonth month =
    case month of
        1 ->
            Just Jan

        2 ->
            Just Feb

        3 ->
            Just Mar

        4 ->
            Just Apr

        5 ->
            Just May

        6 ->
            Just Jun

        7 ->
            Just Jul

        8 ->
            Just Aug

        9 ->
            Just Sep

        10 ->
            Just Oct

        11 ->
            Just Nov

        12 ->
            Just Dec

        _ ->
            Nothing


secsFromDate : Calendar.Date -> Int
secsFromDate =
    (\x -> x // 1000) << Calendar.toMillis


dateFromString : String -> Maybe Calendar.Date
dateFromString stringTime =
    case List.filterMap String.toInt (String.split "-" stringTime) of
        [ year, month, day ] ->
            intToMonth month
                |> Maybe.andThen
                    (\m -> Calendar.fromRawParts { year = year, month = m, day = day })

        _ ->
            Nothing


inputDate : { label_ : String, msg : String -> msg, id_ : Maybe String, value : String } -> Styled.Html msg
inputDate { label_, msg, id_, value } =
    let
        inputIdAttr =
            case id_ of
                Just val ->
                    [ Attrs.id val ]

                Nothing ->
                    []
    in
    Styled.fieldset
        [ css
            [ border3 (px 1) solid (rgb 191 191 191)
            , borderRadius (px 8)
            , width (px 120)
            , boxShadow4 inset (px 0) (px 3) (rgb 235 235 235)
            ]
        ]
        [ Styled.legend
            [ css
                [ Fonts.baseFont
                , fontWeight (int 600)
                , fontSize (px 12)
                , color Colors.navy
                , backgroundColor Colors.white
                ]
            ]
            [ Styled.text label_ ]
        , Styled.fromUnstyled <|
            input ([ Attrs.type_ "date", Attrs.style "border" "0px", onInput msg, Attrs.value value ] ++ inputIdAttr) []
        ]


toDict : List { a | id : Int } -> Dict Int { a | id : Int }
toDict =
    Dict.fromList << List.map (\x -> ( x.id, x ))


loadingSpinner : Styled.Html msg
loadingSpinner =
    Styled.div [ css [ displayFlex, justifyContent center, alignItems center, height (pct 100) ] ]
        [ LoadingSpinner.spinningDots
            |> Svg.withHeight (px 50)
            |> Svg.withWidth (px 50)
            |> Svg.toHtml
        ]


errorMessage : msg -> Styled.Html msg
errorMessage dismissMsg =
    Message.view [ Message.alert, Message.large, Message.onDismiss dismissMsg, Message.plaintext "Došlo je do neočekivane greške 😞" ]


isActiveAssignment : Assignment -> Int -> Bool
isActiveAssignment { activity } currentTime =
    activity.endDate > currentTime


maybeToBool : Maybe a -> Bool
maybeToBool maybe =
    case maybe of
        Just _ ->
            True

        Nothing ->
            False


expectBytes : (Result Http.Error Bytes.Bytes -> msg) -> Http.Expect msg
expectBytes toMsg =
    Http.expectBytesResponse toMsg <|
        \response ->
            case response of
                Http.BadUrl_ url ->
                    Err (Http.BadUrl url)

                Http.Timeout_ ->
                    Err Http.Timeout

                Http.NetworkError_ ->
                    Err Http.NetworkError

                Http.BadStatus_ metadata _ ->
                    Err (Http.BadStatus metadata.statusCode)

                Http.GoodStatus_ _ body ->
                    Ok body


loadFiles : Int -> { token : String, apiBaseUrl : String } -> (Result Http.Error (List FileInfo) -> msg) -> Cmd msg
loadFiles assignmentId { apiBaseUrl, token } msg =
    Api.get
        { apiBaseUrl = apiBaseUrl
        , endpoint = Api.endpoints.documents assignmentId
        , token = token
        , expect = Http.expectJson msg (Decode.field "data" (Decode.list FileInfo.decoder))
        }


updateFile : Int -> File -> { token : String, apiBaseUrl : String } -> (Result Http.Error FileInfo -> msg) -> Cmd msg
updateFile id file { token, apiBaseUrl } msg =
    Api.put
        { apiBaseUrl = apiBaseUrl
        , endpoint = Api.endpoints.document id
        , token = token
        , body = Http.multipartBody [ Http.filePart "document" file ]
        , expect = Http.expectJson msg (Decode.field "data" FileInfo.decoder)
        }


fileInpuView : Maybe String -> String -> Decode.Decoder msg -> Styled.Html msg
fileInpuView fileName extension decoder =
    let
        fileIcon =
            Styled.div
                [ css
                    [ Css.displayFlex
                    , Css.flexDirection Css.column
                    , Css.minWidth (Css.px 50)
                    , Css.property "width" "fit-content"
                    , Css.alignItems Css.center
                    , Css.color Colors.gray45
                    , Css.backgroundColor Colors.gray96
                    , Css.borderRadius (Css.px 10)
                    , Css.padding2 (Css.px 5) (Css.px 10)
                    , Css.hover
                        [ Css.backgroundColor Colors.glacier
                        , Css.color Colors.azure
                        , Css.cursor Css.pointer
                        , Css.Global.descendants
                            [ Css.Global.selector "svg"
                                [ Css.color Colors.azure
                                ]
                            ]
                        ]
                    ]
                ]
                [ UiIcon.document |> Svg.withCss [ Css.height (Css.px 30), Css.width (Css.px 30) ] |> Svg.toHtml
                , Styled.span [] [ Styled.text (Maybe.withDefault extension fileName) ]
                ]
                |> Styled.toUnstyled
    in
    Styled.fromUnstyled <|
        Html.div []
            [ Html.label [ Attrs.for "file-upload" ] [ fileIcon ]
            , Html.input
                [ Attrs.type_ "file"
                , Attrs.id "file-upload"
                , Attrs.accept extension
                , Attrs.multiple False
                , on "change" decoder
                , Attrs.style "display" "none"
                ]
                []
            ]


filesDecoder : Decoder (List File)
filesDecoder =
    Decode.at [ "target", "files" ] (Decode.list File.decoder)


downlaodFile : Int -> { token : String, apiBaseUrl : String } -> (Result Http.Error Bytes.Bytes -> msg) -> Cmd msg
downlaodFile documentId { apiBaseUrl, token } msg =
    Api.get
        { apiBaseUrl = apiBaseUrl
        , endpoint = Api.endpoints.document documentId
        , token = token
        , expect = expectBytes msg
        }


saveData : String -> Bytes.Bytes -> Cmd msg
saveData fileName bytes =
    Download.bytes fileName "application/pdf" bytes


emptyHtmlNode : Styled.Html msg
emptyHtmlNode =
    Styled.text ""


displayIf : Bool -> Styled.Html msg -> Styled.Html msg
displayIf condition htmlNode =
    if condition then
        htmlNode

    else
        emptyHtmlNode


filesView : { isActive : Bool, editAttached : Bool, downloadMsg : FileInfo -> msg, editMsg : FileInfo -> msg } -> List FileInfo -> Styled.Html msg
filesView { isActive, editAttached, downloadMsg, editMsg } files =
    let
        displayCondition : FileInfo -> Bool
        displayCondition =
            (&&) isActive
                << (if editAttached then
                        .attached

                    else
                        not << .attached
                   )

        fileView : FileInfo -> Styled.Html msg
        fileView f =
            Container.view
                [ Container.gray
                , Container.html
                    [ Styled.div [ css [ Css.displayFlex, Css.justifyContent Css.spaceAround, Css.property "gap" "10px", Css.alignItems Css.center ] ]
                        [ Heading.h5 [] [ Styled.text f.fileName ]
                        , Styled.div [ css [ Css.displayFlex, Css.justifyContent Css.spaceAround, Css.property "gap" "10px" ] ]
                            [ Button.button "" [ Button.icon UiIcon.download, Button.onClick (downloadMsg f), Button.small ]
                            , Button.button "" [ Button.icon UiIcon.edit, Button.small, Button.onClick (editMsg f) ]
                                |> displayIf (displayCondition f)
                            ]
                        ]
                    ]
                ]
    in
    Styled.div []
        [ Heading.h4 [] [ Styled.text "Datoteke" ]
        , Styled.div [ css [ Css.displayFlex, Css.flexDirection Css.column, Css.property "gap" "10px" ] ]
            (List.map fileView files)
        ]
