module Evergreen.V120.Types exposing (..)

import AssocList
import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V120.Id
import Evergreen.V120.KeyValueStore
import Evergreen.V120.LocalUUID
import Evergreen.V120.Postmark
import Evergreen.V120.Route
import Evergreen.V120.Stripe.Codec
import Evergreen.V120.Stripe.Product
import Evergreen.V120.Stripe.PurchaseForm
import Evergreen.V120.Stripe.Stripe
import Evergreen.V120.Untrusted
import Evergreen.V120.User
import Evergreen.V120.Weather
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.PriceId
            , price : Evergreen.V120.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.ProductId) Evergreen.V120.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V120.Route.Route
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
    , localUuidData : Maybe Evergreen.V120.LocalUUID.Data
    , userDictionary : Dict.Dict String Evergreen.V120.User.User
    , sessions : BiDict.BiDict Lamdera.SessionId String
    , orders : AssocList.Dict (Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.StripeSessionId) Evergreen.V120.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.StripeSessionId) Evergreen.V120.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.StripeSessionId) Evergreen.V120.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.ProductId) Evergreen.V120.Stripe.Codec.Price2
    , time : Time.Posix
    , products : Evergreen.V120.Stripe.Stripe.ProductInfoDict
    , keyValueStore : Dict.Dict String Evergreen.V120.KeyValueStore.KVDatum
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
            (Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.PriceId
            , price : Evergreen.V120.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.ProductId) Evergreen.V120.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.ProductId, Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.PriceId, Evergreen.V120.Stripe.Product.Product_ )
    , form : Evergreen.V120.Stripe.PurchaseForm.PurchaseForm
    , currentUser : Maybe Evergreen.V120.User.User
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String
    , adminDisplay : AdminDisplay
    , backendModel : Maybe BackendModel
    , route : Evergreen.V120.Route.Route
    , message : String
    , weatherData : Maybe Evergreen.V120.Weather.WeatherData
    , inputCity : String
    , currentKVPair : Maybe ( String, Evergreen.V120.KeyValueStore.KVDatum )
    , keyValueStore : Dict.Dict String Evergreen.V120.KeyValueStore.KVDatum
    , inputKey : String
    , inputValue : String
    , inputFilterData : String
    , kvViewType : Evergreen.V120.KeyValueStore.KVViewType
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
    | BuyProduct (Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.ProductId) (Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.PriceId) Evergreen.V120.Stripe.Product.Product_
    | PressedSelectTicket (Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.ProductId) (Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V120.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.ProductId) (Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.PriceId)
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
    | AddKeyValuePair String Evergreen.V120.KeyValueStore.KVDatum
    | GetValueWithKey String
    | GotValue (Result Http.Error Evergreen.V120.KeyValueStore.KVDatum)
    | DataUploaded (Result Http.Error ())
    | SetKVViewType Evergreen.V120.KeyValueStore.KVViewType


type ToBackend
    = SubmitFormRequest (Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.PriceId) (Evergreen.V120.Untrusted.Untrusted Evergreen.V120.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect (Maybe Evergreen.V120.User.User)
    | RenewPrices
    | SignInRequest String String
    | SignOutRequest String
    | SignUpRequest String String String String
    | GetWeatherData String


type BackendMsg
    = GotTime Time.Posix
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | GotPrices (Result Http.Error (List Evergreen.V120.Stripe.Stripe.PriceData))
    | GotPrices2 Lamdera.ClientId (Result Http.Error (List Evergreen.V120.Stripe.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.PriceId) Evergreen.V120.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V120.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V120.Postmark.PostmarkSendResponse)
    | GotWeatherData Lamdera.ClientId (Result Http.Error Evergreen.V120.Weather.WeatherData)


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V120.Id.Id Evergreen.V120.Stripe.Stripe.StripeSessionId))
    | AdminInspectResponse BackendModel
    | UserSignedIn (Maybe Evergreen.V120.User.User)
    | ReceivedWeatherData (Result Http.Error Evergreen.V120.Weather.WeatherData)
    | GotKeyValueStore (Dict.Dict String Evergreen.V120.KeyValueStore.KVDatum)
