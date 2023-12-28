module Pages.Home exposing (view)

import Element exposing (Element)
import Element.Font
import Html.Attributes
import MarkdownThemed
import Pages.Parts
import Theme
import Types exposing (..)


view : LoadedModel -> Element FrontendMsg_
view model =
    let
        sidePadding =
            if model.window.width < 800 then
                24

            else
                60
    in
    Element.column
        [ Element.width Element.fill ]
        [ Element.column
            [ Element.spacing 50
            , Element.width Element.fill
            , Element.paddingEach { left = sidePadding, right = sidePadding, top = 0, bottom = 24 }
            ]
            [ Pages.Parts.header { window = model.window, isCompact = False }
            , Element.column
                [ Element.width Element.fill, Element.spacing 40 ]
                [ Element.column Theme.contentAttributes [ content1 ]
                , Element.column
                    [ Element.width Element.fill
                    , Element.spacing 24
                    , Element.htmlAttribute (Html.Attributes.id ticketsHtmlId)
                    ]
                    [ Element.el Theme.contentAttributes content2
                    ]
                ]
            ]
        , Theme.footer
        ]


ticketsHtmlId =
    "tickets"


content1 : Element msg
content1 =
    """


Did you attend Elm Camp 2023? We're [open to contributions on Github](https://github.com/elm-camp/website/edit/main/src/Camp23Denmark/Artifacts.elm)!
        """
        |> MarkdownThemed.renderFull


content2 : Element msg
content2 =
    """

Content2
"""
        |> MarkdownThemed.renderFull
