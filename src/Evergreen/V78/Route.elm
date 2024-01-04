module Evergreen.V78.Route exposing (..)

import Evergreen.V78.EmailAddress


type Route
    = HomepageRoute
    | Features
    | Notes
    | SignInRoute
    | Brillig
    | AdminRoute
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V78.EmailAddress.EmailAddress)
    | PaymentCancelRoute
