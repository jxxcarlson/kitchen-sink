module View.Main exposing (view)

import Admin
import Browser exposing (UrlRequest(..))
import Element exposing (Element)
import Element.Background
import Element.Font
import EmailAddress exposing (EmailAddress)
import MarkdownThemed
import Pages.Brillig
import Pages.Features
import Pages.Home
import Pages.Notes
import Pages.Parts
import Pages.Purchase
import Pages.SignIn
import Route exposing (Route(..))
import Theme
import Types exposing (..)
import View.Color
import View.Style



--E.layoutWith { options = [ E.focusStyle View.Utility.noFocus ] }


noFocus : Element.FocusStyle
noFocus =
    { borderColor = Nothing
    , backgroundColor = Nothing
    , shadow = Nothing
    }


view : FrontendModel -> Browser.Document FrontendMsg
view model =
    { title = "Lamdera Kitchen Sink"
    , body =
        [ Theme.css
        , Element.layoutWith { options = [ Element.focusStyle noFocus ] }
            [ Element.width Element.fill
            , Element.Font.color MarkdownThemed.lightTheme.defaultText
            , Element.Font.size 16
            , Element.Font.medium
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
            -- Pages.Home.view model
            Pages.Parts.generic model Pages.Home.view

        Features ->
            Pages.Parts.generic model Pages.Features.view

        Notes ->
            Pages.Parts.generic model Pages.Notes.view

        SignIn ->
            Pages.Parts.generic model Pages.SignIn.view

        Brillig ->
            Pages.Parts.generic model Pages.Brillig.view

        AdminRoute passM ->
            Admin.view model

        Purchase ->
            Pages.Parts.generic model Pages.Purchase.view

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
