module Evergreen.V51.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V51.Id
import Evergreen.V51.LocalUUID
import Evergreen.V51.Postmark
import Evergreen.V51.Route
import Evergreen.V51.Stripe.Codec
import Evergreen.V51.Stripe.Product
import Evergreen.V51.Stripe.PurchaseForm
import Evergreen.V51.Stripe.Stripe
import Evergreen.V51.Untrusted
import Evergreen.V51.User
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.PriceId
            , price : Evergreen.V51.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.ProductId) Evergreen.V51.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V51.Route.Route
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


type alias BackendModel =
    { randomAtmosphericNumbers : Maybe (List Int)
    , localUuidData : Maybe Evergreen.V51.LocalUUID.Data
    , userDictionary : Dict.Dict String Evergreen.V51.User.User
    , orders : AssocList.Dict (Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.StripeSessionId) Evergreen.V51.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.StripeSessionId) Evergreen.V51.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.StripeSessionId) Evergreen.V51.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.ProductId) Evergreen.V51.Stripe.Codec.Price2
    , time : Time.Posix
    , products : Evergreen.V51.Stripe.Stripe.ProductInfoDict
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
            (Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.PriceId
            , price : Evergreen.V51.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.ProductId) Evergreen.V51.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.ProductId, Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.PriceId, Evergreen.V51.Stripe.Product.Product_ )
    , form : Evergreen.V51.Stripe.PurchaseForm.PurchaseForm
    , currentUser : Maybe Evergreen.V51.User.User
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String
    , adminDisplay : AdminDisplay
    , backendModel : Maybe BackendModel
    , route : Evergreen.V51.Route.Route
    , isOrganiser : Bool
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
    | BuyProduct (Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.ProductId) (Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.PriceId) Evergreen.V51.Stripe.Product.Product_
    | PressedSelectTicket (Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.ProductId) (Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V51.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.ProductId) (Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.PriceId)
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


type ToBackend
    = SubmitFormRequest (Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.PriceId) (Evergreen.V51.Untrusted.Untrusted Evergreen.V51.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect (Maybe Evergreen.V51.User.User)
    | RenewPrices
    | SignInRequest String String
    | SignUpRequest String String String String


type BackendMsg
    = GotTime Time.Posix
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | GotPrices (Result Http.Error (List Evergreen.V51.Stripe.Stripe.PriceData))
    | GotPrices2 Lamdera.ClientId (Result Http.Error (List Evergreen.V51.Stripe.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.PriceId) Evergreen.V51.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V51.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V51.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V51.Id.Id Evergreen.V51.Stripe.Stripe.StripeSessionId))
    | AdminInspectResponse BackendModel
    | UserSignedIn (Maybe Evergreen.V51.User.User)
