module Evergreen.V144.Stripe.Codec exposing (..)

import Evergreen.V144.Email
import Evergreen.V144.Id
import Evergreen.V144.Stripe.PurchaseForm
import Evergreen.V144.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V144.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V144.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V144.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.PriceId
    , price : Evergreen.V144.Stripe.Stripe.Price
    }
