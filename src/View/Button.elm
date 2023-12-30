module View.Button exposing (playSound)

import Element
import Element.Background
import Element.Font
import Element.Input
import Theme
import Types


playSound =
    Element.Input.button
        [ Element.Font.color (Element.rgb 0.2 0.2 0.2)
        , Element.width (Element.px 100)
        , Element.height (Element.px 30)
        , Element.Background.color (Element.rgb 0.2 0.2 0.2)
        , Element.Font.color (Element.rgb 0.9 0.9 0.9)
        ]
        { onPress = Just Types.Chirp
        , label =
            Element.el
                [ Element.centerX
                , Element.centerY
                , Element.Font.semiBold
                , Element.Font.size 18

                --, Element.Font.color (Element.rgb 0.1 0.1 0.1)
                ]
                (Element.text "Chirp")
        }
