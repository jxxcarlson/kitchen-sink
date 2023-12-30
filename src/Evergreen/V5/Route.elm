module Evergreen.V5.Route exposing (..)

import Evergreen.V5.EmailAddress


type Route
    = HomepageRoute
    | About
    | Notes
    | Brillig
    | AdminRoute (Maybe String)
    | PaymentSuccessRoute (Maybe Evergreen.V5.EmailAddress.EmailAddress)
    | PaymentCancelRoute
