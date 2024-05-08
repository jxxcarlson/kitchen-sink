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
    Postmark.apiKey "4afe35af-5215-4356-8627-b57f0efac0cc"


postmarkNoReplyEmail : String
postmarkNoReplyEmail =
    "hello@elm-kitchen-sink.lamdera.app"


secretKey =
    case Env.mode of
        Env.Development ->
            "devsecret"

        Env.Production ->
            "prodsecret"
