module Evergreen.V88.Types exposing (..)

import AssocList
import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V88.Id
import Evergreen.V88.LocalUUID
import Evergreen.V88.Postmark
import Evergreen.V88.Route
import Evergreen.V88.Stripe.Codec
import Evergreen.V88.Stripe.Product
import Evergreen.V88.Stripe.PurchaseForm
import Evergreen.V88.Stripe.Stripe
import Evergreen.V88.Untrusted
import Evergreen.V88.User
import Evergreen.V88.Weather
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.PriceId
            , price : Evergreen.V88.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.ProductId) Evergreen.V88.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V88.Route.Route
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
    , localUuidData : Maybe Evergreen.V88.LocalUUID.Data
    , userDictionary : Dict.Dict String Evergreen.V88.User.User
    , sessions : BiDict.BiDict Lamdera.SessionId String
    , orders : AssocList.Dict (Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.StripeSessionId) Evergreen.V88.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.StripeSessionId) Evergreen.V88.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.StripeSessionId) Evergreen.V88.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.ProductId) Evergreen.V88.Stripe.Codec.Price2
    , time : Time.Posix
    , products : Evergreen.V88.Stripe.Stripe.ProductInfoDict
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
            (Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.PriceId
            , price : Evergreen.V88.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.ProductId) Evergreen.V88.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.ProductId, Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.PriceId, Evergreen.V88.Stripe.Product.Product_ )
    , form : Evergreen.V88.Stripe.PurchaseForm.PurchaseForm
    , currentUser : Maybe Evergreen.V88.User.User
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String
    , adminDisplay : AdminDisplay
    , backendModel : Maybe BackendModel
    , route : Evergreen.V88.Route.Route
    , message : String
    , weatherData : Maybe Evergreen.V88.Weather.WeatherData
    , inputCity : String
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
    | BuyProduct (Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.ProductId) (Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.PriceId) Evergreen.V88.Stripe.Product.Product_
    | PressedSelectTicket (Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.ProductId) (Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V88.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.ProductId) (Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.PriceId)
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


type ToBackend
    = SubmitFormRequest (Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.PriceId) (Evergreen.V88.Untrusted.Untrusted Evergreen.V88.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect (Maybe Evergreen.V88.User.User)
    | RenewPrices
    | SignInRequest String String
    | SignOutRequest String
    | SignUpRequest String String String String
    | GetWeatherData String


type BackendMsg
    = GotTime Time.Posix
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | GotPrices (Result Http.Error (List Evergreen.V88.Stripe.Stripe.PriceData))
    | GotPrices2 Lamdera.ClientId (Result Http.Error (List Evergreen.V88.Stripe.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.PriceId) Evergreen.V88.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V88.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V88.Postmark.PostmarkSendResponse)
    | GotWeatherData Lamdera.ClientId (Result Http.Error Evergreen.V88.Weather.WeatherData)


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V88.Id.Id Evergreen.V88.Stripe.Stripe.StripeSessionId))
    | AdminInspectResponse BackendModel
    | UserSignedIn (Maybe Evergreen.V88.User.User)
    | ReceivedWeatherData (Result Http.Error Evergreen.V88.Weather.WeatherData)
