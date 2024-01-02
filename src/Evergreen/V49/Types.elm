module Evergreen.V49.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V49.Id
import Evergreen.V49.LocalUUID
import Evergreen.V49.Postmark
import Evergreen.V49.Route
import Evergreen.V49.Stripe.Codec
import Evergreen.V49.Stripe.Product
import Evergreen.V49.Stripe.PurchaseForm
import Evergreen.V49.Stripe.Stripe
import Evergreen.V49.Untrusted
import Evergreen.V49.User
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.PriceId
            , price : Evergreen.V49.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.ProductId) Evergreen.V49.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V49.Route.Route
    , isOrganiser : Bool
    , initData : Maybe InitData2
    }


type SignInState
    = SignedOut
    | SignUp
    | SignedIn


type alias BackendModel =
    { randomAtmosphericNumbers : Maybe (List Int)
    , localUuidData : Maybe Evergreen.V49.LocalUUID.Data
    , userDictionary : Dict.Dict String Evergreen.V49.User.User
    , orders : AssocList.Dict (Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.StripeSessionId) Evergreen.V49.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.StripeSessionId) Evergreen.V49.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.StripeSessionId) Evergreen.V49.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.ProductId) Evergreen.V49.Stripe.Codec.Price2
    , time : Time.Posix
    , products : Evergreen.V49.Stripe.Stripe.ProductInfoDict
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
            (Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.PriceId
            , price : Evergreen.V49.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.ProductId) Evergreen.V49.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.ProductId, Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.PriceId, Evergreen.V49.Stripe.Product.Product_ )
    , form : Evergreen.V49.Stripe.PurchaseForm.PurchaseForm
    , currentUser : Maybe Evergreen.V49.User.User
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String
    , route : Evergreen.V49.Route.Route
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
    | BuyProduct (Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.ProductId) (Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.PriceId) Evergreen.V49.Stripe.Product.Product_
    | PressedSelectTicket (Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.ProductId) (Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V49.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.ProductId) (Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.PriceId)
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
    = SubmitFormRequest (Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.PriceId) (Evergreen.V49.Untrusted.Untrusted Evergreen.V49.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect (Maybe Evergreen.V49.User.User)
    | RenewPrices
    | SignInRequest String String
    | SignUpRequest String String String String


type BackendMsg
    = GotTime Time.Posix
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | GotPrices (Result Http.Error (List Evergreen.V49.Stripe.Stripe.PriceData))
    | GotPrices2 Lamdera.ClientId (Result Http.Error (List Evergreen.V49.Stripe.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.PriceId) Evergreen.V49.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V49.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V49.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V49.Id.Id Evergreen.V49.Stripe.Stripe.StripeSessionId))
    | AdminInspectResponse BackendModel
    | UserSignedIn (Maybe Evergreen.V49.User.User)
