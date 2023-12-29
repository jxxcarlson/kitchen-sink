module Frontend exposing (app)

--exposing (PriceId, ProductId(..), StripeSessionId)

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


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = subscriptions
        , view = view
        }


subscriptions : FrontendModel -> Sub FrontendMsg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onResize GotWindowSize
        , Browser.Events.onMouseUp (Json.Decode.succeed MouseDown)
        , Time.every 1000 Tick
        ]


queryBool name =
    Query.enum name (Dict.fromList [ ( "true", True ), ( "false", False ) ])


init : Url.Url -> Browser.Navigation.Key -> ( FrontendModel, Cmd FrontendMsg )
init url key =
    let
        route =
            Route.decode url

        -- Use URL = localhost:8000/?organiser=true to see the admin view (??)
        isOrganiser =
            case url |> Url.Parser.parse (Url.Parser.top <?> queryBool "organiser") of
                Just (Just isOrganiser_) ->
                    isOrganiser_

                _ ->
                    False
    in
    ( Loading
        { key = key
        , now = Time.millisToPosix 0
        , window = Nothing
        , initData = Nothing
        , route = route
        , isOrganiser = isOrganiser
        }
    , Cmd.batch
        [ Browser.Dom.getViewport
            |> Task.perform (\{ viewport } -> GotWindowSize (round viewport.width) (round viewport.height))
        , case route of
            PaymentCancelRoute ->
                Lamdera.sendToBackend CancelPurchaseRequest

            AdminRoute passM ->
                case passM of
                    Just pass ->
                        Lamdera.sendToBackend (AdminInspect pass)

                    Nothing ->
                        Cmd.none

            _ ->
                Cmd.none
        ]
    )


update : FrontendMsg -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
update msg model =
    case model of
        Loading loading ->
            case msg of
                GotWindowSize width height ->
                    tryLoading { loading | window = Just { width = width, height = height } }

                _ ->
                    ( model, Cmd.none )

        Loaded loaded ->
            updateLoaded msg loaded |> Tuple.mapFirst Loaded


tryLoading : LoadingModel -> ( FrontendModel, Cmd FrontendMsg )
tryLoading loadingModel =
    Maybe.map2
        (\window { slotsRemaining, prices, ticketsEnabled } ->
            case loadingModel.route of
                _ ->
                    ( Loaded
                        { key = loadingModel.key
                        , now = loadingModel.now
                        , window = window
                        , showTooltip = False
                        , prices = prices
                        , selectedTicket = Nothing
                        , form =
                            { submitStatus = NotSubmitted NotPressedSubmit
                            , attendee1Name = ""
                            , attendee2Name = ""
                            , billingEmail = ""
                            , country = ""
                            , originCity = ""
                            , primaryModeOfTravel = Nothing
                            , grantContribution = "0"
                            , grantApply = False
                            , sponsorship = Nothing
                            }
                        , route = loadingModel.route
                        , showCarbonOffsetTooltip = False
                        , slotsRemaining = slotsRemaining
                        , isOrganiser = loadingModel.isOrganiser
                        , ticketsEnabled = ticketsEnabled
                        , backendModel = Nothing
                        , pressedAudioButton = False
                        }
                    , Cmd.none
                    )
        )
        loadingModel.window
        loadingModel.initData
        |> Maybe.withDefault ( Loading loadingModel, Cmd.none )


updateLoaded : FrontendMsg -> LoadedModel -> ( LoadedModel, Cmd FrontendMsg )
updateLoaded msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Browser.Navigation.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Browser.Navigation.load url
                    )

        UrlChanged url ->
            ( { model | route = Route.decode url }, scrollToTop )

        Tick now ->
            ( { model | now = now }, Cmd.none )

        GotWindowSize width height ->
            ( { model | window = { width = width, height = height } }, Cmd.none )

        PressedShowTooltip ->
            ( { model | showTooltip = True }, Cmd.none )

        MouseDown ->
            ( { model | showTooltip = False, showCarbonOffsetTooltip = False }, Cmd.none )

        -- STRIPE
        PressedSelectTicket productId priceId ->
            case ( AssocList.get productId Tickets.dict, model.ticketsEnabled ) of
                ( Just ticket, TicketsEnabled ) ->
                    if purchaseable ticket.productId model then
                        ( { model | selectedTicket = Just ( productId, priceId ) }
                        , scrollToTop
                        )

                    else
                        ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        FormChanged form ->
            case model.form.submitStatus of
                NotSubmitted _ ->
                    ( { model | form = form }, Cmd.none )

                Submitting ->
                    ( model, Cmd.none )

                SubmitBackendError str ->
                    ( { model | form = form }, Cmd.none )

        PressedSubmitForm productId priceId ->
            let
                form =
                    model.form
            in
            case ( AssocList.get productId Tickets.dict, model.ticketsEnabled ) of
                ( Just ticket, TicketsEnabled ) ->
                    if purchaseable ticket.productId model then
                        case ( form.submitStatus, PurchaseForm.validateForm productId form ) of
                            ( NotSubmitted _, Just validated ) ->
                                ( { model | form = { form | submitStatus = Submitting } }
                                , Lamdera.sendToBackend (SubmitFormRequest priceId (Untrusted.untrust validated))
                                )

                            ( NotSubmitted _, Nothing ) ->
                                ( { model | form = { form | submitStatus = NotSubmitted PressedSubmit } }
                                , Cmd.none
                                )

                            _ ->
                                ( model, Cmd.none )

                    else
                        ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        PressedCancelForm ->
            ( { model | selectedTicket = Nothing }
            , Browser.Dom.getElement ticketsHtmlId
                |> Task.andThen (\{ element } -> Browser.Dom.setViewport 0 element.y)
                |> Task.attempt (\_ -> SetViewport)
            )

        -- /STRIPE
        PressedShowCarbonOffsetTooltip ->
            ( { model | showCarbonOffsetTooltip = True }, Cmd.none )

        SetViewport ->
            ( model, Cmd.none )


scrollToTop : Cmd FrontendMsg
scrollToTop =
    Browser.Dom.setViewport 0 0 |> Task.perform (\() -> SetViewport)


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
updateFromBackend msg model =
    case model of
        Loading loading ->
            case msg of
                InitData initData ->
                    tryLoading { loading | initData = Just initData }

                _ ->
                    ( model, Cmd.none )

        Loaded loaded ->
            updateFromBackendLoaded msg loaded |> Tuple.mapFirst Loaded


updateFromBackendLoaded : ToFrontend -> LoadedModel -> ( LoadedModel, Cmd msg )
updateFromBackendLoaded msg model =
    case msg of
        InitData { prices, slotsRemaining, ticketsEnabled } ->
            ( { model | prices = prices, slotsRemaining = slotsRemaining, ticketsEnabled = ticketsEnabled }, Cmd.none )

        SubmitFormResponse result ->
            case result of
                Ok stripeSessionId ->
                    ( model
                    , Stripe.loadCheckout Env.stripePublicApiKey stripeSessionId
                    )

                Err str ->
                    let
                        form =
                            model.form
                    in
                    ( { model | form = { form | submitStatus = SubmitBackendError str } }, Cmd.none )

        SlotRemainingChanged slotsRemaining ->
            ( { model | slotsRemaining = slotsRemaining }, Cmd.none )

        TicketsEnabledChanged ticketsEnabled ->
            ( { model | ticketsEnabled = ticketsEnabled }, Cmd.none )

        AdminInspectResponse backendModel ->
            ( { model | backendModel = Just backendModel }, Cmd.none )


purchaseable : String -> { a | slotsRemaining : { b | campfireTicket : Bool, campTicket : Bool, couplesCampTicket : Bool } } -> Bool
purchaseable productId model =
    if productId == Product.ticket.campFire then
        model.slotsRemaining.campfireTicket

    else if productId == Product.ticket.camp then
        model.slotsRemaining.campTicket

    else
        model.slotsRemaining.couplesCampTicket


includesAccom productId =
    if productId == Product.ticket.campFire then
        False

    else
        True


view : FrontendModel -> Browser.Document FrontendMsg
view model =
    { title = "Elm Camp"
    , body =
        [ Theme.css
        , Element.layout
            [ Element.width Element.fill
            , Element.Font.color MarkdownThemed.lightTheme.defaultText
            , Element.Font.size 16
            , Element.Font.medium
            , Element.Background.color backgroundColor
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
                    normalButtonAttributes
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
                    normalButtonAttributes
                    { url = Route.encode HomepageRoute
                    , label = Element.el [ Element.centerX ] (Element.text "Return to homepage")
                    }
                ]


ticketsHtmlId =
    "tickets"


normalButtonAttributes =
    [ Element.width Element.fill
    , Element.Background.color (Element.rgb255 255 255 255)
    , Element.padding 16
    , Element.Border.rounded 8
    , Element.alignBottom
    , Element.Border.shadow { offset = ( 0, 1 ), size = 0, blur = 2, color = Element.rgba 0 0 0 0.1 }
    , Element.Font.semiBold
    ]


errorText : String -> Element msg
errorText error =
    Element.paragraph [ Element.Font.color (Element.rgb255 150 0 0) ] [ Element.text error ]


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
                (Theme.submitButtonAttributes (purchaseable ticket.productId model))
                { onPress = Just (PressedSubmitForm productId priceId)
                , label =
                    Element.paragraph
                        [ Element.Font.center ]
                        [ Element.text
                            (if purchaseable ticket.productId model then
                                "Purchase "

                             else
                                "Waitlist"
                            )
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
                normalButtonAttributes
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
        , opportunityGrant form textInput
        , sponsorships model form textInput
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


opportunityGrant form textInput =
    Element.column [ Element.spacing 20 ]
        [ Element.el [ Element.Font.size 20 ] (Element.text "\u{1FAF6} Opportunity grants")
        , Element.paragraph [] [ Element.text "We want Elm Camp to reflect the diverse community of Elm users and benefit from the contribution of anyone, irrespective of financial background. We therefore rely on the support of sponsors and individual participants to lessen the financial impact on those who may otherwise have to abstain from attending." ]
        , Theme.panel []
            [ Element.row [ Element.width Element.fill, Element.spacing 15 ]
                [ Theme.toggleButton "Contribute" (form.grantApply == False) (Just <| FormChanged { form | grantApply = False })
                , Theme.toggleButton "Apply" (form.grantApply == True) (Just <| FormChanged { form | grantApply = True })
                ]
            , case form.grantApply of
                True ->
                    grantApplicationCopy |> MarkdownThemed.renderFull

                False ->
                    Element.column []
                        [ Element.paragraph [] [ Element.text "All amounts are helpful and 100% of the donation (less payment processing fees) will be put to good use supporting travel for our grantees! At the end of purchase, you will be asked whether you wish your donation to be public or anonymous." ]
                        , Element.row [ Element.width Element.fill, Element.spacing 30 ]
                            [ textInput (\a -> FormChanged { form | grantContribution = a }) "" PurchaseForm.validateInt form.grantContribution
                            , Element.column [ Element.width (Element.fillPortion 3) ]
                                [ Element.row [ Element.width (Element.fillPortion 3) ]
                                    [ Element.el [ Element.paddingXY 0 10 ] <| Element.text "0"
                                    , Element.el [ Element.paddingXY 0 10, Element.alignRight ] <| Element.text "500"
                                    ]
                                , Element.Input.slider
                                    [ Element.behindContent
                                        (Element.el
                                            [ Element.width Element.fill
                                            , Element.height (Element.px 5)
                                            , Element.centerY
                                            , Element.Background.color (Element.rgb255 94 176 125)
                                            , Element.Border.rounded 2
                                            ]
                                            Element.none
                                        )
                                    ]
                                    { onChange = \a -> FormChanged { form | grantContribution = String.fromFloat a }
                                    , label = Element.Input.labelHidden "Opportunity grant contribution value selection slider"
                                    , min = 0
                                    , max = 550
                                    , value = String.toFloat form.grantContribution |> Maybe.withDefault 0
                                    , thumb = Element.Input.defaultThumb
                                    , step = Just 10
                                    }
                                , Element.row [ Element.width (Element.fillPortion 3) ]
                                    [ Element.el [ Element.paddingXY 0 10 ] <| Element.text "No contribution"
                                    , Element.el [ Element.paddingXY 0 10, Element.alignRight ] <| Element.text "Donate full ticket"
                                    ]
                                ]
                            ]
                        ]
            ]
        ]


grantApplicationCopy =
    """
If you would like to attend but are unsure about how to cover the combination of ticket and travel expenses, please get in touch with a brief paragraph about what motivates you to attend Elm Camp and how an opportunity grant could help.

Please apply by sending an email to [team@elm.camp](mailto:team@elm.camp). The final date for applications is the 1st of May. Decisions will be communicated directly to each applicant by 5th of May. For this first edition of Elm Camp grant decisions will be made by Elm Camp organizers.

All applicants and grant recipients will remain confidential. In the unlikely case that there are unused funds, the amount will be publicly communicated and saved for future Elm Camp grants.
"""


sponsorships model form textInput =
    Element.column [ Element.spacing 20 ]
        [ Element.el [ Element.Font.size 20 ] (Element.text "🤝 Sponsor Elm Camp")
        , Element.paragraph [] [ Element.text "Position your company as a leading supporter of the Elm community and help Elm Camp Europe 2023 achieve a reasonable ticket offering." ]
        , Product.sponsorshipItems
            |> List.map (sponsorshipOption form)
            |> Theme.rowToColumnWhen 700 model [ Element.spacing 20, Element.width Element.fill ]
        ]


sponsorshipOption form s =
    let
        selected =
            form.sponsorship == Just s.productId

        attrs =
            if selected then
                [ Element.Border.color (Element.rgb255 94 176 125), Element.Border.width 3 ]

            else
                [ Element.Border.color (Element.rgba255 0 0 0 0), Element.Border.width 3 ]
    in
    Theme.panel attrs
        [ Element.el [ Element.Font.size 20, Element.Font.bold ] (Element.text s.name)
        , Element.el [ Element.Font.size 30, Element.Font.bold ] (Element.text <| "€" ++ String.fromInt s.price)
        , Element.paragraph [] [ Element.text s.description ]
        , s.features
            |> List.map (\point -> Element.paragraph [ Element.Font.size 12 ] [ Element.text <| "• " ++ point ])
            |> Element.column [ Element.spacing 5 ]
        , Element.Input.button
            (Theme.submitButtonAttributes True)
            { onPress =
                Just <|
                    FormChanged
                        { form
                            | sponsorship =
                                if selected then
                                    Nothing

                                else
                                    Just s.productId
                        }
            , label =
                Element.el
                    [ Element.centerX, Element.Font.semiBold, Element.Font.color (Element.rgb 1 1 1) ]
                    (Element.text
                        (if selected then
                            "Un-select"

                         else
                            "Select"
                        )
                    )
            }
        ]


backgroundColor : Element.Color
backgroundColor =
    Element.rgb255 255 250 235


radioButton : String -> String -> Bool -> Element ()
radioButton groupName text isChecked =
    Html.label
        [ Html.Attributes.style "padding" "6px"
        , Html.Attributes.style "white-space" "normal"
        , Html.Attributes.style "line-height" "24px"
        ]
        [ Html.input
            [ Html.Attributes.type_ "radio"
            , Html.Attributes.checked isChecked
            , Html.Attributes.name groupName
            , Html.Events.onClick ()
            , Html.Attributes.style "transform" "translateY(-2px)"
            , Html.Attributes.style "margin" "0 8px 0 0"
            ]
            []
        , Html.text text
        ]
        |> Element.html
        |> Element.el []


dallundCastleImage : Element.Length -> String -> Element msg
dallundCastleImage width path =
    Element.image
        [ Element.width width ]
        { src = "/" ++ path, description = "Photo of part of the Dallund Castle" }


ticketCardsView : LoadedModel -> Element FrontendMsg
ticketCardsView model =
    if model.window.width < 950 then
        List.map
            (\( productId, ticket ) ->
                case AssocList.get productId model.prices of
                    Just price ->
                        Tickets.viewMobile (purchaseable ticket.productId model) (PressedSelectTicket productId price.priceId) price.price ticket

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
                        Tickets.viewDesktop (purchaseable ticket.productId model) (PressedSelectTicket productId price.priceId) price.price ticket

                    Nothing ->
                        Element.text "No ticket prices found"
            )
            (AssocList.toList Tickets.dict)
            |> Element.row (Element.spacing 16 :: Theme.contentAttributes)


tooltip : String -> Element msg
tooltip text =
    Element.paragraph
        [ Element.paddingXY 12 8
        , Element.Background.color (Element.rgb 1 1 1)
        , Element.width (Element.px 300)
        , Element.Border.shadow { offset = ( 0, 1 ), size = 0, blur = 4, color = Element.rgba 0 0 0 0.25 }
        ]
        [ Element.text text ]
