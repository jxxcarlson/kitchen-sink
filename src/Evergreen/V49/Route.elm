module Evergreen.V49.Route exposing (..)

import Evergreen.V49.EmailAddress


type Route
    = HomepageRoute
    | Features
    | Notes
    | SignInRoute
    | Brillig
    | AdminRoute
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V49.EmailAddress.EmailAddress)
    | PaymentCancelRoute
