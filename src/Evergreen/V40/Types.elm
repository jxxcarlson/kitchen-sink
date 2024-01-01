module Evergreen.V40.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Evergreen.V40.Id
import Evergreen.V40.Postmark
import Evergreen.V40.Route
import Evergreen.V40.Stripe.Codec
import Evergreen.V40.Stripe.Product
import Evergreen.V40.Stripe.PurchaseForm
import Evergreen.V40.Stripe.Stripe
import Evergreen.V40.Untrusted
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.PriceId
            , price : Evergreen.V40.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.ProductId) Evergreen.V40.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V40.Route.Route
    , isOrganiser : Bool
    , initData : Maybe InitData2
    }


type SignInState
    = SignedOut
    | SignUp
    | SignedIn


type alias BackendModel =
    { orders : AssocList.Dict (Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.StripeSessionId) Evergreen.V40.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.StripeSessionId) Evergreen.V40.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.StripeSessionId) Evergreen.V40.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.ProductId) Evergreen.V40.Stripe.Codec.Price2
    , time : Time.Posix
    , products : Evergreen.V40.Stripe.Stripe.ProductInfoDict
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
            (Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.PriceId
            , price : Evergreen.V40.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.ProductId) Evergreen.V40.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.ProductId, Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.PriceId, Evergreen.V40.Stripe.Product.Product_ )
    , form : Evergreen.V40.Stripe.PurchaseForm.PurchaseForm
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String
    , route : Evergreen.V40.Route.Route
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
    | BuyProduct (Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.ProductId) (Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.PriceId) Evergreen.V40.Stripe.Product.Product_
    | PressedSelectTicket (Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.ProductId) (Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V40.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.ProductId) (Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.PriceId)
    | PressedCancelForm
    | SignIn
    | SetSignInState SignInState
    | SubmitSignIn
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
    = SubmitFormRequest (Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.PriceId) (Evergreen.V40.Untrusted.Untrusted Evergreen.V40.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String
    | SignInRequest String String
    | SignUpRequest String String String String


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List Evergreen.V40.Stripe.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.PriceId) Evergreen.V40.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V40.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V40.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V40.Id.Id Evergreen.V40.Stripe.Stripe.StripeSessionId))
    | AdminInspectResponse BackendModel
