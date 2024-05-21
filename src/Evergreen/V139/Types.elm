module Evergreen.V139.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V139.EmailAddress
import Evergreen.V139.Id
import Evergreen.V139.KeyValueStore
import Evergreen.V139.LocalUUID
import Evergreen.V139.MagicLink.Types
import Evergreen.V139.Postmark
import Evergreen.V139.Route
import Evergreen.V139.Session
import Evergreen.V139.Stripe.Codec
import Evergreen.V139.Stripe.Product
import Evergreen.V139.Stripe.PurchaseForm
import Evergreen.V139.Stripe.Stripe
import Evergreen.V139.Untrusted
import Evergreen.V139.User
import Evergreen.V139.Weather
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.PriceId
            , price : Evergreen.V139.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.ProductId) Evergreen.V139.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V139.Route.Route
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
    , localUuidData : Maybe Evergreen.V139.LocalUUID.Data
    , time : Time.Posix
    , secretCounter : Int
    , sessionDict : AssocList.Dict Lamdera.SessionId String
    , pendingLogins :
        AssocList.Dict
            Lamdera.SessionId
            { loginAttempts : Int
            , emailAddress : Evergreen.V139.EmailAddress.EmailAddress
            , creationTime : Time.Posix
            , loginCode : Int
            }
    , log : Evergreen.V139.MagicLink.Types.Log
    , userDictionary : Dict.Dict String Evergreen.V139.User.User
    , sessions : Evergreen.V139.Session.Sessions
    , sessionInfo : Evergreen.V139.Session.SessionInfo
    , orders : AssocList.Dict (Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.StripeSessionId) Evergreen.V139.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.StripeSessionId) Evergreen.V139.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.StripeSessionId) Evergreen.V139.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.ProductId) Evergreen.V139.Stripe.Codec.Price2
    , products : Evergreen.V139.Stripe.Stripe.ProductInfoDict
    , keyValueStore : Dict.Dict String Evergreen.V139.KeyValueStore.KVDatum
    }


type alias LoadedModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        { width : Int
        , height : Int
        }
    , showTooltip : Bool
    , loginForm : Evergreen.V139.MagicLink.Types.LoginForm
    , loginErrorMessage : Maybe String
    , signInStatus : Evergreen.V139.MagicLink.Types.SignInStatus
    , currentUserData : Maybe Evergreen.V139.User.LoginData
    , prices :
        AssocList.Dict
            (Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.PriceId
            , price : Evergreen.V139.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.ProductId) Evergreen.V139.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.ProductId, Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.PriceId, Evergreen.V139.Stripe.Product.Product_ )
    , form : Evergreen.V139.Stripe.PurchaseForm.PurchaseForm
    , currentUser : Maybe Evergreen.V139.User.User
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String
    , adminDisplay : AdminDisplay
    , backendModel : Maybe BackendModel
    , route : Evergreen.V139.Route.Route
    , message : String
    , language : String
    , weatherData : Maybe Evergreen.V139.Weather.WeatherData
    , inputCity : String
    , currentKVPair : Maybe ( String, Evergreen.V139.KeyValueStore.KVDatum )
    , keyValueStore : Dict.Dict String Evergreen.V139.KeyValueStore.KVDatum
    , inputKey : String
    , inputValue : String
    , inputFilterData : String
    , kvViewType : Evergreen.V139.KeyValueStore.KVViewType
    , kvVerbosity : Evergreen.V139.KeyValueStore.KVVerbosity
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
    | PressedSubmitEmail
    | PressedCancelLogin
    | TypedLoginFormEmail String
    | TypedLoginCode String
    | SignOut
    | BuyProduct (Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.ProductId) (Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.PriceId) Evergreen.V139.Stripe.Product.Product_
    | PressedSelectTicket (Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.ProductId) (Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V139.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.ProductId) (Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.PriceId)
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
    | AddKeyValuePair String Evergreen.V139.KeyValueStore.KVDatum
    | GetValueWithKey String
    | GotValueFromKVStore (Result Http.Error Evergreen.V139.KeyValueStore.KVDatum)
    | DataUploaded (Result Http.Error ())
    | SetKVViewType Evergreen.V139.KeyValueStore.KVViewType
    | CycleKVVerbosity Evergreen.V139.KeyValueStore.KVVerbosity


type ToBackend
    = ToBackendNoOp
    | SubmitFormRequest (Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.PriceId) (Evergreen.V139.Untrusted.Untrusted Evergreen.V139.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect (Maybe Evergreen.V139.User.User)
    | GetBackendModel
    | CheckLoginRequest
    | LoginWithTokenRequest Int
    | GetLoginTokenRequest Evergreen.V139.EmailAddress.EmailAddress
    | LogOutRequest (Maybe Evergreen.V139.User.LoginData)
    | RenewPrices
    | AddUser String String String
    | SignInRequest String String
    | SignOutRequest String
    | RequestSignup String String String String
    | GetWeatherData String
    | GetKeyValueStore


type BackendMsg
    = GotSlowTick Time.Posix
    | GotFastTick Time.Posix
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | AutoLogin Lamdera.SessionId Evergreen.V139.User.LoginData
    | BackendGotTime Lamdera.SessionId Lamdera.ClientId ToBackend Time.Posix
    | SentLoginEmail Time.Posix Evergreen.V139.EmailAddress.EmailAddress (Result Http.Error Evergreen.V139.Postmark.PostmarkSendResponse)
    | AuthenticationConfirmationEmailSent (Result Http.Error Evergreen.V139.Postmark.PostmarkSendResponse)
    | GotPrices (Result Http.Error (List Evergreen.V139.Stripe.Stripe.PriceData))
    | GotPrices2 Lamdera.ClientId (Result Http.Error (List Evergreen.V139.Stripe.Stripe.PriceData))
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.PriceId) Evergreen.V139.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V139.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V139.Postmark.PostmarkSendResponse)
    | GotWeatherData Lamdera.ClientId (Result Http.Error Evergreen.V139.Weather.WeatherData)


type BackendDataStatus
    = Fubar
    | Sunny
    | LoadedBackendData


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V139.Id.Id Evergreen.V139.Stripe.Stripe.StripeSessionId))
    | AdminInspectResponse BackendModel
    | CheckLoginResponse (Result BackendDataStatus Evergreen.V139.User.LoginData)
    | LoginWithTokenResponse (Result Int Evergreen.V139.User.LoginData)
    | GetLoginTokenRateLimited
    | LoggedOutSession
    | RegistrationError String
    | SignInError String
    | UserSignedIn (Maybe Evergreen.V139.User.User)
    | UserRegistered Evergreen.V139.User.User
    | ReceivedWeatherData (Result Http.Error Evergreen.V139.Weather.WeatherData)
    | GotKeyValueStore (Dict.Dict String Evergreen.V139.KeyValueStore.KVDatum)
    | GotBackendModel BackendModel
