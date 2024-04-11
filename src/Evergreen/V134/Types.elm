module Evergreen.V134.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V134.EmailAddress
import Evergreen.V134.Id
import Evergreen.V134.KeyValueStore
import Evergreen.V134.LocalUUID
import Evergreen.V134.Postmark
import Evergreen.V134.Route
import Evergreen.V134.Session
import Evergreen.V134.Stripe.Codec
import Evergreen.V134.Stripe.Product
import Evergreen.V134.Stripe.PurchaseForm
import Evergreen.V134.Stripe.Stripe
import Evergreen.V134.Token.Types
import Evergreen.V134.Untrusted
import Evergreen.V134.User
import Evergreen.V134.Weather
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.PriceId
            , price : Evergreen.V134.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.ProductId) Evergreen.V134.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V134.Route.Route
    , initData : Maybe InitData2
    }


type SignInState
    = SignedOut
    | SignUp
    | SignedIn


type AdminDisplay
    = ADStripe
    | ADUser
    | ADKeyValues


type alias BackendModel =
    { randomAtmosphericNumbers : Maybe (List Int)
    , localUuidData : Maybe Evergreen.V134.LocalUUID.Data
    , secretCounter : Int
    , sessionDict : AssocList.Dict Lamdera.SessionId String
    , pendingLogins :
        AssocList.Dict
            Lamdera.SessionId
            { loginAttempts : Int
            , emailAddress : Evergreen.V134.EmailAddress.EmailAddress
            , creationTime : Time.Posix
            , loginCode : Int
            }
    , log : Evergreen.V134.Token.Types.Log
    , userDictionary : Dict.Dict String Evergreen.V134.User.User
    , sessions : Evergreen.V134.Session.Sessions
    , sessionInfo : Evergreen.V134.Session.SessionInfo
    , orders : AssocList.Dict (Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.StripeSessionId) Evergreen.V134.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.StripeSessionId) Evergreen.V134.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.StripeSessionId) Evergreen.V134.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.ProductId) Evergreen.V134.Stripe.Codec.Price2
    , time : Time.Posix
    , products : Evergreen.V134.Stripe.Stripe.ProductInfoDict
    , keyValueStore : Dict.Dict String Evergreen.V134.KeyValueStore.KVDatum
    }


type alias LoadedModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        { width : Int
        , height : Int
        }
    , showTooltip : Bool
    , loginForm : Evergreen.V134.Token.Types.LoginForm
    , prices :
        AssocList.Dict
            (Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.PriceId
            , price : Evergreen.V134.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.ProductId) Evergreen.V134.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.ProductId, Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.PriceId, Evergreen.V134.Stripe.Product.Product_ )
    , form : Evergreen.V134.Stripe.PurchaseForm.PurchaseForm
    , currentUser : Maybe Evergreen.V134.User.User
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String
    , adminDisplay : AdminDisplay
    , backendModel : Maybe BackendModel
    , route : Evergreen.V134.Route.Route
    , message : String
    , language : String
    , weatherData : Maybe Evergreen.V134.Weather.WeatherData
    , inputCity : String
    , currentKVPair : Maybe ( String, Evergreen.V134.KeyValueStore.KVDatum )
    , keyValueStore : Dict.Dict String Evergreen.V134.KeyValueStore.KVDatum
    , inputKey : String
    , inputValue : String
    , inputFilterData : String
    , kvViewType : Evergreen.V134.KeyValueStore.KVViewType
    , kvVerbosity : Evergreen.V134.KeyValueStore.KVVerbosity
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
    | BuyProduct (Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.ProductId) (Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.PriceId) Evergreen.V134.Stripe.Product.Product_
    | PressedSelectTicket (Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.ProductId) (Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V134.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.ProductId) (Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.PriceId)
    | PressedCancelForm
    | AskToRenewPrices
    | SignIn
    | SetSignInState SignInState
    | SubmitSignIn
    | SubmitSignOut
    | SubmitSignUp
    | InputRealname String
    | InputUsername String
    | InputEmail String
    | InputPassword String
    | InputPasswordConfirmation String
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
    | AddKeyValuePair String Evergreen.V134.KeyValueStore.KVDatum
    | GetValueWithKey String
    | GotValue (Result Http.Error Evergreen.V134.KeyValueStore.KVDatum)
    | DataUploaded (Result Http.Error ())
    | SetKVViewType Evergreen.V134.KeyValueStore.KVViewType
    | CycleVerbosity Evergreen.V134.KeyValueStore.KVVerbosity


type ToBackend
    = SubmitFormRequest (Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.PriceId) (Evergreen.V134.Untrusted.Untrusted Evergreen.V134.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect (Maybe Evergreen.V134.User.User)
    | CheckLoginRequest
    | LoginWithTokenRequest Int
    | GetLoginTokenRequest Evergreen.V134.EmailAddress.EmailAddress
    | LogOutRequest
    | RenewPrices
    | SignInRequest String String
    | SignOutRequest String
    | SignUpRequest String String String String
    | GetWeatherData String
    | GetKeyValueStore


type BackendMsg
    = GotTime Time.Posix
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | BackendGotTime Lamdera.SessionId Lamdera.ClientId ToBackend Time.Posix
    | SentLoginEmail Time.Posix Evergreen.V134.EmailAddress.EmailAddress (Result Http.Error Evergreen.V134.Postmark.PostmarkSendResponse)
    | AuthenticationConfirmationEmailSent (Result Http.Error Evergreen.V134.Postmark.PostmarkSendResponse)
    | GotPrices (Result Http.Error (List Evergreen.V134.Stripe.Stripe.PriceData))
    | GotPrices2 Lamdera.ClientId (Result Http.Error (List Evergreen.V134.Stripe.Stripe.PriceData))
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.PriceId) Evergreen.V134.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V134.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V134.Postmark.PostmarkSendResponse)
    | GotWeatherData Lamdera.ClientId (Result Http.Error Evergreen.V134.Weather.WeatherData)


type BackendDataStatus
    = Fubar
    | Sunny
    | LoadedBackendData


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V134.Id.Id Evergreen.V134.Stripe.Stripe.StripeSessionId))
    | AdminInspectResponse BackendModel
    | CheckLoginResponse (Result BackendDataStatus Evergreen.V134.User.LoginData)
    | LoginWithTokenResponse (Result Int Evergreen.V134.User.LoginData)
    | GetLoginTokenRateLimited
    | LoggedOutSession
    | UserSignedIn (Maybe Evergreen.V134.User.User)
    | ReceivedWeatherData (Result Http.Error Evergreen.V134.Weather.WeatherData)
    | GotKeyValueStore (Dict.Dict String Evergreen.V134.KeyValueStore.KVDatum)
