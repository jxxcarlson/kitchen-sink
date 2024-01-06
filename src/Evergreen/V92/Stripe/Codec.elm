module Evergreen.V92.Stripe.Codec exposing (..)

import Evergreen.V92.Email
import Evergreen.V92.Id
import Evergreen.V92.Stripe.PurchaseForm
import Evergreen.V92.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V92.Id.Id Evergreen.V92.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V92.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V92.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V92.Id.Id Evergreen.V92.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V92.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V92.Id.Id Evergreen.V92.Stripe.Stripe.PriceId
    , price : Evergreen.V92.Stripe.Stripe.Price
    }
