module Evergreen.V136.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V136.EmailAddress
import Evergreen.V136.Id
import Evergreen.V136.KeyValueStore
import Evergreen.V136.LocalUUID
import Evergreen.V136.Postmark
import Evergreen.V136.Route
import Evergreen.V136.Session
import Evergreen.V136.Stripe.Codec
import Evergreen.V136.Stripe.Product
import Evergreen.V136.Stripe.PurchaseForm
import Evergreen.V136.Stripe.Stripe
import Evergreen.V136.Token.Types
import Evergreen.V136.Untrusted
import Evergreen.V136.User
import Evergreen.V136.Weather
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.PriceId
            , price : Evergreen.V136.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.ProductId) Evergreen.V136.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V136.Route.Route
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
    , localUuidData : Maybe Evergreen.V136.LocalUUID.Data
    , time : Time.Posix
    , secretCounter : Int
    , sessionDict : AssocList.Dict Lamdera.SessionId String
    , pendingLogins :
        AssocList.Dict
            Lamdera.SessionId
            { loginAttempts : Int
            , emailAddress : Evergreen.V136.EmailAddress.EmailAddress
            , creationTime : Time.Posix
            , loginCode : Int
            }
    , log : Evergreen.V136.Token.Types.Log
    , userDictionary : Dict.Dict String Evergreen.V136.User.User
    , sessions : Evergreen.V136.Session.Sessions
    , sessionInfo : Evergreen.V136.Session.SessionInfo
    , orders : AssocList.Dict (Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.StripeSessionId) Evergreen.V136.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.StripeSessionId) Evergreen.V136.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.StripeSessionId) Evergreen.V136.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.ProductId) Evergreen.V136.Stripe.Codec.Price2
    , products : Evergreen.V136.Stripe.Stripe.ProductInfoDict
    , keyValueStore : Dict.Dict String Evergreen.V136.KeyValueStore.KVDatum
    }


type alias LoadedModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        { width : Int
        , height : Int
        }
    , showTooltip : Bool
    , loginForm : Evergreen.V136.Token.Types.LoginForm
    , loginErrorMessage : Maybe String
    , signInStatus : Evergreen.V136.Token.Types.SignInStatus
    , currentUserData : Maybe Evergreen.V136.User.LoginData
    , prices :
        AssocList.Dict
            (Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.PriceId
            , price : Evergreen.V136.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.ProductId) Evergreen.V136.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.ProductId, Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.PriceId, Evergreen.V136.Stripe.Product.Product_ )
    , form : Evergreen.V136.Stripe.PurchaseForm.PurchaseForm
    , currentUser : Maybe Evergreen.V136.User.User
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String
    , adminDisplay : AdminDisplay
    , backendModel : Maybe BackendModel
    , route : Evergreen.V136.Route.Route
    , message : String
    , language : String
    , weatherData : Maybe Evergreen.V136.Weather.WeatherData
    , inputCity : String
    , currentKVPair : Maybe ( String, Evergreen.V136.KeyValueStore.KVDatum )
    , keyValueStore : Dict.Dict String Evergreen.V136.KeyValueStore.KVDatum
    , inputKey : String
    , inputValue : String
    , inputFilterData : String
    , kvViewType : Evergreen.V136.KeyValueStore.KVViewType
    , kvVerbosity : Evergreen.V136.KeyValueStore.KVVerbosity
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
    | BuyProduct (Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.ProductId) (Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.PriceId) Evergreen.V136.Stripe.Product.Product_
    | PressedSelectTicket (Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.ProductId) (Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V136.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.ProductId) (Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.PriceId)
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
    | AddKeyValuePair String Evergreen.V136.KeyValueStore.KVDatum
    | GetValueWithKey String
    | GotValueFromKVStore (Result Http.Error Evergreen.V136.KeyValueStore.KVDatum)
    | DataUploaded (Result Http.Error ())
    | SetKVViewType Evergreen.V136.KeyValueStore.KVViewType
    | CycleKVVerbosity Evergreen.V136.KeyValueStore.KVVerbosity


type ToBackend
    = ToBackendNoOp
    | SubmitFormRequest (Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.PriceId) (Evergreen.V136.Untrusted.Untrusted Evergreen.V136.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect (Maybe Evergreen.V136.User.User)
    | GetBackendModel
    | CheckLoginRequest
    | LoginWithTokenRequest Int
    | GetLoginTokenRequest Evergreen.V136.EmailAddress.EmailAddress
    | LogOutRequest
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
    | AutoLogin Lamdera.SessionId Evergreen.V136.User.LoginData
    | BackendGotTime Lamdera.SessionId Lamdera.ClientId ToBackend Time.Posix
    | SentLoginEmail Time.Posix Evergreen.V136.EmailAddress.EmailAddress (Result Http.Error Evergreen.V136.Postmark.PostmarkSendResponse)
    | AuthenticationConfirmationEmailSent (Result Http.Error Evergreen.V136.Postmark.PostmarkSendResponse)
    | GotPrices (Result Http.Error (List Evergreen.V136.Stripe.Stripe.PriceData))
    | GotPrices2 Lamdera.ClientId (Result Http.Error (List Evergreen.V136.Stripe.Stripe.PriceData))
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.PriceId) Evergreen.V136.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V136.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V136.Postmark.PostmarkSendResponse)
    | GotWeatherData Lamdera.ClientId (Result Http.Error Evergreen.V136.Weather.WeatherData)


type BackendDataStatus
    = Fubar
    | Sunny
    | LoadedBackendData


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V136.Id.Id Evergreen.V136.Stripe.Stripe.StripeSessionId))
    | AdminInspectResponse BackendModel
    | CheckLoginResponse (Result BackendDataStatus Evergreen.V136.User.LoginData)
    | LoginWithTokenResponse (Result Int Evergreen.V136.User.LoginData)
    | GetLoginTokenRateLimited
    | LoggedOutSession
    | SignInError String
    | UserSignedIn (Maybe Evergreen.V136.User.User)
    | ReceivedWeatherData (Result Http.Error Evergreen.V136.Weather.WeatherData)
    | GotKeyValueStore (Dict.Dict String Evergreen.V136.KeyValueStore.KVDatum)
    | GotBackendModel BackendModel
