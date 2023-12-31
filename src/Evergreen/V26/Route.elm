module Evergreen.V26.Route exposing (..)

import Evergreen.V26.EmailAddress


type Route
    = HomepageRoute
    | About
    | Notes
    | Brillig
    | AdminRoute (Maybe String)
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V26.EmailAddress.EmailAddress)
    | PaymentCancelRoute
