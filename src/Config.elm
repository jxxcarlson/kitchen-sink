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
    --Postmark.apiKey Env.postmarkApiKey
    Postmark.apiKey "0caf80fa-ebf8-42b9-9e97-abbaa5a0a86a"


postmarkNoReplyEmail : String
postmarkNoReplyEmail =
    "hello@elm-kitchen-sink.lamdera.app"


secretKey =
    case Env.mode of
        Env.Development ->
            "devsecret"

        Env.Production ->
            "prodsecret"
