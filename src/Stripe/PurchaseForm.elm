module Stripe.PurchaseForm exposing
    ( PressedSubmit(..)
    , PurchaseForm
    , PurchaseFormValidated(..)
    , SubmitStatus(..)
    , billingEmail
    , codec
    , getPurchaseData
    , purchaserName
    , validateEmailAddress
    , validateForm
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
    , name : String
    , billingEmail : String
    , country : String
    }


type PurchaseFormValidated
    = ImageCreditPurchase PurchaseData
    | ImageLibraryPackagePurchase PurchaseData


getPurchaseData : PurchaseFormValidated -> PurchaseData
getPurchaseData purchaseForm =
    case purchaseForm of
        ImageCreditPurchase data_ ->
            data_

        ImageLibraryPackagePurchase data_ ->
            data_


type alias PurchaseData =
    { billingName : Name
    , billingEmail : EmailAddress
    }


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
        ImageCreditPurchase a ->
            a.billingEmail

        ImageLibraryPackagePurchase a ->
            a.billingEmail


purchaserName : PurchaseFormValidated -> Name
purchaserName paymentForm =
    case paymentForm of
        ImageCreditPurchase a ->
            a.billingName

        ImageLibraryPackagePurchase a ->
            a.billingName


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
        name =
            validateName form.name

        emailAddress =
            validateEmailAddress form.billingEmail
    in
    case ( name, emailAddress ) of
        ( Ok nameOk, Ok emailAddressOk ) ->
            ImageCreditPurchase
                { billingName = nameOk
                , billingEmail = emailAddressOk
                }
                |> Just

        _ ->
            Nothing


codec : Codec PurchaseFormValidated
codec =
    Codec.custom
        (\a b value ->
            case value of
                ImageCreditPurchase data0 ->
                    a data0

                ImageLibraryPackagePurchase data0 ->
                    b data0
        )
        |> Codec.variant1 "ImageCreditPurchase" ImageCreditPurchase purchaseDataCodec
        |> Codec.variant1 "ImageLibraryPackagePurchase" ImageLibraryPackagePurchase purchaseDataCodec
        |> Codec.buildCustom


purchaseDataCodec : Codec PurchaseData
purchaseDataCodec =
    Codec.object PurchaseData
        |> Codec.field "billingName" .billingName Name.codec
        |> Codec.field "billingEmail" .billingEmail emailAddressCodec
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
