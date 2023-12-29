module Evergreen.V3.Route exposing (..)

import Evergreen.V3.EmailAddress


type Route
    = HomepageRoute
    | About
    | Notes
    | Brillig
    | AdminRoute (Maybe String)
    | PaymentSuccessRoute (Maybe Evergreen.V3.EmailAddress.EmailAddress)
    | PaymentCancelRoute
