module Evergreen.V134.Stripe.Codec exposing (..)

import Evergreen.V134.Email
import Evergreen.V134.Id
import Evergreen.V134.Stripe.PurchaseForm
import Evergreen.V134.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V134.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V134.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V134.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.PriceId
    , price : Evergreen.V134.Stripe.Stripe.Price
    }
