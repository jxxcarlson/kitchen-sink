module User exposing (Role(..), Session, User, UserId)

import Time


type alias UserId =
    String


type alias Session =
    { userId : UserId, expires : Time.Posix }


type alias User =
    { id : UserId
    , realname : String
    , username : String
    , email : String
    , password : String
    , created_at : Time.Posix
    , updated_at : Time.Posix
    , role : Role
    }


type Role
    = AdminRole
    | UserRole
