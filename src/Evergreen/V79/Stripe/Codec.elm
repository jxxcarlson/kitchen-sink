module Evergreen.V79.Stripe.Codec exposing (..)

import Evergreen.V79.Email
import Evergreen.V79.Id
import Evergreen.V79.Stripe.PurchaseForm
import Evergreen.V79.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V79.Id.Id Evergreen.V79.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V79.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V79.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V79.Id.Id Evergreen.V79.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V79.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V79.Id.Id Evergreen.V79.Stripe.Stripe.PriceId
    , price : Evergreen.V79.Stripe.Stripe.Price
    }
