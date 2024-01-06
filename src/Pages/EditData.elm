module Pages.EditData exposing (view)

import Dict
import Element exposing (..)
import Element.Font
import KeyValueStore
import MarkdownThemed
import Predicate
import Theme
import Types exposing (..)
import View.Button
import View.Geometry
import View.Input
import View.Utility


view : LoadedModel -> Element FrontendMsg
view model =
    Element.column []
        [ dataEditor model
        ]


dataEditor : LoadedModel -> Element FrontendMsg
dataEditor model =
    Element.column [ Element.spacing 12 ]
        [ View.Input.templateWithAttr [] "key" model.inputKey InputKey
        , Element.row [ Element.spacing 24 ]
            [ View.Button.getValueWithKey model.inputKey
            , case model.currentUser of
                Nothing ->
                    Element.none

                Just user ->
                    if Predicate.isAdmin model.currentUser then
                        let
                            kvDatum =
                                { key = model.inputKey, value = model.inputValue, curator = "", created_at = model.now, updated_at = model.now }
                        in
                        View.Button.addKeyValuePair model.inputKey kvDatum

                    else
                        Element.none
            , KeyValueStore.rowsAndColumns model.inputValue
            ]
        , View.Input.multilineTemplateWithAttr
            [ Element.width (Element.px 550)
            , Element.height (Element.px (model.window.height - 250))
            , Element.scrollbars
            ]
            "value"
            model.inputValue
            InputValue
        ]


content =
    """*This tab is for a future personal project. I will remove
it when the kitchen sink project is done.*

`-- jxxcarlson`

## Edit Data
    """
        |> MarkdownThemed.renderFull
