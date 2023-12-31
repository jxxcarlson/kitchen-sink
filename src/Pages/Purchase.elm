module Pages.Purchase exposing (..)

import Element
import Element.Font as Font
import Stripe.View
import Types


view : Types.LoadedModel -> Element.Element msg
view model =
    let
        _ =
            Debug.log "model.productInfoDict" model.productInfoDict
    in
    Element.column []
        [ Element.el [ Font.bold ] (Element.text "Price and product info from Stripe")
        , Stripe.View.prices model.prices
        , Element.el [ Font.bold ] (Element.text "Price and product view for user")
        , Stripe.View.productList model.productInfoDict model.prices
        ]
