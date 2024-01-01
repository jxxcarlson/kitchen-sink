module Evergreen.V32.Stripe.Stripe exposing (..)

import AssocList
import Evergreen.V32.Id
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


type alias ProductInfo =
    { name : String
    , description : String
    }


type StripeSessionId
    = StripeSessionId Never


type alias ProductInfoDict =
    AssocList.Dict (Evergreen.V32.Id.Id ProductId) ProductInfo


type alias PriceData =
    { priceId : Evergreen.V32.Id.Id PriceId
    , price : Price
    , productId : Evergreen.V32.Id.Id ProductId
    , isActive : Bool
    , createdAt : Time.Posix
    }
