module Evergreen.V20.Route exposing (..)

import Evergreen.V20.EmailAddress


type Route
    = HomepageRoute
    | About
    | Notes
    | Brillig
    | AdminRoute (Maybe String)
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V20.EmailAddress.EmailAddress)
    | PaymentCancelRoute
