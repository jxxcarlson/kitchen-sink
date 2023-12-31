module Stripe.Purchase exposing (..)

import AssocList
import Element exposing (Element)
import Element.Background as Background
import Element.Border
import Element.Font as Font
import Element.Input
import Id exposing (Id(..))
import Stripe.Helpers
import Stripe.Stripe exposing (Price, PriceId, ProductId)
import Types exposing (..)
import View.Color
import View.Utility


type alias Ticket =
    { name : String
    , description : String
    , image : String
    , productId : String
    }


viewId : Id a -> Element msg
viewId idx =
    Element.el [ Element.width (Element.px 200) ] (Element.text (Id.toString idx))


errorText : String -> Element msg
errorText error =
    Element.paragraph [ Font.color (Element.rgb255 150 0 0) ] [ Element.text error ]
