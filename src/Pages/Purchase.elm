module Pages.Purchase exposing (..)

import Element
import Stripe.View
import View.Button


view model =
    Element.column []
        [ Stripe.View.prices model.prices
        ]
