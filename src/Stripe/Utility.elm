module Stripe.Utility exposing (purchaseable)

import Stripe.Product


purchaseable : String -> { a | slotsRemaining : { b | campfireTicket : Bool, campTicket : Bool, couplesCampTicket : Bool } } -> Bool
purchaseable productId model =
    if productId == Stripe.Product.ticket.campFire then
        model.slotsRemaining.campfireTicket

    else if productId == Stripe.Product.ticket.camp then
        model.slotsRemaining.campTicket

    else
        model.slotsRemaining.couplesCampTicket
