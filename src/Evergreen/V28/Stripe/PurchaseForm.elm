module Evergreen.V28.Stripe.PurchaseForm exposing (..)

import Evergreen.V28.EmailAddress
import Evergreen.V28.Name


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
    { billingName : Evergreen.V28.Name.Name
    , billingEmail : Evergreen.V28.EmailAddress.EmailAddress
    }


type PurchaseFormValidated
    = ImageCreditPurchase PurchaseData
    | ImageLibraryPackagePurchase PurchaseData
