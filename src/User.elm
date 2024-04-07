module User exposing (Id, LoginData, Role(..), User, loginDataOfUser)

import EmailAddress exposing (EmailAddress)
import Time


type alias User =
    { id : String
    , realname : String
    , username : String
    , email : EmailAddress
    , created_at : Time.Posix
    , updated_at : Time.Posix
    , role : Role
    , recentLoginEmails : List Time.Posix
    }


type alias LoginData =
    { username : String
    }


loginDataOfUser : User -> LoginData
loginDataOfUser user =
    { username = user.username
    }


type Role
    = AdminRole
    | UserRole


type alias Id =
    String
