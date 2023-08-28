module ProfessorPage.GroupsPage exposing (..)

import Accessibility.Styled as Html exposing (Html)
import Css exposing (auto, column, displayFlex, flexDirection, height, margin, maxWidth, minWidth, pct, rem, width)
import Group exposing (Group)
import Svg.Styled.Attributes exposing (css)


view : List Group -> Html msg
view =
    Html.div
        [ css
            [ displayFlex
            , flexDirection column
            , margin auto
            , height (pct 100)
            , width (pct 75)
            , maxWidth (rem 70)
            , minWidth (rem 30)
            ]
        ]
        << List.map Group.view
