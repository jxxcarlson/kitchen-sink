module View.CustomElement exposing (timeFormatted, viewDateFromTime)

import Element exposing (Element)
import Html exposing (Html, div, node, option, p, select, text)
import Html.Attributes exposing (attribute, style, value)
import Html.Events exposing (on)
import Json.Decode
import Time
import Types


fullCalendar : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
fullCalendar =
    Html.node "full-calendar"


timeFormatted : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
timeFormatted =
    Html.node "time-formatted"



-- The code below is adapted from https://guide.elm-lang.org/interop/custom_elements


viewDateFromTime : String -> Time.Zone -> Time.Posix -> Element Types.FrontendMsg
viewDateFromTime language zone time =
    div []
        [ p [ style "height" "20px", style "width" "140px" ] [ viewDate_ language (Time.toYear zone time) (monthFromTime zone time) (Time.toDay zone time) ]
        , select
            [ on "change" (Json.Decode.map Types.LanguageChanged valueDecoder)
            ]
            [ option [ value "en-US" ] [ text "en-US" ]
            , option [ value "en-GB" ] [ text "en-GB" ]
            , option [ value "sr-RS" ] [ text "sr-RS" ]
            ]
        ]
        |> Element.html


viewDate_ : String -> Int -> Int -> Int -> Html msg
viewDate_ lang year month day =
    node "intl-date"
        [ attribute "lang" lang
        , attribute "year" (String.fromInt year)
        , attribute "month" (String.fromInt (month - 1)) -- month is 0-indexed
        , attribute "day" (String.fromInt day)
        ]
        []


valueDecoder : Json.Decode.Decoder String
valueDecoder =
    Json.Decode.field "currentTarget" (Json.Decode.field "value" Json.Decode.string)


monthFromTime : Time.Zone -> Time.Posix -> Int
monthFromTime zone time =
    case Time.toMonth zone time of
        Time.Jan ->
            1

        Time.Feb ->
            2

        Time.Mar ->
            3

        Time.Apr ->
            4

        Time.May ->
            5

        Time.Jun ->
            6

        Time.Jul ->
            7

        Time.Aug ->
            8

        Time.Sep ->
            9

        Time.Oct ->
            10

        Time.Nov ->
            11

        Time.Dec ->
            12
