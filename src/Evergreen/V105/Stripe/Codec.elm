module Evergreen.V105.Stripe.Codec exposing (..)

import Evergreen.V105.Email
import Evergreen.V105.Id
import Evergreen.V105.Stripe.PurchaseForm
import Evergreen.V105.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V105.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V105.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V105.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.PriceId
    , price : Evergreen.V105.Stripe.Stripe.Price
    }
