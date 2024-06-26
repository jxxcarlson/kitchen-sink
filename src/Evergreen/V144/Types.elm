module Evergreen.V144.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V144.EmailAddress
import Evergreen.V144.Id
import Evergreen.V144.KeyValueStore
import Evergreen.V144.LocalUUID
import Evergreen.V144.Postmark
import Evergreen.V144.Route
import Evergreen.V144.Session
import Evergreen.V144.Stripe.Codec
import Evergreen.V144.Stripe.Product
import Evergreen.V144.Stripe.PurchaseForm
import Evergreen.V144.Stripe.Stripe
import Evergreen.V144.Token.Types
import Evergreen.V144.Untrusted
import Evergreen.V144.User
import Evergreen.V144.Weather
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.PriceId
            , price : Evergreen.V144.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.ProductId) Evergreen.V144.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V144.Route.Route
    , initData : Maybe InitData2
    }


type SignInState
    = SignedOut
    | SignUp
    | SignedIn


type AdminDisplay
    = ADStripe
    | ADUser
    | ADSession
    | ADKeyValues


type alias BackendModel =
    { randomAtmosphericNumbers : Maybe (List Int)
    , localUuidData : Maybe Evergreen.V144.LocalUUID.Data
    , time : Time.Posix
    , secretCounter : Int
    , sessionDict : AssocList.Dict Lamdera.SessionId String
    , pendingLogins :
        AssocList.Dict
            Lamdera.SessionId
            { loginAttempts : Int
            , emailAddress : Evergreen.V144.EmailAddress.EmailAddress
            , creationTime : Time.Posix
            , loginCode : Int
            }
    , log : Evergreen.V144.Token.Types.Log
    , users : Dict.Dict String Evergreen.V144.User.User
    , sessions : Evergreen.V144.Session.Sessions
    , sessionInfo : Evergreen.V144.Session.SessionInfo
    , orders : AssocList.Dict (Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.StripeSessionId) Evergreen.V144.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.StripeSessionId) Evergreen.V144.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.StripeSessionId) Evergreen.V144.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.ProductId) Evergreen.V144.Stripe.Codec.Price2
    , products : Evergreen.V144.Stripe.Stripe.ProductInfoDict
    , keyValueStore : Dict.Dict String Evergreen.V144.KeyValueStore.KVDatum
    }


type alias LoadedModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        { width : Int
        , height : Int
        }
    , showTooltip : Bool
    , loginForm : Evergreen.V144.Token.Types.LoginForm
    , loginErrorMessage : Maybe String
    , signInStatus : Evergreen.V144.Token.Types.SignInStatus
    , currentUserData : Maybe Evergreen.V144.User.LoginData
    , prices :
        AssocList.Dict
            (Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.PriceId
            , price : Evergreen.V144.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.ProductId) Evergreen.V144.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.ProductId, Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.PriceId, Evergreen.V144.Stripe.Product.Product_ )
    , form : Evergreen.V144.Stripe.PurchaseForm.PurchaseForm
    , currentUser : Maybe Evergreen.V144.User.User
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String
    , adminDisplay : AdminDisplay
    , backendModel : Maybe BackendModel
    , route : Evergreen.V144.Route.Route
    , message : String
    , language : String
    , weatherData : Maybe Evergreen.V144.Weather.WeatherData
    , inputCity : String
    , currentKVPair : Maybe ( String, Evergreen.V144.KeyValueStore.KVDatum )
    , keyValueStore : Dict.Dict String Evergreen.V144.KeyValueStore.KVDatum
    , inputKey : String
    , inputValue : String
    , inputFilterData : String
    , kvViewType : Evergreen.V144.KeyValueStore.KVViewType
    , kvVerbosity : Evergreen.V144.KeyValueStore.KVVerbosity
    }


type FrontendModel
    = Loading LoadingModel
    | Loaded LoadedModel


type FrontendMsg
    = NoOp
    | UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | Tick Time.Posix
    | GotWindowSize Int Int
    | PressedShowTooltip
    | MouseDown
    | SubmitEmailForToken
    | CancelSignIn
    | TypedEmailInSignInForm String
    | UseReceivedCodetoSignIn String
    | SignOut
    | BuyProduct (Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.ProductId) (Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.PriceId) Evergreen.V144.Stripe.Product.Product_
    | PressedSelectTicket (Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.ProductId) (Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V144.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.ProductId) (Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.PriceId)
    | PressedCancelForm
    | AskToRenewPrices
    | SubmitSignUp
    | InputRealname String
    | InputUsername String
    | InputEmail String
    | CancelSignUp
    | OpenSignUp
    | SetAdminDisplay AdminDisplay
    | SetViewport
    | LanguageChanged String
    | CopyTextToClipboard String
    | Chirp
    | RequestWeatherData String
    | InputCity String
    | InputKey String
    | InputValue String
    | InputFilterData String
    | NewKeyValuePair
    | AddKeyValuePair String Evergreen.V144.KeyValueStore.KVDatum
    | GetValueWithKey String
    | GotValueFromKVStore (Result Http.Error Evergreen.V144.KeyValueStore.KVDatum)
    | DataUploaded (Result Http.Error ())
    | SetKVViewType Evergreen.V144.KeyValueStore.KVViewType
    | CycleKVVerbosity Evergreen.V144.KeyValueStore.KVVerbosity


type ToBackend
    = ToBackendNoOp
    | SubmitFormRequest (Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.PriceId) (Evergreen.V144.Untrusted.Untrusted Evergreen.V144.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect (Maybe Evergreen.V144.User.User)
    | GetBackendModel
    | CheckLoginRequest
    | SigInWithTokenRequest Int
    | GetSignInTokenRequest Evergreen.V144.EmailAddress.EmailAddress
    | SignOutRequest (Maybe Evergreen.V144.User.LoginData)
    | RenewPrices
    | AddUser String String String
    | RequestSignup String String String
    | GetWeatherData String
    | GetKeyValueStore


type BackendMsg
    = GotSlowTick Time.Posix
    | GotFastTick Time.Posix
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | AutoLogin Lamdera.SessionId Evergreen.V144.User.LoginData
    | BackendGotTime Lamdera.SessionId Lamdera.ClientId ToBackend Time.Posix
    | SentLoginEmail Time.Posix Evergreen.V144.EmailAddress.EmailAddress (Result Http.Error Evergreen.V144.Postmark.PostmarkSendResponse)
    | AuthenticationConfirmationEmailSent (Result Http.Error Evergreen.V144.Postmark.PostmarkSendResponse)
    | GotPrices (Result Http.Error (List Evergreen.V144.Stripe.Stripe.PriceData))
    | GotPrices2 Lamdera.ClientId (Result Http.Error (List Evergreen.V144.Stripe.Stripe.PriceData))
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.PriceId) Evergreen.V144.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V144.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V144.Postmark.PostmarkSendResponse)
    | GotWeatherData Lamdera.ClientId (Result Http.Error Evergreen.V144.Weather.WeatherData)


type BackendDataStatus
    = Fubar
    | Sunny
    | LoadedBackendData


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V144.Id.Id Evergreen.V144.Stripe.Stripe.StripeSessionId))
    | AdminInspectResponse BackendModel
    | CheckSignInResponse (Result BackendDataStatus Evergreen.V144.User.LoginData)
    | SignInWithTokenResponse (Result Int Evergreen.V144.User.LoginData)
    | GetLoginTokenRateLimited
    | LoggedOutSession
    | RegistrationError String
    | SignInError String
    | UserSignedIn (Maybe Evergreen.V144.User.User)
    | UserRegistered Evergreen.V144.User.User
    | ReceivedWeatherData (Result Http.Error Evergreen.V144.Weather.WeatherData)
    | GotKeyValueStore (Dict.Dict String Evergreen.V144.KeyValueStore.KVDatum)
    | GotBackendModel BackendModel
