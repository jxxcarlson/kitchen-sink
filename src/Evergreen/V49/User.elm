module Evergreen.V49.User exposing (..)

import Time


type alias User =
    { id : String
    , realname : String
    , username : String
    , email : String
    , password : String
    , created_at : Time.Posix
    , updated_at : Time.Posix
    }
