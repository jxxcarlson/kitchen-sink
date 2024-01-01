module Evergreen.V32.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Evergreen.V32.Id
import Evergreen.V32.Postmark
import Evergreen.V32.Route
import Evergreen.V32.Stripe.Codec
import Evergreen.V32.Stripe.PurchaseForm
import Evergreen.V32.Stripe.Stripe
import Evergreen.V32.Stripe.Tickets
import Evergreen.V32.Untrusted
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.PriceId
            , price : Evergreen.V32.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.ProductId) Evergreen.V32.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V32.Route.Route
    , isOrganiser : Bool
    , initData : Maybe InitData2
    }


type alias BackendModel =
    { orders : AssocList.Dict (Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.StripeSessionId) Evergreen.V32.Stripe.Codec.Order
    , pendingOrder : AssocList.Dict (Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.StripeSessionId) Evergreen.V32.Stripe.Codec.PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.StripeSessionId) Evergreen.V32.Stripe.Codec.PendingOrder
    , prices : AssocList.Dict (Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.ProductId) Evergreen.V32.Stripe.Codec.Price2
    , time : Time.Posix
    , products : Evergreen.V32.Stripe.Stripe.ProductInfoDict
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
            (Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.PriceId
            , price : Evergreen.V32.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.ProductId) Evergreen.V32.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.ProductId, Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.PriceId, Evergreen.V32.Stripe.Tickets.Product_ )
    , form : Evergreen.V32.Stripe.PurchaseForm.PurchaseForm
    , route : Evergreen.V32.Route.Route
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
    | BuyProduct (Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.ProductId) (Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.PriceId) Evergreen.V32.Stripe.Tickets.Product_
    | PressedSelectTicket (Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.ProductId) (Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V32.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.ProductId) (Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.PriceId)
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport
    | CopyTextToClipboard String
    | Chirp


type ToBackend
    = SubmitFormRequest (Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.PriceId) (Evergreen.V32.Untrusted.Untrusted Evergreen.V32.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List Evergreen.V32.Stripe.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.PriceId) Evergreen.V32.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V32.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V32.Postmark.PostmarkSendResponse)


type TicketsEnabled
    = TicketsEnabled
    | TicketsDisabled
        { adminMessage : String
        }


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V32.Id.Id Evergreen.V32.Stripe.Stripe.StripeSessionId))
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel
