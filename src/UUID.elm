module UUID exposing (getAtmosphericRandomNumber)

import Http
import Types


getAtmosphericRandomNumber : Cmd Types.BackendMsg
getAtmosphericRandomNumber =
    Http.get
        { url = randomNumberUrl 9
        , expect = Http.expectString Types.GotAtmosphericRandomNumber
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
