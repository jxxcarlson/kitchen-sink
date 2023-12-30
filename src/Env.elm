module Env exposing (..)

import EmailAddress exposing (EmailAddress)
import Postmark


type Mode
    = Development
    | Production


domain =
    "http://localhost:8000"


stripePrivateApiKey =
    -- Test environment, prod key set in prod
    "sk_test_BmyEiWFhwdb5PH3hGD5xZXft00r6mCGnKI"


stripePublicApiKey =
    "pk_test_S7leIg6SGfj2NMkUaP6ipIOv00gGgSlmgj"


isProduction_ =
    "false"


isProduction =
    String.toLower isProduction_ == "true"


postmarkApiKey_ =
    ""


postmarkApiKey =
    Postmark.apiKey postmarkApiKey_


developerEmails_ =
    ""


developerEmails : List EmailAddress
developerEmails =
    List.filterMap (\email -> String.trim email |> EmailAddress.fromString) (String.split "," developerEmails_)


adminPassword =
    "123"


mode =
    Development
