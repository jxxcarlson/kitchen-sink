module Env exposing (Mode(..), adminPassword, developerEmails, developerEmails_, domain, isProduction, isProduction_, mode, postmarkApiKey, postmarkApiKey_, stripePrivateApiKey, stripePublicApiKey)

import EmailAddress exposing (EmailAddress)
import Postmark


type Mode
    = Development
    | Production


domain =
    "http://localhost:8000"


stripePrivateApiKey =
    -- Test environment, prod key set in prod (from JC app)
    "sk_test_51NAzlOJtjekdqXYjLzfJqA8YUts8rrrn1YSdikUFlZh01GzaILQwb1CjJ63DGTWktITs6UXhdV0jtVzv8Th6IXHv009EHRocoM"


stripePublicApiKey =
    "pk_test_S7leIg6SGfj2NMkUaP6ipIOv00gGgSlmgj"


isProduction_ =
    "false"


isProduction =
    String.toLower isProduction_ == "true"


postmarkApiKey_ =
    "ddd"


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
