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
    let
        saveButton =
            case model.currentUser of
                Nothing ->
                    Element.none

                Just user ->
                    if Predicate.isAdmin model.currentUser && model.inputKey /= "" && model.inputValue /= "" then
                        let
                            curator =
                                case model.currentKVPair of
                                    Nothing ->
                                        user.username

                                    Just kvp ->
                                        (Tuple.second kvp).curator

                            created_at =
                                case model.currentKVPair of
                                    Nothing ->
                                        model.now

                                    Just ( key, value ) ->
                                        value.created_at

                            kvDatum =
                                { key = model.inputKey, value = model.inputValue, curator = curator, created_at = created_at, updated_at = model.now }
                        in
                        case model.currentKVPair of
                            Nothing ->
                                View.Button.saveKeyValuePair model.inputKey kvDatum

                            Just _ ->
                                View.Button.updateKeyValuePair model.inputKey kvDatum

                    else
                        View.Button.noOp "Save"
    in
    Element.column [ Element.spacing 12 ]
        [ View.Input.templateWithAttr [] "key" model.inputKey InputKey
        , Element.row [ Element.spacing 24 ]
            [ View.Button.getValueWithKey model.inputKey
            , View.Button.newKeyValuePair
            , saveButton
            , KeyValueStore.rowsAndColumns model.inputValue

            --, Element.el [ Element.Font.italic ] (text <| "created: " ++ View.Utility.toUtcString value.created_at)
            --, Element.el [ Element.Font.italic ] (text <| "updated: " ++ View.Utility.toUtcString value.updated_at)
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
