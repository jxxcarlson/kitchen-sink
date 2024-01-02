module Evergreen.V51.Route exposing (..)

import Evergreen.V51.EmailAddress


type Route
    = HomepageRoute
    | Features
    | Notes
    | SignInRoute
    | Brillig
    | AdminRoute
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V51.EmailAddress.EmailAddress)
    | PaymentCancelRoute
