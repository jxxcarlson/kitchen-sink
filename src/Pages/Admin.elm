module Pages.Admin exposing (Window, content, loadProdBackend, toMonth, toUtcString, view, viewExpiredOrders, viewExpiredOrdersPretty, viewKeyValuePairs, viewOrders, viewPair, viewPendingOrder, viewPrices, viewPricesPretty, viewStripeData, viewUser, viewUserData, viewUserDictionary)

import AssocList
import Codec
import Dict
import Element exposing (..)
import Element.Font
import EmailAddress
import Id exposing (Id)
import Lamdera
import MarkdownThemed
import Name
import Stripe.Codec
import Stripe.PurchaseForm
import Stripe.Stripe as Stripe exposing (Price, PriceData, PriceId, ProductId, StripeSessionId)
import Stripe.View
import Theme
import Time exposing (Month(..))
import Types exposing (..)
import User
import View.Button
import View.Geometry


type alias Window =
    { width : Int
    , height : Int
    }


view : LoadedModel -> Element FrontendMsg
view model =
    Element.column []
        [ Element.row [ Element.spacing 24, Element.paddingEach { left = 0, right = 0, top = 0, bottom = 24 } ]
            [ View.Button.setAdminDisplay model.adminDisplay ADUser "Users"
            , View.Button.setAdminDisplay model.adminDisplay ADKeyValues "Key-Value Store"
            , View.Button.setAdminDisplay model.adminDisplay ADStripe "Stripe Data"
            ]
        , case model.backendModel of
            Nothing ->
                text "Can't find that data"

            Just backendModel ->
                case model.adminDisplay of
                    ADUser ->
                        viewUserData model.window backendModel

                    ADKeyValues ->
                        viewKeyValuePairs model.window backendModel

                    ADStripe ->
                        viewStripeData backendModel
        ]


viewKeyValuePairs : Window -> BackendModel -> Element msg
viewKeyValuePairs window backendModel =
    column
        [ width fill
        , spacing 12
        , height (px <| window.height - 2 * View.Geometry.headerFooterHeight)
        ]
        ([ Element.column Theme.contentAttributes [ content ]
         , Element.el [ Element.Font.bold ] (text "Key-Value Store")
         ]
            ++ List.map viewPair (Dict.toList backendModel.keyValueStore)
        )


content =
    """
### RPC Example

Add key-value pairs to the key-value store by sending this
POST request:

```
curl -X POST -d '{ "key": "foo", "value": "1234" }' \\
   -H 'content-type: application/json' \\
   https://elm-kitchen-sink.lamdera.app/_r/putKeyValuePair
```

Retrieve key-value pairs from the key-value store by sending
the request

```
curl -X POST -d '{ "key": "foo" }' \\
-H 'content-type: application/json' \\
https://elm-kitchen-sink.lamdera.app/_r/getKeyValuePair
```
"""
        |> MarkdownThemed.renderFull


viewPair : ( String, String ) -> Element msg
viewPair ( key, value ) =
    row
        [ width fill
        , spacing 12
        ]
        [ text (key ++ ":")
        , text value
        ]


viewUserData : Window -> BackendModel -> Element msg
viewUserData window backendModel =
    column
        [ width fill
        , spacing 12
        ]
        [ viewUserDictionary window backendModel.userDictionary ]


viewUserDictionary : Window -> Dict.Dict String User.User -> Element msg
viewUserDictionary window userDictionary =
    --type alias User =
    --    { id : String
    --    , realname : String
    --    , username : String
    --    , email : String
    --    , password : String
    --    , created_at : Time.Posix
    --    , updated_at : Time.Posix
    --    }
    let
        users : List User.User
        users =
            Dict.values userDictionary
    in
    column
        [ width fill
        , Element.height (Element.px <| window.width - 2 * View.Geometry.headerFooterHeight)
        , Element.scrollbarY
        , Element.spacing 24
        ]
        (List.map viewUser users)


viewUser : User.User -> Element msg
viewUser =
    \user ->
        column
            [ width fill
            ]
            [ text ("realname: " ++ user.realname)
            , text ("username: " ++ user.username)
            , text ("email: " ++ user.email)
            , text ("id: " ++ user.id)
            ]


viewStripeData : BackendModel -> Element msg
viewStripeData backendModel =
    --{ randomAtmosphericNumbers : Maybe (List Int)
    --    , localUuidData : Maybe LocalUUID.Data
    --
    --    -- USER
    --    , userDictionary : Dict.Dict String User.User
    --
    --    --STRIPE
    --    , orders : AssocList.Dict (Id StripeSessionId) Stripe.Codec.Order
    --    , pendingOrder : AssocList.Dict (Id StripeSessionId) Stripe.Codec.PendingOrder
    --    , expiredOrders : AssocList.Dict (Id StripeSessionId) Stripe.Codec.PendingOrder
    --    , prices : AssocList.Dict (Id ProductId) Stripe.Codec.Price2
    --    , time : Time.Posix
    --    , products : Stripe.Stripe.ProductInfoDict
    --    }
    column
        [ width fill
        , spacing 40
        ]
        [ viewOrders backendModel.orders
        , viewPendingOrder backendModel.pendingOrder
        , viewExpiredOrdersPretty backendModel.expiredOrders
        , viewPricesPretty backendModel.prices
        ]


viewPrices : AssocList.Dict (Id ProductId) Stripe.Codec.Price2 -> Element msg
viewPrices prices =
    column
        [ width fill
        ]
        [ text "Prices"
        , Codec.encodeToString 2 (Stripe.Codec.assocListCodec Stripe.Codec.price2Codec) prices |> text
        ]


viewPricesPretty : AssocList.Dict (Id ProductId) Stripe.Codec.Price2 -> Element msg
viewPricesPretty prices =
    column
        [ width fill
        ]
        (Element.el [ Element.Font.bold ] (text "Prices")
            :: List.map Stripe.View.viewEntry (prices |> AssocList.toList)
        )


viewOrders : AssocList.Dict (Id StripeSessionId) Stripe.Codec.Order -> Element msg
viewOrders orders =
    column
        [ width fill
        ]
        [ text "Orders"
        , Codec.encodeToString 2 (Stripe.Codec.assocListCodec Stripe.Codec.orderCodec) orders |> text
        ]


viewPendingOrder : AssocList.Dict (Id StripeSessionId) Stripe.Codec.PendingOrder -> Element msg
viewPendingOrder pendingOrders =
    column
        [ width fill
        ]
        [ text "Pending Orders"
        , Codec.encodeToString 2 (Stripe.Codec.assocListCodec Stripe.Codec.pendingOrderCodec) pendingOrders |> text
        ]


viewExpiredOrders : AssocList.Dict (Id StripeSessionId) Stripe.Codec.PendingOrder -> Element msg
viewExpiredOrders expiredOrders =
    column
        [ width fill
        ]
        [ text "Expired Orders"
        , Codec.encodeToString 2 (Stripe.Codec.assocListCodec Stripe.Codec.pendingOrderCodec) expiredOrders |> text
        ]


toUtcString : Time.Posix -> String
toUtcString time =
    String.fromInt (Time.toYear Time.utc time)
        ++ "-"
        ++ toMonth (Time.toMonth Time.utc time)
        ++ "-"
        ++ String.fromInt (Time.toDay Time.utc time)
        ++ " "
        ++ String.fromInt (Time.toHour Time.utc time)
        ++ ":"
        ++ String.fromInt (Time.toMinute Time.utc time)
        ++ ":"
        ++ String.fromInt (Time.toSecond Time.utc time)
        ++ " (UTC)"


toMonth : Time.Month -> String
toMonth month =
    case month of
        Jan ->
            "Jan"

        Feb ->
            "Feb"

        Mar ->
            "Mar"

        Apr ->
            "Apr"

        May ->
            "May"

        Jun ->
            "Jun"

        Jul ->
            "Jul"

        Aug ->
            "Aug"

        Sep ->
            "Sep"

        Oct ->
            "Oct"

        Nov ->
            "Nov"

        Dec ->
            "Dec"


viewExpiredOrdersPretty : AssocList.Dict (Id StripeSessionId) Stripe.Codec.PendingOrder -> Element msg
viewExpiredOrdersPretty expiredOrders =
    let
        orders : List ( Id StripeSessionId, Stripe.Codec.PendingOrder )
        orders =
            expiredOrders
                |> AssocList.toList

        viewOrder : ( Id StripeSessionId, Stripe.Codec.PendingOrder ) -> Element msg
        viewOrder ( id, order ) =
            column
                [ width fill
                ]
                [ text ("name: " ++ (order.form |> Stripe.PurchaseForm.getPurchaseData |> .billingName |> Name.nameToString))
                , text ("email: " ++ (order.form |> Stripe.PurchaseForm.getPurchaseData |> .billingEmail |> EmailAddress.toString))
                , text ("date-time: " ++ (order |> .submitTime |> toUtcString))
                , text ("id: " ++ Id.toString id)
                , text ("priceId: " ++ Id.toString order.priceId)
                , text ("sessionId: " ++ order.sessionId)
                ]
    in
    column
        [ width fill
        , Element.spacing 24
        ]
        (Element.el [ Element.Font.bold ] (text "Expired Orders") :: List.map viewOrder orders)


loadProdBackend : Cmd msg
loadProdBackend =
    let
        x =
            1

        -- pass =
        --     Env.adminPassword
    in
    Cmd.none
