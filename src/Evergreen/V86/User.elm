module Evergreen.V86.User exposing (..)

import Time


type Role
    = AdminRole
    | UserRole


type alias User =
    { id : String
    , realname : String
    , username : String
    , email : String
    , password : String
    , created_at : Time.Posix
    , updated_at : Time.Posix
    , role : Role
    }
