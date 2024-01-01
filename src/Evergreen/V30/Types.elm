module Evergreen.V30.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Evergreen.V30.Id
import Evergreen.V30.Postmark
import Evergreen.V30.Route
import Evergreen.V30.Stripe.PurchaseForm
import Evergreen.V30.Stripe.Stripe
import Evergreen.V30.Stripe.Tickets
import Evergreen.V30.Untrusted
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.PriceId
            , price : Evergreen.V30.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.ProductId) Evergreen.V30.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V30.Route.Route
    , isOrganiser : Bool
    , initData : Maybe InitData2
    }


type EmailResult
    = SendingEmail
    | EmailSuccess Evergreen.V30.Postmark.PostmarkSendResponse
    | EmailFailed Http.Error


type alias Order =
    { priceId : Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V30.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V30.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.PriceId
    , price : Evergreen.V30.Stripe.Stripe.Price
    }


type TicketsEnabled
    = TicketsEnabled
    | TicketsDisabled
        { adminMessage : String
        }


type alias BackendModel =
    { orders : AssocList.Dict (Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.StripeSessionId) Order
    , pendingOrder : AssocList.Dict (Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.StripeSessionId) PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.StripeSessionId) PendingOrder
    , prices : AssocList.Dict (Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.ProductId) Price2
    , time : Time.Posix
    , ticketsEnabled : TicketsEnabled
    , products : Evergreen.V30.Stripe.Stripe.ProductInfoDict
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
            (Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.PriceId
            , price : Evergreen.V30.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.ProductId) Evergreen.V30.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.ProductId, Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.PriceId, Evergreen.V30.Stripe.Tickets.Product_ )
    , form : Evergreen.V30.Stripe.PurchaseForm.PurchaseForm
    , route : Evergreen.V30.Route.Route
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
    | BuyProduct (Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.ProductId) (Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.PriceId) Evergreen.V30.Stripe.Tickets.Product_
    | PressedSelectTicket (Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.ProductId) (Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V30.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.ProductId) (Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.PriceId)
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport
    | CopyTextToClipboard String
    | Chirp


type ToBackend
    = SubmitFormRequest (Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.PriceId) (Evergreen.V30.Untrusted.Untrusted Evergreen.V30.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List Evergreen.V30.Stripe.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.PriceId) Evergreen.V30.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V30.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V30.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData InitData2
    | GotMessage String
    | SubmitFormResponse (Result String (Evergreen.V30.Id.Id Evergreen.V30.Stripe.Stripe.StripeSessionId))
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel
