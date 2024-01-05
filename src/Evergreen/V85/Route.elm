module Evergreen.V85.Route exposing (..)

import Evergreen.V85.EmailAddress


type Route
    = HomepageRoute
    | Features
    | Notes
    | SignInRoute
    | Brillig
    | AdminRoute
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V85.EmailAddress.EmailAddress)
    | PaymentCancelRoute
