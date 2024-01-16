module Evergreen.V130.Session exposing (..)

import BiDict
import Dict
import Lamdera
import Time


type alias Username =
    String


type alias Sessions =
    BiDict.BiDict Lamdera.SessionId Username


type Interaction
    = ISignIn Time.Posix
    | ISignOut Time.Posix
    | ISignUp Time.Posix


type alias SessionInfo =
    Dict.Dict Lamdera.SessionId Interaction
