module Evergreen.V50.Route exposing (..)

import Evergreen.V50.EmailAddress


type Route
    = HomepageRoute
    | Features
    | Notes
    | SignInRoute
    | Brillig
    | AdminRoute
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V50.EmailAddress.EmailAddress)
    | PaymentCancelRoute
