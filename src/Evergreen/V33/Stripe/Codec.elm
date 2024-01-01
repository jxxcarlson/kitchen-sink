module Evergreen.V33.Stripe.Codec exposing (..)

import Evergreen.V33.Email
import Evergreen.V33.Id
import Evergreen.V33.Stripe.PurchaseForm
import Evergreen.V33.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V33.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V33.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V33.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.PriceId
    , price : Evergreen.V33.Stripe.Stripe.Price
    }
