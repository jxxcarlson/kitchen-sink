module Evergreen.V25.Stripe.PurchaseForm exposing (..)

import Evergreen.V25.EmailAddress
import Evergreen.V25.Name
import String.Nonempty


type PressedSubmit
    = PressedSubmit
    | NotPressedSubmit


type SubmitStatus
    = NotSubmitted PressedSubmit
    | Submitting
    | SubmitBackendError String


type alias PurchaseForm =
    { submitStatus : SubmitStatus
    , name : String
    , billingEmail : String
    , country : String
    }


type alias PurchaseData =
    { billingName : Evergreen.V25.Name.Name
    , billingEmail : Evergreen.V25.EmailAddress.EmailAddress
    , country : String.Nonempty.NonemptyString
    }


type PurchaseFormValidated
    = ImageCreditPurchase PurchaseData
    | ImageLibraryPackagePurchase PurchaseData
