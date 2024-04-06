module LoginWithToken exposing (Log, LogItem(..))

import Time
import User


type LogItem
    = LoginsRateLimited User.Id
    | FailedToCreateLoginCode Int


type alias Log =
    List ( Time.Posix, LogItem )
