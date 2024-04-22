module Evergreen.V135.Stripe.Codec exposing (..)

import Evergreen.V135.Email
import Evergreen.V135.Id
import Evergreen.V135.Stripe.PurchaseForm
import Evergreen.V135.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V135.Id.Id Evergreen.V135.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V135.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V135.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V135.Id.Id Evergreen.V135.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V135.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V135.Id.Id Evergreen.V135.Stripe.Stripe.PriceId
    , price : Evergreen.V135.Stripe.Stripe.Price
    }
