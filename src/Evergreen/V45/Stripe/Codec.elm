module Evergreen.V45.Stripe.Codec exposing (..)

import Evergreen.V45.Email
import Evergreen.V45.Id
import Evergreen.V45.Stripe.PurchaseForm
import Evergreen.V45.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V45.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V45.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V45.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.PriceId
    , price : Evergreen.V45.Stripe.Stripe.Price
    }
