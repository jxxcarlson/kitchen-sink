module View.Button exposing
    ( addKeyValuePair
    , askToRenewPrices
    , buyProduct
    , copyTextToClipboard
    , playSound
    , requestWeatherData
    , setAdminDisplay
    , setSignInState
    , signIn
    , signOut
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



-- USER


signIn : Element.Element Types.FrontendMsg
signIn =
    button Types.SubmitSignIn "Submit"


signOut : Element.Element Types.FrontendMsg
signOut =
    button Types.SubmitSignOut "Sign out"


signUp : Element.Element Types.FrontendMsg
signUp =
    button Types.SubmitSignUp "Submit"


setSignInState : String -> Types.SignInState -> Element.Element Types.FrontendMsg
setSignInState label state =
    button (Types.SetSignInState state) label


setAdminDisplay : Types.AdminDisplay -> Types.AdminDisplay -> String -> Element.Element Types.FrontendMsg
setAdminDisplay currentDisplay newDisplay label =
    highlightableButton (currentDisplay == newDisplay) (Types.SetAdminDisplay newDisplay) label


highlight condition =
    if condition then
        [ Element.Font.color View.Color.yellow ]

    else
        [ Element.Font.color View.Color.white ]



-- EXAMPLES


requestWeatherData : String -> Element.Element Types.FrontendMsg
requestWeatherData city =
    button (Types.RequestWeatherData city) "Get Weather"


copyTextToClipboard : String -> String -> Element.Element Types.FrontendMsg
copyTextToClipboard label text =
    button (Types.CopyTextToClipboard text) label


playSound : Element.Element Types.FrontendMsg
playSound =
    button Types.Chirp "Chirp"



-- STRIPE


buyProduct : Id Stripe.ProductId -> Id Stripe.PriceId -> Stripe.Product.Product_ -> Element.Element Types.FrontendMsg
buyProduct productId priceId product =
    button (Types.BuyProduct productId priceId product) "Buy"



-- DATA (JC)


addKeyValuePair : String -> String -> Element.Element Types.FrontendMsg
addKeyValuePair key value =
    button (Types.AddKeyValuePair key value) "Add Key-Value Pair"


askToRenewPrices : Element.Element Types.FrontendMsg
askToRenewPrices =
    button Types.AskToRenewPrices "Renew Prices"



-- BUTTON FUNCTION


button msg label =
    Element.Input.button
        buttonStyle
        { onPress = Just msg
        , label =
            Element.el buttonLabelStyle (Element.text label)
        }


highlightableButton condition msg label =
    Element.Input.button
        buttonStyle
        { onPress = Just msg
        , label =
            Element.el (buttonLabelStyle ++ highlight condition) (Element.text label)
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
