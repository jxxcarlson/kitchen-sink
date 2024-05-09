module View.Button exposing
    ( askToRenewPrices
    , buyProduct
    , cancelSignUp
    , copyTextToClipboard
    , cycleVerbosity
    , getValueWithKey
    , newKeyValuePair
    , noOp
    , openSignUp
    , playSound
    , saveKeyValuePair
    , setAdminDisplay
    , setKVViewType
    , signOut
    , signUp
    , updateKeyValuePair
    )

import Element
import Element.Background
import Element.Border as Border
import Element.Font
import Element.Input
import Id exposing (Id)
import KeyValueStore
import Stripe.Product
import Stripe.Stripe as Stripe
import Types
import View.Color



-- USER


signUp : Element.Element Types.FrontendMsg
signUp =
    button Types.SubmitSignUp "Submit"


signOut : String -> Element.Element Types.FrontendMsg
signOut str =
    button Types.SignOut ("Sign out " ++ str)


cancelSignUp =
    button Types.CancelSignUp "Cancel"


openSignUp =
    button Types.OpenSignUp "Sign up"


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


cycleVerbosity : KeyValueStore.KVVerbosity -> Element.Element Types.FrontendMsg
cycleVerbosity currentVerbosity =
    let
        newVerbosity =
            case currentVerbosity of
                KeyValueStore.KVQuiet ->
                    KeyValueStore.KVVerbose

                KeyValueStore.KVVerbose ->
                    KeyValueStore.KVQuiet

        label =
            case currentVerbosity of
                KeyValueStore.KVQuiet ->
                    "Quiet"

                KeyValueStore.KVVerbose ->
                    "Verbose"
    in
    button (Types.CycleKVVerbosity newVerbosity) label


setKVViewType : KeyValueStore.KVViewType -> KeyValueStore.KVViewType -> String -> Element.Element Types.FrontendMsg
setKVViewType currentViewType newViewType label =
    highlightableButton (currentViewType == newViewType) (Types.SetKVViewType newViewType) label


saveKeyValuePair : String -> KeyValueStore.KVDatum -> Element.Element Types.FrontendMsg
saveKeyValuePair key value =
    button (Types.AddKeyValuePair key value) "Save"


updateKeyValuePair : String -> KeyValueStore.KVDatum -> Element.Element Types.FrontendMsg
updateKeyValuePair key value =
    button (Types.AddKeyValuePair key value) "Update"


newKeyValuePair : Element.Element Types.FrontendMsg
newKeyValuePair =
    button Types.NewKeyValuePair "New"


getValueWithKey : String -> Element.Element Types.FrontendMsg
getValueWithKey key =
    button (Types.GetValueWithKey key) "Get"


noOp : String -> Element.Element Types.FrontendMsg
noOp label =
    buttonwithAttr [ Element.Background.color View.Color.medGray ] Types.NoOp label



--- STRIPE


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


buttonwithAttr attr msg label =
    Element.Input.button
        (buttonStyle ++ attr)
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
    , Element.mouseDown
        [ Element.Background.color View.Color.buttonHighlight
        ]
    ]


buttonLabelStyle =
    [ Element.centerX
    , Element.centerY
    , Element.Font.size 15
    ]
