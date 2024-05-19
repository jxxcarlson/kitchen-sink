module Config exposing
    ( contactEmail
    , postmarkApiKey
    , secretKey
    )

import Env
import Postmark exposing (ApiKey)


contactEmail : String
contactEmail =
    "foo@bar.com"


postmarkApiKey : Postmark.ApiKey
postmarkApiKey =
    -- Env.postmarkApiKey
    Postmark.apiKey "f721b217d-8e74-4d67-a88c-458e03dc137c"


postmarkNoReplyEmail : String
postmarkNoReplyEmail =
    "hello@elm-kitchen-sink.lamdera.app"


secretKey =
    case Env.mode of
        Env.Development ->
            "devsecret"

        Env.Production ->
            "prodsecret"
