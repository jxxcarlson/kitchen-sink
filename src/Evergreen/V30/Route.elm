module Evergreen.V30.Route exposing (..)

import Evergreen.V30.EmailAddress


type Route
    = HomepageRoute
    | Features
    | Notes
    | Brillig
    | AdminRoute (Maybe String)
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V30.EmailAddress.EmailAddress)
    | PaymentCancelRoute
