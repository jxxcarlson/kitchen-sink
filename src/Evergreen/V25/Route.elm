module Evergreen.V25.Route exposing (..)

import Evergreen.V25.EmailAddress


type Route
    = HomepageRoute
    | About
    | Notes
    | Brillig
    | AdminRoute (Maybe String)
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V25.EmailAddress.EmailAddress)
    | PaymentCancelRoute
