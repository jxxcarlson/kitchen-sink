module Evergreen.V139.Stripe.Codec exposing (..)

import Evergreen.V139.Email
import Evergreen.V139.Id
import Evergreen.V139.Stripe.PurchaseForm
import Evergreen.V139.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V139.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V139.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V139.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.PriceId
    , price : Evergreen.V139.Stripe.Stripe.Price
    }
