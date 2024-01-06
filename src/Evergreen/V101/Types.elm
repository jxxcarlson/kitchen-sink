module Evergreen.V101.Types exposing (..)

import AssocList
import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V101.Id
import Evergreen.V101.LocalUUID
import Evergreen.V101.Postmark
import Evergreen.V101.Route
import Evergreen.V101.Stripe.Codec
import Evergreen.V101.Stripe.Product
import Evergreen.V101.Stripe.PurchaseForm
import Evergreen.V101.Stripe.Stripe
import Evergreen.V101.Untrusted
import Evergreen.V101.User
import Evergreen.V101.Weather
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.PriceId
            , price : Evergreen.V101.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.ProductId) Evergreen.V101.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V101.Route.Route
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
    , localUuidData : Maybe Evergreen.V101.LocalUUID.Data
    , userDictionary : Dict.Dict String Evergreen.V101.User.User
    , sessions : BiDict.BiDict Lamdera.SessionId String
    , orders : AssocList.Dict (Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.StripeSessionId) Evergreen.V101.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.StripeSessionId) Evergreen.V101.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.StripeSessionId) Evergreen.V101.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.ProductId) Evergreen.V101.Stripe.Codec.Price2
    , time : Time.Posix
    , products : Evergreen.V101.Stripe.Stripe.ProductInfoDict
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
            (Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.PriceId
            , price : Evergreen.V101.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.ProductId) Evergreen.V101.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.ProductId, Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.PriceId, Evergreen.V101.Stripe.Product.Product_ )
    , form : Evergreen.V101.Stripe.PurchaseForm.PurchaseForm
    , currentUser : Maybe Evergreen.V101.User.User
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String
    , adminDisplay : AdminDisplay
    , backendModel : Maybe BackendModel
    , route : Evergreen.V101.Route.Route
    , message : String
    , weatherData : Maybe Evergreen.V101.Weather.WeatherData
    , inputCity : String
    , inputKey : String
    , inputValue : String
    , inputFilterData : String
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
    | BuyProduct (Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.ProductId) (Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.PriceId) Evergreen.V101.Stripe.Product.Product_
    | PressedSelectTicket (Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.ProductId) (Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V101.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.ProductId) (Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.PriceId)
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


type ToBackend
    = SubmitFormRequest (Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.PriceId) (Evergreen.V101.Untrusted.Untrusted Evergreen.V101.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect (Maybe Evergreen.V101.User.User)
    | RenewPrices
    | SignInRequest String String
    | SignOutRequest String
    | SignUpRequest String String String String
    | GetWeatherData String


type BackendMsg
    = GotTime Time.Posix
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | GotPrices (Result Http.Error (List Evergreen.V101.Stripe.Stripe.PriceData))
    | GotPrices2 Lamdera.ClientId (Result Http.Error (List Evergreen.V101.Stripe.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.PriceId) Evergreen.V101.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V101.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V101.Postmark.PostmarkSendResponse)
    | GotWeatherData Lamdera.ClientId (Result Http.Error Evergreen.V101.Weather.WeatherData)


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V101.Id.Id Evergreen.V101.Stripe.Stripe.StripeSessionId))
    | AdminInspectResponse BackendModel
    | UserSignedIn (Maybe Evergreen.V101.User.User)
    | ReceivedWeatherData (Result Http.Error Evergreen.V101.Weather.WeatherData)
