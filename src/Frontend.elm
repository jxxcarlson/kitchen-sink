module Frontend exposing (app)

import Admin
import AssocList
import Audio exposing (Audio, AudioCmd)
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
import Inventory
import Json.Decode
import Lamdera
import LiveSchedule
import MarkdownThemed
import Pages.About
import Pages.Brillig
import Pages.Home
import Pages.Parts
import Ports
import Product
import PurchaseForm exposing (PressedSubmit(..), PurchaseForm, PurchaseFormValidated(..), SubmitStatus(..))
import Route exposing (Route(..), SubPage(..))
import String.Nonempty
import Stripe exposing (PriceId, ProductId(..))
import Task
import Theme
import Tickets exposing (Ticket)
import Time
import TravelMode
import Types exposing (..)
import Untrusted
import Url
import Url.Parser exposing ((</>), (<?>))
import Url.Parser.Query as Query


app =
    Audio.lamderaFrontendWithAudio
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update =
            \_ msg model ->
                let
                    ( newModel, cmd ) =
                        update msg model
                in
                ( newModel, cmd, Audio.cmdNone )
        , updateFromBackend =
            \_ toFrontend model ->
                let
                    ( newModel, cmd ) =
                        updateFromBackend toFrontend model
                in
                ( newModel, cmd, Audio.cmdNone )
        , subscriptions = \_ model -> subscriptions model
        , view = \_ model -> view model
        , audio = audio
        , audioPort = { toJS = Ports.audioPortToJS, fromJS = Ports.audioPortFromJS }
        }


audio : a -> FrontendModel_ -> Audio
audio _ model =
    case model of
        Loading _ ->
            Audio.silence

        Loaded loaded ->
            case ( loaded.route, loaded.audio ) of
                ( LiveScheduleRoute, Just song ) ->
                    if loaded.pressedAudioButton then
                        LiveSchedule.audio song

                    else
                        Audio.silence

                _ ->
                    Audio.silence


subscriptions : FrontendModel_ -> Sub FrontendMsg_
subscriptions _ =
    Sub.batch
        [ Browser.Events.onResize GotWindowSize
        , Browser.Events.onMouseUp (Json.Decode.succeed MouseDown)
        , Time.every 1000 Tick
        ]


queryBool name =
    Query.enum name (Dict.fromList [ ( "true", True ), ( "false", False ) ])


init : Url.Url -> Browser.Navigation.Key -> ( FrontendModel_, Cmd FrontendMsg_, AudioCmd FrontendMsg_ )
init url key =
    let
        route =
            Route.decode url

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
        , audio = Nothing
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
    , case route of
        Route.LiveScheduleRoute ->
            Audio.loadAudio LoadedMusic "cowboy bebob - elm.mp3"

        _ ->
            Audio.cmdNone
    )


update : FrontendMsg_ -> FrontendModel_ -> ( FrontendModel_, Cmd FrontendMsg_ )
update msg model =
    case model of
        Loading loading ->
            case msg of
                GotWindowSize width height ->
                    tryLoading { loading | window = Just { width = width, height = height } }

                LoadedMusic result ->
                    tryLoading { loading | audio = Just result }

                _ ->
                    ( model, Cmd.none )

        Loaded loaded ->
            updateLoaded msg loaded |> Tuple.mapFirst Loaded


tryLoading : LoadingModel -> ( FrontendModel_, Cmd FrontendMsg_ )
tryLoading loadingModel =
    Maybe.map2
        (\window { slotsRemaining, prices, ticketsEnabled } ->
            case ( loadingModel.audio, loadingModel.route ) of
                ( Just (Ok song), LiveScheduleRoute ) ->
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
                        , audio = Just song
                        , pressedAudioButton = False
                        }
                    , Cmd.none
                    )

                ( _, LiveScheduleRoute ) ->
                    ( Loading loadingModel, Cmd.none )

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
                        , audio = Nothing
                        , pressedAudioButton = False
                        }
                    , Cmd.none
                    )
        )
        loadingModel.window
        loadingModel.initData
        |> Maybe.withDefault ( Loading loadingModel, Cmd.none )


updateLoaded : FrontendMsg_ -> LoadedModel -> ( LoadedModel, Cmd FrontendMsg_ )
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

        PressedShowCarbonOffsetTooltip ->
            ( { model | showCarbonOffsetTooltip = True }, Cmd.none )

        SetViewport ->
            ( model, Cmd.none )

        LoadedMusic _ ->
            ( model, Cmd.none )

        LiveScheduleMsg liveScheduleMsg ->
            case liveScheduleMsg of
                LiveSchedule.PressedAllowAudio ->
                    ( { model | pressedAudioButton = True }, Cmd.none )


scrollToTop : Cmd FrontendMsg_
scrollToTop =
    Browser.Dom.setViewport 0 0 |> Task.perform (\() -> SetViewport)


updateFromBackend : ToFrontend -> FrontendModel_ -> ( FrontendModel_, Cmd FrontendMsg_ )
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


view : FrontendModel_ -> Browser.Document FrontendMsg_
view model =
    { title = "Elm Camp"
    , body =
        [ Theme.css

        -- , W.Styles.globalStyles
        -- , W.Styles.baseTheme
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
                Loading loading ->
                    Element.column [ Element.width Element.fill, Element.padding 20 ]
                        [ (case loading.audio of
                            Just (Err error) ->
                                case error of
                                    Audio.FailedToDecode ->
                                        "Failed to decode song"

                                    Audio.NetworkError ->
                                        "Network error"

                                    Audio.UnknownError ->
                                        "Unknown error"

                                    Audio.ErrorThatHappensWhenYouLoadMoreThan1000SoundsDueToHackyWorkAroundToMakeThisPackageBehaveMoreLikeAnEffectPackage ->
                                        "Unknown error"

                            _ ->
                                "Loading..."
                          )
                            |> Element.text
                            |> Element.el [ Element.centerX ]
                        ]

                Loaded loaded ->
                    loadedView loaded
            )
        ]
    }


loadedView : LoadedModel -> Element FrontendMsg_
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
                , Theme.footer
                ]

        Brillig ->
            Element.column
                [ Element.width Element.fill, Element.height Element.fill ]
                [ Pages.Parts.header { window = model.window, isCompact = True }
                , Element.column
                    (Element.padding 20 :: Theme.contentAttributes)
                    [ Pages.Brillig.view model
                    ]
                , Theme.footer
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

        LiveScheduleRoute ->
            LiveSchedule.view model |> Element.map LiveScheduleMsg


ticketsHtmlId =
    "tickets"



-- slotsLeftText : { a | slotsRemaining : Int } -> String
-- slotsLeftText model =
--     String.fromInt model.slotsRemaining
--         ++ "/"
--         ++ String.fromInt totalSlotsAvailable
--         ++ " slots left"


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


formView : LoadedModel -> Id ProductId -> Id PriceId -> Ticket -> Element FrontendMsg_
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
        , carbonOffsetForm textInput model.showCarbonOffsetTooltip form
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
    Element.rgb255 255 244 225


carbonOffsetForm textInput showCarbonOffsetTooltip form =
    Element.column
        [ Element.width Element.fill
        , Element.spacing 24
        , Element.paddingEach { left = 16, right = 16, top = 32, bottom = 16 }
        , Element.Border.width 2
        , Element.Border.color (Element.rgb255 94 176 125)
        , Element.Border.rounded 12
        , Element.el
            [ (if showCarbonOffsetTooltip then
                tooltip "We collect this info so we can estimate the carbon footprint of your trip. We pay Ecologi to offset some of the environmental impact (this is already priced in and doesn't change the shown ticket price)"

               else
                Element.none
              )
                |> Element.below
            , Element.moveUp 20
            , Element.moveRight 8
            , Element.Background.color backgroundColor
            ]
            (Element.Input.button
                [ Element.padding 8 ]
                { onPress = Just PressedShowCarbonOffsetTooltip
                , label =
                    Element.row
                        []
                        [ Element.el [ Element.Font.size 20 ] (Element.text "🌲 Carbon offsetting ")
                        , Element.el [ Element.Font.size 12 ] (Element.text "ℹ️")
                        ]
                }
            )
            |> Element.inFront
        ]
        [ textInput
            (\a -> FormChanged { form | country = a })
            "Country you live in"
            (\text ->
                case String.Nonempty.fromString text of
                    Just nonempty ->
                        Ok nonempty

                    Nothing ->
                        Err "Please type in the name of the country you live in"
            )
            form.country
        , textInput
            (\a -> FormChanged { form | originCity = a })
            "City you live in (or nearest city to you)"
            (\text ->
                case String.Nonempty.fromString text of
                    Just nonempty ->
                        Ok nonempty

                    Nothing ->
                        Err "Please type in the name of city nearest to you"
            )
            form.originCity
        , Element.column
            [ Element.spacing 8 ]
            [ Element.paragraph
                [ Element.Font.semiBold ]
                [ Element.text "What will be your primary method of travelling to the event?" ]
            , TravelMode.all
                |> List.map
                    (\choice ->
                        radioButton "travel-mode" (TravelMode.toString choice) (Just choice == form.primaryModeOfTravel)
                            |> Element.map
                                (\() ->
                                    if Just choice == form.primaryModeOfTravel then
                                        FormChanged { form | primaryModeOfTravel = Nothing }

                                    else
                                        FormChanged { form | primaryModeOfTravel = Just choice }
                                )
                    )
                |> Element.column []
            , case ( form.submitStatus, form.primaryModeOfTravel ) of
                ( NotSubmitted PressedSubmit, Nothing ) ->
                    errorText "Please select one of the above"

                _ ->
                    Element.none
            ]
        ]


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


ticketCardsView : LoadedModel -> Element FrontendMsg_
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


venueAccessContent : Element msg
venueAccessContent =
    Element.column
        []
        [ """
# The venue and access

## The venue

**Dallund Slot**<br/>
Dallundvej 63<br/>
5471 Søndersø<br/>
Denmark

[Google Maps](https://goo.gl/maps/1WGiHRc7NaNimBzx5)

[https://www.dallundcastle.dk/](https://www.dallundcastle.dk/)

## Getting there

### via train, bus & 2 km walk/Elm Camp shuttle

* Travel to Odense train station ([Danske Statsbaner](https://www.dsb.dk/en/))
* From the station take [bus 191](https://www.fynbus.dk/find-din-rejse/rute,190) to Søndersø (_OBC Nord Plads H_ to _Søndersø Bypark_)
* Elm Camp will be organising shuttles between Søndersø and the venue at key times
* You can walk 2 km from Søndersø to the venue if you don't mind a short section of unpaved road

### via car

* There is ample parking on site

### via plane

* Major airports in Denmark are Copenhagen, Billund and Aarhus
* Malmö (Sweden) also has good connections to Denmark

For other travel options also check [Rejseplanen](https://www.rejseplanen.dk/), [The Man in Seat 61](https://www.seat61.com/Denmark.htm), [Trainline](https://www.thetrainline.com/) and [Flixbus](https://www.flixbus.co.uk/coach/odense).

## Local amenities

Food and drinks are available on site, but if you forgot to pack a toothbrush or need that gum you like, Søndersø offers a few shops.

### Supermarkets

- SuperBrugsen (7 am—8 pm), Toftekær 4
- Rema 1000 (7 am—9 pm), Odensevej 3
- Netto (7 am—10 pm), Vesterled 45

### Health

- Pharmacy ([Søndersø Apotek](https://soendersoeapotek.a-apoteket.dk/)) (9 am—5:30 pm), near SuperBrugsen supermarket

## Accessibility

### Not step free.

* Bedrooms, toilets, dining rooms and conference talk / workshop rooms can all be accessed via a lift which is 3 steps from ground level

### It's an old manor house

* The house has been renovated to a high standard but there are creaky bits, be sensible when exploring
* There are plenty of spaces to hang out in private or in a small quiet group
* There are a variety of seating options

### Toilets

* All toilets are gender neutral
* There is one public toilet on each of the 3 floors
* All attendees staying at the hotel have a private ensuite in their room
* The level of accessibility of toilets needs to be confirmed (please ask if you have specific needs)

### Open water & rough ground

* The house is set in landscaped grounds, there are paths and rough bits.
* There is a lake with a pier for swimming and fishing off of, right next to the house that is NOT fenced

## Participating in conversations

* The official conference language will be English. We ask that attendees conduct as much of their conversations in English in order to include as many people as possible
* We do not have facility for captioning or signing, please get in touch as soon as possible if you would benefit from something like that and we'll see what we can do
* We aim to provide frequent breaks of a decent length, so if this feels lacking to you at any time, let an organiser know

## Contacting the organisers

If you have questions or concerns about this website or attending Elm Camp, please get in touch

    """
            ++ contactDetails
            |> MarkdownThemed.renderFull
        , Html.iframe
            [ Html.Attributes.src "/map.html"
            , Html.Attributes.style "width" "100%"
            , Html.Attributes.style "height" "auto"
            , Html.Attributes.style "aspect-ratio" "21 / 9"
            , Html.Attributes.style "border" "none"
            ]
            []
            |> Element.html
        ]


contactDetails : String
contactDetails =
    """
* Elmcraft Discord: [#elm-camp-23](https://discord.gg/QeZDXJrN78) channel or DM Katja#0091
* Email: [team@elm.camp](mailto:team@elm.camp)
* Elm Slack: @katjam
"""
