module Evergreen.V105.Types exposing (..)

import AssocList
import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V105.Id
import Evergreen.V105.KeyValueStore
import Evergreen.V105.LocalUUID
import Evergreen.V105.Postmark
import Evergreen.V105.Route
import Evergreen.V105.Stripe.Codec
import Evergreen.V105.Stripe.Product
import Evergreen.V105.Stripe.PurchaseForm
import Evergreen.V105.Stripe.Stripe
import Evergreen.V105.Untrusted
import Evergreen.V105.User
import Evergreen.V105.Weather
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.PriceId
            , price : Evergreen.V105.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.ProductId) Evergreen.V105.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V105.Route.Route
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
    , localUuidData : Maybe Evergreen.V105.LocalUUID.Data
    , userDictionary : Dict.Dict String Evergreen.V105.User.User
    , sessions : BiDict.BiDict Lamdera.SessionId String
    , orders : AssocList.Dict (Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.StripeSessionId) Evergreen.V105.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.StripeSessionId) Evergreen.V105.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.StripeSessionId) Evergreen.V105.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.ProductId) Evergreen.V105.Stripe.Codec.Price2
    , time : Time.Posix
    , products : Evergreen.V105.Stripe.Stripe.ProductInfoDict
    , keyValueStore : Dict.Dict String String
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
            (Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.PriceId
            , price : Evergreen.V105.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.ProductId) Evergreen.V105.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.ProductId, Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.PriceId, Evergreen.V105.Stripe.Product.Product_ )
    , form : Evergreen.V105.Stripe.PurchaseForm.PurchaseForm
    , currentUser : Maybe Evergreen.V105.User.User
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String
    , adminDisplay : AdminDisplay
    , backendModel : Maybe BackendModel
    , route : Evergreen.V105.Route.Route
    , message : String
    , weatherData : Maybe Evergreen.V105.Weather.WeatherData
    , inputCity : String
    , inputKey : String
    , inputValue : String
    , inputFilterData : String
    , kvViewType : Evergreen.V105.KeyValueStore.KVViewType
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
    | BuyProduct (Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.ProductId) (Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.PriceId) Evergreen.V105.Stripe.Product.Product_
    | PressedSelectTicket (Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.ProductId) (Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V105.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.ProductId) (Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.PriceId)
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
    | AddKeyValuePair String String
    | GetValueWithKey String
    | GotValue (Result Http.Error String)
    | DataUploaded (Result Http.Error ())
    | SetKVViewType Evergreen.V105.KeyValueStore.KVViewType


type ToBackend
    = SubmitFormRequest (Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.PriceId) (Evergreen.V105.Untrusted.Untrusted Evergreen.V105.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect (Maybe Evergreen.V105.User.User)
    | RenewPrices
    | SignInRequest String String
    | SignOutRequest String
    | SignUpRequest String String String String
    | GetWeatherData String


type BackendMsg
    = GotTime Time.Posix
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | GotPrices (Result Http.Error (List Evergreen.V105.Stripe.Stripe.PriceData))
    | GotPrices2 Lamdera.ClientId (Result Http.Error (List Evergreen.V105.Stripe.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.PriceId) Evergreen.V105.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V105.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V105.Postmark.PostmarkSendResponse)
    | GotWeatherData Lamdera.ClientId (Result Http.Error Evergreen.V105.Weather.WeatherData)


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V105.Id.Id Evergreen.V105.Stripe.Stripe.StripeSessionId))
    | AdminInspectResponse BackendModel
    | UserSignedIn (Maybe Evergreen.V105.User.User)
    | ReceivedWeatherData (Result Http.Error Evergreen.V105.Weather.WeatherData)
