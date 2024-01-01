module UUID exposing (..)

import Http
import Types


getRandomNumber : Cmd Types.BackendMsg
getRandomNumber =
    Http.get
        { url = randomNumberUrl 9
        , expect = Http.expectString Types.GotAtomsphericRandomNumber
        }


{-| maxDigits < 10
-}
randomNumberUrl : Int -> String
randomNumberUrl maxDigits =
    let
        maxNumber =
            10 ^ maxDigits

        prefix =
            "https://www.random.org/integers/?num=1&min=1&max="

        suffix =
            "&col=1&base=10&format=plain&rnd=d\n            new"
    in
    prefix ++ String.fromInt maxNumber ++ suffix
