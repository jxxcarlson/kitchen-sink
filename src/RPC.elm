module RPC exposing (..)

import AssocList
import Backend
import Codec
import Email.Html as Html
import Email.Html.Attributes as Attributes
import EmailAddress exposing (EmailAddress)
import Env
import Http
import Id
import Json.Decode
import Json.Encode
import Lamdera exposing (SessionId)
import Lamdera.Wire3 as Wire3
import LamderaRPC
import List.Nonempty exposing (Nonempty(..))
import Name
import Postmark
import String.Nonempty exposing (NonemptyString(..))
import Stripe.PurchaseForm as PurchaseForm
import Stripe.Stripe as Stripe exposing (Webhook(..))
import Stripe.Tickets as Tickets exposing (Product_)
import Task exposing (Task)
import Types exposing (BackendModel, BackendMsg(..), EmailResult(..), TicketsEnabled(..), ToFrontend(..))


backendModelEndpoint :
    SessionId
    -> BackendModel
    -> Json.Decode.Value
    -> ( Result Http.Error Json.Decode.Value, BackendModel, Cmd BackendMsg )
backendModelEndpoint _ model request =
    case Json.Decode.decodeValue Json.Decode.string request of
        Ok ok ->
            if ok == Env.adminPassword then
                ( Ok (Codec.encodeToValue Types.backendModelCodec model), model, Cmd.none )

            else
                ( Http.BadBody "Invalid admin password" |> Err, model, Cmd.none )

        Err _ ->
            ( Http.BadBody "Expected request body to look like this: \"SECRET_KEY\"" |> Err, model, Cmd.none )


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
                                    case Backend.priceIdToProductId model order.priceId of
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
                                                , emailResult = SendingEmail
                                                }
                                                model.orders
                                      }
                                    , Postmark.sendEmail
                                        (ConfirmationEmailSent stripeSessionId)
                                        Env.postmarkApiKey
                                        { from = { name = "elm-camp", email = Backend.elmCampEmailAddress }
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
                                    ( Err (Http.BadBody error), model, Backend.errorEmail error )

                        Nothing ->
                            let
                                error =
                                    "Stripe session not found: stripeSessionId: "
                                        ++ Id.toString stripeSessionId
                            in
                            ( Err (Http.BadBody error), model, Backend.errorEmail error )

        Err error ->
            let
                errorText =
                    "Failed to decode webhook: "
                        ++ Json.Decode.errorToString error
            in
            ( Err (Http.BadBody errorText), model, Backend.errorEmail errorText )


confirmationEmail : Product_ -> { subject : NonemptyString, textBody : String, htmlBody : Html.Html }
confirmationEmail ticket =
    { subject =
        String.Nonempty.append
            ticket.name
            (NonemptyString ' ' " purchase confirmation")
    , textBody =
        "This is a confirmation email for your purchase of "
            ++ ticket.name
            ++ "\n("
            ++ ticket.description
            ++ ")\n\n"
            ++ "We look forward to seeing you at the elm-camp unconference!\n\n"
            ++ "You can review the schedule at "
            ++ Env.domain
            ++ "/#schedule"
            ++ ". If you have any questions, email us at "
            ++ EmailAddress.toString Backend.elmCampEmailAddress
            ++ " (or just reply to this email)"
    , htmlBody =
        Html.div
            []
            [ Html.div []
                [ Html.text "This is a confirmation email for your purchase of the "
                , Html.b [] [ Html.text ticket.name ]
                ]
            , Html.div [ Attributes.paddingBottom "16px" ] [ Html.text (" (" ++ ticket.description ++ ")") ]
            , Html.div [ Attributes.paddingBottom "16px" ] [ Html.text "We look forward to seeing you at the elm-camp unconference!" ]
            , Html.div []
                [ Html.a
                    [ Attributes.href (Env.domain ++ "/#schedule") ]
                    [ Html.text "You can review the schedule here" ]
                , Html.text ". If you have any questions, email us at "
                , Html.a
                    [ Attributes.href ("mailto:" ++ EmailAddress.toString Backend.elmCampEmailAddress) ]
                    [ Html.text (EmailAddress.toString Backend.elmCampEmailAddress) ]
                , Html.text " (or just reply to this email)"
                ]
            ]
    }



-- Things that should be auto-generated in future


requestPurchaseCompletedEndpoint : String -> Task Http.Error String
requestPurchaseCompletedEndpoint value =
    LamderaRPC.asTask Wire3.encodeString Wire3.decodeString value "purchaseCompletedEndpoint"


lamdera_handleEndpoints :
    LamderaRPC.RPCArgs
    -> BackendModel
    -> ( LamderaRPC.RPCResult, BackendModel, Cmd BackendMsg )
lamdera_handleEndpoints args model =
    case args.endpoint of
        "stripe" ->
            LamderaRPC.handleEndpointJson purchaseCompletedEndpoint args model

        "backend-model" ->
            LamderaRPC.handleEndpointJson backendModelEndpoint args model

        "tickets-enabled" ->
            ( LamderaRPC.ResultString "enabled"
            , { model | ticketsEnabled = TicketsEnabled }
            , Lamdera.broadcast (TicketsEnabledChanged TicketsEnabled)
            )

        "tickets-disabled" ->
            let
                ticketStatus =
                    TicketsDisabled { adminMessage = "Ticket sales temporarily disabled" }
            in
            ( LamderaRPC.ResultString "enabled"
            , { model | ticketsEnabled = ticketStatus }
            , Lamdera.broadcast (TicketsEnabledChanged ticketStatus)
            )

        _ ->
            ( LamderaRPC.ResultFailure <| Http.BadBody <| "Unknown endpoint " ++ args.endpoint, model, Cmd.none )
