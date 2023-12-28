module Pages.About exposing (..)

import Element exposing (Element)
import Types exposing (..)


view : LoadedModel -> Element FrontendMsg_
view model =
    Element.text "About"
