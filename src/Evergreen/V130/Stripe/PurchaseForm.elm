module Evergreen.V130.Stripe.PurchaseForm exposing (..)

import Evergreen.V130.EmailAddress
import Evergreen.V130.Name


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
    { billingName : Evergreen.V130.Name.Name
    , billingEmail : Evergreen.V130.EmailAddress.EmailAddress
    }


type PurchaseFormValidated
    = ImageCreditPurchase PurchaseData
    | ImageLibraryPackagePurchase PurchaseData
