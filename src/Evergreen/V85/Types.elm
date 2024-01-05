module Evergreen.V85.Types exposing (..)

import AssocList
import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V85.Id
import Evergreen.V85.LocalUUID
import Evergreen.V85.Postmark
import Evergreen.V85.Route
import Evergreen.V85.Stripe.Codec
import Evergreen.V85.Stripe.Product
import Evergreen.V85.Stripe.PurchaseForm
import Evergreen.V85.Stripe.Stripe
import Evergreen.V85.Untrusted
import Evergreen.V85.User
import Evergreen.V85.Weather
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.PriceId
            , price : Evergreen.V85.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.ProductId) Evergreen.V85.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V85.Route.Route
    , isOrganiser : Bool
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
    , localUuidData : Maybe Evergreen.V85.LocalUUID.Data
    , userDictionary : Dict.Dict String Evergreen.V85.User.User
    , sessions : BiDict.BiDict Lamdera.SessionId String
    , orders : AssocList.Dict (Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.StripeSessionId) Evergreen.V85.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.StripeSessionId) Evergreen.V85.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.StripeSessionId) Evergreen.V85.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.ProductId) Evergreen.V85.Stripe.Codec.Price2
    , time : Time.Posix
    , products : Evergreen.V85.Stripe.Stripe.ProductInfoDict
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
            (Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.PriceId
            , price : Evergreen.V85.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.ProductId) Evergreen.V85.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.ProductId, Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.PriceId, Evergreen.V85.Stripe.Product.Product_ )
    , form : Evergreen.V85.Stripe.PurchaseForm.PurchaseForm
    , currentUser : Maybe Evergreen.V85.User.User
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String
    , adminDisplay : AdminDisplay
    , backendModel : Maybe BackendModel
    , route : Evergreen.V85.Route.Route
    , isOrganiser : Bool
    , message : String
    , weatherData : Maybe Evergreen.V85.Weather.WeatherData
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
    | BuyProduct (Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.ProductId) (Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.PriceId) Evergreen.V85.Stripe.Product.Product_
    | PressedSelectTicket (Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.ProductId) (Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V85.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.ProductId) (Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.PriceId)
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
    = SubmitFormRequest (Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.PriceId) (Evergreen.V85.Untrusted.Untrusted Evergreen.V85.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect (Maybe Evergreen.V85.User.User)
    | RenewPrices
    | SignInRequest String String
    | SignOutRequest String
    | SignUpRequest String String String String
    | GetWeatherData String


type BackendMsg
    = GotTime Time.Posix
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | GotPrices (Result Http.Error (List Evergreen.V85.Stripe.Stripe.PriceData))
    | GotPrices2 Lamdera.ClientId (Result Http.Error (List Evergreen.V85.Stripe.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.PriceId) Evergreen.V85.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V85.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V85.Postmark.PostmarkSendResponse)
    | GotWeatherData Lamdera.ClientId (Result Http.Error Evergreen.V85.Weather.WeatherData)


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V85.Id.Id Evergreen.V85.Stripe.Stripe.StripeSessionId))
    | AdminInspectResponse BackendModel
    | UserSignedIn (Maybe Evergreen.V85.User.User)
    | ReceivedWeatherData (Result Http.Error Evergreen.V85.Weather.WeatherData)
