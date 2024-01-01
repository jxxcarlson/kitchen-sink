module Evergreen.V42.Stripe.Codec exposing (..)

import Evergreen.V42.Email
import Evergreen.V42.Id
import Evergreen.V42.Stripe.PurchaseForm
import Evergreen.V42.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V42.Id.Id Evergreen.V42.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V42.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V42.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V42.Id.Id Evergreen.V42.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V42.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V42.Id.Id Evergreen.V42.Stripe.Stripe.PriceId
    , price : Evergreen.V42.Stripe.Stripe.Price
    }
