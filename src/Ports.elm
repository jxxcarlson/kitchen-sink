port module Ports exposing
    ( playSound
    , stripe_from_js
    , stripe_to_js
    , supermario_copy_to_clipboard_to_js
    )

import Json.Decode
import Json.Encode


port stripe_to_js : Json.Encode.Value -> Cmd msg


port stripe_from_js : ({ msg : String, value : Json.Decode.Value } -> msg) -> Sub msg


port supermario_copy_to_clipboard_to_js : Json.Decode.Value -> Cmd msg


port playSound : Json.Encode.Value -> Cmd msg
