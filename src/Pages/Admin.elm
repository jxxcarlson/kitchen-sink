module Pages.Admin exposing (view)

import Element exposing (Element)
import Element.Font
import Theme
import Types exposing (..)
import View.Button


view : LoadedModel -> Element FrontendMsg
view model =
    Element.column [ Element.paddingXY 0 30 ]
        [ Element.row
            ([ Element.spacing 20
             ]
                ++ Theme.contentAttributes
            )
            [ View.Button.playSound
            , View.Button.copyTextToClipboard "Copy Pi to Clipboard" "3.141592653589793238462643383279502884197169399375105820974944592307816406286"
            ]
        ]
