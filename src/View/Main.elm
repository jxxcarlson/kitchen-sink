module View.Main exposing (view)

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


view : FrontendModel -> Browser.Document FrontendMsg
view model =
    { title = "Lamdera Kitchen Sink"
    , body =
        [ Theme.css
        , Element.layout
            [ Element.width Element.fill
            , Element.Font.color MarkdownThemed.lightTheme.defaultText
            , Element.Font.size 16
            , Element.Font.medium
            , Element.Background.color View.Style.backgroundColor
            , (case model of
                Loading _ ->
                    Element.none

                Loaded loaded ->
                    case loaded.ticketsEnabled of
                        TicketsEnabled ->
                            Element.none

                        TicketsDisabled { adminMessage } ->
                            Element.paragraph
                                [ Element.Font.color (Element.rgb 1 1 1)
                                , Element.Font.medium
                                , Element.Font.size 20
                                , Element.Background.color (Element.rgb 0.5 0 0)
                                , Element.padding 8
                                , Element.width Element.fill
                                ]
                                [ Element.text adminMessage ]
              )
                |> Element.inFront
            ]
            (case model of
                Loading _ ->
                    Element.column [ Element.width Element.fill, Element.padding 20 ]
                        [ "Loading..."
                            |> Element.text
                            |> Element.el [ Element.centerX ]
                        ]

                Loaded loaded ->
                    loadedView loaded
            )
        ]
    }


loadedView : LoadedModel -> Element FrontendMsg
loadedView model =
    case model.route of
        HomepageRoute ->
            Pages.Home.view model

        About ->
            Element.column
                [ Element.width Element.fill, Element.height Element.fill ]
                [ Pages.Parts.header { window = model.window, isCompact = True }
                , Element.column
                    (Element.padding 20 :: Theme.contentAttributes)
                    [ Pages.About.view model
                    ]
                , Pages.Parts.footer
                ]

        Notes ->
            Element.column
                [ Element.width Element.fill, Element.height Element.fill ]
                [ Pages.Parts.header { window = model.window, isCompact = True }
                , Element.column
                    (Element.padding 20 :: Theme.contentAttributes)
                    [ Pages.Notes.view model
                    ]
                , Pages.Parts.footer
                ]

        Brillig ->
            Element.column
                [ Element.width Element.fill, Element.height Element.fill ]
                [ Pages.Parts.header { window = model.window, isCompact = True }
                , Element.column
                    (Element.padding 20 :: Theme.contentAttributes)
                    [ Pages.Brillig.view model
                    ]
                , Pages.Parts.footer
                ]

        AdminRoute passM ->
            Admin.view model

        PaymentSuccessRoute maybeEmailAddress ->
            Element.column
                [ Element.centerX, Element.centerY, Element.padding 24, Element.spacing 16 ]
                [ Element.paragraph [ Element.Font.size 20, Element.Font.center ] [ Element.text "Your ticket purchase was successful!" ]
                , Element.paragraph
                    [ Element.width (Element.px 420) ]
                    [ Element.text "An email has been sent to "
                    , case maybeEmailAddress of
                        Just emailAddress ->
                            EmailAddress.toString emailAddress
                                |> Element.text
                                |> Element.el [ Element.Font.semiBold ]

                        Nothing ->
                            Element.text "your email address"
                    , Element.text " with additional information."
                    ]
                , Element.link
                    View.Style.normalButtonAttributes
                    { url = Route.encode HomepageRoute
                    , label = Element.el [ Element.centerX ] (Element.text "Return to homepage")
                    }
                ]

        PaymentCancelRoute ->
            Element.column
                [ Element.centerX, Element.centerY, Element.padding 24, Element.spacing 16 ]
                [ Element.paragraph
                    [ Element.Font.size 20 ]
                    [ Element.text "You cancelled your ticket purchase" ]
                , Element.link
                    View.Style.normalButtonAttributes
                    { url = Route.encode HomepageRoute
                    , label = Element.el [ Element.centerX ] (Element.text "Return to homepage")
                    }
                ]
