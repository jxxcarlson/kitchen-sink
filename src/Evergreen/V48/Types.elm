module Evergreen.V48.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V48.Id
import Evergreen.V48.LocalUUID
import Evergreen.V48.Postmark
import Evergreen.V48.Route
import Evergreen.V48.Stripe.Codec
import Evergreen.V48.Stripe.Product
import Evergreen.V48.Stripe.PurchaseForm
import Evergreen.V48.Stripe.Stripe
import Evergreen.V48.Untrusted
import Evergreen.V48.User
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.PriceId
            , price : Evergreen.V48.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.ProductId) Evergreen.V48.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V48.Route.Route
    , isOrganiser : Bool
    , initData : Maybe InitData2
    }


type SignInState
    = SignedOut
    | SignUp
    | SignedIn


type alias BackendModel =
    { randomAtmosphericNumbers : Maybe (List Int)
    , localUuidData : Maybe Evergreen.V48.LocalUUID.Data
    , userDictionary : Dict.Dict String Evergreen.V48.User.User
    , orders : AssocList.Dict (Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.StripeSessionId) Evergreen.V48.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.StripeSessionId) Evergreen.V48.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.StripeSessionId) Evergreen.V48.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.ProductId) Evergreen.V48.Stripe.Codec.Price2
    , time : Time.Posix
    , products : Evergreen.V48.Stripe.Stripe.ProductInfoDict
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
            (Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.PriceId
            , price : Evergreen.V48.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.ProductId) Evergreen.V48.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.ProductId, Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.PriceId, Evergreen.V48.Stripe.Product.Product_ )
    , form : Evergreen.V48.Stripe.PurchaseForm.PurchaseForm
    , currentUser : Maybe Evergreen.V48.User.User
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String
    , route : Evergreen.V48.Route.Route
    , isOrganiser : Bool
    , backendModel : Maybe BackendModel
    , message : String
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
    | BuyProduct (Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.ProductId) (Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.PriceId) Evergreen.V48.Stripe.Product.Product_
    | PressedSelectTicket (Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.ProductId) (Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V48.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.ProductId) (Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.PriceId)
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
    | SetViewport
    | CopyTextToClipboard String
    | Chirp


type ToBackend
    = SubmitFormRequest (Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.PriceId) (Evergreen.V48.Untrusted.Untrusted Evergreen.V48.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String
    | RenewPrices
    | SignInRequest String String
    | SignUpRequest String String String String


type BackendMsg
    = GotTime Time.Posix
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | GotPrices (Result Http.Error (List Evergreen.V48.Stripe.Stripe.PriceData))
    | GotPrices2 Lamdera.ClientId (Result Http.Error (List Evergreen.V48.Stripe.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.PriceId) Evergreen.V48.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V48.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V48.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V48.Id.Id Evergreen.V48.Stripe.Stripe.StripeSessionId))
    | AdminInspectResponse BackendModel
    | UserSignedIn (Maybe Evergreen.V48.User.User)
