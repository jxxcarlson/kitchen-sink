module Martin exposing (HtmlId(..), elementId, elementId_, idToString, noAttr)

import Element
import Html.Attributes


{-| The id of a DOM node.
-}
type HtmlId
    = HtmlId String


{-| Convert an HtmlId to a String.
-}
idToString : HtmlId -> String
idToString (HtmlId htmlId) =
    htmlId


elementId : HtmlId -> Element.Attribute msg
elementId id =
    Html.Attributes.id (idToString id) |> Element.htmlAttribute


elementId_ : String -> Element.Attribute msg
elementId_ id =
    Html.Attributes.id id |> Element.htmlAttribute


noAttr : Element.Attribute msg
noAttr =
    Element.inFront Element.none


noPointerEvents : Element.Attribute msg
noPointerEvents =
    Element.htmlAttribute (Html.Attributes.style "pointer-events" "none")



-- HtmlId "loginForm_emailInput"


emailInputId : Element.Attribute msg
emailInputId =
    Html.Attributes.id "loginForm_emailInput" |> Element.htmlAttribute
