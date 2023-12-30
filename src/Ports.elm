port module Ports exposing
    ( stripe_from_js
    , stripe_to_js
    )

import Json.Decode
import Json.Encode


port stripe_to_js : Json.Encode.Value -> Cmd msg


port stripe_from_js : ({ msg : String, value : Json.Decode.Value } -> msg) -> Sub msg
