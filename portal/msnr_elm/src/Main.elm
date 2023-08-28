module Main exposing (main)

import Accessibility.Styled as Html exposing (Html)
import Browser exposing (Document)
import Browser.Navigation as Nav
import Css exposing (..)
import Html.Styled.Attributes exposing (css, href)
import Http
import LoginPage as Login
import Nri.Ui.AssignmentIcon.V2 as AssignmentIcon
import Nri.Ui.Button.V10 as Button
import Nri.Ui.Colors.V1 as Colors
import Nri.Ui.Heading.V2 as Heading
import Nri.Ui.Loading.V1 as LoadingSpinner
import Nri.Ui.Svg.V1 as Svg exposing (Svg)
import Nri.Ui.UiIcon.V1 as UiIcon
import Page exposing (..)
import ProfessorPage
import RegistrationPage as Registration
import Route exposing (Route)
import Session as Session exposing (Msg(..), Session, logout, silentTokenRefresh)
import SetPasswordPage as SetPassword
import StudentPage
import StudentPage.Model as StudentPageModel
import Time
import Url exposing (Url)
import Url.Parser exposing ((</>))
import UserType exposing (UserType(..))


type ContentModel
    = ProfessorModel ProfessorPage.Model
    | StudentModel StudentPageModel.Model
    | NoContent


type alias Model =
    { currentUser : UserType
    , currentRoute : Route
    , currentPage : Page
    , accessTokenExpiresIn : Float
    , key : Nav.Key
    , mainContent : ContentModel
    , initalLoading : Bool
    , apiBaseUrl : String
    }


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | GotProfessorMsg ProfessorPage.Msg
    | GotStudentMsg StudentPage.Msg
    | GotLoginMsg Login.Msg
    | GotRegistrationMsg Registration.Msg
    | GotPasswordMsg SetPassword.Msg
    | GotInitSessionMsg Session.Msg
    | GotSessionMsg Session.Msg
    | RefreshTick Time.Posix
    | Logout


updateMainContent : Model -> Session -> ContentModel
updateMainContent { mainContent, apiBaseUrl } ({ accessToken } as session) =
    case mainContent of
        NoContent ->
            initMainContent apiBaseUrl session

        ProfessorModel model ->
            ProfessorModel { model | accessToken = accessToken }

        StudentModel model ->
            StudentModel { model | accessToken = accessToken }


initMainContent : String -> Session -> ContentModel
initMainContent apiBaseUrl { accessToken, userInfo, studentInfo, semesterId } =
    case studentInfo of
        Just stInfo ->
            StudentModel (StudentPageModel.init apiBaseUrl accessToken userInfo stInfo semesterId)

        Nothing ->
            ProfessorModel (ProfessorPage.init apiBaseUrl accessToken semesterId)


updateFromSession : Model -> Session -> Model
updateFromSession model session =
    { model
        | accessTokenExpiresIn = session.expiresIn
        , currentUser = UserType.fromSession session
        , mainContent = updateMainContent model session
    }


updateFromSessionResult : Model -> Result Http.Error Session -> Model
updateFromSessionResult model result =
    case result of
        Ok session ->
            updateFromSession model session

        Err _ ->
            model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.currentPage, model.mainContent ) of
        ( ClickedLink urlRequest, _, _ ) ->
            case urlRequest of
                Browser.External href ->
                    ( model, Nav.load href )

                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

        ( ChangedUrl url, _, _ ) ->
            updateUrl url model

        ( GotInitSessionMsg (GotTokenResult result), _, _ ) ->
            let
                model_ =
                    updateFromSessionResult { model | initalLoading = False } result
            in
            case Route.guard model_.currentUser model_.currentRoute model_.key of
                Just redirection ->
                    ( model_, redirection )

                Nothing ->
                    ( model_, initCommand model_ )

        ( GotSessionMsg (GotTokenResult result), _, _ ) ->
            case result of
                Ok session ->
                    ( updateFromSession model session, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        ( GotSessionMsg (GotSessionResult result), LoginPage loginModel, _ ) ->
            case result of
                Ok session ->
                    ( updateFromSession model session, Route.redirectTo model.key Route.Home )

                Err error ->
                    ( { model | currentPage = LoginPage (Login.updateError loginModel error) }
                    , Cmd.none
                    )

        ( GotLoginMsg loginMsg, LoginPage loginModel, _ ) ->
            Login.update loginMsg loginModel
                |> toPageWithModel LoginPage GotSessionMsg model

        ( GotPasswordMsg passwordMsg, SetPasswordPage passwordModel, _ ) ->
            case passwordMsg of
                SetPassword.SessionMsg (Session.GotSessionResult (Ok session)) ->
                    ( updateFromSession model session, Route.redirectTo model.key Route.Home )

                _ ->
                    SetPassword.update passwordMsg passwordModel
                        |> toPageWithModel SetPasswordPage GotPasswordMsg model

        ( GotRegistrationMsg regMsg, RegistrationPage regModel, _ ) ->
            Registration.update regMsg regModel
                |> toPageWithModel RegistrationPage GotRegistrationMsg model

        ( GotProfessorMsg profMsg, ProfessorPage, ProfessorModel model_ ) ->
            let
                ( profModel, cmd ) =
                    ProfessorPage.update profMsg model_
            in
            ( { model | mainContent = ProfessorModel profModel }
            , cmd |> Cmd.map GotProfessorMsg
            )

        ( GotStudentMsg studentMsg, _, StudentModel model_ ) ->
            let
                ( studentModel, cmd ) =
                    StudentPage.update studentMsg model_
            in
            ( { model | mainContent = StudentModel studentModel }
            , cmd |> Cmd.map GotStudentMsg
            )

        ( RefreshTick _, _, _ ) ->
            ( model, silentTokenRefresh model.apiBaseUrl |> Cmd.map GotSessionMsg )

        ( Logout, _, _ ) ->
            ( { model | currentUser = Guest, mainContent = NoContent }
            , Cmd.batch
                [ Route.redirectTo model.key Route.Home
                , logout model.apiBaseUrl |> Cmd.map GotSessionMsg
                ]
            )

        _ ->
            ( model, Cmd.none )


toPageWithModel : (pageModel -> Page) -> (subMsg -> Msg) -> Model -> ( pageModel, Cmd subMsg ) -> ( Model, Cmd Msg )
toPageWithModel page toMsg model ( pageModel, pageCmd ) =
    ( { model | currentPage = page pageModel }
    , Cmd.map toMsg pageCmd
    )


subscriptions : Model -> Sub Msg
subscriptions { currentUser, accessTokenExpiresIn } =
    let
        refreshTick =
            case currentUser of
                Guest ->
                    Sub.none

                _ ->
                    Time.every (1000 * (accessTokenExpiresIn - 5)) RefreshTick
    in
    Sub.batch [ refreshTick ]


updateUrl : Url -> Model -> ( Model, Cmd Msg )
updateUrl url model =
    let
        route =
            Route.fromUrl url

        model_ =
            { model | currentPage = Page.forRoute route model.apiBaseUrl, currentRoute = route }
    in
    ( model_, initCommand model_ )


initCommand : Model -> Cmd Msg
initCommand { currentRoute, mainContent } =
    case ( currentRoute, mainContent ) of
        ( Route.Professor profRoute, ProfessorModel profModel ) ->
            ProfessorPage.initCmd profModel profRoute |> Cmd.map GotProfessorMsg

        ( Route.Student, StudentModel studentModel ) ->
            StudentPage.initCmd studentModel
                |> Cmd.map GotStudentMsg

        _ ->
            Cmd.none


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init { apiBaseUrl } url key =
    let
        route =
            Route.fromUrl url

        sessionCheck =
            silentTokenRefresh apiBaseUrl |> Cmd.map GotInitSessionMsg
    in
    ( { currentPage = Page.forRoute route apiBaseUrl
      , key = key
      , accessTokenExpiresIn = 0
      , currentRoute = route
      , mainContent = NoContent
      , currentUser = Guest
      , initalLoading = True
      , apiBaseUrl = apiBaseUrl
      }
    , sessionCheck
    )


homePageView : Html Msg
homePageView =
    Html.text "Home"


notFoundPageView : Html Msg
notFoundPageView =
    Html.text "Not found"


view_ : Model -> Html Msg
view_ model =
    let
        content =
            if model.initalLoading then
                LoadingSpinner.fadeInPage

            else
                case ( model.currentPage, model.mainContent ) of
                    ( HomePage, _ ) ->
                        homePageView

                    ( StudentPage, StudentModel studentModel ) ->
                        StudentPage.view studentModel |> Html.map GotStudentMsg

                    ( ProfessorPage, ProfessorModel profModel ) ->
                        ProfessorPage.view profModel model.currentRoute |> Html.map GotProfessorMsg

                    ( LoginPage loginModel, _ ) ->
                        Login.view loginModel |> Html.map GotLoginMsg

                    ( RegistrationPage regModel, _ ) ->
                        Registration.view regModel |> Html.map GotRegistrationMsg

                    ( SetPasswordPage setPwsModel, _ ) ->
                        SetPassword.view setPwsModel |> Html.map GotPasswordMsg

                    _ ->
                        notFoundPageView
    in
    Html.div
        [ css [ Css.height (vh 100), displayFlex, flexDirection column ] ]
        [ viewHeader model
        , Html.main_
            [ css
                [ backgroundColor Colors.gray96
                , flexGrow (int 1)
                , margin4 (px 0) (px 8) (px 8) (px 8)
                , padding4 (px 8) (px 0) (px 0) (px 0)
                ]
            ]
            [ content ]
        ]


view : Model -> Document Msg
view model =
    { title = "MSNR"
    , body = [ view_ model |> Html.toUnstyled ]
    }


viewHeader : Model -> Html Msg
viewHeader { currentUser, currentRoute } =
    let
        navIcon : { route : Route, icon : Svg } -> Html Msg
        navIcon { route, icon } =
            let
                isActive =
                    case ( route, currentRoute ) of
                        ( Route.Professor (Route.ActivityAssignments _), Route.Professor (Route.ActivityAssignments _) ) ->
                            True

                        _ ->
                            route == currentRoute

                color =
                    if isActive then
                        Colors.textHighlightBlue

                    else
                        Colors.gray45
            in
            Html.div
                [ css [ height (px 32), width (px 32), marginLeft (rem 1), marginRight (rem 1) ] ]
                [ Html.a
                    [ href (Route.toString route) ]
                    [ icon
                        |> Svg.withColor color
                        |> Svg.toHtml
                    ]
                ]

        navbar =
            let
                navItems =
                    Html.nav
                        [ css [ displayFlex, justifyContent center ] ]
                        << (::) (navIcon { route = Route.Home, icon = UiIcon.home })
            in
            case currentUser of
                Student _ ->
                    navItems [ navIcon { route = Route.Student, icon = AssignmentIcon.quiz } ]

                Professor _ ->
                    navItems (List.map (\{ icon, route } -> navIcon { icon = icon, route = Route.Professor route }) ProfessorPage.navIcons)

                _ ->
                    Html.text ""

        loginButtons =
            if currentUser == Guest then
                [ Button.link "Napravi nalog"
                    [ Button.secondary
                    , Button.linkSpa (Route.toString Route.Registration)
                    ]
                , Button.link "Prijavi se"
                    [ Button.primary
                    , Button.linkSpa (Route.toString Route.Login)
                    ]
                ]

            else
                [ Button.button "Odjavi se"
                    [ Button.primary
                    , Button.onClick Logout
                    ]
                ]
    in
    Html.header
        [ css
            [ backgroundColor Colors.white
            , displayFlex
            , justifyContent spaceBetween
            , alignItems center
            , margin (px 8)
            ]
        ]
        [ Heading.h2 [ Heading.css [ color Colors.textHighlightBlue ] ] [ Html.text "MSNR" ]
        , navbar
        , Html.div [] loginButtons
        ]


type alias Flags =
    { apiBaseUrl : String
    }


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
