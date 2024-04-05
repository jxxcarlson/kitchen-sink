module Config exposing (contactEmail, postmarkServerToken, secretKey)

import Env


contactEmail : String
contactEmail =
    "foo@bar.com"


postmarkServerToken =
    case Env.mode of
        Env.Development ->
            "dev"

        Env.Production ->
            "prod"


secretKey =
    case Env.mode of
        Env.Development ->
            "dev"

        Env.Production ->
            "prod"
