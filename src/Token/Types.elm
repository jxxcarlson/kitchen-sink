module Token.Types exposing (EnterEmail2, EnterLoginCode2, LoginCodeStatus(..), LoginForm(..), Msg(..))

import Dict exposing (Dict)
import EmailAddress exposing (EmailAddress)


type Msg
    = PressedSubmitEmail
    | PressedCancelLogin
    | TypedLoginFormEmail String
    | TypedLoginCode String


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
