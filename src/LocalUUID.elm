module LocalUUID exposing (getAtmosphericRandomNumbers, randomNumberUrl)

import Http
import Types


getAtmosphericRandomNumbers : Cmd Types.BackendMsg
getAtmosphericRandomNumbers =
    Http.get
        { url = randomNumberUrl 4 9
        , expect = Http.expectString Types.GotAtmosphericRandomNumbers
        }


{-| maxDigits < 10
-}
randomNumberUrl : Int -> Int -> String
randomNumberUrl n maxDigits =
    let
        maxNumber =
            10 ^ maxDigits

        prefix =
            "https://www.random.org/integers/?num="

        suffix =
            "&col=" ++ String.fromInt n ++ "&base=10&format=plain&rnd=new"
    in
    prefix ++ String.fromInt n ++ "&min=1&max=" ++ String.fromInt maxNumber ++ suffix
