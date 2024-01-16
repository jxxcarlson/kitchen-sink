module View.CustomElement exposing (timeFormatted, viewDate)

import Element exposing (Element)
import Html exposing (Html, div, node, option, p, select, text)
import Html.Attributes exposing (attribute, style, value)
import Html.Events exposing (on)
import Json.Decode
import Types


fullCalendar : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
fullCalendar =
    Html.node "full-calendar"


timeFormatted : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
timeFormatted =
    Html.node "time-formatted"



-- The code below is taken from https://guide.elm-lang.org/interop/custom_elements


viewDate : String -> Element Types.FrontendMsg
viewDate language =
    div []
        [ p [] [ viewDate_ language 2012 5 ]
        , select
            [ on "change" (Json.Decode.map Types.LanguageChanged valueDecoder)
            ]
            [ option [ value "sr-RS" ] [ text "sr-RS" ]
            , option [ value "en-GB" ] [ text "en-GB" ]
            , option [ value "en-US" ] [ text "en-US" ]
            ]
        ]
        |> Element.html


viewDate_ : String -> Int -> Int -> Html msg
viewDate_ lang year month =
    node "intl-date"
        [ attribute "lang" lang
        , attribute "year" (String.fromInt year)
        , attribute "month" (String.fromInt month)
        ]
        []


valueDecoder : Json.Decode.Decoder String
valueDecoder =
    Json.Decode.field "currentTarget" (Json.Decode.field "value" Json.Decode.string)
