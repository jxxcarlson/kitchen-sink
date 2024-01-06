module Evergreen.V120.Stripe.Codec exposing (..)

import Evergreen.V120.Email
import Evergreen.V120.Id
import Evergreen.V120.Stripe.PurchaseForm
import Evergreen.V120.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V120.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V120.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V120.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.PriceId
    , price : Evergreen.V120.Stripe.Stripe.Price
    }
