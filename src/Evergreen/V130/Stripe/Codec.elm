module Evergreen.V130.Stripe.Codec exposing (..)

import Evergreen.V130.Email
import Evergreen.V130.Id
import Evergreen.V130.Stripe.PurchaseForm
import Evergreen.V130.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V130.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V130.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V130.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.PriceId
    , price : Evergreen.V130.Stripe.Stripe.Price
    }
