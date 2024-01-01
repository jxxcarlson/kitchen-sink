module Evergreen.V32.Route exposing (..)

import Evergreen.V32.EmailAddress


type Route
    = HomepageRoute
    | Features
    | Notes
    | Brillig
    | AdminRoute (Maybe String)
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V32.EmailAddress.EmailAddress)
    | PaymentCancelRoute
