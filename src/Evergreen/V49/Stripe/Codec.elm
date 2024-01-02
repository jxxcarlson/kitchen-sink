module Evergreen.V49.Stripe.Codec exposing (..)

import Evergreen.V49.Email
import Evergreen.V49.Id
import Evergreen.V49.Stripe.PurchaseForm
import Evergreen.V49.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V49.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V49.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V49.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.PriceId
    , price : Evergreen.V49.Stripe.Stripe.Price
    }
