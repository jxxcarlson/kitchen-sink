module Evergreen.V20.Stripe.PurchaseForm exposing (..)

import Evergreen.V20.EmailAddress
import Evergreen.V20.Name
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
    { billingName : Evergreen.V20.Name.Name
    , billingEmail : Evergreen.V20.EmailAddress.EmailAddress
    , country : String.Nonempty.NonemptyString
    }


type PurchaseFormValidated
    = ImageCreditPurchase PurchaseData
    | ImageLibraryPackagePurchase PurchaseData
