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
    -- Postmark.apiKey Env.postmarkApiKey
    Postmark.apiKey "e4457a18-289d-4dd2-96f5-2ccf68dc2879"


postmarkNoReplyEmail : String
postmarkNoReplyEmail =
    "hello@elm-kitchen-sink.lamdera.app"


secretKey =
    case Env.mode of
        Env.Development ->
            "devsecret"

        Env.Production ->
            "prodsecret"
