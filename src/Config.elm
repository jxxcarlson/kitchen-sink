module Config exposing
    ( contactEmail
    , postmarkApiKey
    , postmarkServerToken
    , secretKey
    )

import Env
import Postmark exposing (ApiKey)


contactEmail : String
contactEmail =
    "foo@bar.com"


postmarkApiKey : Postmark.ApiKey
postmarkApiKey =
    case Env.mode of
        Env.Development ->
            Postmark.apiKey "dev"

        Env.Production ->
            Postmark.apiKey "prod"


postmarkServerToken : ApiKey
postmarkServerToken =
    case Env.mode of
        Env.Development ->
            Postmark.apiKey "hohoho"

        Env.Production ->
            Postmark.apiKey "hahaha


secretKey =
    case Env.mode of
        Env.Development ->
            "devsecret"

        Env.Production ->
            "prodsecret"
