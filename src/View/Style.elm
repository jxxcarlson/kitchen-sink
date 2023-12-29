module View.Style exposing (backgroundColor, normalButtonAttributes)

import Element
import Element.Background
import Element.Border
import Element.Font


backgroundColor : Element.Color
backgroundColor =
    Element.rgb255 255 250 235


normalButtonAttributes =
    [ Element.width Element.fill
    , Element.Background.color (Element.rgb255 255 255 255)
    , Element.padding 16
    , Element.Border.rounded 8
    , Element.alignBottom
    , Element.Border.shadow { offset = ( 0, 1 ), size = 0, blur = 2, color = Element.rgba 0 0 0 0.1 }
    , Element.Font.semiBold
    ]
