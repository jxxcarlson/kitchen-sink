module Evergreen.V137.Stripe.Codec exposing (..)

import Evergreen.V137.Email
import Evergreen.V137.Id
import Evergreen.V137.Stripe.PurchaseForm
import Evergreen.V137.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V137.Id.Id Evergreen.V137.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V137.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V137.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V137.Id.Id Evergreen.V137.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V137.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V137.Id.Id Evergreen.V137.Stripe.Stripe.PriceId
    , price : Evergreen.V137.Stripe.Stripe.Price
    }
