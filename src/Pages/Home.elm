module Pages.Home exposing (view)

import Element exposing (Element)
import Element.Font
import Html.Attributes
import MarkdownThemed
import Pages.Parts
import Theme
import Types exposing (..)
import View.Button


view : LoadedModel -> Element FrontendMsg
view model =
    let
        sidePadding =
            if model.window.width < 800 then
                24

            else
                60
    in
    Element.column
        [ Element.width Element.fill, Element.height (Element.px model.window.height) ]
        [ Element.column
            [ Element.spacing 50
            , Element.width Element.fill
            , Element.paddingEach { left = 0, right = sidePadding, top = 0, bottom = 24 }
            ]
            [ Pages.Parts.header { window = model.window, isCompact = False }
            , Element.column
                [ Element.width Element.fill
                , Element.spacing 40
                , Element.paddingEach { left = 54, right = 0, top = 0, bottom = 0 }
                ]
                [ Element.column Theme.contentAttributes [ content ]
                ]
            , Element.column
                ([ Element.spacing 40
                 , Element.paddingEach { left = 54, right = 0, top = 0, bottom = 0 }
                 ]
                    ++ Theme.contentAttributes
                )
                [ Element.row [ Element.spacing 24 ] [ Element.text "We use ports for this: ", View.Button.playSound ] ]
            ]
        , Pages.Parts.footer
        ]


content : Element msg
content =
    """


This is the begining of a starter template for Lamdera apps. Not much to
show yet, but that will change bye and bye.
The repo is on  [Github](https://github.com/jxxcarlson/kitchen-sink).

See the **About** and **Note** tabs for more information. In **About** you will
find a list of features that will be added to this template. In **Note** you will
find details on implementing these features.

Meanwhile, below is one such feature, a button that produces a sound when clicked.
        """
        |> MarkdownThemed.renderFull
