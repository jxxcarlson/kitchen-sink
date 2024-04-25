module Types exposing
    ( AdminDisplay(..)
    , BackendDataStatus(..)
    , BackendModel
    , BackendMsg(..)
    , FrontendModel(..)
    , FrontendMsg(..)
    , InitData2
    , LoadedModel
    , LoadingModel
    , SignInState(..)
    , ToBackend(..)
    , ToFrontend(..)
    )

import AssocList
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import EmailAddress exposing (EmailAddress)
import Http
import Id exposing (Id)
import KeyValueStore
import Lamdera exposing (ClientId, SessionId)
import LocalUUID
import Postmark exposing (PostmarkSendResponse)
import Route exposing (Route)
import Session
import Stripe.Codec
import Stripe.Product
import Stripe.PurchaseForm exposing (PurchaseForm, PurchaseFormValidated)
import Stripe.Stripe exposing (Price, PriceData, PriceId, ProductId, StripeSessionId)
import Time
import Token.Types
import Untrusted exposing (Untrusted)
import Url exposing (Url)
import User
import Weather


type alias IntDict a =
    Dict Int a


type FrontendModel
    = Loading LoadingModel
    | Loaded LoadedModel


type alias LoadingModel =
    { key : Key
    , now : Time.Posix
    , window : Maybe { width : Int, height : Int }
    , route : Route
    , initData : Maybe InitData2
    }


type alias LoadedModel =
    { key : Key
    , now : Time.Posix
    , window : { width : Int, height : Int }
    , showTooltip : Bool

    -- TOKEN
    , loginForm : Token.Types.LoginForm
    , loginErrorMessage : Maybe String

    -- User
    , currentUserData : Maybe User.LoginData

    -- STRIPE
    , prices : AssocList.Dict (Id ProductId) { priceId : Id PriceId, price : Price }
    , productInfoDict : AssocList.Dict (Id ProductId) Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Id ProductId, Id PriceId, Stripe.Product.Product_ )
    , form : PurchaseForm

    -- USER
    , currentUser : Maybe User.User
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String

    -- ADMIN
    , adminDisplay : AdminDisplay
    , backendModel : Maybe BackendModel

    --
    , route : Route
    , message : String

    -- EXAMPLES
    , language : String -- Internationalization of date custom element
    , weatherData : Maybe Weather.WeatherData
    , inputCity : String

    -- DATA (JC)
    , currentKVPair : Maybe ( String, KeyValueStore.KVDatum )
    , keyValueStore : Dict.Dict String KeyValueStore.KVDatum
    , inputKey : String
    , inputValue : String
    , inputFilterData : String
    , kvViewType : KeyValueStore.KVViewType
    , kvVerbosity : KeyValueStore.KVVerbosity
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
    , localUuidData : Maybe LocalUUID.Data
    , time : Time.Posix

    -- TOKEN
    , secretCounter : Int
    , sessionDict : AssocList.Dict SessionId String -- sessionId usernamae
    , pendingLogins :
        AssocList.Dict
            SessionId
            { loginAttempts : Int
            , emailAddress : EmailAddress
            , creationTime : Time.Posix
            , loginCode : Int
            }
    , log : Token.Types.Log

    -- logs here
    -- USER
    , userDictionary : Dict.Dict String User.User
    , sessions : Session.Sessions
    , sessionInfo : Session.SessionInfo

    --STRIPE
    , orders : AssocList.Dict (Id StripeSessionId) Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Id StripeSessionId) Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Id StripeSessionId) Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Id ProductId) Stripe.Codec.Price2
    , products : Stripe.Stripe.ProductInfoDict

    -- EXPERIMENTAL
    , keyValueStore : Dict.Dict String KeyValueStore.KVDatum
    }


type FrontendMsg
    = NoOp
    | UrlClicked UrlRequest
    | UrlChanged Url
    | Tick Time.Posix
    | GotWindowSize Int Int
    | PressedShowTooltip
    | MouseDown
      -- TOKEN
    | PressedSubmitEmail
    | PressedCancelLogin
    | TypedLoginFormEmail String
    | TypedLoginCode String
    | SignOut
      -- STRIPE
    | BuyProduct (Id ProductId) (Id PriceId) Stripe.Product.Product_
    | PressedSelectTicket (Id ProductId) (Id PriceId)
    | FormChanged PurchaseForm
    | PressedSubmitForm (Id ProductId) (Id PriceId)
    | PressedCancelForm
    | AskToRenewPrices
      -- USER: sign up
    | SubmitSignUp
    | InputRealname String
    | InputUsername String
    | InputEmail String
    | CancelSignUp
      -- ADMIN
    | SetAdminDisplay AdminDisplay
      --
    | SetViewport
      -- EXAMPLES
    | LanguageChanged String -- for internationalization of date
    | CopyTextToClipboard String
    | Chirp
    | RequestWeatherData String
    | InputCity String
      -- DATA (JC)
    | InputKey String
    | InputValue String
    | InputFilterData String
    | NewKeyValuePair
    | AddKeyValuePair String KeyValueStore.KVDatum
    | GetValueWithKey String
    | GotValueFromKVStore (Result Http.Error KeyValueStore.KVDatum)
    | DataUploaded (Result Http.Error ())
    | SetKVViewType KeyValueStore.KVViewType
    | CycleKVVerbosity KeyValueStore.KVVerbosity


type ToBackend
    = ToBackendNoOp
    | SubmitFormRequest (Id PriceId) (Untrusted PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect (Maybe User.User)
    | GetBackendModel
      -- TOKEN
    | CheckLoginRequest
    | LoginWithTokenRequest Int
    | GetLoginTokenRequest EmailAddress
    | LogOutRequest
      -- STRIPE
    | RenewPrices
      -- USER
    | AddUser String String String -- realname, username, email
    | SignInRequest String String
    | SignOutRequest String
    | RequestSignup String String String String -- realname, username, email, password
      -- EXAMPLES
    | GetWeatherData String
      -- DATA (JC)
    | GetKeyValueStore



-- YADAYADA:
--required = Email.PostmarkSendResponse
--
--found =  Postmark.PostmarkSendResponse
--
-- Missing fields: { submittedAt : String, messageId : String }
-- Mismatched fields:
--   Field to:
--   Required: String
-- Found: List EmailAddress


type BackendMsg
    = GotSlowTick Time.Posix
    | GotFastTick Time.Posix
    | OnConnected SessionId ClientId
    | GotAtmosphericRandomNumbers (Result Http.Error String)
      -- TOKEN
    | AutoLogin SessionId User.LoginData
    | BackendGotTime SessionId ClientId ToBackend Time.Posix
    | SentLoginEmail Time.Posix EmailAddress (Result Http.Error Postmark.PostmarkSendResponse)
    | AuthenticationConfirmationEmailSent (Result Http.Error Postmark.PostmarkSendResponse)
      -- STRIPE
    | GotPrices (Result Http.Error (List PriceData))
    | GotPrices2 ClientId (Result Http.Error (List PriceData))
    | CreatedCheckoutSession SessionId ClientId (Id PriceId) PurchaseFormValidated (Result Http.Error ( Id StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Id StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Id StripeSessionId) (Result Http.Error PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Postmark.PostmarkSendResponse)
      -- EXAMPLES
    | GotWeatherData ClientId (Result Http.Error Weather.WeatherData)


type alias InitData2 =
    { prices : AssocList.Dict (Id ProductId) { priceId : Id PriceId, price : Price }
    , productInfo : AssocList.Dict (Id ProductId) Stripe.Stripe.ProductInfo
    }


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Id StripeSessionId))
    | AdminInspectResponse BackendModel
      -- TOKEN
    | CheckLoginResponse (Result BackendDataStatus User.LoginData)
    | LoginWithTokenResponse (Result Int User.LoginData)
    | GetLoginTokenRateLimited
    | LoggedOutSession
    | SignInError String
      -- USER
    | UserSignedIn (Maybe User.User)
      -- EXAMPLE
    | ReceivedWeatherData (Result Http.Error Weather.WeatherData)
      -- DATA (JC)
    | GotKeyValueStore (Dict.Dict String KeyValueStore.KVDatum)
    | GotBackendModel BackendModel



-- STRIPE
-- TOKEN


type BackendDataStatus
    = Fubar
    | Sunny
    | LoadedBackendData
