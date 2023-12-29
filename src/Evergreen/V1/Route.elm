module Evergreen.V1.Route exposing (..)

import Evergreen.V1.EmailAddress


type Route
    = HomepageRoute
    | About
    | Notes
    | Brillig
    | AdminRoute (Maybe String)
    | PaymentSuccessRoute (Maybe Evergreen.V1.EmailAddress.EmailAddress)
    | PaymentCancelRoute
