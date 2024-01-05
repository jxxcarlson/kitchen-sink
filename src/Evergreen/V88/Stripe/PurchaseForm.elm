module Evergreen.V88.Stripe.PurchaseForm exposing (..)

import Evergreen.V88.EmailAddress
import Evergreen.V88.Name


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
    { billingName : Evergreen.V88.Name.Name
    , billingEmail : Evergreen.V88.EmailAddress.EmailAddress
    }


type PurchaseFormValidated
    = ImageCreditPurchase PurchaseData
    | ImageLibraryPackagePurchase PurchaseData
