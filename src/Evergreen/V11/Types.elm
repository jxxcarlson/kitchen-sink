module Evergreen.V11.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Evergreen.V11.Id
import Evergreen.V11.Postmark
import Evergreen.V11.Route
import Evergreen.V11.Stripe.PurchaseForm
import Evergreen.V11.Stripe.Stripe
import Evergreen.V11.Untrusted
import Http
import Lamdera
import Time
import Url


type TicketsEnabled
    = TicketsEnabled
    | TicketsDisabled
        { adminMessage : String
        }


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.PriceId
            , price : Evergreen.V11.Stripe.Stripe.Price
            }
    , ticketsEnabled : TicketsEnabled
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V11.Route.Route
    , isOrganiser : Bool
    , initData : Maybe InitData2
    }


type EmailResult
    = SendingEmail
    | EmailSuccess Evergreen.V11.Postmark.PostmarkSendResponse
    | EmailFailed Http.Error


type alias Order =
    { priceId : Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V11.Stripe.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V11.Stripe.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.PriceId
    , price : Evergreen.V11.Stripe.Stripe.Price
    }


type alias BackendModel =
    { orders : AssocList.Dict (Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.StripeSessionId) Order
    , pendingOrder : AssocList.Dict (Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.StripeSessionId) PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.StripeSessionId) PendingOrder
    , prices : AssocList.Dict (Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.ProductId) Price2
    , time : Time.Posix
    , ticketsEnabled : TicketsEnabled
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
            (Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.ProductId)
            { priceId : Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.PriceId
            , price : Evergreen.V11.Stripe.Stripe.Price
            }
    , selectedTicket : Maybe ( Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.ProductId, Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.PriceId )
    , form : Evergreen.V11.Stripe.PurchaseForm.PurchaseForm
    , route : Evergreen.V11.Route.Route
    , showCarbonOffsetTooltip : Bool
    , isOrganiser : Bool
    , ticketsEnabled : TicketsEnabled
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
    | PressedSelectTicket (Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.ProductId) (Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.PriceId)
    | FormChanged Evergreen.V11.Stripe.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.ProductId) (Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.PriceId)
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport
    | Chirp


type ToBackend
    = SubmitFormRequest (Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.PriceId) (Evergreen.V11.Untrusted.Untrusted Evergreen.V11.Stripe.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List Evergreen.V11.Stripe.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.PriceId) Evergreen.V11.Stripe.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.StripeSessionId) (Result Http.Error Evergreen.V11.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V11.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData InitData2
    | SubmitFormResponse (Result String (Evergreen.V11.Id.Id Evergreen.V11.Stripe.Stripe.StripeSessionId))
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel
