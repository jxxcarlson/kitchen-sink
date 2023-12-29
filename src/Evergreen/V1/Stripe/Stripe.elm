module Evergreen.V1.Stripe.Stripe exposing (..)

import Evergreen.V1.Id
import Money
import Time


type ProductId
    = ProductId Never


type PriceId
    = PriceId Never


type alias Price =
    { currency : Money.Currency
    , amount : Int
    }


type StripeSessionId
    = StripeSessionId Never


type alias PriceData =
    { priceId : Evergreen.V1.Id.Id PriceId
    , price : Price
    , productId : Evergreen.V1.Id.Id ProductId
    , isActive : Bool
    , createdAt : Time.Posix
    }
