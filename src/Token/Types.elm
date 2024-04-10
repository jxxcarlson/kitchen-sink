module Token.Types exposing
    ( EnterEmail2
    , EnterLoginCode2
    , Log
    , LogItem(..)
    , LoginCodeStatus(..)
    , LoginForm(..)
    )

import Dict exposing (Dict)
import EmailAddress exposing (EmailAddress)
import Time
import User


type LoginForm
    = EnterEmail EnterEmail2
    | EnterLoginCode EnterLoginCode2


type alias EnterEmail2 =
    { email : String
    , pressedSubmitEmail : Bool
    , rateLimited : Bool
    }


type alias EnterLoginCode2 =
    { sentTo : EmailAddress, loginCode : String, attempts : Dict Int LoginCodeStatus }


type LoginCodeStatus
    = Checking
    | NotValid


type LogItem
    = LoginsRateLimited User.Id
    | FailedToCreateLoginCode Int


type alias Log =
    List ( Time.Posix, LogItem )
