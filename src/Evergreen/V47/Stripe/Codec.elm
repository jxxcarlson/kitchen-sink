module Evergreen.V47.Stripe.Codec exposing (..)

import Evergreen.V47.Email
import Evergreen.V47.Id
import Evergreen.V47.Stripe.PurchaseForm
import Evergreen.V47.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V47.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V47.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V47.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.PriceId
    , price : Evergreen.V47.Stripe.Stripe.Price
    }
