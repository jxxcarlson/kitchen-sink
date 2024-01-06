module Evergreen.V126.Types exposing (..)

import AssocList
import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V126.Id
import Evergreen.V126.KeyValueStore
import Evergreen.V126.LocalUUID
import Evergreen.V126.Postmark
import Evergreen.V126.Route
import Evergreen.V126.Stripe.Codec
import Evergreen.V126.Stripe.Product
import Evergreen.V126.Stripe.PurchaseForm
import Evergreen.V126.Stripe.Stripe
import Evergreen.V126.Untrusted
import Evergreen.V126.User
import Evergreen.V126.Weather
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.PriceId
            , price : Evergreen.V126.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.ProductId) Evergreen.V126.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V126.Route.Route
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
    , localUuidData : Maybe Evergreen.V126.LocalUUID.Data
    , userDictionary : Dict.Dict String Evergreen.V126.User.User
    , sessions : BiDict.BiDict Lamdera.SessionId String
    , orders : AssocList.Dict (Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.StripeSessionId) Evergreen.V126.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.StripeSessionId) Evergreen.V126.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.StripeSessionId) Evergreen.V126.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.ProductId) Evergreen.V126.Stripe.Codec.Price2
    , time : Time.Posix
    , products : Evergreen.V126.Stripe.Stripe.ProductInfoDict
    , keyValueStore : Dict.Dict String Evergreen.V126.KeyValueStore.KVDatum
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
            (Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.PriceId
            , price : Evergreen.V126.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.ProductId) Evergreen.V126.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.ProductId, Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.PriceId, Evergreen.V126.Stripe.Product.Product_ )
    , form : Evergreen.V126.Stripe.PurchaseForm.PurchaseForm
    , currentUser : Maybe Evergreen.V126.User.User
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String
    , adminDisplay : AdminDisplay
    , backendModel : Maybe BackendModel
    , route : Evergreen.V126.Route.Route
    , message : String
    , weatherData : Maybe Evergreen.V126.Weather.WeatherData
    , inputCity : String
    , currentKVPair : Maybe ( String, Evergreen.V126.KeyValueStore.KVDatum )
    , keyValueStore : Dict.Dict String Evergreen.V126.KeyValueStore.KVDatum
    , inputKey : String
    , inputValue : String
    , inputFilterData : String
    , kvViewType : Evergreen.V126.KeyValueStore.KVViewType
    , kvVerbosity : Evergreen.V126.KeyValueStore.KVVerbosity
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
    | BuyProduct (Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.ProductId) (Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.PriceId) Evergreen.V126.Stripe.Product.Product_
    | PressedSelectTicket (Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.ProductId) (Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V126.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.ProductId) (Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.PriceId)
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
    | CopyTextToClipboard String
    | Chirp
    | RequestWeatherData String
    | InputCity String
    | InputKey String
    | InputValue String
    | InputFilterData String
    | NewKeyValuePair
    | AddKeyValuePair String Evergreen.V126.KeyValueStore.KVDatum
    | GetValueWithKey String
    | GotValue (Result Http.Error Evergreen.V126.KeyValueStore.KVDatum)
    | DataUploaded (Result Http.Error ())
    | SetKVViewType Evergreen.V126.KeyValueStore.KVViewType
    | CycleVerbosity Evergreen.V126.KeyValueStore.KVVerbosity


type ToBackend
    = SubmitFormRequest (Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.PriceId) (Evergreen.V126.Untrusted.Untrusted Evergreen.V126.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect (Maybe Evergreen.V126.User.User)
    | RenewPrices
    | SignInRequest String String
    | SignOutRequest String
    | SignUpRequest String String String String
    | GetWeatherData String
    | GetKeyValueStore


type BackendMsg
    = GotTime Time.Posix
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | GotPrices (Result Http.Error (List Evergreen.V126.Stripe.Stripe.PriceData))
    | GotPrices2 Lamdera.ClientId (Result Http.Error (List Evergreen.V126.Stripe.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.PriceId) Evergreen.V126.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V126.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V126.Postmark.PostmarkSendResponse)
    | GotWeatherData Lamdera.ClientId (Result Http.Error Evergreen.V126.Weather.WeatherData)


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V126.Id.Id Evergreen.V126.Stripe.Stripe.StripeSessionId))
    | AdminInspectResponse BackendModel
    | UserSignedIn (Maybe Evergreen.V126.User.User)
    | ReceivedWeatherData (Result Http.Error Evergreen.V126.Weather.WeatherData)
    | GotKeyValueStore (Dict.Dict String Evergreen.V126.KeyValueStore.KVDatum)
