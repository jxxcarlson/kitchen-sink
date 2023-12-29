module Pages.Home exposing (view)

import Element exposing (Element)
import Element.Font
import Html.Attributes
import MarkdownThemed
import Pages.Parts
import Theme
import Types exposing (..)


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
            , Element.paddingEach { left = sidePadding, right = sidePadding, top = 0, bottom = 24 }
            ]
            [ Pages.Parts.header { window = model.window, isCompact = False }
            , Element.column
                [ Element.width Element.fill, Element.spacing 40 ]
                [ Element.column Theme.contentAttributes [ content ]
                ]
            ]
        , Pages.Parts.footer
        ]


content : Element msg
content =
    """


This is the begining of a starter template for Lamdera apps. The repo is on  [Github](https://github.com/jxxcarlson/kitchen-sink-template).
        """
        |> MarkdownThemed.renderFull
