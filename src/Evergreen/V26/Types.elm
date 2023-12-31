module Evergreen.V26.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Evergreen.V26.Id
import Evergreen.V26.Postmark
import Evergreen.V26.Route
import Evergreen.V26.Stripe.PurchaseForm
import Evergreen.V26.Stripe.Stripe
import Evergreen.V26.Stripe.Tickets
import Evergreen.V26.Untrusted
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.PriceId
            , price : Evergreen.V26.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.ProductId) Evergreen.V26.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V26.Route.Route
    , isOrganiser : Bool
    , initData : Maybe InitData2
    }


type EmailResult
    = SendingEmail
    | EmailSuccess Evergreen.V26.Postmark.PostmarkSendResponse
    | EmailFailed Http.Error


type alias Order =
    { priceId : Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V26.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V26.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.PriceId
    , price : Evergreen.V26.Stripe.Stripe.Price
    }


type TicketsEnabled
    = TicketsEnabled
    | TicketsDisabled
        { adminMessage : String
        }


type alias BackendModel =
    { orders : AssocList.Dict (Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.StripeSessionId) Order
    , pendingOrder : AssocList.Dict (Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.StripeSessionId) PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.StripeSessionId) PendingOrder
    , prices : AssocList.Dict (Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.ProductId) Price2
    , time : Time.Posix
    , ticketsEnabled : TicketsEnabled
    , products : Evergreen.V26.Stripe.Stripe.ProductInfoDict
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
            (Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.PriceId
            , price : Evergreen.V26.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.ProductId) Evergreen.V26.Stripe.Stripe.ProductInfo
    , selectedProduct : Maybe ( Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.ProductId, Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.PriceId, Evergreen.V26.Stripe.Tickets.Product_ )
    , form : Evergreen.V26.Stripe.PurchaseForm.PurchaseForm
    , route : Evergreen.V26.Route.Route
    , showCarbonOffsetTooltip : Bool
    , isOrganiser : Bool
    , backendModel : Maybe BackendModel
    , pressedAudioButton : Bool
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
    | BuyProduct (Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.ProductId) (Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.PriceId) Evergreen.V26.Stripe.Tickets.Product_
    | PressedSelectTicket (Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.ProductId) (Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V26.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.ProductId) (Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.PriceId)
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport
    | Chirp


type ToBackend
    = SubmitFormRequest (Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.PriceId) (Evergreen.V26.Untrusted.Untrusted Evergreen.V26.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List Evergreen.V26.Stripe.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.PriceId) Evergreen.V26.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V26.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V26.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData InitData2
    | SubmitFormResponse (Result String (Evergreen.V26.Id.Id Evergreen.V26.Stripe.Stripe.StripeSessionId))
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel
