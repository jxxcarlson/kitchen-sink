module Evergreen.V13.Route exposing (..)

import Evergreen.V13.EmailAddress


type Route
    = HomepageRoute
    | About
    | Notes
    | Brillig
    | AdminRoute (Maybe String)
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V13.EmailAddress.EmailAddress)
    | PaymentCancelRoute
