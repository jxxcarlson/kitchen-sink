module View.Utility exposing
    ( count
    , decrementModN
    , elementAttribute
    , focusOnElement
    , format2decimals
    , formatMoney
    , incrementModN
    , jumpToTop
    , noFocus
    , onEnter
    , roundTo
    , scrollToTop
    , scrollToTopForId
    , showIf
    )

import Browser.Dom as Dom
import Element exposing (Element)
import Html
import Html.Attributes as HA
import Html.Events
import Json.Decode
import Task exposing (Task)
import Types exposing (FrontendMsg, LoadedModel)


scrollToTop : Cmd FrontendMsg
scrollToTop =
    Dom.setViewport 0 0 |> Task.perform (\() -> Types.SetViewport)


scrollToTopForId : String -> Cmd FrontendMsg
scrollToTopForId id =
    Dom.getElement id
        |> Task.andThen (\vp -> Dom.setViewport 0 vp.viewport.y)
        -- |> Task.andThen (\vp -> Dom.setViewport 0 0)
        |> Task.attempt (\_ -> Types.SetViewport)


jumpToBottom : String -> Cmd FrontendMsg
jumpToBottom id =
    Dom.getViewportOf id
        |> Task.andThen (\info -> Dom.setViewportOf id 0 info.scene.height)
        |> Task.attempt (\_ -> Types.NoOp)


jumpToTop : String -> Cmd FrontendMsg
jumpToTop id =
    Dom.getViewportOf id
        |> Task.andThen (\_ -> Dom.setViewportOf id 0 0)
        |> Task.attempt (\_ -> Types.NoOp)


onEnter : FrontendMsg -> Element.Attribute FrontendMsg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.Decode.succeed msg

            else
                Json.Decode.fail "not ENTER"
    in
    Html.Events.on "keydown" (Html.Events.keyCode |> Json.Decode.andThen isEnter)
        |> Element.htmlAttribute



---XXX---


count : List a -> List b -> Element msg
count filteredItems allItems =
    Element.el [ Element.width (Element.px 42) ]
        (Element.text
            ((String.fromInt <| List.length filteredItems)
                ++ "/"
                ++ (String.fromInt <| List.length allItems)
            )
        )


formatMoney : Float -> String
formatMoney x =
    "$" ++ format2decimals x


format2decimals : Float -> String
format2decimals x =
    let
        y =
            roundTo 2 x |> String.fromFloat
    in
    if String.contains "." y then
        case roundTo 2 x |> String.fromFloat |> String.split "." of
            [ a, b ] ->
                a ++ "." ++ String.padRight 2 '0' b

            _ ->
                y ++ ".00"

    else
        y ++ ".00"


roundTo : Int -> Float -> Float
roundTo n x =
    let
        factor =
            10.0 ^ toFloat n

        x2 =
            x * factor |> round |> toFloat
    in
    x2 / factor


incrementModN : Int -> Int -> Int
incrementModN modulus k =
    modBy modulus (k + 1)


decrementModN : Int -> Int -> Int
decrementModN modulus k =
    if k > 0 then
        modBy modulus (k - 1)

    else
        modulus - 1


showIf : Bool -> Element msg -> Element msg
showIf isVisible element =
    if isVisible then
        element

    else
        Element.none


hideIf : Bool -> Element msg -> Element msg
hideIf condition element =
    if condition then
        Element.none

    else
        element


getElementWithViewPort : Dom.Viewport -> String -> Task Dom.Error ( Dom.Element, Dom.Viewport )
getElementWithViewPort vp id =
    Dom.getElement id
        |> Task.map (\el -> ( el, vp ))


focusOnElement : String -> Cmd FrontendMsg
focusOnElement identifier =
    Task.attempt (\_ -> Types.NoOp) (Dom.focus identifier)


noFocus : Element.FocusStyle
noFocus =
    { borderColor = Nothing
    , backgroundColor = Nothing
    , shadow = Nothing
    }


cssNode : String -> Element FrontendMsg
cssNode fileName =
    Html.node "link" [ HA.rel "stylesheet", HA.href fileName ] [] |> Element.html


elementAttribute : String -> String -> Element.Attribute msg
elementAttribute key value =
    Element.htmlAttribute (HA.attribute key value)
