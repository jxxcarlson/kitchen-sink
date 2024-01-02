module View.CustomElement exposing (datePicker)

import Html


datePicker : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
datePicker =
    Html.node "date-picker"
