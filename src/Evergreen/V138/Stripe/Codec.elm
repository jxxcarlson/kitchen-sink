module Evergreen.V138.Stripe.Codec exposing (..)

import Evergreen.V138.Email
import Evergreen.V138.Id
import Evergreen.V138.Stripe.PurchaseForm
import Evergreen.V138.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V138.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V138.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V138.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.PriceId
    , price : Evergreen.V138.Stripe.Stripe.Price
    }
