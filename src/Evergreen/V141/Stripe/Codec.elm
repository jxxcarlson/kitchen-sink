module Evergreen.V141.Stripe.Codec exposing (..)

import Evergreen.V141.Email
import Evergreen.V141.Id
import Evergreen.V141.Stripe.PurchaseForm
import Evergreen.V141.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V141.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V141.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V141.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.PriceId
    , price : Evergreen.V141.Stripe.Stripe.Price
    }
