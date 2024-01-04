module RPC exposing (lamdera_handleEndpoints, requestPurchaseCompletedEndpoint)

import AssocList
import Backend
import BackendHelper
import Codec
import Dict
import Email
import Email.Html as Html
import Email.Html.Attributes as Attributes
import EmailAddress exposing (EmailAddress)
import Env
import Http
import Id
import Json.Decode
import Json.Decode.Pipeline
import Json.Encode
import Lamdera exposing (SessionId)
import Lamdera.Wire3 as Wire3
import LamderaRPC exposing (RPC(..))
import List.Nonempty exposing (Nonempty(..))
import Name
import Postmark
import String.Nonempty exposing (NonemptyString(..))
import Stripe.Product as Tickets exposing (Product_)
import Stripe.PurchaseForm as PurchaseForm
import Stripe.Stripe as Stripe exposing (Webhook(..))
import Task exposing (Task)
import Types exposing (BackendModel, BackendMsg(..), ToFrontend(..))



-- STRIPE


purchaseCompletedEndpoint :
    SessionId
    -> BackendModel
    -> Json.Decode.Value
    -> ( Result Http.Error Json.Decode.Value, BackendModel, Cmd BackendMsg )
purchaseCompletedEndpoint _ model request =
    let
        response =
            if Env.isProduction then
                Ok (Json.Encode.string "prod")

            else
                Ok (Json.Encode.string "dev")
    in
    case Json.Decode.decodeValue Stripe.decodeWebhook request of
        Ok webhook ->
            case webhook of
                StripeSessionCompleted stripeSessionId ->
                    case AssocList.get stripeSessionId model.pendingOrder of
                        Just order ->
                            let
                                maybeTicket : Maybe Product_
                                maybeTicket =
                                    case BackendHelper.priceIdToProductId model order.priceId of
                                        Just productId ->
                                            AssocList.get productId Tickets.dict

                                        Nothing ->
                                            Nothing
                            in
                            case maybeTicket of
                                Just ticket ->
                                    let
                                        { subject, textBody, htmlBody } =
                                            confirmationEmail ticket
                                    in
                                    ( response
                                    , { model
                                        | pendingOrder = AssocList.remove stripeSessionId model.pendingOrder
                                        , orders =
                                            AssocList.insert
                                                stripeSessionId
                                                { priceId = order.priceId
                                                , submitTime = order.submitTime
                                                , form = order.form
                                                , emailResult = Email.SendingEmail
                                                }
                                                model.orders
                                      }
                                    , Postmark.sendEmail
                                        (ConfirmationEmailSent stripeSessionId)
                                        Env.postmarkApiKey
                                        { from = { name = "elm-camp", email = BackendHelper.purchaseSupportAddres }
                                        , to =
                                            Nonempty
                                                { name = PurchaseForm.purchaserName order.form |> Name.toString
                                                , email = PurchaseForm.billingEmail order.form
                                                }
                                                []
                                        , subject = subject
                                        , body = Postmark.BodyBoth htmlBody textBody
                                        , messageStream = "outbound"
                                        }
                                    )

                                Nothing ->
                                    let
                                        error =
                                            "Ticket not found: priceId"
                                                ++ Id.toString order.priceId
                                                ++ ", stripeSessionId: "
                                                ++ Id.toString stripeSessionId
                                    in
                                    ( Err (Http.BadBody error), model, BackendHelper.errorEmail error )

                        Nothing ->
                            let
                                error =
                                    "Stripe session not found: stripeSessionId: "
                                        ++ Id.toString stripeSessionId
                            in
                            ( Err (Http.BadBody error), model, BackendHelper.errorEmail error )

        Err error ->
            let
                errorText =
                    "Failed to decode webhook: "
                        ++ Json.Decode.errorToString error
            in
            ( Err (Http.BadBody errorText), model, BackendHelper.errorEmail errorText )


confirmationEmail : Product_ -> { subject : NonemptyString, textBody : String, htmlBody : Html.Html }
confirmationEmail product =
    { subject =
        String.Nonempty.append
            product.name
            (NonemptyString ' ' " purchase confirmation")
    , textBody =
        "This is a confirmation email for your purchase of "
            ++ product.name
            ++ "\n("
            ++ product.description
            ++ ").\n\n"
            ++ "If you have any questions, email us at "
            ++ EmailAddress.toString BackendHelper.purchaseSupportAddres
            ++ " (or just reply to this email)"
    , htmlBody =
        Html.div
            []
            [ Html.div []
                [ Html.text "This is a confirmation email for your purchase of the "
                , Html.b [] [ Html.text product.name ]
                ]
            , Html.div [ Attributes.paddingBottom "16px" ] [ Html.text (" (" ++ product.description ++ ")") ]
            , Html.div [ Attributes.paddingBottom "16px" ] [ Html.text "We look forward to seeing you at the elm-camp unconference!" ]
            , Html.div []
                [ Html.text "If you have any questions, email us at "
                , Html.a
                    [ Attributes.href ("mailto:" ++ EmailAddress.toString BackendHelper.purchaseSupportAddres) ]
                    [ Html.text (EmailAddress.toString BackendHelper.purchaseSupportAddres) ]
                , Html.text " (or just reply to this email)"
                ]
            ]
    }



-- Things that should be auto-generated in future


requestPurchaseCompletedEndpoint : String -> Task Http.Error String
requestPurchaseCompletedEndpoint value =
    LamderaRPC.asTask Wire3.encodeString Wire3.decodeString value "purchaseCompletedEndpoint"



-- EXAMPLE (Mario)


reverse : SessionId -> BackendModel -> String -> ( Result error String, BackendModel, Cmd msg )
reverse sessionId model input =
    ( Ok <| String.reverse input, model, Cmd.none )



-- Things that should be auto-generated in future


requestReverse : String -> Task Http.Error String
requestReverse value =
    LamderaRPC.asTask Wire3.encodeString Wire3.decodeString value "reverse"



-- Define the handler


exampleJson : SessionId -> BackendModel -> Json.Encode.Value -> ( Result Http.Error Json.Encode.Value, BackendModel, Cmd BackendMsg )
exampleJson sessionId model jsonArg =
    let
        decoder =
            Json.Decode.succeed identity
                |> Json.Decode.Pipeline.required "name" Json.Decode.string

        encoder =
            Json.Encode.string
    in
    case Json.Decode.decodeValue decoder jsonArg of
        Ok name ->
            ( Ok <| encoder <| String.reverse name
            , model
            , Cmd.none
            )

        Err err ->
            ( Err <|
                Http.BadBody <|
                    "Failed to decode arg for [json] "
                        ++ "exampleJson "
                        ++ Json.Decode.errorToString err
            , model
            , Cmd.none
            )



--  KEY-VALUE STORE


type alias KV =
    { key : String, value : String }


putKeyValuePair : SessionId -> BackendModel -> Json.Encode.Value -> ( Result Http.Error Json.Encode.Value, BackendModel, Cmd msg )
putKeyValuePair sessionId model jsonArg =
    case Json.Decode.decodeValue keyValueDecoder jsonArg of
        Ok kv ->
            ( Ok (keyValueEncoder kv)
            , { model | keyValueStore = Dict.insert kv.key kv.value model.keyValueStore }
            , Cmd.none
            )

        Err err ->
            ( Err <|
                Http.BadBody <|
                    "Failed to decode arg for [json] "
                        ++ "putKeyValuePair "
                        ++ Json.Decode.errorToString err
            , model
            , Cmd.none
            )


getKeyValuePair : SessionId -> BackendModel -> Json.Encode.Value -> ( Result Http.Error Json.Encode.Value, BackendModel, Cmd msg )
getKeyValuePair sessionId model jsonArg =
    let
        decoder =
            Json.Decode.succeed identity
                |> Json.Decode.Pipeline.required "key" Json.Decode.string
    in
    case Json.Decode.decodeValue decoder jsonArg of
        Ok key ->
            ( Ok (Json.Encode.string (Dict.get key model.keyValueStore |> Maybe.withDefault ("Unknown key: " ++ key)))
            , model
            , Cmd.none
            )

        Err err ->
            ( Err <|
                Http.BadBody <|
                    "Failed to decode arg for [json] "
                        ++ "getKeyValuePair "
                        ++ Json.Decode.errorToString err
            , model
            , Cmd.none
            )


keyValueDecoder : Json.Decode.Decoder KV
keyValueDecoder =
    Json.Decode.map2 KV
        (Json.Decode.field "key" Json.Decode.string)
        (Json.Decode.field "value" Json.Decode.string)


keyValueEncoder : KV -> Json.Encode.Value
keyValueEncoder kv =
    Json.Encode.object
        [ ( "key", Json.Encode.string kv.key )
        , ( "value", Json.Encode.string kv.value )
        ]



-- ENDPOINTS


lamdera_handleEndpoints :
    LamderaRPC.RPCArgs
    -> BackendModel
    -> ( LamderaRPC.RPCResult, BackendModel, Cmd BackendMsg )
lamdera_handleEndpoints args model =
    case args.endpoint of
        "stripe" ->
            LamderaRPC.handleEndpointJson purchaseCompletedEndpoint args model

        "reverse" ->
            LamderaRPC.handleEndpoint reverse Wire3.decodeString Wire3.encodeString args model

        "exampleJson" ->
            LamderaRPC.handleEndpointJson exampleJson args model

        "putKeyValuePair" ->
            LamderaRPC.handleEndpointJson putKeyValuePair args model

        "getKeyValuePair" ->
            LamderaRPC.handleEndpointJson getKeyValuePair args model

        _ ->
            ( LamderaRPC.ResultFailure <| Http.BadBody <| "Unknown endpoint " ++ args.endpoint, model, Cmd.none )



-- CURL REQUESTS
{-
   curl -X POST -d '{ "name": "jane" }' -H 'content-type: application/json' localhost:8000/_r/exampleJson

   curl -X POST -d '{ "key": "foo", "value": "1234" }' -H 'content-type: application/json' localhost:8000/_r/putKeyValuePair

   curl -X POST -d '{ "key": "foo" }' -H 'content-type: application/json' localhost:8000/_r/getKeyValuePair

   curl -X POST -d '{ "key": "foo", "value": "1234" }' -H 'content-type: application/json' https://elm-kitchen-sink.lamdera.app/_r/putKeyValuePair

-}
