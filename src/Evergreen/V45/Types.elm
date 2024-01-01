module Evergreen.V45.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Evergreen.V45.Id
import Evergreen.V45.Postmark
import Evergreen.V45.Route
import Evergreen.V45.Stripe.Codec
import Evergreen.V45.Stripe.Product
import Evergreen.V45.Stripe.PurchaseForm
import Evergreen.V45.Stripe.Stripe
import Evergreen.V45.Untrusted
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.PriceId
            , price : Evergreen.V45.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.ProductId) Evergreen.V45.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V45.Route.Route
    , isOrganiser : Bool
    , initData : Maybe InitData2
    }


type SignInState
    = SignedOut
    | SignUp
    | SignedIn


type alias BackendModel =
    { randomAtmosphericNumber : Maybe Int
    , orders : AssocList.Dict (Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.StripeSessionId) Evergreen.V45.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.StripeSessionId) Evergreen.V45.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.StripeSessionId) Evergreen.V45.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.ProductId) Evergreen.V45.Stripe.Codec.Price2
    , time : Time.Posix
    , products : Evergreen.V45.Stripe.Stripe.ProductInfoDict
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
            (Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.PriceId
            , price : Evergreen.V45.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.ProductId) Evergreen.V45.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.ProductId, Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.PriceId, Evergreen.V45.Stripe.Product.Product_ )
    , form : Evergreen.V45.Stripe.PurchaseForm.PurchaseForm
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String
    , route : Evergreen.V45.Route.Route
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
    | BuyProduct (Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.ProductId) (Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.PriceId) Evergreen.V45.Stripe.Product.Product_
    | PressedSelectTicket (Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.ProductId) (Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V45.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.ProductId) (Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.PriceId)
    | PressedCancelForm
    | AskToRenewPrices
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
    = SubmitFormRequest (Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.PriceId) (Evergreen.V45.Untrusted.Untrusted Evergreen.V45.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String
    | RenewPrices
    | SignInRequest String String
    | SignUpRequest String String String String


type BackendMsg
    = GotTime Time.Posix
    | GotAtmosphericRandomNumber (Result Http.Error String)
    | GotPrices (Result Http.Error (List Evergreen.V45.Stripe.Stripe.PriceData))
    | GotPrices2 Lamdera.ClientId (Result Http.Error (List Evergreen.V45.Stripe.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.PriceId) Evergreen.V45.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V45.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V45.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V45.Id.Id Evergreen.V45.Stripe.Stripe.StripeSessionId))
    | AdminInspectResponse BackendModel
