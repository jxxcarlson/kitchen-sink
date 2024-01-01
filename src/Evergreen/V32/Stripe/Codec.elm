module Evergreen.V32.Stripe.Codec exposing (..)

import Evergreen.V32.Email
import Evergreen.V32.Id
import Evergreen.V32.Stripe.PurchaseForm
import Evergreen.V32.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V32.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V32.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V32.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.PriceId
    , price : Evergreen.V32.Stripe.Stripe.Price
    }
