module Evergreen.V136.Stripe.Codec exposing (..)

import Evergreen.V136.Email
import Evergreen.V136.Id
import Evergreen.V136.Stripe.PurchaseForm
import Evergreen.V136.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V136.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V136.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V136.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.PriceId
    , price : Evergreen.V136.Stripe.Stripe.Price
    }
