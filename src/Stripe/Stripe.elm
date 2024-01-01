module Stripe.Stripe exposing
    ( Price
    , PriceData
    , PriceId(..)
    , ProductId(..)
    , ProductInfo
    , ProductInfoDict
    , StripeSessionId(..)
    , Webhook(..)
    , cancelPath
    , createCheckoutSession
    , decodeWebhook
    , emailAddressParameter
    , expireSession
    , getPrices
    , loadCheckout
    , stripeSessionIdParameter
    , successPath
    )

import AssocList
import EmailAddress exposing (EmailAddress)
import Env
import Http
import HttpHelpers exposing (..)
import Id exposing (Id)
import Json.Decode as D
import Json.Decode.Pipeline exposing (..)
import Json.Encode as E
import Money
import Ports exposing (stripe_to_js)
import Task exposing (Task)
import Time
import Url exposing (percentEncode)
import Url.Builder



-- HTTP Backend API


type alias Price =
    { currency : Money.Currency, amount : Int }


type ProductId
    = ProductId Never


type PriceId
    = PriceId Never


type Webhook
    = StripeSessionCompleted (Id StripeSessionId)


type alias ProductInfo =
    { name : String, description : String }


type alias ProductInfoDict =
    AssocList.Dict (Id ProductId) ProductInfo


decodeWebhook : D.Decoder Webhook
decodeWebhook =
    D.field "type" D.string
        |> D.andThen
            (\eventType ->
                case eventType of
                    "checkout.session.completed" ->
                        D.succeed StripeSessionCompleted
                            |> required "data" (D.field "object" (D.field "id" Id.decoder))

                    _ ->
                        D.fail ("Unhandled stripe webhook event: " ++ eventType)
            )


type alias PriceData =
    { priceId : Id PriceId, price : Price, productId : Id ProductId, isActive : Bool, createdAt : Time.Posix }


getPrices : (Result Http.Error (List PriceData) -> msg) -> Cmd msg
getPrices toMsg =
    Http.request
        { method = "GET"
        , headers = headers
        , url = "https://api.stripe.com/v1/prices"
        , body = Http.emptyBody
        , expect = expectJson_ toMsg decodePrices
        , timeout = Nothing
        , tracker = Nothing
        }


decodePrices =
    D.field "data" (D.list decodePrice)


decodePrice : D.Decoder PriceData
decodePrice =
    D.succeed
        (\priceId currency amount productId isActive createdAt ->
            { priceId = priceId
            , price = Price currency amount
            , productId = productId
            , isActive = isActive
            , createdAt = createdAt
            }
        )
        |> required "id" Id.decoder
        |> required "currency" decodeCurrency
        |> optional "unit_amount" D.int 0
        |> required "product" Id.decoder
        |> required "active" D.bool
        |> required "created" (D.map Time.millisToPosix D.int)


decodeCurrency =
    D.andThen
        (\text ->
            case Money.fromString text of
                Just currency ->
                    D.succeed currency

                Nothing ->
                    D.fail "Not recognized currency"
        )
        D.string


createCheckoutSession :
    { priceId : Id PriceId
    , emailAddress : EmailAddress
    , now : Time.Posix
    , expiresInMinutes : Int
    }
    -> Task Http.Error (Id StripeSessionId)
createCheckoutSession { priceId, emailAddress, now, expiresInMinutes } =
    -- @TODO support multiple prices, see Data.Tickets
    let
        body =
            formBody <|
                [ ( "line_items[0][price]", Id.toString priceId )
                , ( "line_items[0][quantity]", "1" )
                , ( "mode", "payment" )
                , ( "allow_promotion_codes", "true" )

                -- Stripe expects seconds since epoch
                , ( "expires_at", String.fromInt <| (Time.posixToMillis now // 1000) + (expiresInMinutes * 60) )
                , ( "success_url"
                  , Url.Builder.crossOrigin
                        Env.domain
                        [ successPath ]
                        [ Url.Builder.string emailAddressParameter (EmailAddress.toString emailAddress) ]
                  )
                , ( "cancel_url"
                  , Url.Builder.crossOrigin Env.domain [ cancelPath ] []
                  )
                , ( "customer_email", EmailAddress.toString emailAddress )
                ]
    in
    Http.task
        { method = "POST"
        , headers = headers
        , url = "https://api.stripe.com/v1/checkout/sessions"
        , body = body
        , resolver = jsonResolver decodeSession
        , timeout = Nothing
        }


emailAddressParameter : String
emailAddressParameter =
    "email-address"


stripeSessionIdParameter : String
stripeSessionIdParameter =
    "stripe-session"


successPath : String
successPath =
    "stripeSuccess"


cancelPath : String
cancelPath =
    "stripeCancel"


expireSession : Id StripeSessionId -> Task Http.Error ()
expireSession stripeSessionId =
    Http.task
        { method = "POST"
        , headers = headers
        , url =
            Url.Builder.crossOrigin
                "https://api.stripe.com"
                [ "v1", "checkout", "sessions", Id.toString stripeSessionId, "expire" ]
                []
        , body = Http.emptyBody
        , resolver = jsonResolver (D.succeed ())
        , timeout = Nothing
        }


type alias CreateSessionRequest =
    { payment_method_types : String
    , line_items_price : String
    , line_items_quantity : Int
    , mode : String
    , success_url : String
    , cancel_url : String
    }


type StripeSessionId
    = StripeSessionId Never


decodeSession : D.Decoder (Id StripeSessionId)
decodeSession =
    D.field "id" Id.decoder


headers : List Http.Header
headers =
    [ Http.header "Authorization" ("Bearer " ++ Env.stripePrivateApiKey) ]



-- Ports API


loadCheckout : String -> Id StripeSessionId -> Cmd msg
loadCheckout publicApiKey sid =
    toJsMessage "loadCheckout"
        [ ( "id", Id.encode sid )
        , ( "publicApiKey", E.string publicApiKey )
        ]


toJsMessage : String -> List ( String, E.Value ) -> Cmd msg
toJsMessage msg values =
    stripe_to_js <|
        E.object
            (( "msg", E.string msg ) :: values)



-- Helpers


{-| Encode a CGI parameter pair.
-}
cgiParameter : ( String, String ) -> String
cgiParameter ( key, value ) =
    percentEncode key ++ "=" ++ percentEncode value


{-| Encode a CGI parameter list.
-}
cgiParameters : List ( String, String ) -> String
cgiParameters =
    List.map cgiParameter
        >> String.join "&"


{-| Put some key-value pairs in the body of your `Request`. This will automatically
add the `Content-Type: application/x-www-form-urlencoded` header.
-}
formBody : List ( String, String ) -> Http.Body
formBody =
    cgiParameters
        >> Http.stringBody "application/x-www-form-urlencoded"


type OrderStatus
    = Pending
    | Failed String
    | Paid StripePaymentId
    | Refunded StripePaymentId


type StripePaymentId
    = StripePaymentId String


type Product
    = Watchamacallit Price
    | Thingamabob Price


type alias CityCode =
    String
