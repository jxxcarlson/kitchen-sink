module Evergreen.V13.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Evergreen.V13.Id
import Evergreen.V13.Postmark
import Evergreen.V13.Route
import Evergreen.V13.Stripe.PurchaseForm
import Evergreen.V13.Stripe.Stripe
import Evergreen.V13.Untrusted
import Http
import Lamdera
import Time
import Url


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.PriceId
            , price : Evergreen.V13.Stripe.Stripe.Price
            }
    , productInfo : AssocList.Dict (Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.ProductId) Evergreen.V13.Stripe.Stripe.ProductInfo
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V13.Route.Route
    , isOrganiser : Bool
    , initData : Maybe InitData2
    }


type EmailResult
    = SendingEmail
    | EmailSuccess Evergreen.V13.Postmark.PostmarkSendResponse
    | EmailFailed Http.Error


type alias Order =
    { priceId : Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V13.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V13.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.PriceId
    , price : Evergreen.V13.Stripe.Stripe.Price
    }


type TicketsEnabled
    = TicketsEnabled
    | TicketsDisabled
        { adminMessage : String
        }


type alias BackendModel =
    { orders : AssocList.Dict (Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.StripeSessionId) Order
    , pendingOrder : AssocList.Dict (Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.StripeSessionId) PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.StripeSessionId) PendingOrder
    , prices : AssocList.Dict (Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.ProductId) Price2
    , time : Time.Posix
    , ticketsEnabled : TicketsEnabled
    , products : Evergreen.V13.Stripe.Stripe.ProductInfoDict
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
            (Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.PriceId
            , price : Evergreen.V13.Stripe.Stripe.Price
            }
    , productInfoDict : AssocList.Dict (Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.ProductId) Evergreen.V13.Stripe.Stripe.ProductInfo
    , selectedTicket : Maybe ( Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.ProductId, Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.PriceId )
    , form : Evergreen.V13.Stripe.PurchaseForm.PurchaseForm
    , route : Evergreen.V13.Route.Route
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
    | PressedSelectTicket (Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.ProductId) (Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V13.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.ProductId) (Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.PriceId)
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport
    | Chirp


type ToBackend
    = SubmitFormRequest (Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.PriceId) (Evergreen.V13.Untrusted.Untrusted Evergreen.V13.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List Evergreen.V13.Stripe.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.PriceId) Evergreen.V13.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V13.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V13.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData InitData2
    | SubmitFormResponse (Result String (Evergreen.V13.Id.Id Evergreen.V13.Stripe.Stripe.StripeSessionId))
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel
