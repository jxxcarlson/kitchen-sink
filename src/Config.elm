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
    --- Postmark.apiKey Env.postmarkApiKey
    Postmark.apiKey "8c367317-28fb-4cee-96fb-de178d607868"


postmarkNoReplyEmail : String
postmarkNoReplyEmail =
    "hello@elm-kitchen-sink.lamdera.app"


secretKey =
    case Env.mode of
        Env.Development ->
            "devsecret"

        Env.Production ->
            "prodsecret"
