module User exposing
    ( EmailString
    , Id
    , LoginData
    , Role(..)
    , User
    , Username
    , loginDataOfUser
    )

import EmailAddress exposing (EmailAddress)
import Time


type alias User =
    { id : String
    , fullname : String
    , username : String
    , email : EmailAddress
    , emailString : EmailString
    , created_at : Time.Posix
    , updated_at : Time.Posix
    , roles : List Role
    , recentLoginEmails : List Time.Posix
    }


type alias Username =
    String


type alias EmailString =
    String


type alias LoginData =
    { username : String
    , email : EmailString
    , name : String
    , roles : List Role
    }


loginDataOfUser : User -> LoginData
loginDataOfUser user =
    { username = user.username
    , roles = user.roles
    , name = user.fullname
    , email = user.emailString
    }


type Role
    = AdminRole
    | UserRole


type alias Id =
    String
