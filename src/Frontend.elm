module Frontend exposing (app)

import AssocList
import Auth.Common
import Auth.Flow
import Browser exposing (UrlRequest(..))
import Browser.Dom
import Browser.Events
import Browser.Navigation
import Dict
import EmailAddress
import Env
import Helper
import Json.Decode
import Json.Encode
import KeyValueStore
import Lamdera
import MagicLink.Auth
import MagicLink.Frontend
import MagicLink.LoginForm
import MagicLink.Types exposing (LoginForm(..))
import Ports
import RPC
import Route exposing (Route(..))
import Stripe.Product as Tickets exposing (Product_)
import Stripe.PurchaseForm as PurchaseForm
    exposing
        ( PressedSubmit(..)
        , PurchaseForm
        , PurchaseFormValidated(..)
        , SubmitStatus(..)
        )
import Stripe.Stripe as Stripe
import Stripe.View
import Task
import Time
import Types
    exposing
        ( AdminDisplay(..)
        , BackendModel
        , FrontendModel(..)
        , FrontendMsg(..)
        , LoadedModel
        , LoadingModel
        , SignInState(..)
        , ToBackend(..)
        , ToFrontend(..)
        )
import Untrusted
import Url
import Url.Parser exposing ((</>), (<?>))
import Url.Parser.Query as Query
import User
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
    in
    ( Loading
        { key = key
        , initUrl = url
        , now = Time.millisToPosix 0
        , window = Nothing
        , initData = Nothing
        , route = route
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

                        -- MAGICLINK
                        , authFlow = Auth.Common.Idle
                        , authRedirectBaseUrl =
                            let
                                initUrl =
                                    loadingModel.initUrl
                            in
                            { initUrl | query = Nothing, fragment = Nothing }
                        , loginForm = MagicLink.LoginForm.init
                        , loginErrorMessage = Nothing
                        , signInStatus = MagicLink.Types.NotSignedIn

                        -- USER
                        , currentUserData = Nothing
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
                        , backendModel = Nothing
                        , message = ""

                        -- EXAMPLES
                        , language = "en-US"
                        , inputCity = ""
                        , weatherData = Nothing

                        -- DATA
                        , currentKVPair = Nothing
                        , keyValueStore = Dict.empty
                        , inputKey = ""
                        , inputValue = ""
                        , inputFilterData = ""
                        , kvViewType = KeyValueStore.KVVSummary
                        , kvVerbosity = KeyValueStore.KVQuiet
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

        -- MAGICLINK
        SubmitEmailForSignIn ->
            MagicLink.Frontend.submitEmailForSignin model

        AuthSigninRequested { methodId, email } ->
            Auth.Flow.signInRequested methodId model email
                |> Tuple.mapSecond (AuthToBackend >> Lamdera.sendToBackend)

        CancelSignIn ->
            ( { model | route = HomepageRoute }, Cmd.none )

        CancelSignUp ->
            ( { model | signInStatus = MagicLink.Types.NotSignedIn }, Cmd.none )

        OpenSignUp ->
            ( { model | signInStatus = MagicLink.Types.SigningUp }, Cmd.none )

        TypedEmailInSignInForm email ->
            MagicLink.Frontend.enterEmail model email

        UseReceivedCodetoSignIn loginCode ->
            MagicLink.Frontend.signInWithCode model loginCode

        SubmitSignUp ->
            MagicLink.Frontend.submitSignUp model

        SignOut ->
            MagicLink.Frontend.signOut model

        InputRealname str ->
            ( { model | realname = str }, Cmd.none )

        InputUsername str ->
            ( { model | username = str }, Cmd.none )

        InputEmail str ->
            ( { model | email = str }, Cmd.none )

        -- ADMIN
        SetAdminDisplay adminDisplay ->
            ( { model | adminDisplay = adminDisplay }, Cmd.none )

        -- CUSTOM ELEMENT EXAMPLES
        LanguageChanged language ->
            ( { model | language = language }
            , Cmd.none
            )

        -- PORTS EXAMPLES
        CopyTextToClipboard text ->
            ( model, Ports.supermario_copy_to_clipboard_to_js (Json.Encode.string text) )

        Chirp ->
            ( model, Ports.playSound (Json.Encode.string "chirp.mp3") )

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

        -- EXAMPLES
        RequestWeatherData city ->
            ( model, Lamdera.sendToBackend (GetWeatherData city) )

        InputCity str ->
            ( { model | inputCity = str }, Cmd.none )

        -- DATA
        InputKey str ->
            ( { model | inputKey = str }, Cmd.none )

        InputValue str ->
            ( { model | inputValue = str }, Cmd.none )

        InputFilterData str ->
            ( { model | inputFilterData = str }, Cmd.none )

        NewKeyValuePair ->
            ( { model | currentKVPair = Nothing, inputKey = "??", inputValue = "" }, Cmd.none )

        AddKeyValuePair key value ->
            ( model, RPC.putKVPair key value )

        GetValueWithKey key ->
            ( model, RPC.getValueWithKey key )

        GotValueFromKVStore result ->
            case result of
                Ok value ->
                    ( { model
                        | currentKVPair = Just ( value.key, value )
                        , inputValue =
                            value.value
                                --|> String.dropLeft 1
                                --|> String.dropRight 1
                                |> String.replace "\\n" "\n"
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | currentKVPair = Nothing, inputValue = "Oops!", message = "Error finding value for given key" }, Cmd.none )

        SetKVViewType kvViewType ->
            ( { model | kvViewType = kvViewType }, Cmd.none )

        CycleKVVerbosity newVerbosity ->
            ( { model | kvVerbosity = newVerbosity }, Cmd.none )

        DataUploaded _ ->
            ( model, Lamdera.sendToBackend Types.GetKeyValueStore )


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
        AuthToFrontend authToFrontendMsg ->
            MagicLink.Auth.updateFromBackend authToFrontendMsg model

        GotBackendModel beModel ->
            ( { model | backendModel = Just beModel }, Cmd.none )

        -- MAGICLINK
        UserAuthResponse _ ->
            -- TODO (placholder)
            ( model, Cmd.none )

        AuthSuccess _ ->
            -- TODO (placholder)
            ( model, Cmd.none )

        UserInfoMsg _ ->
            -- TODO (placholder)
            ( model, Cmd.none )

        SignInError message ->
            MagicLink.Frontend.handleSignInError model message

        RegistrationError str ->
            MagicLink.Frontend.handleRegistrationError model str

        CheckSignInResponse _ ->
            ( model, Cmd.none )

        SignInWithTokenResponse result ->
            MagicLink.Frontend.signInWithTokenResponse model result

        GetLoginTokenRateLimited ->
            ( model, Cmd.none )

        LoggedOutSession ->
            ( model, Cmd.none )

        UserRegistered user ->
            MagicLink.Frontend.userRegistered model user

        UserSignedIn maybeUser ->
            ( { model | signInStatus = MagicLink.Types.NotSignedIn }, Cmd.none )

        -- STRIPE
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

        ReceivedWeatherData result ->
            case result of
                Ok weatherData ->
                    ( { model | weatherData = Just weatherData }, Cmd.none )

                Err _ ->
                    ( { model | weatherData = Nothing, message = "Error getting weather data" }, Cmd.none )

        -- DATA
        GotKeyValueStore keyValueStore ->
            ( { model | keyValueStore = keyValueStore }, Cmd.none )
