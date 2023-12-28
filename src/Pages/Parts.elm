module Pages.Parts exposing (header)

import Element exposing (Element)
import Element.Font
import MarkdownThemed
import Route exposing (Route(..))
import Theme


header : { window : { width : Int, height : Int }, isCompact : Bool } -> Element msg
header config =
    let
        illustrationAltText =
            "Illustration of a small camp site in a richly green forest"

        titleSize =
            if config.window.width < 800 then
                35

            else
                50

        elmCampTitle =
            Element.link
                []
                { url = Route.encode HomepageRoute
                , label = Element.el [ Element.Font.size titleSize, Theme.glow, Element.paddingXY 0 8 ] (Element.text "Kitchen Sink App Template")
                }

        elmCampNextTopLine =
            Element.row
                [ Element.centerX, Element.spacing 13 ]
                [ Element.image
                    [ Element.width (Element.px 49) ]
                    { src = "/elm-camp-tangram.webp", description = "The Elm Logo" }
                ]
    in
    if config.window.width < 1000 || config.isCompact then
        Element.column
            [ Element.padding 30, Element.spacing 20, Element.centerX ]
            [ if config.isCompact then
                Element.none

              else
                Element.image
                    [ Element.width (Element.maximum 523 Element.fill) ]
                    { src = "/logo.webp", description = illustrationAltText }
            , Element.row
                [ Element.spacing 24, Element.centerX ]
                [ elmCampTitle
                , elmCampNextTopLine
                ]
            ]

    else
        Element.row
            [ Element.padding 30, Element.spacing 40, Element.centerX ]
            [ elmCampTitle
            , elmCampNextTopLine
            ]
