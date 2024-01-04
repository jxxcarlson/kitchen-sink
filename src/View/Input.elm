module View.Input exposing (passwordTemplateWithAttr, template, templateWithAttr)

import Element
import Element.Border
import Element.Font
import Element.Input
import Types
import View.Utility


template : String -> String -> (String -> msg) -> Element.Element msg
template title text onChange =
    Element.Input.text
        [ Element.Border.rounded 8 ]
        { text = text
        , onChange = onChange
        , placeholder = Nothing
        , label = Element.Input.labelAbove [ Element.Font.semiBold ] (Element.text title)
        }


templateWithAttr : List (Element.Attr () msg) -> String -> String -> (String -> msg) -> Element.Element msg
templateWithAttr attr title text onChange =
    Element.Input.text
        ([ Element.Border.rounded 8 ] ++ attr)
        { text = text
        , onChange = onChange
        , placeholder = Just (Element.Input.placeholder [] (Element.text title))
        , label = Element.Input.labelHidden ""
        }


passwordTemplateWithAttr : List (Element.Attr () msg) -> String -> String -> (String -> msg) -> Element.Element msg
passwordTemplateWithAttr attr title text onChange =
    Element.Input.newPassword
        ([ Element.Border.rounded 8 ] ++ attr)
        { text = text
        , onChange = onChange
        , placeholder = Nothing
        , label = Element.Input.labelAbove [ Element.Font.semiBold ] (Element.text title)
        , show = False
        }
