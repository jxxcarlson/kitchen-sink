module Evergreen.V114.Stripe.Codec exposing (..)

import Evergreen.V114.Email
import Evergreen.V114.Id
import Evergreen.V114.Stripe.PurchaseForm
import Evergreen.V114.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V114.Id.Id Evergreen.V114.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V114.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V114.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V114.Id.Id Evergreen.V114.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V114.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V114.Id.Id Evergreen.V114.Stripe.Stripe.PriceId
    , price : Evergreen.V114.Stripe.Stripe.Price
    }
