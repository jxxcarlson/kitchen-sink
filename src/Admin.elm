module Admin exposing (..)

import AssocList
import Codec
import Element exposing (..)
import Id exposing (Id)
import Lamdera
import Stripe.Stripe as Stripe exposing (Price, PriceData, PriceId, ProductId, StripeSessionId)
import Types exposing (..)


view : LoadedModel -> Element msg
view model =
    case model.backendModel of
        Just backendModel ->
            viewAdmin backendModel

        Nothing ->
            text "loading"


viewAdmin : BackendModel -> Element msg
viewAdmin backendModel =
    -- type alias BackendModel =
    --     { orders : AssocList.Dict (Id StripeSessionId) Order
    --     , pendingOrder : AssocList.Dict (Id StripeSessionId) PendingOrder
    --     , expiredOrders : AssocList.Dict (Id StripeSessionId) PendingOrder
    --     , prices : AssocList.Dict (Id ProductId) Price2
    --     , time : Time.Posix
    --     , ticketsEnabled : TicketsEnabled
    --     }
    column
        [ width fill
        , spacing 40
        ]
        [ text "Admin"
        , viewOrders backendModel.orders
        , viewPendingOrder backendModel.pendingOrder
        , viewExpiredOrders backendModel.expiredOrders
        , viewPrices backendModel.prices
        , viewTicketsEnabled backendModel.ticketsEnabled
        ]


viewTicketsEnabled : TicketsEnabled -> Element msg
viewTicketsEnabled ticketsEnabled =
    column
        [ width fill
        ]
        [ text "TicketsEnabled:"
        , case ticketsEnabled of
            TicketsEnabled ->
                text "TicketsEnabled"

            TicketsDisabled d ->
                text <| "TicketsDisabled" ++ d.adminMessage
        ]


viewPrices : AssocList.Dict (Id ProductId) Price2 -> Element msg
viewPrices prices =
    column
        [ width fill
        ]
        [ text "Prices"
        , Codec.encodeToString 2 (Types.assocListCodec Types.price2Codec) prices |> text
        ]


viewOrders : AssocList.Dict (Id StripeSessionId) Types.Order -> Element msg
viewOrders orders =
    column
        [ width fill
        ]
        [ text "Orders"
        , Codec.encodeToString 2 (Types.assocListCodec Types.orderCodec) orders |> text
        ]


viewPendingOrder : AssocList.Dict (Id StripeSessionId) PendingOrder -> Element msg
viewPendingOrder pendingOrders =
    column
        [ width fill
        ]
        [ text "Pending Orders"
        , Codec.encodeToString 2 (Types.assocListCodec Types.pendingOrderCodec) pendingOrders |> text
        ]


viewExpiredOrders : AssocList.Dict (Id StripeSessionId) PendingOrder -> Element msg
viewExpiredOrders expiredOrders =
    column
        [ width fill
        ]
        [ text "Expired Orders"
        , Codec.encodeToString 2 (Types.assocListCodec Types.pendingOrderCodec) expiredOrders |> text
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



-- debugAssocList assoc =
--     assoc
--         |> AssocList.toList
--         |> List.map
--             (\data ->
--                 column
--                     [ width fill
--                     ]
--                     [ paragraph [] [ text (Debug.toString data) ]
--                     ]
--             )
--         |> column []
