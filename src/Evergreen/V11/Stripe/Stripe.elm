module Evergreen.V11.Stripe.Stripe exposing (..)

import Evergreen.V11.Id
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
    { priceId : Evergreen.V11.Id.Id PriceId
    , price : Price
    , productId : Evergreen.V11.Id.Id ProductId
    , isActive : Bool
    , createdAt : Time.Posix
    }
