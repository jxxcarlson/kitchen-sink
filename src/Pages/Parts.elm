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
                64

            else
                80

        elmCampTitle =
            Element.link
                []
                { url = Route.encode HomepageRoute
                , label = Element.el [ Element.Font.size titleSize, Theme.glow, Element.paddingXY 0 8 ] (Element.text "Elm Camp")
                }

        elmCampNextTopLine =
            Element.row
                [ Element.centerX, Element.spacing 13 ]
                [ Element.image
                    [ Element.width (Element.px 49) ]
                    { src = "/elm-camp-tangram.webp", description = "The logo of Elm Camp, a tangram in green forest colors" }
                , Element.column
                    [ Element.spacing 2, Element.Font.size 24, Element.moveUp 1 ]
                    [ Element.el [ Theme.glow ] (Element.text "Unconference")
                    , Element.el [ Element.Font.extraBold, Element.Font.color MarkdownThemed.lightTheme.elmText ] (Element.text "Planet Earth 2024")
                    ]
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
            , Element.column
                [ Element.spacing 24, Element.centerX ]
                [ elmCampTitle
                , elmCampNextTopLine
                ]
            ]

    else
        Element.row
            [ Element.padding 30, Element.spacing 40, Element.centerX ]
            [ Element.image
                [ Element.width (Element.px 523) ]
                { src = "/logo.webp", description = illustrationAltText }
            , Element.column
                [ Element.spacing 24 ]
                [ elmCampTitle
                , elmCampNextTopLine
                ]
            ]
