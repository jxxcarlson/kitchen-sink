module Evergreen.V11.Route exposing (..)

import Evergreen.V11.EmailAddress


type Route
    = HomepageRoute
    | About
    | Notes
    | Brillig
    | AdminRoute (Maybe String)
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V11.EmailAddress.EmailAddress)
    | PaymentCancelRoute
