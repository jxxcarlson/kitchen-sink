module View.MyElement exposing
    ( Label
    , emailAddressLink
    , errorColor
    , gray
    , label
    , onEnter
    , onKey
    , primaryButton
    , routeLinkNewTab
    , secondaryButton
    )

import Element exposing (Element)
import Element.Font
import Element.Input
import Html
import Html.Attributes
import Html.Events
import Json.Decode as Decode
import Martin
import Pages.Parts
import Route exposing (Route)


errorColor =
    Element.rgb 1 0 0


gray =
    Element.rgb 0.5 0.5 0.5


type alias Label msg =
    { element : Element msg, id : Martin.HtmlId }


onKey : msg -> Element.Attribute msg
onKey message =
    Html.Events.on "key" (Decode.succeed message) |> Element.htmlAttribute


onEnter : msg -> Element.Attribute msg
onEnter message =
    Html.Events.on "enter" (Decode.succeed message) |> Element.htmlAttribute


label : String -> List (Element.Attribute msg) -> Element msg -> { element : Element msg, id : Element.Input.Label msg }
label idString attrList element =
    { element = element
    , id = Element.Input.labelAbove (Martin.elementId_ idString :: attrList) (Element.text "Foo")
    }


routeLinkNewTab : Route -> Route -> Element msg
routeLinkNewTab currentRoute route =
    Element.link
        (Pages.Parts.linkStyle currentRoute route)
        { url = Route.encode route, label = Element.text (Route.encode route) }


secondaryButton : List (Element.Attribute msg) -> msg -> String -> Element msg
secondaryButton attrList message txt =
    Element.Input.button attrList { onPress = Just message, label = Element.text txt }


primaryButton : Martin.HtmlId -> msg -> String -> Element msg
primaryButton htmlId message txt =
    Element.Input.button [ Martin.elementId htmlId ] { onPress = Just message, label = Element.text txt }


emailAddressLink : String -> Element msg
emailAddressLink email =
    Html.a [ Html.Attributes.href ("mailto:" ++ email) ] [ Html.text email ] |> Element.html
