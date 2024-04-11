module Evergreen.V134.User exposing (..)

import Evergreen.V134.EmailAddress
import Time


type Role
    = AdminRole
    | UserRole


type alias User =
    { id : String
    , realname : String
    , username : String
    , email : Evergreen.V134.EmailAddress.EmailAddress
    , created_at : Time.Posix
    , updated_at : Time.Posix
    , role : Role
    , recentLoginEmails : List Time.Posix
    }


type alias Id =
    String


type alias LoginData =
    { username : String
    }
