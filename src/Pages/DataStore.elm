module Pages.DataStore exposing (view)

import Dict
import Element exposing (..)
import Element.Font
import MarkdownThemed
import Theme
import Types exposing (..)
import View.Geometry
import View.Input


view : LoadedModel -> Element FrontendMsg
view model =
    Element.column []
        [ case model.backendModel of
            Nothing ->
                text "Can't find that data"

            Just backendModel ->
                viewKeyValuePairs model backendModel
        ]


viewKeyValuePairs : LoadedModel -> BackendModel -> Element FrontendMsg
viewKeyValuePairs model backendModel =
    column
        [ width fill
        , spacing 12
        , height (px <| model.window.height - 2 * View.Geometry.headerFooterHeight)
        ]
        ([ -- Element.column Theme.contentAttributes [ content ]
           Element.row [ Element.spacing 24 ]
            [ View.Input.templateWithAttr [ Element.width (Element.px 150) ] "Filter Data" model.inputFilterData InputFilterData
            ]
         , Element.el [ Element.Font.bold, Element.Font.size 24 ] (text "Raw Data")
         ]
            ++ List.map viewPair
                (Dict.toList backendModel.keyValueStore |> List.filter (\( key, value ) -> String.contains model.inputFilterData (key ++ value)))
        )


type alias Window =
    { width : Int
    , height : Int
    }


viewPair : ( String, String ) -> Element msg
viewPair ( key, value ) =
    if String.contains "\n" value then
        Element.column
            [ width fill
            , spacing 4
            ]
            [ Element.el [ Element.Font.bold, Element.Font.underline ] (text key)
            , Element.el
                [ width fill
                , spacing 12
                , height fill
                ]
                (text value)
            ]

    else
        Element.row
            [ width fill
            , spacing 12
            ]
            [ Element.el [ Element.Font.bold ] (text key)
            , text value
            ]


content =
    """Retrieve key-value pairs by sending the requests of the form

```
curl -X POST -d '{ "key": "hubble1929" }' -H 'content-type: application/json' \\
https://elm-kitchen-sink.lamdera.app/_r/getKeyValuePair
```"""
        |> MarkdownThemed.renderFull
