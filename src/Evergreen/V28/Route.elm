module Evergreen.V28.Route exposing (..)

import Evergreen.V28.EmailAddress


type Route
    = HomepageRoute
    | About
    | Notes
    | Brillig
    | AdminRoute (Maybe String)
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V28.EmailAddress.EmailAddress)
    | PaymentCancelRoute
