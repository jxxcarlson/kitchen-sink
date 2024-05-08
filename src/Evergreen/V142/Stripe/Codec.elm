module Evergreen.V142.Stripe.Codec exposing (..)

import Evergreen.V142.Email
import Evergreen.V142.Id
import Evergreen.V142.Stripe.PurchaseForm
import Evergreen.V142.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V142.Id.Id Evergreen.V142.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V142.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V142.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V142.Id.Id Evergreen.V142.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V142.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V142.Id.Id Evergreen.V142.Stripe.Stripe.PriceId
    , price : Evergreen.V142.Stripe.Stripe.Price
    }
