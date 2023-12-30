module Untrusted exposing
    ( Untrusted(..)
    , emailAddress
    , name
    , purchaseForm
    , untrust
    )

import EmailAddress exposing (EmailAddress)
import Name exposing (Name)
import Stripe.PurchaseForm as PurchaseForm exposing (PurchaseFormValidated(..))
import Toop exposing (T2(..), T3(..))


{-| We can't be sure a value we got from the frontend hasn't been tampered with.
In cases where an opaque type uses code to give some kind of guarantee (for example
MaxAttendees makes sure the max number of attendees is at least 2) we wrap the value in Unstrusted to
make sure we don't forget to validate the value again on the backend.
-}
type Untrusted a
    = Untrusted a


name : Untrusted Name -> Maybe Name
name (Untrusted a) =
    Name.toString a |> Name.fromString |> Result.toMaybe


emailAddress : Untrusted EmailAddress -> Maybe EmailAddress
emailAddress (Untrusted a) =
    EmailAddress.toString a |> EmailAddress.fromString


purchaseForm : Untrusted PurchaseFormValidated -> Maybe PurchaseFormValidated
purchaseForm (Untrusted a) =
    case a of
        CampfireTicketPurchase b ->
            case T2 (untrust b.attendeeName |> name) (untrust b.billingEmail |> emailAddress) of
                T2 (Just attendeeName) (Just billingEmail) ->
                    { attendeeName = attendeeName
                    , billingEmail = billingEmail
                    , country = b.country
                    , originCity = b.originCity
                    }
                        |> CampfireTicketPurchase
                        |> Just

                _ ->
                    Nothing

        CampTicketPurchase b ->
            case T2 (untrust b.attendeeName |> name) (untrust b.billingEmail |> emailAddress) of
                T2 (Just attendeeName) (Just billingEmail) ->
                    { attendeeName = attendeeName
                    , billingEmail = billingEmail
                    , country = b.country
                    , originCity = b.originCity
                    }
                        |> CampTicketPurchase
                        |> Just

                _ ->
                    Nothing


untrust : a -> Untrusted a
untrust =
    Untrusted
