module Evergreen.V6.Route exposing (..)

import Evergreen.V6.EmailAddress


type Route
    = HomepageRoute
    | About
    | Notes
    | Brillig
    | AdminRoute (Maybe String)
    | PaymentSuccessRoute (Maybe Evergreen.V6.EmailAddress.EmailAddress)
    | PaymentCancelRoute
