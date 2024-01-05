module Evergreen.V84.Stripe.Codec exposing (..)

import Evergreen.V84.Email
import Evergreen.V84.Id
import Evergreen.V84.Stripe.PurchaseForm
import Evergreen.V84.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V84.Id.Id Evergreen.V84.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V84.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V84.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V84.Id.Id Evergreen.V84.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V84.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V84.Id.Id Evergreen.V84.Stripe.Stripe.PriceId
    , price : Evergreen.V84.Stripe.Stripe.Price
    }
