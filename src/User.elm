module User exposing (..)

import Time


type alias User =
    { id : Int
    , name : String
    , email : String
    , password : String
    , created_at : Time.Posix
    , updated_at : Time.Posix
    }
