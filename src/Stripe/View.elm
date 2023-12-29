module Stripe.View exposing (formView, ticketCardsView, ticketsHtmlId)

import Admin
import AssocList
import Browser exposing (UrlRequest(..))
import Browser.Dom
import Browser.Events
import Browser.Navigation
import Dict
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import EmailAddress exposing (EmailAddress)
import Env
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Id exposing (Id)
import Json.Decode
import Lamdera
import LiveSchedule
import MarkdownThemed
import Pages.About
import Pages.Brillig
import Pages.Home
import Pages.Notes
import Pages.Parts
import Ports
import Route exposing (Route(..), SubPage(..))
import String.Nonempty
import Stripe.Product as Product
import Stripe.PurchaseForm as PurchaseForm exposing (PressedSubmit(..), PurchaseForm, PurchaseFormValidated(..), SubmitStatus(..))
import Stripe.Stripe as Stripe
import Stripe.Tickets as Tickets exposing (Ticket)
import Stripe.Utility
import Task
import Theme
import Time
import TravelMode
import Types exposing (..)
import Untrusted
import Url
import Url.Parser exposing ((</>), (<?>))
import Url.Parser.Query as Query
import View.Style


formView : LoadedModel -> Id Stripe.ProductId -> Id Stripe.PriceId -> Ticket -> Element FrontendMsg
formView model productId priceId ticket =
    let
        form =
            model.form

        textInput : (String -> msg) -> String -> (String -> Result String value) -> String -> Element msg
        textInput onChange title validator text =
            Element.column
                [ Element.spacing 4, Element.width Element.fill ]
                [ Element.Input.text
                    [ Element.Border.rounded 8 ]
                    { text = text
                    , onChange = onChange
                    , placeholder = Nothing
                    , label = Element.Input.labelAbove [ Element.Font.semiBold ] (Element.text title)
                    }
                , case ( form.submitStatus, validator text ) of
                    ( NotSubmitted PressedSubmit, Err error ) ->
                        errorText error

                    _ ->
                        Element.none
                ]

        submitButton =
            Element.Input.button
                Theme.submitButtonAttributes
                { onPress = Just (PressedSubmitForm productId priceId)
                , label =
                    Element.paragraph
                        [ Element.Font.center ]
                        [ Element.text "Purchase "
                        , case form.submitStatus of
                            NotSubmitted pressedSubmit ->
                                Element.none

                            Submitting ->
                                Element.el [ Element.moveDown 5 ] Theme.spinnerWhite

                            SubmitBackendError err ->
                                Element.none
                        ]
                }

        cancelButton =
            Element.Input.button
                View.Style.normalButtonAttributes
                { onPress = Just PressedCancelForm
                , label = Element.el [ Element.centerX ] (Element.text "Cancel")
                }
    in
    Element.column
        [ Element.width Element.fill, Element.spacing 24 ]
        [ Element.column
            [ Element.width Element.fill
            , Element.spacing 24
            , Element.padding 16
            ]
            [ textInput (\a -> FormChanged { form | attendee1Name = a }) "Your name" PurchaseForm.validateName form.attendee1Name
            , if productId == Id.fromString Product.ticket.couplesCamp then
                textInput
                    (\a -> FormChanged { form | attendee2Name = a })
                    "Person you're sharing a room with"
                    PurchaseForm.validateName
                    form.attendee2Name

              else
                Element.none
            , textInput
                (\a -> FormChanged { form | billingEmail = a })
                "Billing email address"
                PurchaseForm.validateEmailAddress
                form.billingEmail
            ]
        , """
By purchasing a ticket, you agree to the event [Code of Conduct](/code-of-conduct).

Please note: you have selected a ticket that ***${ticketAccom} accommodation***.
"""
            |> String.replace "${ticketAccom}"
                (if includesAccom ticket.productId then
                    "includes"

                 else
                    "does not include"
                )
            |> MarkdownThemed.renderFull
        , case form.submitStatus of
            NotSubmitted pressedSubmit ->
                Element.none

            Submitting ->
                -- @TODO spinner
                Element.none

            SubmitBackendError err ->
                Element.paragraph [] [ Element.text err ]
        , if model.window.width > 600 then
            Element.row [ Element.width Element.fill, Element.spacing 16 ] [ cancelButton, submitButton ]

          else
            Element.column [ Element.width Element.fill, Element.spacing 16 ] [ submitButton, cancelButton ]
        , """
Your order will be processed by Elm Camp's fiscal host: <img src="/sponsors/cofoundry.png" width="100" />.
""" |> MarkdownThemed.renderFull
        ]


ticketCardsView : LoadedModel -> Element FrontendMsg
ticketCardsView model =
    if model.window.width < 950 then
        List.map
            (\( productId, ticket ) ->
                case AssocList.get productId model.prices of
                    Just price ->
                        Tickets.viewMobile (PressedSelectTicket productId price.priceId) price.price ticket

                    Nothing ->
                        Element.text "No ticket prices found"
            )
            (AssocList.toList Tickets.dict)
            |> Element.column [ Element.spacing 16 ]

    else
        List.map
            (\( productId, ticket ) ->
                case AssocList.get productId model.prices of
                    Just price ->
                        Tickets.viewDesktop (PressedSelectTicket productId price.priceId) price.price ticket

                    Nothing ->
                        Element.text "No ticket prices found"
            )
            (AssocList.toList Tickets.dict)
            |> Element.row (Element.spacing 16 :: Theme.contentAttributes)



-- HELPERS


errorText : String -> Element msg
errorText error =
    Element.paragraph [ Element.Font.color (Element.rgb255 150 0 0) ] [ Element.text error ]


includesAccom productId =
    if productId == Product.ticket.campFire then
        False

    else
        True


ticketsHtmlId =
    "tickets"
