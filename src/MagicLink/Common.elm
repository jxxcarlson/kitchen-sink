module MagicLink.Common exposing (..)

import Lamdera exposing (..)
import Types


sendMessage : ClientId -> String -> Cmd msg
sendMessage clientId message =
    Lamdera.sendToFrontend clientId
        (Types.ReceivedMessage (Ok message))
