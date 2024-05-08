module Evergreen.V143.Stripe.Codec exposing (..)

import Evergreen.V143.Email
import Evergreen.V143.Id
import Evergreen.V143.Stripe.PurchaseForm
import Evergreen.V143.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V143.Id.Id Evergreen.V143.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V143.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V143.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V143.Id.Id Evergreen.V143.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V143.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V143.Id.Id Evergreen.V143.Stripe.Stripe.PriceId
    , price : Evergreen.V143.Stripe.Stripe.Price
    }
