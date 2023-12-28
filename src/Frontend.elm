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


header : { window : { width : Int, height : Int }, isCompact : Bool } -> Element msg
header config =
    let
        illustrationAltText =
            "Illustration of a small camp site in a richly green forest"

        titleSize =
            if config.window.width < 800 then
                64

            else
                80

        elmCampTitle =
            Element.link
                []
                { url = Route.encode HomepageRoute
                , label = Element.el [ Element.Font.size titleSize, Theme.glow, Element.paddingXY 0 8 ] (Element.text "Elm Camp")
                }

        elmCampNextTopLine =
            Element.row
                [ Element.centerX, Element.spacing 13 ]
                [ Element.image
                    [ Element.width (Element.px 49) ]
                    { src = "/elm-camp-tangram.webp", description = "The logo of Elm Camp, a tangram in green forest colors" }
                , Element.column
                    [ Element.spacing 2, Element.Font.size 24, Element.moveUp 1 ]
                    [ Element.el [ Theme.glow ] (Element.text "Unconference")
                    , Element.el [ Element.Font.extraBold, Element.Font.color MarkdownThemed.lightTheme.elmText ] (Element.text "Planet Earth 2024")
                    ]
                ]
    in
    if config.window.width < 1000 || config.isCompact then
        Element.column
            [ Element.padding 30, Element.spacing 20, Element.centerX ]
            [ if config.isCompact then
                Element.none

              else
                Element.image
                    [ Element.width (Element.maximum 523 Element.fill) ]
                    { src = "/logo.webp", description = illustrationAltText }
            , Element.column
                [ Element.spacing 24, Element.centerX ]
                [ elmCampTitle
                , elmCampNextTopLine
                ]
            ]

    else
        Element.row
            [ Element.padding 30, Element.spacing 40, Element.centerX ]
            [ Element.image
                [ Element.width (Element.px 523) ]
                { src = "/logo.webp", description = illustrationAltText }
            , Element.column
                [ Element.spacing 24 ]
                [ elmCampTitle
                , elmCampNextTopLine
                ]
            ]


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
            homepageView model

        UnconferenceFormatRoute ->
            Element.column
                [ Element.width Element.fill, Element.height Element.fill ]
                [ header { window = model.window, isCompact = True }
                , Element.column
                    (Element.padding 20 :: Theme.contentAttributes)
                    [ unconferenceFormatContent
                    ]
                , Theme.footer
                ]

        VenueAndAccessRoute ->
            Element.column
                [ Element.width Element.fill, Element.height Element.fill ]
                [ header { window = model.window, isCompact = True }
                , Element.column
                    (Element.padding 20 :: Theme.contentAttributes)
                    [ venueAccessContent
                    ]
                , Theme.footer
                ]

        CodeOfConductRoute ->
            Element.column
                [ Element.width Element.fill, Element.height Element.fill ]
                [ header { window = model.window, isCompact = True }
                , Element.column
                    (Element.padding 20 :: Theme.contentAttributes)
                    [ codeOfConductContent
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


homepageView : LoadedModel -> Element FrontendMsg_
homepageView model =
    let
        sidePadding =
            if model.window.width < 800 then
                24

            else
                60
    in
    Element.column
        [ Element.width Element.fill ]
        [ Element.column
            [ Element.spacing 50
            , Element.width Element.fill
            , Element.paddingEach { left = sidePadding, right = sidePadding, top = 0, bottom = 24 }
            ]
            [ header { window = model.window, isCompact = False }
            , Element.column
                [ Element.width Element.fill, Element.spacing 40 ]
                [ Element.column Theme.contentAttributes [ content1 ]
                , Element.column
                    Theme.contentAttributes
                    [ MarkdownThemed.renderFull "# Last year's sponsors"
                    , sponsors model.window
                    ]
                , Element.column
                    [ Element.width Element.fill
                    , Element.spacing 24
                    , Element.htmlAttribute (Html.Attributes.id ticketsHtmlId)
                    ]
                    [ Element.el Theme.contentAttributes content2
                    , Element.el Theme.contentAttributes content3
                    ]
                ]
            ]
        , Theme.footer
        ]



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


content1 : Element msg
content1 =
    """
Elm Camp brings an opportunity for Elm makers & tool builders to gather, communicate and collaborate. Our goal is to strengthen and sustain the Elm ecosystem and community.

Elm Camp is an event geared towards reconnecting in-person and collaborating on the current and future community landscape of the Elm ecosystem that surrounds the Elm core language.

Over the last few years, Elm has seen community-driven tools and libraries expanding the potential and utility of the Elm language, stemming from a steady pace of continued commercial and hobbyist adoption.

There is great potential for progress and innovation in a creative, focused, in-person gathering. It’s been a long while since we’ve had this opportunity for folks who are investing in the future of Elm. We expect the wider community and practitioners to benefit from this collaborative exploration of our problems and goals.

Last year was our first Elm Camp and unconference. Our intention remains the same: to run as a small, casual and low-stress event, and pave the way for future Elm Camps across the world.

# Help us plan Elm Camp 2024!

We're still working out the details for Elm Camp 2024. We're on the hunt for a new venue, and we need your help! If you have ideas for a local (to you) venue, please take a few minutes to fill out our [venue survey](https://docs.google.com/forms/d/e/1FAIpQLSemvyUQURU_Dowyvp-5K6miBve5KWjoVTb9D65w82lrPpnBIg)

# What happened at Elm Camp 2023

Last year we ran a 3-day event in Odense, Denmark. Here are some of the memories folks have shared:

"""

        ++ """<br/>

Did you attend Elm Camp 2023? We're [open to contributions on Github](https://github.com/elm-camp/website/edit/main/src/Camp23Denmark/Artifacts.elm)!
        """
        |> MarkdownThemed.renderFull


tooltip : String -> Element msg
tooltip text =
    Element.paragraph
        [ Element.paddingXY 12 8
        , Element.Background.color (Element.rgb 1 1 1)
        , Element.width (Element.px 300)
        , Element.Border.shadow { offset = ( 0, 1 ), size = 0, blur = 4, color = Element.rgba 0 0 0 0.25 }
        ]
        [ Element.text text ]


content2 : Element msg
content2 =
    """

# Opportunity grants

Last year, we were able to offer opportunity grants to cover both ticket and travel costs for a number of attendees who would otherwise not have been able to attend. We're still working out the details for next year's event, but we hope to be able to offer the same opportunity again.

**Thanks to Concentric and generous individual sponsors for making the Elm Camp 2023 opportunity grants possible**.

# 2024 Organisers

Elm Camp is a community-driven non-profit initiative, organised by enthusiastic members of the Elm community.

"""
        ++ organisers2024
        |> MarkdownThemed.renderFull


organisers2024 =
    """
🇬🇧 Katja Mordaunt – Uses web tech to help improve the reach of charities, artists, activists & community groups. Industry advocate for functional & Elm. Co-founder of [codereading.club](https://codereading.club/)

🇺🇸 James Carlson – Developer of [Scripta.io](https://scripta.io), a web publishing platform for technical documents in mathematics, physics, and the like. Currently working for [exosphere.app](https://exosphere.app), an all-Elm cloud-computing project

🇬🇧 Mario Rogic – Organiser of the [Elm London](https://meetdown.app/group/37aa26/Elm-London-Meetup) and [Elm Online](https://meetdown.app/group/10561/Elm-Online-Meetup) meetups. Groundskeeper of [Elmcraft](https://elmcraft.org/), founder of [Lamdera](https://lamdera.com/).

🇩🇪 Johannes Emerich – Works at [Dividat](https://dividat.com/en), making a console with small games and a large controller. Remembers when Elm demos were about the intricacies of how high Super Mario jumps.

🇺🇸 Wolfgang Schuster – Author of [Elm weekly](https://www.elmweekly.nl/), hobbyist and professional Elm developer. Currently working at [Vendr](https://www.vendr.com/).

🇬🇧 Hayleigh Thompson – Terminally online in the Elm community. Competitive person-help. Developer relations engineer at [xyflow](https://www.xyflow.com/).
"""


content3 =
    """
# Sponsorship options

Sponsoring Elm Camp gives your company the opportunity to support and connect with the Elm community. Your contribution helps members of the community to get together by keeping individual ticket prices at a reasonable level.

If you're interested in sponsoring please get in touch with the team at [team@elm.camp](mailto:team@elm.camp).

# Something else?

Problem with something above? Get in touch with the team at [team@elm.camp](mailto:team@elm.camp)."""
        |> MarkdownThemed.renderFull


sponsors : { window | width : Int } -> Element msg
sponsors window =
    let
        asImg { image, url, width } =
            Element.newTabLink
                [ Element.width Element.fill ]
                { url = url
                , label =
                    Element.image
                        [ Element.width
                            (Element.px
                                (if window.width < 800 then
                                    toFloat width * 0.7 |> round

                                 else
                                    width
                                )
                            )
                        ]
                        { src = "/sponsors/" ++ image, description = url }
                }
    in
    [ asImg { image = "vendr.png", url = "https://www.vendr.com/", width = 250 }
    , asImg { image = "concentrichealthlogo.svg", url = "https://concentric.health/", width = 250 }
    , asImg { image = "logo-dividat.svg", url = "https://dividat.com", width = 170 }
    , asImg { image = "lamdera-logo-black.svg", url = "https://lamdera.com/", width = 200 }
    , asImg { image = "scripta.io.svg", url = "https://scripta.io", width = 200 }
    , asImg { image = "bekk.svg", url = "https://www.bekk.no/", width = 200 }
    , Element.newTabLink
        [ Element.width Element.fill ]
        { url = "https://www.elmweekly.nl"
        , label =
            Element.row [ Element.spacing 10, Element.width (Element.px 200) ]
                [ Element.image
                    [ Element.width
                        (Element.px
                            (if window.width < 800 then
                                toFloat 60 * 0.7 |> round

                             else
                                60
                            )
                        )
                    ]
                    { src = "/sponsors/" ++ "elm-weekly.svg", description = "https://www.elmweekly.nl" }
                , Element.el [ Element.Font.size 24 ] <| Element.text "Elm Weekly"
                ]
        }
    , asImg { image = "cookiewolf-logo.png", url = "", width = 220 }
    ]
        -- |> List.map asImg
        |> Element.wrappedRow [ Element.spacing 32 ]


unconferenceFormatContent : Element msg
unconferenceFormatContent =
    """
# Unconference Format

## First and foremost, there are no unchangeable rules, with the exception of the "rule of two feet":
### It is expected that people move freely between sessions at any time. If you are no longer interested in listening or contributing to the conversation, find another one.

<br/>

> <br/>
> You know how at a conference, the best discussions often occur when people are relaxed during coffee breaks? That's the whole idea of an unconference: it's like a long, informal coffee break where everyone can contribute to the conversation. The participants drive the agenda. Any structure that exists at an unconference is just there to kick things off and to help the conversations flow smoothly, not to restrict or dictate the topics.

<br/>
<br/>

## We are doing this together.
## The following is intended as a collective starting point.

# Plan

## Before Elm Camp

- People can start proposing presentations before Elm camp in the form of cards on a Trello board which will be a place for conversations and serve as a schedule during the unconference and an archive after.
- There are 2 pre-planned sessions (the unkeynotes at the start and end of Elm Camp)
- We'll start with 3 tracks. If needed, more concurrent sessions may be scheduled during the unconference.
- Sessions will be offered in 15 and 30 minute blocks.
- We encourage attendees to think about how they might like to document or share our discussions with the community after Elm Camp. e.g. blog posts, graphics, videos

## During Elm Camp

- We'll arrange collective scheduling sessions every morning, where together we pitch, vote for and schedule sessions.
- All tracks will run in sync to allow for easy switching between sessions.
- We'll have reserved time for public announcements. You'll have a couple minutes on stage if needed.
- The schedule will be clearly displayed both online and at the venue for easy reference.
- Session locations will have distinctive names for effortless navigation.
- Session endings will be made clear to prevent overruns.
- Doors will be kept open to make moving along easy.
- Breaks are scheduled to provide downtime.
- The organisers will be readily available and identifiable for any assistance needed.

# Guidelines

## Be inclusive

- There is no restriction or theme on the subject for proposed topics, except that they should be with positive intent. Think do no harm and don't frame your session negatively. A simple, open question is best.
- If you want to talk about something and someone here wants to talk with you about it, grab some space and make it happen. You don't need permission, but keep it open to everyone and don't disrupt running sessions.
- Think of it as a gathering of people having open conversations
- Think discussion: talk _with_, not talk _at_. Share a 20-second description of what you think would be interesting to talk about and why.
- As much as possible, the organisers want to be normal session participants. We're one of you.
- People will be freely moving in and out of sessions. If you find yourself in an empty room, migrate.
- The event has some fixed infrastructure to keep the environment positive. But outside of that if you want to change something, feel free to make it happen.

## What happens here, stays here, by default.

- Assume people are comfortable saying stuff here because it's not going on twitter, so if you do want to quote someone during or after Elm Camp, please get their permission.
- Any outputs from the event should focus on the ideas, initiatives and projects discussed, as opposed to personal opinons or statements by individuals.
    """
        |> MarkdownThemed.renderFull


codeOfConductContent : Element msg
codeOfConductContent =
    """
# Code of Conduct

Elm Camp welcomes people with a wide range of backgrounds, experiences and knowledge. We can learn a lot from each other. It's important for us to make sure the environment where these discussions happen is inclusive and supportive. Everyone should feel comfortable to participate! The following guidelines are meant to codify these intentions.

## Help everyone feel welcome at Elm Camp

Everyone at Elm Camp is part of Elm Camp. There are a few staff on call and preparing food, but there are no other guests at the hotel.

We expect everyone here to ensure that our community is harrassment-free for everyone.

### Examples of behaviours that help us to provide an an open, welcoming, diverse, inclusive, and healthy community:

* Demonstrating empathy and kindness toward other people
* Being respectful of differing opinions, viewpoints, and experiences
* Giving and gracefully accepting constructive feedback
* Accepting responsibility and apologising to those affected by our mistakes
* Learning from our and others' mistakes and not repeating negative behaviour
* Focusing on what is best for the overall community, not just ourselves as individuals
* Consider sharing your pronouns when introducing yourself, even if you think they are obvious
* Respect the name and pronouns others introduce themselves with
* When discussing code, avoid criticising the person who wrote the code or referring to the quality of the code in a negative way
* Leave silences to allow everyone a chance to speak
* When standing around talking, leave space for new people to join your converation (sometimes referred to pacman shape)
* If you think something you are about to say might be offensive, consider not saying it. If you need to say it, please warn people beforehand.


### Examples of unacceptable behavior include:

* Public or private harassment of any kind including offensive comments related to gender, sexual orientation, disability, physical appearance, body size, race, politics, or religion
* The use of sexualised language or imagery, and sexual attention or advances of any kind
* Interrupting people when they are speaking
* Sharing others' private information, such as a physical or email address, without their explicit permission
* Other conduct which could reasonably be considered inappropriate in a professional setting


## Guidelines for running a camp session

As a facilitator it's important that you not only follow our code of conduct, but also help to enforce it.

If you have any concerns when planning, during or after your session, please get in touch with one of the organisers so we can help you.


## Talk to us

If you experience any behaviours or atmosphere at Elm Camp that feels contrary to these values, please let us know. We want everyone to feel safe, equal and welcome.

* Email the organiser team: [team@elm.camp](mailto:team@elm.camp)
* Contact Katja on [Elm slack](https://elm-lang.org/community/slack): @katjam or [Elmcraft Discord](https://discord.gg/QeZDXJrN78): Katja#0091

## How we handle Code of Conduct issues

If someone makes you or anyone else feel unsafe or unwelcome, please report it as soon as possible. You can make a report personally, anonymously or ask someone to do it on your behalf.

The Code of Conduct is in place to protect everyone at Elm Camp. If any participant violates these rules the organisers will take action.

We prefer to resolve things collaboratively and listening to everyone involved. We can all learn things from each other if we discuss issues openly.

However, if you feel you want help resolving something more privately, please ask an organiser. We are here to support you. The organisers will never disclose who brought the matter to our attention, in the case that they prefer to remain anonymous.

Where appropriate, we aim to be forgiving: if it seems like someone has made a good-natured mistake, we want to give space to grow and learn and a chance to apologise.

Where deemed necessary, the organisers will ask participants who harm the Elm Camp community to leave. This Code of Conduct is a guide, and since we can’t possibly write down all the ways you can hurt people, we may ask participants to leave for reasons that we didn’t write down explicitly here.

If you have any questions, concerns or suggestions regarding this policy, please get in touch.

This code of conduct was inspired by the [!!Con code of conduct](https://bangbangcon.com/conduct.html) and drafted with the guidance of the [Geek Feminism Wiki](https://geekfeminism.fandom.com/wiki/Conference_anti-harassment/Policy_resources)
    """
        |> MarkdownThemed.renderFull


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
