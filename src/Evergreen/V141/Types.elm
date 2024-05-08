module Evergreen.V141.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V141.EmailAddress
import Evergreen.V141.Id
import Evergreen.V141.KeyValueStore
import Evergreen.V141.LocalUUID
import Evergreen.V141.Postmark
import Evergreen.V141.Route
import Evergreen.V141.Session
import Evergreen.V141.Stripe.Codec
import Evergreen.V141.Stripe.Product
import Evergreen.V141.Stripe.PurchaseForm
import Evergreen.V141.Stripe.Stripe
import Evergreen.V141.Token.Types
import Evergreen.V141.Untrusted
import Evergreen.V141.User
import Evergreen.V141.Weather
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.PriceId
            , price : Evergreen.V141.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.ProductId) Evergreen.V141.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V141.Route.Route
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
    , localUuidData : Maybe Evergreen.V141.LocalUUID.Data
    , time : Time.Posix
    , secretCounter : Int
    , sessionDict : AssocList.Dict Lamdera.SessionId String
    , pendingLogins :
        AssocList.Dict
            Lamdera.SessionId
            { loginAttempts : Int
            , emailAddress : Evergreen.V141.EmailAddress.EmailAddress
            , creationTime : Time.Posix
            , loginCode : Int
            }
    , log : Evergreen.V141.Token.Types.Log
    , userDictionary : Dict.Dict String Evergreen.V141.User.User
    , sessions : Evergreen.V141.Session.Sessions
    , sessionInfo : Evergreen.V141.Session.SessionInfo
    , orders : AssocList.Dict (Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.StripeSessionId) Evergreen.V141.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.StripeSessionId) Evergreen.V141.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.StripeSessionId) Evergreen.V141.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.ProductId) Evergreen.V141.Stripe.Codec.Price2
    , products : Evergreen.V141.Stripe.Stripe.ProductInfoDict
    , keyValueStore : Dict.Dict String Evergreen.V141.KeyValueStore.KVDatum
    }


type alias LoadedModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        { width : Int
        , height : Int
        }
    , showTooltip : Bool
    , loginForm : Evergreen.V141.Token.Types.LoginForm
    , loginErrorMessage : Maybe String
    , signInStatus : Evergreen.V141.Token.Types.SignInStatus
    , currentUserData : Maybe Evergreen.V141.User.LoginData
    , prices :
        AssocList.Dict
            (Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.PriceId
            , price : Evergreen.V141.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.ProductId) Evergreen.V141.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.ProductId, Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.PriceId, Evergreen.V141.Stripe.Product.Product_ )
    , form : Evergreen.V141.Stripe.PurchaseForm.PurchaseForm
    , currentUser : Maybe Evergreen.V141.User.User
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String
    , adminDisplay : AdminDisplay
    , backendModel : Maybe BackendModel
    , route : Evergreen.V141.Route.Route
    , message : String
    , language : String
    , weatherData : Maybe Evergreen.V141.Weather.WeatherData
    , inputCity : String
    , currentKVPair : Maybe ( String, Evergreen.V141.KeyValueStore.KVDatum )
    , keyValueStore : Dict.Dict String Evergreen.V141.KeyValueStore.KVDatum
    , inputKey : String
    , inputValue : String
    , inputFilterData : String
    , kvViewType : Evergreen.V141.KeyValueStore.KVViewType
    , kvVerbosity : Evergreen.V141.KeyValueStore.KVVerbosity
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
    | BuyProduct (Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.ProductId) (Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.PriceId) Evergreen.V141.Stripe.Product.Product_
    | PressedSelectTicket (Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.ProductId) (Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V141.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.ProductId) (Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.PriceId)
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
    | AddKeyValuePair String Evergreen.V141.KeyValueStore.KVDatum
    | GetValueWithKey String
    | GotValueFromKVStore (Result Http.Error Evergreen.V141.KeyValueStore.KVDatum)
    | DataUploaded (Result Http.Error ())
    | SetKVViewType Evergreen.V141.KeyValueStore.KVViewType
    | CycleKVVerbosity Evergreen.V141.KeyValueStore.KVVerbosity


type ToBackend
    = ToBackendNoOp
    | SubmitFormRequest (Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.PriceId) (Evergreen.V141.Untrusted.Untrusted Evergreen.V141.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect (Maybe Evergreen.V141.User.User)
    | GetBackendModel
    | CheckLoginRequest
    | SigInWithTokenRequest Int
    | GetSignInTokenRequest Evergreen.V141.EmailAddress.EmailAddress
    | SignOutRequest (Maybe Evergreen.V141.User.LoginData)
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
    | AutoLogin Lamdera.SessionId Evergreen.V141.User.LoginData
    | BackendGotTime Lamdera.SessionId Lamdera.ClientId ToBackend Time.Posix
    | SentLoginEmail Time.Posix Evergreen.V141.EmailAddress.EmailAddress (Result Http.Error Evergreen.V141.Postmark.PostmarkSendResponse)
    | AuthenticationConfirmationEmailSent (Result Http.Error Evergreen.V141.Postmark.PostmarkSendResponse)
    | GotPrices (Result Http.Error (List Evergreen.V141.Stripe.Stripe.PriceData))
    | GotPrices2 Lamdera.ClientId (Result Http.Error (List Evergreen.V141.Stripe.Stripe.PriceData))
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.PriceId) Evergreen.V141.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V141.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V141.Postmark.PostmarkSendResponse)
    | GotWeatherData Lamdera.ClientId (Result Http.Error Evergreen.V141.Weather.WeatherData)


type BackendDataStatus
    = Fubar
    | Sunny
    | LoadedBackendData


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V141.Id.Id Evergreen.V141.Stripe.Stripe.StripeSessionId))
    | AdminInspectResponse BackendModel
    | CheckLoginResponse (Result BackendDataStatus Evergreen.V141.User.LoginData)
    | LoginWithTokenResponse (Result Int Evergreen.V141.User.LoginData)
    | GetLoginTokenRateLimited
    | LoggedOutSession
    | RegistrationError String
    | SignInError String
    | UserSignedIn (Maybe Evergreen.V141.User.User)
    | UserRegistered Evergreen.V141.User.User
    | ReceivedWeatherData (Result Http.Error Evergreen.V141.Weather.WeatherData)
    | GotKeyValueStore (Dict.Dict String Evergreen.V141.KeyValueStore.KVDatum)
    | GotBackendModel BackendModel
