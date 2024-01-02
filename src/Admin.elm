module Admin exposing (..)

import AssocList
import Codec
import Dict
import Element exposing (..)
import Element.Font
import Id exposing (Id)
import Lamdera
import Stripe.Codec
import Stripe.Stripe as Stripe exposing (Price, PriceData, PriceId, ProductId, StripeSessionId)
import Types exposing (..)
import User
import View.Geometry


type alias Window =
    { width : Int
    , height : Int
    }


view : LoadedModel -> Element msg
view model =
    case model.adminDisplay of
        ADUser ->
            case model.backendModel of
                Just backendModel ->
                    viewUserData model.window backendModel

                Nothing ->
                    text "Can't find User data"

        ADStripe ->
            case model.backendModel of
                Just backendModel ->
                    viewStripeData backendModel

                Nothing ->
                    text "Can't find Stripe data"


viewUserData : Window -> BackendModel -> Element msg
viewUserData window backendModel =
    column
        [ width fill
        , spacing 12
        ]
        [ Element.el
            [ Element.paddingEach { left = 0, right = 0, top = 48, bottom = 0 }
            , Element.Font.bold
            , Element.Font.size 18
            ]
            (text "User Data")
        , viewUserDictionary window backendModel.userDictionary
        ]


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
        [ Element.el [ Element.Font.bold, Element.Font.size 18 ] (text "Stripe Data")
        , viewOrders backendModel.orders
        , viewPendingOrder backendModel.pendingOrder
        , viewExpiredOrders backendModel.expiredOrders
        , viewPrices backendModel.prices
        ]


viewPrices : AssocList.Dict (Id ProductId) Stripe.Codec.Price2 -> Element msg
viewPrices prices =
    column
        [ width fill
        ]
        [ text "Prices"
        , Codec.encodeToString 2 (Stripe.Codec.assocListCodec Stripe.Codec.price2Codec) prices |> text
        ]


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


loadProdBackend : Cmd msg
loadProdBackend =
    let
        x =
            1

        -- pass =
        --     Env.adminPassword
    in
    Cmd.none
