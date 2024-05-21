module Evergreen.V144.MagicLink.Types exposing (..)

import Dict
import Evergreen.V144.EmailAddress
import Evergreen.V144.User
import Time


type alias EnterEmail2 =
    { email : String
    , pressedSubmitEmail : Bool
    , rateLimited : Bool
    }


type LoginCodeStatus
    = Checking
    | NotValid


type alias EnterLoginCode2 =
    { sentTo : Evergreen.V144.EmailAddress.EmailAddress
    , loginCode : String
    , attempts : Dict.Dict Int LoginCodeStatus
    }


type LoginForm
    = EnterEmail EnterEmail2
    | EnterLoginCode EnterLoginCode2


type SignInStatus
    = NotSignedIn
    | ErrorNotRegistered String
    | SuccessfulRegistration String String
    | SigningUp
    | SignedIn


type LogItem
    = LoginsRateLimited Evergreen.V144.User.Id
    | FailedToCreateLoginCode Int


type alias Log =
    List ( Time.Posix, LogItem )
