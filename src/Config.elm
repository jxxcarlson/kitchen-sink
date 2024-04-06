module Config exposing
    ( contactEmail
    , postmarkApiKey
    , postmarkServerToken
    , secretKey
    )

import Env


contactEmail : String
contactEmail =
    "foo@bar.com"


postmarkApiKey =
    case Env.mode of
        Env.Development ->
            "dev"

        Env.Production ->
            "prod"


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
