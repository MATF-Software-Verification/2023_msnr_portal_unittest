module Route exposing (..)

import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, parse, s, string, top)
import UserType as UT exposing (UserType)


type Route
    = Home
    | Student
    | Login
    | Registration
    | Professor ProfessorSubRoute
    | SetPassword String
    | NotFound


type alias ActivityId =
    Int


type ProfessorSubRoute
    = RegistrationRequests
    | Activities
    | ActivityAssignments ActivityId
    | Topics
    | Groups


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home top
        , Parser.map Student (s "student")
        , Parser.map Login (s "login")
        , Parser.map Registration (s "register")
        , Parser.map Professor (s "professor" </> professorParser)
        , Parser.map SetPassword (s "setPassword" </> string)
        , Parser.map NotFound (s "notFound")
        ]


professorParser : Parser (ProfessorSubRoute -> a) a
professorParser =
    Parser.oneOf
        [ Parser.map RegistrationRequests (s "registrations")
        , Parser.map Activities (s "activities")
        , Parser.map ActivityAssignments (s "activities" </> Parser.int </> s "assignments")
        , Parser.map Topics (s "topics")
        , Parser.map Groups (s "groups")
        ]


fromUrl : Url -> Route
fromUrl =
    Maybe.withDefault NotFound << parse parser


guard : UserType -> Route -> Nav.Key -> Maybe (Cmd msg)
guard user route key =
    let
        redirectWithKey =
            redirectTo key
    in
    case ( user, route ) of
        ( UT.Guest, Home ) ->
            Nothing

        ( UT.Guest, Login ) ->
            Nothing

        ( UT.Guest, Registration ) ->
            Nothing

        ( UT.Guest, SetPassword _ ) ->
            Nothing

        ( UT.Student _, Student ) ->
            Nothing

        ( UT.Student _, _ ) ->
            Just (redirectWithKey Home)

        ( UT.Professor _, Professor _ ) ->
            Nothing

        ( UT.Professor _, _ ) ->
            Just (redirectWithKey Home)

        _ ->
            Just (redirectWithKey NotFound)


redirectTo : Nav.Key -> Route -> Cmd msg
redirectTo key route =
    Nav.pushUrl key (toString route)


toString : Route -> String
toString route =
    case route of
        Home ->
            "/"

        Student ->
            "/student"

        Login ->
            "/login"

        Registration ->
            "/register"

        Professor subRoute ->
            "/professor" ++ professorSubRouteToString subRoute

        SetPassword uuid ->
            "/setPassword/" ++ uuid

        NotFound ->
            "/notFound"


professorSubRouteToString : ProfessorSubRoute -> String
professorSubRouteToString route =
    case route of
        RegistrationRequests ->
            "/registrations"

        Activities ->
            "/activities"

        ActivityAssignments activityId ->
            "/activities/" ++ String.fromInt activityId ++ "/assignments"

        Topics ->
            "/topics"

        Groups ->
            "/groups"
