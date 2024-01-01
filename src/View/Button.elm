module View.Button exposing
    ( buyProduct
    , copyTextToClipboard
    , playSound
    , setSignInState
    , signIn
    , signUp
    )

import Element
import Element.Background
import Element.Border as Border
import Element.Font
import Element.Input
import Id exposing (Id)
import Stripe.Product
import Stripe.Stripe as Stripe
import Types
import View.Color


signIn : Element.Element Types.FrontendMsg
signIn =
    button Types.SubmitSignIn "Submit"


signUp : Element.Element Types.FrontendMsg
signUp =
    button Types.SubmitSignUp "Submit"


setSignInState : String -> Types.SignInState -> Element.Element Types.FrontendMsg
setSignInState label state =
    button (Types.SetSignInState state) label


copyTextToClipboard : String -> String -> Element.Element Types.FrontendMsg
copyTextToClipboard label text =
    button (Types.CopyTextToClipboard text) label


playSound : Element.Element Types.FrontendMsg
playSound =
    button Types.Chirp "Chirp"


buyProduct : Id Stripe.ProductId -> Id Stripe.PriceId -> Stripe.Product.Product_ -> Element.Element Types.FrontendMsg
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
