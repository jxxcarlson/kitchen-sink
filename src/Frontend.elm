module Frontend exposing (app)

--exposing (PriceId, ProductId(..), StripeSessionId)

import AssocList
import Browser exposing (UrlRequest(..))
import Browser.Dom
import Browser.Events
import Browser.Navigation
import Dict
import Env
import Json.Decode
import Json.Encode
import Lamdera
import Ports
import Predicate
import Route exposing (Route(..))
import Stripe.Product as Tickets exposing (Product_)
import Stripe.PurchaseForm as PurchaseForm exposing (PressedSubmit(..), PurchaseForm, PurchaseFormValidated(..), SubmitStatus(..))
import Stripe.Stripe as Stripe
import Stripe.View
import Task
import Time
import Types exposing (..)
import Untrusted
import Url
import Url.Parser exposing ((</>), (<?>))
import Url.Parser.Query as Query
import View.Main


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = subscriptions
        , view = View.Main.view
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
        (\window { prices, productInfo } ->
            case loadingModel.route of
                _ ->
                    ( Loaded
                        { key = loadingModel.key
                        , now = loadingModel.now
                        , window = window
                        , showTooltip = False
                        , prices = prices
                        , productInfoDict = productInfo
                        , selectedProduct = Nothing
                        , form =
                            { submitStatus = NotSubmitted NotPressedSubmit
                            , name = ""
                            , billingEmail = ""
                            , country = ""
                            }

                        -- USER
                        , currentUser = Nothing
                        , realname = ""
                        , username = ""
                        , email = ""
                        , password = ""
                        , passwordConfirmation = ""
                        , signInState = SignedOut

                        -- ADMIN
                        , adminDisplay = ADUser

                        --
                        , route = loadingModel.route
                        , isOrganiser = loadingModel.isOrganiser
                        , backendModel = Nothing
                        , message = ""
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
        NoOp ->
            ( model, Cmd.none )

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
            ( { model | showTooltip = False }, Cmd.none )

        -- ADMIN
        SetAdminDisplay adminDisplay ->
            ( { model | adminDisplay = adminDisplay }, Cmd.none )

        -- PORTS EXAMPLES
        CopyTextToClipboard text ->
            ( model, Ports.supermario_copy_to_clipboard_to_js (Json.Encode.string text) )

        Chirp ->
            ( model, Ports.playSound (Json.Encode.string "chirp.mp3") )

        -- USER
        SetSignInState state ->
            ( { model
                | signInState = state
                , username = ""
                , realname = ""
                , email = ""
                , password = ""
                , passwordConfirmation = ""
              }
            , Cmd.none
            )

        SignIn ->
            ( model, Cmd.none )

        SubmitSignIn ->
            ( model, Lamdera.sendToBackend (SignInRequest model.username model.password) )

        SubmitSignOut ->
            ( { model
                | currentUser = Nothing
                , signInState = SignedOut
                , username = ""
                , password = ""
              }
            , Cmd.none
            )

        SubmitSignUp ->
            let
                msg1 : Maybe String
                msg1 =
                    if model.password == model.passwordConfirmation then
                        Nothing

                    else
                        Just "Passwords do not match"

                msg2 : Maybe String
                msg2 =
                    if String.length model.password < 8 then
                        Just "Password must be at least 8 characters long"

                    else
                        Nothing

                msg3 : Maybe String
                msg3 =
                    if not <| String.contains "@" model.email then
                        Just "Email must contain @"

                    else
                        Nothing

                messages : List String
                messages =
                    List.filterMap identity [ msg1, msg2, msg3 ]

                message =
                    String.join ", " messages
            in
            ( { model | message = message }
            , if messages == [] then
                Lamdera.sendToBackend (SignUpRequest model.realname model.username model.email model.password)

              else
                Cmd.none
            )

        InputRealname str ->
            ( { model | realname = str }, Cmd.none )

        InputUsername str ->
            ( { model | username = str }, Cmd.none )

        InputEmail str ->
            ( { model | email = str }, Cmd.none )

        InputPassword str ->
            ( { model | password = str }, Cmd.none )

        InputPasswordConfirmation str ->
            ( { model | passwordConfirmation = str }, Cmd.none )

        -- STRIPE
        BuyProduct productId priceId product ->
            ( { model | selectedProduct = Just ( productId, priceId, product ) }, Cmd.none )

        PressedSelectTicket productId priceId ->
            case AssocList.get productId Tickets.dict of
                Just product ->
                    ( { model | selectedProduct = Just ( productId, priceId, product ) }
                    , scrollToTop
                    )

                _ ->
                    ( model, Cmd.none )

        FormChanged form ->
            case model.form.submitStatus of
                NotSubmitted _ ->
                    ( { model | form = form }, Cmd.none )

                Submitting ->
                    ( model, Cmd.none )

                SubmitBackendError _ ->
                    ( { model | form = form }, Cmd.none )

        PressedSubmitForm productId priceId ->
            let
                form =
                    model.form
            in
            case AssocList.get productId model.productInfoDict of
                Just _ ->
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

                _ ->
                    ( model, Cmd.none )

        PressedCancelForm ->
            ( { model | selectedProduct = Nothing }
            , Browser.Dom.getElement Stripe.View.ticketsHtmlId
                |> Task.andThen (\{ element } -> Browser.Dom.setViewport 0 element.y)
                |> Task.attempt (\_ -> SetViewport)
            )

        AskToRenewPrices ->
            ( model, Lamdera.sendToBackend RenewPrices )

        -- /STRIPE
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
        InitData { prices, productInfo } ->
            ( { model | prices = prices, productInfoDict = productInfo }, Cmd.none )

        GotMessage message ->
            ( { model | message = message }, Cmd.none )

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

        AdminInspectResponse backendModel ->
            ( { model | backendModel = Just backendModel }, Cmd.none )

        -- USER
        UserSignedIn maybeUser ->
            case maybeUser of
                Nothing ->
                    ( { model
                        | signInState = SignedOut
                        , realname = ""
                        , username = ""
                        , email = ""
                        , password = ""
                        , passwordConfirmation = ""
                        , currentUser = Nothing
                      }
                    , Cmd.none
                    )

                Just user ->
                    ( { model
                        | signInState = SignedIn
                        , realname = ""
                        , username = ""
                        , email = ""
                        , password = ""
                        , passwordConfirmation = ""
                        , currentUser = Just user
                      }
                    , if Predicate.isAdmin (Just user) then
                        Lamdera.sendToBackend (AdminInspect maybeUser)

                      else
                        Cmd.none
                    )
