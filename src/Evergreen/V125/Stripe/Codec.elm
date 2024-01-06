module Evergreen.V125.Stripe.Codec exposing (..)

import Evergreen.V125.Email
import Evergreen.V125.Id
import Evergreen.V125.Stripe.PurchaseForm
import Evergreen.V125.Stripe.Stripe
import Lamdera
import Time


type alias Order =
    { priceId : Evergreen.V125.Id.Id Evergreen.V125.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V125.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : Evergreen.V125.Email.EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V125.Id.Id Evergreen.V125.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V125.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V125.Id.Id Evergreen.V125.Stripe.Stripe.PriceId
    , price : Evergreen.V125.Stripe.Stripe.Price
    }
