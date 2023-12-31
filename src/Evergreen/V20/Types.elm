module Evergreen.V20.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Evergreen.V20.Id
import Evergreen.V20.Postmark
import Evergreen.V20.Route
import Evergreen.V20.Stripe.PurchaseForm
import Evergreen.V20.Stripe.Stripe
import Evergreen.V20.Untrusted
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.PriceId
            , price : Evergreen.V20.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.ProductId) Evergreen.V20.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V20.Route.Route
    , isOrganiser : Bool
    , initData : Maybe InitData2
    }


type EmailResult
    = SendingEmail
    | EmailSuccess Evergreen.V20.Postmark.PostmarkSendResponse
    | EmailFailed Http.Error


type alias Order =
    { priceId : Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V20.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V20.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.PriceId
    , price : Evergreen.V20.Stripe.Stripe.Price
    }


type TicketsEnabled
    = TicketsEnabled
    | TicketsDisabled
        { adminMessage : String
        }


type alias BackendModel =
    { orders : AssocList.Dict (Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.StripeSessionId) Order
    , pendingOrder : AssocList.Dict (Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.StripeSessionId) PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.StripeSessionId) PendingOrder
    , prices : AssocList.Dict (Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.ProductId) Price2
    , time : Time.Posix
    , ticketsEnabled : TicketsEnabled
    , products : Evergreen.V20.Stripe.Stripe.ProductInfoDict
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
            (Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.PriceId
            , price : Evergreen.V20.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.ProductId) Evergreen.V20.Stripe.Stripe.ProductInfo
    , selectedTicket : Maybe ( Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.ProductId, Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.PriceId )
    , form : Evergreen.V20.Stripe.PurchaseForm.PurchaseForm
    , route : Evergreen.V20.Route.Route
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
    | PressedSelectTicket (Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.ProductId) (Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V20.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.ProductId) (Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.PriceId)
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport
    | Chirp


type ToBackend
    = SubmitFormRequest (Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.PriceId) (Evergreen.V20.Untrusted.Untrusted Evergreen.V20.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List Evergreen.V20.Stripe.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.PriceId) Evergreen.V20.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V20.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V20.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData InitData2
    | SubmitFormResponse (Result String (Evergreen.V20.Id.Id Evergreen.V20.Stripe.Stripe.StripeSessionId))
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel
