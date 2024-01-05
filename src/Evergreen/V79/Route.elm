module Evergreen.V79.Route exposing (..)

import Evergreen.V79.EmailAddress


type Route
    = HomepageRoute
    | Features
    | Notes
    | SignInRoute
    | Brillig
    | AdminRoute
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V79.EmailAddress.EmailAddress)
    | PaymentCancelRoute
