module Evergreen.V142.Stripe.PurchaseForm exposing (..)

import Evergreen.V142.EmailAddress
import Evergreen.V142.Name


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
    { billingName : Evergreen.V142.Name.Name
    , billingEmail : Evergreen.V142.EmailAddress.EmailAddress
    }


type PurchaseFormValidated
    = ImageCreditPurchase PurchaseData
    | ImageLibraryPackagePurchase PurchaseData
