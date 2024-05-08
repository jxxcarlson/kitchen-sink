module Evergreen.V138.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V138.EmailAddress
import Evergreen.V138.Id
import Evergreen.V138.KeyValueStore
import Evergreen.V138.LocalUUID
import Evergreen.V138.Postmark
import Evergreen.V138.Route
import Evergreen.V138.Session
import Evergreen.V138.Stripe.Codec
import Evergreen.V138.Stripe.Product
import Evergreen.V138.Stripe.PurchaseForm
import Evergreen.V138.Stripe.Stripe
import Evergreen.V138.Token.Types
import Evergreen.V138.Untrusted
import Evergreen.V138.User
import Evergreen.V138.Weather
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.PriceId
            , price : Evergreen.V138.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.ProductId) Evergreen.V138.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V138.Route.Route
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
    , localUuidData : Maybe Evergreen.V138.LocalUUID.Data
    , time : Time.Posix
    , secretCounter : Int
    , sessionDict : AssocList.Dict Lamdera.SessionId String
    , pendingLogins :
        AssocList.Dict
            Lamdera.SessionId
            { loginAttempts : Int
            , emailAddress : Evergreen.V138.EmailAddress.EmailAddress
            , creationTime : Time.Posix
            , loginCode : Int
            }
    , log : Evergreen.V138.Token.Types.Log
    , userDictionary : Dict.Dict String Evergreen.V138.User.User
    , sessions : Evergreen.V138.Session.Sessions
    , sessionInfo : Evergreen.V138.Session.SessionInfo
    , orders : AssocList.Dict (Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.StripeSessionId) Evergreen.V138.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.StripeSessionId) Evergreen.V138.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.StripeSessionId) Evergreen.V138.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.ProductId) Evergreen.V138.Stripe.Codec.Price2
    , products : Evergreen.V138.Stripe.Stripe.ProductInfoDict
    , keyValueStore : Dict.Dict String Evergreen.V138.KeyValueStore.KVDatum
    }


type alias LoadedModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        { width : Int
        , height : Int
        }
    , showTooltip : Bool
    , loginForm : Evergreen.V138.Token.Types.LoginForm
    , loginErrorMessage : Maybe String
    , signInStatus : Evergreen.V138.Token.Types.SignInStatus
    , currentUserData : Maybe Evergreen.V138.User.LoginData
    , prices :
        AssocList.Dict
            (Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.PriceId
            , price : Evergreen.V138.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.ProductId) Evergreen.V138.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.ProductId, Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.PriceId, Evergreen.V138.Stripe.Product.Product_ )
    , form : Evergreen.V138.Stripe.PurchaseForm.PurchaseForm
    , currentUser : Maybe Evergreen.V138.User.User
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String
    , adminDisplay : AdminDisplay
    , backendModel : Maybe BackendModel
    , route : Evergreen.V138.Route.Route
    , message : String
    , language : String
    , weatherData : Maybe Evergreen.V138.Weather.WeatherData
    , inputCity : String
    , currentKVPair : Maybe ( String, Evergreen.V138.KeyValueStore.KVDatum )
    , keyValueStore : Dict.Dict String Evergreen.V138.KeyValueStore.KVDatum
    , inputKey : String
    , inputValue : String
    , inputFilterData : String
    , kvViewType : Evergreen.V138.KeyValueStore.KVViewType
    , kvVerbosity : Evergreen.V138.KeyValueStore.KVVerbosity
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
    | BuyProduct (Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.ProductId) (Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.PriceId) Evergreen.V138.Stripe.Product.Product_
    | PressedSelectTicket (Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.ProductId) (Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V138.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.ProductId) (Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.PriceId)
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
    | AddKeyValuePair String Evergreen.V138.KeyValueStore.KVDatum
    | GetValueWithKey String
    | GotValueFromKVStore (Result Http.Error Evergreen.V138.KeyValueStore.KVDatum)
    | DataUploaded (Result Http.Error ())
    | SetKVViewType Evergreen.V138.KeyValueStore.KVViewType
    | CycleKVVerbosity Evergreen.V138.KeyValueStore.KVVerbosity


type ToBackend
    = ToBackendNoOp
    | SubmitFormRequest (Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.PriceId) (Evergreen.V138.Untrusted.Untrusted Evergreen.V138.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect (Maybe Evergreen.V138.User.User)
    | GetBackendModel
    | CheckLoginRequest
    | LoginWithTokenRequest Int
    | GetLoginTokenRequest Evergreen.V138.EmailAddress.EmailAddress
    | LogOutRequest (Maybe Evergreen.V138.User.LoginData)
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
    | AutoLogin Lamdera.SessionId Evergreen.V138.User.LoginData
    | BackendGotTime Lamdera.SessionId Lamdera.ClientId ToBackend Time.Posix
    | SentLoginEmail Time.Posix Evergreen.V138.EmailAddress.EmailAddress (Result Http.Error Evergreen.V138.Postmark.PostmarkSendResponse)
    | AuthenticationConfirmationEmailSent (Result Http.Error Evergreen.V138.Postmark.PostmarkSendResponse)
    | GotPrices (Result Http.Error (List Evergreen.V138.Stripe.Stripe.PriceData))
    | GotPrices2 Lamdera.ClientId (Result Http.Error (List Evergreen.V138.Stripe.Stripe.PriceData))
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.PriceId) Evergreen.V138.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V138.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V138.Postmark.PostmarkSendResponse)
    | GotWeatherData Lamdera.ClientId (Result Http.Error Evergreen.V138.Weather.WeatherData)


type BackendDataStatus
    = Fubar
    | Sunny
    | LoadedBackendData


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V138.Id.Id Evergreen.V138.Stripe.Stripe.StripeSessionId))
    | AdminInspectResponse BackendModel
    | CheckLoginResponse (Result BackendDataStatus Evergreen.V138.User.LoginData)
    | LoginWithTokenResponse (Result Int Evergreen.V138.User.LoginData)
    | GetLoginTokenRateLimited
    | LoggedOutSession
    | RegistrationError String
    | SignInError String
    | UserSignedIn (Maybe Evergreen.V138.User.User)
    | UserRegistered Evergreen.V138.User.User
    | ReceivedWeatherData (Result Http.Error Evergreen.V138.Weather.WeatherData)
    | GotKeyValueStore (Dict.Dict String Evergreen.V138.KeyValueStore.KVDatum)
    | GotBackendModel BackendModel
