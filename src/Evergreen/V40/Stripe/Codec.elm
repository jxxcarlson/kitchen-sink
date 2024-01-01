module Evergreen.V40.Stripe.Codec exposing (..)

import Evergreen.V40.Email
import Evergreen.V40.Id
import Evergreen.V40.Stripe.PurchaseForm
import Evergreen.V40.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V40.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V40.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V40.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.PriceId
    , price : Evergreen.V40.Stripe.Stripe.Price
    }
