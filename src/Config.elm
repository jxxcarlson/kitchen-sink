module Config exposing
    ( ApiKey
    , contactEmail
    , postmarkApiKey
    , postmarkServerToken
    , secretKey
    )

import Env


contactEmail : String
contactEmail =
    "foo@bar.com"


type alias ApiKey =
    String


postmarkApiKey : ApiKey
postmarkApiKey =
    case Env.mode of
        Env.Development ->
            "dev"

        Env.Production ->
            "prod"


postmarkServerToken : ApiKey
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
