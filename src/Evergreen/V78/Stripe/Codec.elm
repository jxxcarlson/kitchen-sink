module Evergreen.V78.Stripe.Codec exposing (..)

import Evergreen.V78.Email
import Evergreen.V78.Id
import Evergreen.V78.Stripe.PurchaseForm
import Evergreen.V78.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V78.Id.Id Evergreen.V78.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V78.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V78.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V78.Id.Id Evergreen.V78.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V78.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V78.Id.Id Evergreen.V78.Stripe.Stripe.PriceId
    , price : Evergreen.V78.Stripe.Stripe.Price
    }
