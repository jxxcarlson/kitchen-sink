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
import Auth.Common
import Auth.Flow
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import EmailAddress exposing (EmailAddress)
import Http
import Id exposing (Id)
import KeyValueStore
import Lamdera exposing (ClientId, SessionId)
import LocalUUID
import MagicLink.Types
import Postmark exposing (PostmarkSendResponse)
import Route exposing (Route)
import Session
import Stripe.Codec
import Stripe.Product
import Stripe.PurchaseForm exposing (PurchaseForm, PurchaseFormValidated)
import Stripe.Stripe exposing (Price, PriceData, PriceId, ProductId, StripeSessionId)
import Time
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
    , initUrl : Url
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

    -- MAGICLINK
    , authFlow : Auth.Common.Flow
    , authRedirectBaseUrl : Url
    , signinForm : MagicLink.Types.SiginForm
    , loginErrorMessage : Maybe String
    , signInStatus : MagicLink.Types.SignInStatus
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

    -- MAGICLINK
    , pendingAuths : Dict Lamdera.SessionId Auth.Common.PendingAuth
    , pendingEmailAuths : Dict Lamdera.SessionId Auth.Common.PendingEmailAuth
    , sessions : Dict SessionId Auth.Common.UserInfo
    , secretCounter : Int
    , sessionDict : AssocList.Dict SessionId String -- Dict sessionId usernames
    , pendingLogins :
        AssocList.Dict
            SessionId
            { loginAttempts : Int
            , emailAddress : EmailAddress
            , creationTime : Time.Posix
            , loginCode : Int
            }
    , log : MagicLink.Types.Log
    , users : Dict.Dict User.EmailString User.User
    , userNameToEmailString : Dict.Dict User.Username User.EmailString
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
      -- MAGICLINK
    | SubmitEmailForSignIn
    | AuthSigninRequested { methodId : Auth.Common.MethodId, email : Maybe String }
      --
    | CancelSignIn
    | TypedEmailInSignInForm String
    | ReceivedSigninCode String
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
    | OpenSignUp
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
      -- MAGICLINK
    | AuthToBackend Auth.Common.ToBackend
      ---
    | CheckLoginRequest
    | SigInWithToken Int
    | RequestMagicToken EmailAddress
    | SignOutRequest (Maybe User.LoginData)
      -- STRIPE
    | RenewPrices
      -- USER
    | AddUser String String String -- realname, username, email
    | RequestSignup String String String -- realname, username, email
      -- EXAMPLES
    | GetWeatherData String
      -- DATA (JC)
    | GetKeyValueStore


type BackendMsg
    = NoOpBackendMsg
    | GotSlowTick Time.Posix
    | GotFastTick Time.Posix
    | OnConnected SessionId ClientId
    | GotAtmosphericRandomNumbers (Result Http.Error String)
      -- MAGICLINK
    | AuthBackendMsg Auth.Common.BackendMsg
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
      -- MAGICLINK
    | AuthToFrontend Auth.Common.ToFrontend
    | AuthSuccess Auth.Common.UserInfo
    | UserInfoMsg (Maybe Auth.Common.UserInfo)
      ---
    | CheckSignInResponse (Result BackendDataStatus User.LoginData)
    | SignInWithTokenResponse (Result Int User.LoginData)
    | GetLoginTokenRateLimited
    | LoggedOutSession
    | RegistrationError String
    | SignInError String
      -- USER
    | ReceivedMessage (Result String String) -- MAGICLINK
    | UserSignedIn (Maybe User.User)
    | UserRegistered User.User
      -- EXAMPLE
    | ReceivedWeatherData (Result Http.Error Weather.WeatherData)
      -- DATA (JC)
    | GotKeyValueStore (Dict.Dict String KeyValueStore.KVDatum)
    | GotBackendModel BackendModel



-- SentLoginEmail Time.Posix EmailAddress (Result Http.Error Postmark.PostmarkSendResponse)


type BackendDataStatus
    = Fubar
    | Sunny
    | LoadedBackendData
