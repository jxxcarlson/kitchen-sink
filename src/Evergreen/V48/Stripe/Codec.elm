module Evergreen.V48.Stripe.Codec exposing (..)

import Evergreen.V48.Email
import Evergreen.V48.Id
import Evergreen.V48.Stripe.PurchaseForm
import Evergreen.V48.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V48.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V48.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V48.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.PriceId
    , price : Evergreen.V48.Stripe.Stripe.Price
    }
