module Evergreen.V107.Stripe.PurchaseForm exposing (..)

import Evergreen.V107.EmailAddress
import Evergreen.V107.Name


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
    { billingName : Evergreen.V107.Name.Name
    , billingEmail : Evergreen.V107.EmailAddress.EmailAddress
    }


type PurchaseFormValidated
    = ImageCreditPurchase PurchaseData
    | ImageLibraryPackagePurchase PurchaseData
