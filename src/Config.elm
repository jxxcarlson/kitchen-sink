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
    Postmark.apiKey "f41d1173-86ca-419b-a4ef-e420bffc2624"


postmarkNoReplyEmail : String
postmarkNoReplyEmail =
    "hello@elm-kitchen-sink.lamdera.app"


secretKey =
    case Env.mode of
        Env.Development ->
            "devsecret"

        Env.Production ->
            "prodsecret"
