module View.Style exposing (normalButtonAttributes)

import Element
import Element.Background
import Element.Border
import Element.Font
import View.Color


normalButtonAttributes =
    [ Element.width Element.fill
    , Element.Background.color View.Color.blue
    , Element.padding 16
    , Element.Border.rounded 8
    , Element.Font.color View.Color.white w
    , Element.alignBottom
    , Element.Border.shadow { offset = ( 0, 1 ), size = 0, blur = 2, color = Element.rgba 0 0 0 0.1 }
    , Element.Font.semiBold
    ]
