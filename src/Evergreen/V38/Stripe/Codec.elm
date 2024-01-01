module Evergreen.V38.Stripe.Codec exposing (..)

import Evergreen.V38.Email
import Evergreen.V38.Id
import Evergreen.V38.Stripe.PurchaseForm
import Evergreen.V38.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V38.Id.Id Evergreen.V38.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V38.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V38.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V38.Id.Id Evergreen.V38.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V38.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V38.Id.Id Evergreen.V38.Stripe.Stripe.PriceId
    , price : Evergreen.V38.Stripe.Stripe.Price
    }
