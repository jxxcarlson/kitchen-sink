module Evergreen.V126.Stripe.Codec exposing (..)

import Evergreen.V126.Email
import Evergreen.V126.Id
import Evergreen.V126.Stripe.PurchaseForm
import Evergreen.V126.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V126.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V126.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V126.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.PriceId
    , price : Evergreen.V126.Stripe.Stripe.Price
    }
