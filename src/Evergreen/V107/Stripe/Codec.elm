module Evergreen.V107.Stripe.Codec exposing (..)

import Evergreen.V107.Email
import Evergreen.V107.Id
import Evergreen.V107.Stripe.PurchaseForm
import Evergreen.V107.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V107.Id.Id Evergreen.V107.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V107.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V107.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V107.Id.Id Evergreen.V107.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V107.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V107.Id.Id Evergreen.V107.Stripe.Stripe.PriceId
    , price : Evergreen.V107.Stripe.Stripe.Price
    }
