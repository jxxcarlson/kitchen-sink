module Types exposing (..)

import AssocList
import Audio
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Codec exposing (Codec)
import Dict
import Http
import Id exposing (Id)
import Lamdera exposing (ClientId, SessionId)
import LiveSchedule
import Money
import Postmark exposing (PostmarkSendResponse)
import Route exposing (Route)
import Stripe.PurchaseForm as PurchaseForm exposing (PurchaseForm, PurchaseFormValidated)
import Stripe.Stripe exposing (Price, PriceData, PriceId, ProductId, StripeSessionId)
import Time
import Untrusted exposing (Untrusted)
import Url exposing (Url)


type alias FrontendModel =
    Audio.Model FrontendMsg_ FrontendModel_


type FrontendModel_
    = Loading LoadingModel
    | Loaded LoadedModel


type alias LoadingModel =
    { key : Key
    , now : Time.Posix
    , window : Maybe { width : Int, height : Int }
    , route : Route
    , isOrganiser : Bool
    , initData : Maybe InitData2
    , audio : Maybe (Result Audio.LoadError Audio.Source)
    }


type alias LoadedModel =
    { key : Key
    , now : Time.Posix
    , window : { width : Int, height : Int }
    , showTooltip : Bool
    , prices : AssocList.Dict (Id ProductId) { priceId : Id PriceId, price : Price }
    , selectedTicket : Maybe ( Id ProductId, Id PriceId )
    , form : PurchaseForm
    , route : Route
    , showCarbonOffsetTooltip : Bool
    , slotsRemaining : TicketAvailability
    , isOrganiser : Bool
    , ticketsEnabled : TicketsEnabled
    , backendModel : Maybe BackendModel
    , audio : Maybe Audio.Source
    , pressedAudioButton : Bool
    }


type alias TicketAvailability =
    { campTicket : Bool
    , couplesCampTicket : Bool
    , campfireTicket : Bool
    }


type alias BackendModel =
    { orders : AssocList.Dict (Id StripeSessionId) Order
    , pendingOrder : AssocList.Dict (Id StripeSessionId) PendingOrder
    , expiredOrders : AssocList.Dict (Id StripeSessionId) PendingOrder
    , prices : AssocList.Dict (Id ProductId) Price2
    , time : Time.Posix
    , ticketsEnabled : TicketsEnabled
    }


type alias Price2 =
    { priceId : Id PriceId, price : Price }


backendModelCodec : Codec BackendModel
backendModelCodec =
    Codec.object BackendModel
        |> Codec.field "orders" .orders (assocListCodec orderCodec)
        |> Codec.field "pendingOrder" .pendingOrder (assocListCodec pendingOrderCodec)
        |> Codec.field "expiredOrders" .expiredOrders (assocListCodec pendingOrderCodec)
        |> Codec.field "prices" .prices (assocListCodec price2Codec)
        |> Codec.field "time" .time timeCodec
        |> Codec.field "ticketsEnabled" .ticketsEnabled ticketsEnabledCodec
        |> Codec.buildObject


ticketsEnabledCodec : Codec TicketsEnabled
ticketsEnabledCodec =
    Codec.custom
        (\a b value ->
            case value of
                TicketsEnabled ->
                    a

                TicketsDisabled { adminMessage } ->
                    b adminMessage
        )
        |> Codec.variant0 "TicketsEnabled" TicketsEnabled
        |> Codec.variant1 "TicketsDisabled" (\a -> TicketsDisabled { adminMessage = a }) Codec.string
        |> Codec.buildCustom


price2Codec : Codec Price2
price2Codec =
    Codec.object Price2
        |> Codec.field "priceId" .priceId idCodec
        |> Codec.field "price" .price priceCodec
        |> Codec.buildObject


priceCodec : Codec Price
priceCodec =
    Codec.object Price
        |> Codec.field "currency" .currency currencyCodec
        |> Codec.field "amount" .amount Codec.int
        |> Codec.buildObject


currencyCodec : Codec Money.Currency
currencyCodec =
    Codec.andThen
        (\text ->
            case Money.fromString text of
                Just money ->
                    Codec.succeed money

                Nothing ->
                    Codec.fail ("Invalid currency: " ++ text)
        )
        Money.toString
        Codec.string


assocListCodec : Codec b -> Codec (AssocList.Dict (Id a) b)
assocListCodec codec =
    Codec.map
        (\dict -> Dict.toList dict |> List.map (Tuple.mapFirst Id.fromString) |> AssocList.fromList)
        (\assocList -> AssocList.toList assocList |> List.map (Tuple.mapFirst Id.toString) |> Dict.fromList)
        (Codec.dict codec)


idCodec : Codec (Id a)
idCodec =
    Codec.map Id.fromString Id.toString Codec.string


type alias PendingOrder =
    { priceId : Id PriceId
    , submitTime : Time.Posix
    , form : PurchaseFormValidated
    , sessionId : SessionId
    }


type alias Order =
    { priceId : Id PriceId
    , submitTime : Time.Posix
    , form : PurchaseFormValidated
    , emailResult : EmailResult

    --, products : List Product
    --, sponsorship : Maybe Sponsorship
    --, opportunityGrantContribution : Price
    --, status : OrderStatus
    }


pendingOrderCodec : Codec PendingOrder
pendingOrderCodec =
    Codec.object PendingOrder
        |> Codec.field "priceId" .priceId idCodec
        |> Codec.field "submitTime" .submitTime timeCodec
        |> Codec.field "form" .form PurchaseForm.codec
        |> Codec.field "sessionId" .sessionId Codec.string
        |> Codec.buildObject


orderCodec : Codec { priceId : Id PriceId, submitTime : Time.Posix, form : PurchaseFormValidated, emailResult : EmailResult }
orderCodec =
    Codec.object Order
        |> Codec.field "priceId" .priceId idCodec
        |> Codec.field "submitTime" .submitTime timeCodec
        |> Codec.field "form" .form PurchaseForm.codec
        |> Codec.field "emailResult" .emailResult emailResultCodec
        |> Codec.buildObject


emailResultCodec =
    Codec.custom
        (\a b c value ->
            case value of
                SendingEmail ->
                    a

                EmailSuccess data0 ->
                    b data0

                EmailFailed data0 ->
                    c data0
        )
        |> Codec.variant0 "SendingEmail" SendingEmail
        |> Codec.variant1 "EmailSuccess" EmailSuccess postmarkSendResponseCodec
        |> Codec.variant1 "EmailFailed" EmailFailed httpErrorCodec
        |> Codec.buildCustom


postmarkSendResponseCodec =
    Codec.object PostmarkSendResponse
        |> Codec.field "to" .to Codec.string
        |> Codec.field "submittedAt" .submittedAt Codec.string
        |> Codec.field "messageId" .messageId Codec.string
        |> Codec.field "errorCode" .errorCode Codec.int
        |> Codec.field "message" .message Codec.string
        |> Codec.buildObject


httpErrorCodec =
    Codec.custom
        (\a b c d e value ->
            case value of
                Http.BadUrl data0 ->
                    a data0

                Http.Timeout ->
                    b

                Http.NetworkError ->
                    c

                Http.BadStatus int ->
                    d int

                Http.BadBody string ->
                    e string
        )
        |> Codec.variant1 "Http.BadUrl" Http.BadUrl Codec.string
        |> Codec.variant0 "Http.Timeout" Http.Timeout
        |> Codec.variant0 "Http.NetworkError" Http.NetworkError
        |> Codec.variant1 "Http.BadStatus" Http.BadStatus Codec.int
        |> Codec.variant1 "Http.BadBody" Http.BadBody Codec.string
        |> Codec.buildCustom


timeCodec : Codec Time.Posix
timeCodec =
    Codec.map Time.millisToPosix Time.posixToMillis Codec.int


type EmailResult
    = SendingEmail
    | EmailSuccess PostmarkSendResponse
    | EmailFailed Http.Error


type OrderStatus
    = Pending
    | Failed String
    | Paid StripePaymentId
    | Refunded StripePaymentId


type StripePaymentId
    = StripePaymentId String


type Product
    = CampTicket Price
    | CouplesCampTicket Price
    | CampfireTicket Price


type Sponsorship
    = SponsorBronze Price
    | SponsorSilver Price
    | SponsorGold Price


type alias CityCode =
    String


type alias FrontendMsg =
    Audio.Msg FrontendMsg_


type FrontendMsg_
    = UrlClicked UrlRequest
    | UrlChanged Url
    | Tick Time.Posix
    | GotWindowSize Int Int
    | PressedShowTooltip
    | MouseDown
    | PressedSelectTicket (Id ProductId) (Id PriceId)
    | FormChanged PurchaseForm
    | PressedSubmitForm (Id ProductId) (Id PriceId)
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport
    | LoadedMusic (Result Audio.LoadError Audio.Source)
    | LiveScheduleMsg LiveSchedule.Msg


type ToBackend
    = SubmitFormRequest (Id PriceId) (Untrusted PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List PriceData))
    | OnConnected SessionId ClientId
    | CreatedCheckoutSession SessionId ClientId (Id PriceId) PurchaseFormValidated (Result Http.Error ( Id StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Id StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Id StripeSessionId) (Result Http.Error PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error PostmarkSendResponse)


type alias InitData2 =
    { prices : AssocList.Dict (Id ProductId) { priceId : Id PriceId, price : Price }
    , slotsRemaining : TicketAvailability
    , ticketsEnabled : TicketsEnabled
    }


type ToFrontend
    = InitData InitData2
    | SubmitFormResponse (Result String (Id StripeSessionId))
    | SlotRemainingChanged TicketAvailability
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel


type TicketsEnabled
    = TicketsEnabled
    | TicketsDisabled { adminMessage : String }


maxSlotsAvailable =
    50
