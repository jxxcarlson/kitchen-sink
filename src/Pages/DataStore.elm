module Pages.DataStore exposing (view)

import Dict
import Element exposing (..)
import Element.Font
import KeyValueStore
import MarkdownThemed
import Types exposing (..)
import View.Button
import View.Geometry
import View.Input
import View.Utility



--view : LoadedModel -> Element FrontendMsg
--view model =
--    Element.column []
--        [ viewKeyValuePairs model
--        ]


view : LoadedModel -> Element FrontendMsg
view model =
    let
        data : List ( String, KeyValueStore.KVDatum )
        data =
            Dict.toList model.keyValueStore
                |> List.filter (\( key, value ) -> String.contains model.inputFilterData (key ++ value.value))
                |> List.sortBy (\( key, _ ) -> key)
    in
    column
        [ width fill
        , spacing 12
        , height (px <| model.window.height - 2 * View.Geometry.headerFooterHeight)
        ]
        [ -- Element.column Theme.contentAttributes [ content ]
          Element.row [ Element.spacing 24 ]
            [ View.Input.templateWithAttr [ Element.width (Element.px 150) ] "Filter Data" model.inputFilterData InputFilterData
            ]
        , Element.row [ Element.spacing 18 ]
            [ View.Button.setKVViewType model.kvViewType KeyValueStore.KVRaw "Raw Data"
            , View.Button.setKVViewType model.kvViewType KeyValueStore.KVVSummary "Summary"
            , View.Button.setKVViewType model.kvViewType KeyValueStore.KVVKey "Key"
            , View.Button.cycleVerbosity model.kvVerbosity
            ]
        , Element.column
            [ Element.scrollbars
            , Element.spacing 12
            , Element.width (Element.px 600)
            , Element.height (Element.px (model.window.height - 2 * View.Geometry.headerFooterHeight - 150))
            ]
            (case model.kvViewType of
                KeyValueStore.KVRaw ->
                    List.map (viewPair model.kvVerbosity) data

                KeyValueStore.KVVSummary ->
                    List.map (viewSummary model.kvVerbosity) data

                KeyValueStore.KVVKey ->
                    List.map viewKey data
            )
        ]


type alias Window =
    { width : Int
    , height : Int
    }


viewKey : ( String, KeyValueStore.KVDatum ) -> Element msg
viewKey ( key, value ) =
    if String.contains "\n" value.value then
        Element.column
            [ width fill
            , spacing 4
            ]
            [ Element.el [ Element.Font.bold, Element.Font.underline ] (text key)
            , KeyValueStore.rowsAndColumns value.value
            ]

    else
        Element.row
            [ width fill
            , spacing 12
            ]
            [ Element.el [ Element.Font.bold ] (text key)
            ]


viewSummary : KeyValueStore.KVVerbosity -> ( String, KeyValueStore.KVDatum ) -> Element msg
viewSummary verbosity ( key, value ) =
    let
        getSummary : String -> String
        getSummary str =
            str
                |> String.lines
                |> List.filter (\line -> String.left 1 line == "#")
                |> List.reverse
                |> List.drop 1
                |> List.reverse
                |> String.join "\n"
    in
    if String.contains "\n" value.value then
        Element.column
            [ width fill
            , spacing 4
            ]
            [ Element.el [ Element.Font.bold, Element.Font.underline ] (text key)
            , View.Utility.showIf (verbosity == KeyValueStore.KVVerbose) <| Element.el [ Element.Font.italic ] (text <| "curator: " ++ value.curator)
            , View.Utility.showIf (verbosity == KeyValueStore.KVVerbose) <| Element.el [ Element.Font.italic ] (text <| "created: " ++ View.Utility.toUtcString value.created_at)
            , View.Utility.showIf (verbosity == KeyValueStore.KVVerbose) <| Element.el [ Element.Font.italic ] (text <| "updated: " ++ View.Utility.toUtcString value.updated_at)
            , KeyValueStore.rowsAndColumns value.value
            , Element.el
                [ width fill
                , spacing 12
                , height fill
                ]
                (text (getSummary value.value))
            ]

    else
        Element.row
            [ width fill
            , spacing 12
            ]
            [ Element.el [ Element.Font.bold ] (text key)
            , text value.value
            ]


viewPair : KeyValueStore.KVVerbosity -> ( String, KeyValueStore.KVDatum ) -> Element msg
viewPair verbosity ( key, value ) =
    if String.contains "\n" value.value then
        Element.column
            [ width fill
            , spacing 4
            ]
            [ Element.el [ Element.Font.bold, Element.Font.underline ] (text key)
            , View.Utility.showIf (verbosity == KeyValueStore.KVVerbose) <| Element.el [ Element.Font.italic ] (text <| "curator: " ++ value.curator)
            , View.Utility.showIf (verbosity == KeyValueStore.KVVerbose) <| Element.el [ Element.Font.italic ] (text <| "created: " ++ View.Utility.toUtcString value.created_at)
            , View.Utility.showIf (verbosity == KeyValueStore.KVVerbose) <| Element.el [ Element.Font.italic ] (text <| "updated: " ++ View.Utility.toUtcString value.updated_at)
            , KeyValueStore.rowsAndColumns value.value
            , Element.el
                [ width fill
                , spacing 12
                , height fill
                ]
                (text value.value)
            ]

    else
        Element.row
            [ width fill
            , spacing 12
            ]
            [ Element.el [ Element.Font.bold ] (text key)
            , text value.value
            ]


content =
    """Retrieve key-value pairs by sending the requests of the form

```
curl -X POST -d '{ "key": "hubble1929" }' -H 'content-type: application/json' \\
https://elm-kitchen-sink.lamdera.app/_r/getKeyValuePair
```"""
        |> MarkdownThemed.renderFull
