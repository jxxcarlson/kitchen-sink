module Pages.Purchase exposing (..)

import AssocList
import Element
import Element.Font as Font
import Stripe.View
import Types


view : Types.LoadedModel -> Element.Element Types.FrontendMsg
view model =
    Element.column [ Element.paddingEach { top = 50, bottom = 9, left = 0, right = 0 } ]
        [ Element.el [ Font.italic, Font.size 18, Element.paddingXY 0 18 ] (Element.text "(( Oops!  A regression ... fox coming soon! ))")
        , Element.el [ Font.bold, Font.size 24 ] (Element.text "Purchase Item:")
        , Stripe.View.productList model model.productInfoDict model.prices
        , case model.selectedProduct of
            Nothing ->
                Element.none

            Just ( productId, priceId, productInfo ) ->
                case AssocList.get productId model.productInfoDict of
                    Nothing ->
                        Element.none

                    Just productInfo_ ->
                        Stripe.View.formView model productId priceId (Stripe.View.makeProduct_ productId productInfo_)
        , Element.column [ Element.paddingEach { top = 40, bottom = 10, left = 0, right = 0 } ]
            [ Element.el [ Font.bold, Font.size 24 ] (Element.text "Developer info")
            , Stripe.View.prices model.prices
            ]
        ]
