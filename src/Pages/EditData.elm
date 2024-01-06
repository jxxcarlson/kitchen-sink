module Pages.EditData exposing (view)

import Dict
import Element exposing (..)
import Element.Font
import MarkdownThemed
import Theme
import Types exposing (..)
import View.Button
import View.Geometry
import View.Input
import View.Utility


view : LoadedModel -> Element FrontendMsg
view model =
    Element.column []
        [ case model.backendModel of
            Nothing ->
                text "Can't find that data"

            Just backendModel ->
                dataEditor model backendModel
        ]


dataEditor : LoadedModel -> BackendModel -> Element FrontendMsg
dataEditor model backendModel =
    Element.column [ Element.spacing 12 ]
        [ View.Input.templateWithAttr [] "key" model.inputKey InputKey
        , View.Input.multilineTemplateWithAttr
            [ Element.width (Element.px 500)
            , Element.height (Element.px (model.window.height - 250))
            , Element.scrollbars

            --, View.Utility.elementAttribute "white-space" "pre"
            ]
            "value"
            model.inputValue
            InputValue
        , Element.row [ Element.spacing 24 ]
            [ View.Button.addKeyValuePair model.inputKey model.inputValue
            , View.Button.getValueWithKey model.inputKey
            ]
        ]


content =
    """*This tab is for a future personal project. I will remove
it when the kitchen sink project is done.*

`-- jxxcarlson`

## Edit Data
    """
        |> MarkdownThemed.renderFull