module Stripe.PurchaseForm exposing
    ( PressedSubmit(..)
    , PurchaseForm
    , PurchaseFormValidated(..)
    , SinglePurchaseData
    , SubmitStatus(..)
    , attendeeName
    , billingEmail
    , codec
    , commonPurchaseData
    , validateEmailAddress
    , validateForm
    , validateInt
    , validateName
    )

import Codec exposing (Codec)
import EmailAddress exposing (EmailAddress)
import Id exposing (Id)
import Name exposing (Name)
import String.Nonempty exposing (NonemptyString)
import Stripe.Stripe exposing (ProductId(..))
import Toop exposing (T3(..), T4(..), T5(..), T6(..), T7(..), T8(..))


type alias PurchaseForm =
    { submitStatus : SubmitStatus
    , attendee1Name : String
    , attendee2Name : String
    , billingEmail : String
    , country : String
    , originCity : String
    , grantApply : Bool
    }


type PurchaseFormValidated
    = CampfireTicketPurchase SinglePurchaseData
    | CampTicketPurchase SinglePurchaseData


type alias SinglePurchaseData =
    { attendeeName : Name
    , billingEmail : EmailAddress
    , country : NonemptyString
    , originCity : NonemptyString
    }


commonPurchaseData purchaseFormValidated =
    case purchaseFormValidated of
        CampfireTicketPurchase a ->
            a

        CampTicketPurchase a ->
            a


type SubmitStatus
    = NotSubmitted PressedSubmit
    | Submitting
    | SubmitBackendError String


type PressedSubmit
    = PressedSubmit
    | NotPressedSubmit


billingEmail : PurchaseFormValidated -> EmailAddress
billingEmail paymentForm =
    case paymentForm of
        CampfireTicketPurchase a ->
            a.billingEmail

        CampTicketPurchase a ->
            a.billingEmail


attendeeName : PurchaseFormValidated -> Name
attendeeName paymentForm =
    case paymentForm of
        CampfireTicketPurchase a ->
            a.attendeeName

        CampTicketPurchase a ->
            a.attendeeName


validateInt : String -> Result String Int
validateInt s =
    case String.toInt s of
        Nothing ->
            Err "Invalid number"

        Just x ->
            Ok x


validateName : String -> Result String Name
validateName name =
    Name.fromString name |> Result.mapError Name.errorToString


validateEmailAddress : String -> Result String EmailAddress
validateEmailAddress text =
    if String.trim text == "" then
        Err "Please enter an email address"

    else
        case EmailAddress.fromString text of
            Just emailAddress ->
                Ok emailAddress

            Nothing ->
                Err "Invalid email address"


validateForm : Id ProductId -> PurchaseForm -> Maybe PurchaseFormValidated
validateForm productId form =
    let
        name1 =
            validateName form.attendee1Name

        name2 =
            validateName form.attendee2Name

        emailAddress =
            validateEmailAddress form.billingEmail

        country =
            String.Nonempty.fromString form.country

        originCity =
            String.Nonempty.fromString form.originCity
    in
    let
        product =
            if productId == Id.fromString "Product.ticket.camp" then
                CampTicketPurchase

            else
                CampfireTicketPurchase
    in
    case T4 name1 emailAddress country originCity of
        T4 (Ok name1Ok) (Ok emailAddressOk) (Just countryOk) (Just originCityOk) ->
            product
                { attendeeName = name1Ok
                , billingEmail = emailAddressOk
                , country = countryOk
                , originCity = originCityOk
                }
                |> Just

        _ ->
            Nothing


codec : Codec PurchaseFormValidated
codec =
    Codec.custom
        (\a b value ->
            case value of
                CampfireTicketPurchase data0 ->
                    a data0

                CampTicketPurchase data0 ->
                    b data0
        )
        |> Codec.variant1 "CampfireTicketPurchase" CampfireTicketPurchase singlePurchaseDataCodec
        |> Codec.variant1 "CampTicketPurchase" CampTicketPurchase singlePurchaseDataCodec
        |> Codec.buildCustom


singlePurchaseDataCodec : Codec SinglePurchaseData
singlePurchaseDataCodec =
    Codec.object SinglePurchaseData
        |> Codec.field "attendeeName" .attendeeName Name.codec
        |> Codec.field "billingEmail" .billingEmail emailAddressCodec
        |> Codec.field "country" .country nonemptyStringCodec
        |> Codec.field "originCity" .originCity nonemptyStringCodec
        |> Codec.buildObject


nonemptyStringCodec =
    Codec.andThen
        (\text ->
            case String.Nonempty.fromString text of
                Just nonempty ->
                    Codec.succeed nonempty

                Nothing ->
                    Codec.fail ("Invalid nonempty string: " ++ text)
        )
        String.Nonempty.toString
        Codec.string


emailAddressCodec : Codec EmailAddress
emailAddressCodec =
    Codec.andThen
        (\text ->
            case EmailAddress.fromString text of
                Just email ->
                    Codec.succeed email

                Nothing ->
                    Codec.fail ("Invalid email: " ++ text)
        )
        EmailAddress.toString
        Codec.string
