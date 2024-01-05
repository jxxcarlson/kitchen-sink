module Evergreen.V84.Route exposing (..)

import Evergreen.V84.EmailAddress


type Route
    = HomepageRoute
    | Features
    | Notes
    | SignInRoute
    | Brillig
    | AdminRoute
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V84.EmailAddress.EmailAddress)
    | PaymentCancelRoute
