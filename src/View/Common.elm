module Common exposing (radioButton, tooltip)

import Element exposing (Element)
import Element.Background
import Element.Border
import Html exposing (Html)
import Html.Attributes
import Html.Events


radioButton : String -> String -> Bool -> Element ()
radioButton groupName text isChecked =
    Html.label
        [ Html.Attributes.style "padding" "6px"
        , Html.Attributes.style "white-space" "normal"
        , Html.Attributes.style "line-height" "24px"
        ]
        [ Html.input
            [ Html.Attributes.type_ "radio"
            , Html.Attributes.checked isChecked
            , Html.Attributes.name groupName
            , Html.Events.onClick ()
            , Html.Attributes.style "transform" "translateY(-2px)"
            , Html.Attributes.style "margin" "0 8px 0 0"
            ]
            []
        , Html.text text
        ]
        |> Element.html
        |> Element.el []


tooltip : String -> Element msg
tooltip text =
    Element.paragraph
        [ Element.paddingXY 12 8
        , Element.Background.color (Element.rgb 1 1 1)
        , Element.width (Element.px 300)
        , Element.Border.shadow { offset = ( 0, 1 ), size = 0, blur = 4, color = Element.rgba 0 0 0 0.25 }
        ]
        [ Element.text text ]
