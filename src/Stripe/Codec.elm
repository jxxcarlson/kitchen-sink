module Stripe.Codec exposing (..)

import AssocList
import Codec exposing (Codec)
import Dict
import Email
import Id exposing (Id)
import Lamdera exposing (ClientId, SessionId)
import Money
import Stripe.PurchaseForm as PurchaseForm exposing (PurchaseForm, PurchaseFormValidated)
import Stripe.Stripe exposing (Price, PriceData, PriceId, ProductId, StripeSessionId)
import Time


type alias Price2 =
    { priceId : Id PriceId, price : Price }


price2Codec : Codec Price2
price2Codec =
    Codec.object Price2
        |> Codec.field "priceId" .priceId idCodec
        |> Codec.field "price" .price priceCodec
        |> Codec.buildObject


priceCodec : Codec Price
priceCodec =
    Codec.object Price
        |> Codec.field "currency" .currency currencyCodec
        |> Codec.field "amount" .amount Codec.int
        |> Codec.buildObject


currencyCodec : Codec Money.Currency
currencyCodec =
    Codec.andThen
        (\text ->
            case Money.fromString text of
                Just money ->
                    Codec.succeed money

                Nothing ->
                    Codec.fail ("Invalid currency: " ++ text)
        )
        Money.toString
        Codec.string


assocListCodec : Codec b -> Codec (AssocList.Dict (Id a) b)
assocListCodec codec =
    Codec.map
        (\dict -> Dict.toList dict |> List.map (Tuple.mapFirst Id.fromString) |> AssocList.fromList)
        (\assocList -> AssocList.toList assocList |> List.map (Tuple.mapFirst Id.toString) |> Dict.fromList)
        (Codec.dict codec)


idCodec : Codec (Id a)
idCodec =
    Codec.map Id.fromString Id.toString Codec.string


type alias PendingOrder =
    { priceId : Id PriceId
    , submitTime : Time.Posix
    , form : PurchaseFormValidated
    , sessionId : SessionId
    }


type alias Order =
    { priceId : Id PriceId
    , submitTime : Time.Posix
    , form : PurchaseFormValidated
    , emailResult : Email.EmailResult
    }


productInfoCodec : Codec Stripe.Stripe.ProductInfo
productInfoCodec =
    Codec.object Stripe.Stripe.ProductInfo
        |> Codec.field "name" .name Codec.string
        |> Codec.field "description" .description Codec.string
        |> Codec.buildObject


pendingOrderCodec : Codec PendingOrder
pendingOrderCodec =
    Codec.object PendingOrder
        |> Codec.field "priceId" .priceId idCodec
        |> Codec.field "submitTime" .submitTime timeCodec
        |> Codec.field "form" .form PurchaseForm.codec
        |> Codec.field "sessionId" .sessionId Codec.string
        |> Codec.buildObject


orderCodec : Codec { priceId : Id PriceId, submitTime : Time.Posix, form : PurchaseFormValidated, emailResult : Email.EmailResult }
orderCodec =
    Codec.object Order
        |> Codec.field "priceId" .priceId idCodec
        |> Codec.field "submitTime" .submitTime timeCodec
        |> Codec.field "form" .form PurchaseForm.codec
        |> Codec.field "emailResult" .emailResult Email.emailResultCodec
        |> Codec.buildObject


timeCodec : Codec Time.Posix
timeCodec =
    Codec.map Time.millisToPosix Time.posixToMillis Codec.int
