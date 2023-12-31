module View.Button exposing (playSound)

import Element
import Element.Background
import Element.Font
import Element.Input
import Theme
import Types
import View.Color


playSound : Element.Element Types.FrontendMsg
playSound =
    button Types.Chirp "Chirp"



-- BUTTON FUNCTION


button msg label =
    Element.Input.button
        buttonStyle
        { onPress = Just msg
        , label =
            Element.el buttonLabelStyle (Element.text label)
        }


buttonStyle =
    [ Element.Font.color (Element.rgb 0.2 0.2 0.2)
    , Element.height Element.shrink
    , Element.paddingXY 8 8
    , Element.Background.color View.Color.blue
    , Element.Font.color View.Color.white
    ]


buttonLabelStyle =
    [ Element.centerX
    , Element.centerY
    , Element.Font.size 15
    ]
