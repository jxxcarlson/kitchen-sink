module Evergreen.V101.Stripe.Codec exposing (..)

import Evergreen.V101.Email
import Evergreen.V101.Id
import Evergreen.V101.Stripe.PurchaseForm
import Evergreen.V101.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V101.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V101.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V101.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.PriceId
    , price : Evergreen.V101.Stripe.Stripe.Price
    }
