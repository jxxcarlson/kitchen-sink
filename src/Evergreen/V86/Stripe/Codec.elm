module Evergreen.V86.Stripe.Codec exposing (..)

import Evergreen.V86.Email
import Evergreen.V86.Id
import Evergreen.V86.Stripe.PurchaseForm
import Evergreen.V86.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V86.Id.Id Evergreen.V86.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V86.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V86.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V86.Id.Id Evergreen.V86.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V86.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V86.Id.Id Evergreen.V86.Stripe.Stripe.PriceId
    , price : Evergreen.V86.Stripe.Stripe.Price
    }
