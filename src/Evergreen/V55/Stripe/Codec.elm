module Evergreen.V55.Stripe.Codec exposing (..)

import Evergreen.V55.Email
import Evergreen.V55.Id
import Evergreen.V55.Stripe.PurchaseForm
import Evergreen.V55.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V55.Id.Id Evergreen.V55.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V55.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V55.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V55.Id.Id Evergreen.V55.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V55.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V55.Id.Id Evergreen.V55.Stripe.Stripe.PriceId
    , price : Evergreen.V55.Stripe.Stripe.Price
    }
