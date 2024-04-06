module User exposing (Id, Role(..), User)

import EmailAddress exposing (EmailAddress)
import Time


type alias User =
    { id : String
    , realname : String
    , username : String
    , email : EmailAddress
    , password : String
    , created_at : Time.Posix
    , updated_at : Time.Posix
    , role : Role
    , recentLoginEmails : List Time.Posix
    }


type Role
    = AdminRole
    | UserRole


type alias Id =
    String
