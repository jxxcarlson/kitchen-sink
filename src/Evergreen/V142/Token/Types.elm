module Evergreen.V142.MagicLink.Types exposing (..)

import Dict
import Evergreen.V142.EmailAddress
import Evergreen.V142.User
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
    { sentTo : Evergreen.V142.EmailAddress.EmailAddress
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
    = LoginsRateLimited Evergreen.V142.User.Id
    | FailedToCreateLoginCode Int


type alias Log =
    List ( Time.Posix, LogItem )
