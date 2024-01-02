module Evergreen.V47.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V47.Id
import Evergreen.V47.LocalUUID
import Evergreen.V47.Postmark
import Evergreen.V47.Route
import Evergreen.V47.Stripe.Codec
import Evergreen.V47.Stripe.Product
import Evergreen.V47.Stripe.PurchaseForm
import Evergreen.V47.Stripe.Stripe
import Evergreen.V47.Untrusted
import Evergreen.V47.User
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.PriceId
            , price : Evergreen.V47.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.ProductId) Evergreen.V47.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V47.Route.Route
    , isOrganiser : Bool
    , initData : Maybe InitData2
    }


type SignInState
    = SignedOut
    | SignUp
    | SignedIn


type alias BackendModel =
    { randomAtmosphericNumbers : Maybe (List Int)
    , localUuidData : Maybe Evergreen.V47.LocalUUID.Data
    , userDictionary : Dict.Dict String Evergreen.V47.User.User
    , orders : AssocList.Dict (Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.StripeSessionId) Evergreen.V47.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.StripeSessionId) Evergreen.V47.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.StripeSessionId) Evergreen.V47.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.ProductId) Evergreen.V47.Stripe.Codec.Price2
    , time : Time.Posix
    , products : Evergreen.V47.Stripe.Stripe.ProductInfoDict
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
            (Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.PriceId
            , price : Evergreen.V47.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.ProductId) Evergreen.V47.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.ProductId, Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.PriceId, Evergreen.V47.Stripe.Product.Product_ )
    , form : Evergreen.V47.Stripe.PurchaseForm.PurchaseForm
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String
    , route : Evergreen.V47.Route.Route
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
    | BuyProduct (Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.ProductId) (Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.PriceId) Evergreen.V47.Stripe.Product.Product_
    | PressedSelectTicket (Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.ProductId) (Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V47.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.ProductId) (Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.PriceId)
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
    = SubmitFormRequest (Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.PriceId) (Evergreen.V47.Untrusted.Untrusted Evergreen.V47.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String
    | RenewPrices
    | SignInRequest String String
    | SignUpRequest String String String String


type BackendMsg
    = GotTime Time.Posix
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | GotPrices (Result Http.Error (List Evergreen.V47.Stripe.Stripe.PriceData))
    | GotPrices2 Lamdera.ClientId (Result Http.Error (List Evergreen.V47.Stripe.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.PriceId) Evergreen.V47.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V47.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V47.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V47.Id.Id Evergreen.V47.Stripe.Stripe.StripeSessionId))
    | AdminInspectResponse BackendModel
