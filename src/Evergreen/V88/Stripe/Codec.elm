module Evergreen.V88.Stripe.Codec exposing (..)

import Evergreen.V88.Email
import Evergreen.V88.Id
import Evergreen.V88.Stripe.PurchaseForm
import Evergreen.V88.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V88.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V88.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V88.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.PriceId
    , price : Evergreen.V88.Stripe.Stripe.Price
    }
