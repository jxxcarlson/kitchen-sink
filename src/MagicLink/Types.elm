module MagicLink.Types exposing
    ( EnterEmail_
    , EnterLoginCode_
    , Log
    , LogItem(..)
    , LoginCodeStatus(..)
    , SignInStatus(..)
    , SigninForm(..)
    )

import Dict exposing (Dict)
import EmailAddress exposing (EmailAddress)
import Time
import User


type SigninForm
    = EnterEmail EnterEmail_
    | EnterSigninCode EnterLoginCode_


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


type alias EnterEmail_ =
    { email : String
    , pressedSubmitEmail : Bool
    , rateLimited : Bool
    }


type alias EnterLoginCode_ =
    { sentTo : EmailAddress, loginCode : String, attempts : Dict Int LoginCodeStatus }


type alias Log =
    List ( Time.Posix, LogItem )
