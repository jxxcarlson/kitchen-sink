module Evergreen.V50.Stripe exposing (..)

import Evergreen.V50.Id
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
    { priceId : Evergreen.V50.Id.Id PriceId
    , price : Price
    , productId : Evergreen.V50.Id.Id ProductId
    , isActive : Bool
    , createdAt : Time.Posix
    }
