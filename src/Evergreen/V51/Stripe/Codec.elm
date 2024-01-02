module Evergreen.V51.Stripe.Codec exposing (..)

import Evergreen.V51.Email
import Evergreen.V51.Id
import Evergreen.V51.Stripe.PurchaseForm
import Evergreen.V51.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V51.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V51.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V51.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.PriceId
    , price : Evergreen.V51.Stripe.Stripe.Price
    }
