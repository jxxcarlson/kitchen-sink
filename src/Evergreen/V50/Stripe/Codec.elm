module Evergreen.V50.Stripe.Codec exposing (..)

import Evergreen.V50.Email
import Evergreen.V50.Id
import Evergreen.V50.Stripe.PurchaseForm
import Evergreen.V50.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V50.Id.Id Evergreen.V50.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V50.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V50.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V50.Id.Id Evergreen.V50.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V50.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V50.Id.Id Evergreen.V50.Stripe.Stripe.PriceId
    , price : Evergreen.V50.Stripe.Stripe.Price
    }
