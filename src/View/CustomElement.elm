module View.CustomElement exposing (fullCalendar, timeFormatted)

import Html


fullCalendar : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
fullCalendar =
    Html.node "full-calendar"


timeFormatted : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
timeFormatted =
    Html.node "time-formatted"
