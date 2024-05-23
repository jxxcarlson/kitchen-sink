module MagicLink.Types exposing
    ( EnterEmail2
    , EnterLoginCode2
    , Log
    , LogItem(..)
    , LoginCodeStatus(..)
    , LoginForm(..)
    , SignInStatus(..)
    )

import Dict exposing (Dict)
import EmailAddress exposing (EmailAddress)
import Time
import User


type LoginForm
    = EnterEmail EnterEmail2
    | EnterSigninCode EnterLoginCode2


type SignInStatus
    = NotSignedIn
    | ErrorNotRegistered String
    | SuccessfulRegistration String String
    | SigningUp
    | SignedIn


type LoginCodeStatus
    = Checking
    | NotValid


type LogItem
    = LoginsRateLimited User.Id
    | FailedToCreateLoginCode Int


type alias EnterEmail2 =
    { email : String
    , pressedSubmitEmail : Bool
    , rateLimited : Bool
    }


type alias EnterLoginCode2 =
    { sentTo : EmailAddress, loginCode : String, attempts : Dict Int LoginCodeStatus }


type alias Log =
    List ( Time.Posix, LogItem )
