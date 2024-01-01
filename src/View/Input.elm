module View.Input exposing (template)

import Element
import Element.Border
import Element.Font
import Element.Input


template title text onChange =
    Element.Input.text
        [ Element.Border.rounded 8 ]
        { text = text
        , onChange = onChange
        , placeholder = Nothing
        , label = Element.Input.labelAbove [ Element.Font.semiBold ] (Element.text title)
        }
