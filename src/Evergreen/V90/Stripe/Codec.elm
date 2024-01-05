module Evergreen.V90.Stripe.Codec exposing (..)

import Evergreen.V90.Email
import Evergreen.V90.Id
import Evergreen.V90.Stripe.PurchaseForm
import Evergreen.V90.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V90.Id.Id Evergreen.V90.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V90.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V90.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V90.Id.Id Evergreen.V90.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V90.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V90.Id.Id Evergreen.V90.Stripe.Stripe.PriceId
    , price : Evergreen.V90.Stripe.Stripe.Price
    }
