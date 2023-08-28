module Page exposing (..)

import LoginPage as LP
import RegistrationPage as RP
import Route exposing (Route)
import SetPasswordPage as SPP
import UserType exposing (UserType(..))


type Page
    = HomePage
    | LoginPage LP.Model
    | RegistrationPage RP.Model
    | SetPasswordPage SPP.Model
    | ProfessorPage
    | StudentPage
    | NotFoundPage


forRoute : Route -> String -> Page
forRoute route apiBaseUrl =
    case route of
        Route.Home ->
            HomePage

        Route.Login ->
            LoginPage (LP.init apiBaseUrl)

        Route.Registration ->
            RegistrationPage (RP.init apiBaseUrl)

        Route.SetPassword uuid ->
            SetPasswordPage (SPP.init apiBaseUrl uuid)

        Route.Professor _ ->
            ProfessorPage

        Route.Student ->
            StudentPage

        _ ->
            NotFoundPage
