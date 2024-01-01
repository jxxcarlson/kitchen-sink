module Evergreen.V33.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Evergreen.V33.Id
import Evergreen.V33.Postmark
import Evergreen.V33.Route
import Evergreen.V33.Stripe.Codec
import Evergreen.V33.Stripe.PurchaseForm
import Evergreen.V33.Stripe.Stripe
import Evergreen.V33.Stripe.Tickets
import Evergreen.V33.Untrusted
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.PriceId
            , price : Evergreen.V33.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.ProductId) Evergreen.V33.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V33.Route.Route
    , isOrganiser : Bool
    , initData : Maybe InitData2
    }


type alias BackendModel =
    { orders : AssocList.Dict (Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.StripeSessionId) Evergreen.V33.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.StripeSessionId) Evergreen.V33.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.StripeSessionId) Evergreen.V33.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.ProductId) Evergreen.V33.Stripe.Codec.Price2
    , time : Time.Posix
    , products : Evergreen.V33.Stripe.Stripe.ProductInfoDict
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
            (Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.PriceId
            , price : Evergreen.V33.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.ProductId) Evergreen.V33.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.ProductId, Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.PriceId, Evergreen.V33.Stripe.Tickets.Product_ )
    , form : Evergreen.V33.Stripe.PurchaseForm.PurchaseForm
    , route : Evergreen.V33.Route.Route
    , showCarbonOffsetTooltip : Bool
    , isOrganiser : Bool
    , backendModel : Maybe BackendModel
    , pressedAudioButton : Bool
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
    | BuyProduct (Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.ProductId) (Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.PriceId) Evergreen.V33.Stripe.Tickets.Product_
    | PressedSelectTicket (Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.ProductId) (Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V33.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.ProductId) (Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.PriceId)
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport
    | CopyTextToClipboard String
    | Chirp


type ToBackend
    = SubmitFormRequest (Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.PriceId) (Evergreen.V33.Untrusted.Untrusted Evergreen.V33.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List Evergreen.V33.Stripe.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.PriceId) Evergreen.V33.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V33.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V33.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V33.Id.Id Evergreen.V33.Stripe.Stripe.StripeSessionId))
    | AdminInspectResponse BackendModel
