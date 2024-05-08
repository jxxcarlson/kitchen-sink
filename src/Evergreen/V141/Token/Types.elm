module Evergreen.V141.Token.Types exposing (..)

import Dict
import Evergreen.V141.EmailAddress
import Evergreen.V141.User
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
    { sentTo : Evergreen.V141.EmailAddress.EmailAddress
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
    = LoginsRateLimited Evergreen.V141.User.Id
    | FailedToCreateLoginCode Int


type alias Log =
    List ( Time.Posix, LogItem )
