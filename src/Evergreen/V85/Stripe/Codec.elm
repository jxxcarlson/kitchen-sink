module Evergreen.V85.Stripe.Codec exposing (..)

import Evergreen.V85.Email
import Evergreen.V85.Id
import Evergreen.V85.Stripe.PurchaseForm
import Evergreen.V85.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V85.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V85.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V85.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.PriceId
    , price : Evergreen.V85.Stripe.Stripe.Price
    }
