module Pages.Parts exposing (footer, header)

import Element exposing (Element)
import Element.Background
import Element.Font
import Route exposing (Route(..))
import Theme


header : { window : { width : Int, height : Int }, isCompact : Bool } -> Element msg
header config =
    Element.el
        [ Element.Background.color (Element.rgb255 64 64 109)
        , Element.paddingXY 24 16
        , Element.width Element.fill
        , Element.alignTop
        ]
        (Element.wrappedRow
            ([ Element.spacing 32
             , Element.Background.color (Element.rgb255 64 64 109)
             , Element.Font.color (Element.rgb 1 1 1)
             ]
                ++ Theme.contentAttributes
            )
            [ Element.link
                []
                { url = Route.encode HomepageRoute, label = Element.text "Home" }
            , Element.link
                []
                { url = Route.encode About, label = Element.text "About" }
            , Element.link
                []
                { url = Route.encode Notes, label = Element.text "Notes" }
            ]
        )


footer : Element msg
footer =
    Element.el
        [ Element.Background.color (Element.rgb255 64 64 109)
        , Element.paddingXY 24 16
        , Element.width Element.fill
        , Element.alignBottom
        ]
        (Element.wrappedRow
            ([ Element.spacing 32
             , Element.Background.color (Element.rgb255 64 64 109)
             , Element.Font.color (Element.rgb 1 1 1)
             ]
                ++ Theme.contentAttributes
            )
            [ Element.link
                []
                { url = Route.encode Brillig, label = Element.text "Brillig" }
            ]
        )
