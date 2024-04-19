module Config exposing
    ( contactEmail
    , postmarkApiKey
    , postmarkNoReplyEmail
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


postmarkNoReplyEmail : String
postmarkNoReplyEmail =
    case Env.mode of
        Env.Development ->
            "hello@elm-kitchen-sink.lamdera.app"

        Env.Production ->
            " hello@elm-kitchen-sink.lamdera.app"


secretKey =
    case Env.mode of
        Env.Development ->
            "devsecret"

        Env.Production ->
            "prodsecret"
