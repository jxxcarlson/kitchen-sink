module View.Button exposing (buyProduct, copyTextToClipboard, playSound)

import Element
import Element.Background
import Element.Border as Border
import Element.Font
import Element.Input
import Id exposing (Id)
import Stripe.Stripe as Stripe
import Stripe.Tickets
import Theme
import Types
import View.Color


copyTextToClipboard : String -> String -> Element.Element Types.FrontendMsg
copyTextToClipboard label text =
    button (Types.CopyTextToClipboard text) label


playSound : Element.Element Types.FrontendMsg
playSound =
    button Types.Chirp "Chirp"


buyProduct : Id Stripe.ProductId -> Id Stripe.PriceId -> Stripe.Tickets.Product_ -> Element.Element Types.FrontendMsg
buyProduct productId priceId product =
    button (Types.BuyProduct productId priceId product) "Buy"



-- BUTTON FUNCTION


button msg label =
    Element.Input.button
        buttonStyle
        { onPress = Just msg
        , label =
            Element.el buttonLabelStyle (Element.text label)
        }


buttonStyle =
    [ Element.Font.color (Element.rgb 0.2 0.2 0.2)
    , Element.height Element.shrink
    , Element.paddingXY 8 8
    , Border.rounded 8
    , Element.Background.color View.Color.blue
    , Element.Font.color View.Color.white
    ]


buttonLabelStyle =
    [ Element.centerX
    , Element.centerY
    , Element.Font.size 15
    ]
