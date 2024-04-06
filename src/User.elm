module User exposing (Id, Role(..), User)

import Time


type alias User =
    { id : String
    , realname : String
    , username : String
    , email : String
    , password : String
    , created_at : Time.Posix
    , updated_at : Time.Posix
    , role : Role
    , recentLoginEmails : Time.Posix
    }


type Role
    = AdminRole
    | UserRole


type alias Id =
    String
