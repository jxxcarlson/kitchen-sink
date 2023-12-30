module Evergreen.V5.Stripe.PurchaseForm exposing (..)

import Evergreen.V5.EmailAddress
import Evergreen.V5.Name
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
    , attendee1Name : String
    , attendee2Name : String
    , billingEmail : String
    , country : String
    , originCity : String
    , grantApply : Bool
    }


type alias SinglePurchaseData =
    { attendeeName : Evergreen.V5.Name.Name
    , billingEmail : Evergreen.V5.EmailAddress.EmailAddress
    , country : String.Nonempty.NonemptyString
    , originCity : String.Nonempty.NonemptyString
    }


type PurchaseFormValidated
    = CampfireTicketPurchase SinglePurchaseData
    | CampTicketPurchase SinglePurchaseData
