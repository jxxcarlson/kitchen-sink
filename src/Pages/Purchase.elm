module Pages.Purchase exposing (..)

import Element
import Stripe.View
import Types


view : Types.LoadedModel -> Element.Element msg
view model =
    let
        _ =
            Debug.log "model.productInfoDict" model.productInfoDict
    in
    Element.column []
        [ Stripe.View.prices model.prices
        , Stripe.View.productList model.productInfoDict model.prices
        ]
