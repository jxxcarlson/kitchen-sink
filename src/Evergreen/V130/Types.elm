module Evergreen.V130.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V130.Id
import Evergreen.V130.KeyValueStore
import Evergreen.V130.LocalUUID
import Evergreen.V130.Postmark
import Evergreen.V130.Route
import Evergreen.V130.Session
import Evergreen.V130.Stripe.Codec
import Evergreen.V130.Stripe.Product
import Evergreen.V130.Stripe.PurchaseForm
import Evergreen.V130.Stripe.Stripe
import Evergreen.V130.Untrusted
import Evergreen.V130.User
import Evergreen.V130.Weather
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.PriceId
            , price : Evergreen.V130.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.ProductId) Evergreen.V130.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V130.Route.Route
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
    , localUuidData : Maybe Evergreen.V130.LocalUUID.Data
    , userDictionary : Dict.Dict String Evergreen.V130.User.User
    , sessions : Evergreen.V130.Session.Sessions
    , sessionInfo : Evergreen.V130.Session.SessionInfo
    , orders : AssocList.Dict (Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.StripeSessionId) Evergreen.V130.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.StripeSessionId) Evergreen.V130.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.StripeSessionId) Evergreen.V130.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.ProductId) Evergreen.V130.Stripe.Codec.Price2
    , time : Time.Posix
    , products : Evergreen.V130.Stripe.Stripe.ProductInfoDict
    , keyValueStore : Dict.Dict String Evergreen.V130.KeyValueStore.KVDatum
    }


type alias LoadedModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        { width : Int
        , height : Int
        }
    , showTooltip : Bool
    , prices :
        AssocList.Dict
            (Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.PriceId
            , price : Evergreen.V130.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.ProductId) Evergreen.V130.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.ProductId, Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.PriceId, Evergreen.V130.Stripe.Product.Product_ )
    , form : Evergreen.V130.Stripe.PurchaseForm.PurchaseForm
    , currentUser : Maybe Evergreen.V130.User.User
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String
    , adminDisplay : AdminDisplay
    , backendModel : Maybe BackendModel
    , route : Evergreen.V130.Route.Route
    , message : String
    , language : String
    , weatherData : Maybe Evergreen.V130.Weather.WeatherData
    , inputCity : String
    , currentKVPair : Maybe ( String, Evergreen.V130.KeyValueStore.KVDatum )
    , keyValueStore : Dict.Dict String Evergreen.V130.KeyValueStore.KVDatum
    , inputKey : String
    , inputValue : String
    , inputFilterData : String
    , kvViewType : Evergreen.V130.KeyValueStore.KVViewType
    , kvVerbosity : Evergreen.V130.KeyValueStore.KVVerbosity
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
    | BuyProduct (Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.ProductId) (Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.PriceId) Evergreen.V130.Stripe.Product.Product_
    | PressedSelectTicket (Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.ProductId) (Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V130.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.ProductId) (Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.PriceId)
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
    | AddKeyValuePair String Evergreen.V130.KeyValueStore.KVDatum
    | GetValueWithKey String
    | GotValue (Result Http.Error Evergreen.V130.KeyValueStore.KVDatum)
    | DataUploaded (Result Http.Error ())
    | SetKVViewType Evergreen.V130.KeyValueStore.KVViewType
    | CycleVerbosity Evergreen.V130.KeyValueStore.KVVerbosity


type ToBackend
    = SubmitFormRequest (Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.PriceId) (Evergreen.V130.Untrusted.Untrusted Evergreen.V130.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect (Maybe Evergreen.V130.User.User)
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
    | GotPrices (Result Http.Error (List Evergreen.V130.Stripe.Stripe.PriceData))
    | GotPrices2 Lamdera.ClientId (Result Http.Error (List Evergreen.V130.Stripe.Stripe.PriceData))
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.PriceId) Evergreen.V130.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V130.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V130.Postmark.PostmarkSendResponse)
    | GotWeatherData Lamdera.ClientId (Result Http.Error Evergreen.V130.Weather.WeatherData)


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V130.Id.Id Evergreen.V130.Stripe.Stripe.StripeSessionId))
    | AdminInspectResponse BackendModel
    | UserSignedIn (Maybe Evergreen.V130.User.User)
    | ReceivedWeatherData (Result Http.Error Evergreen.V130.Weather.WeatherData)
    | GotKeyValueStore (Dict.Dict String Evergreen.V130.KeyValueStore.KVDatum)
