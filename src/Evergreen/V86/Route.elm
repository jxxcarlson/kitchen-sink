module Evergreen.V86.Route exposing (..)

import Evergreen.V86.EmailAddress


type Route
    = HomepageRoute
    | Features
    | Notes
    | SignInRoute
    | Brillig
    | AdminRoute
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V86.EmailAddress.EmailAddress)
    | PaymentCancelRoute
