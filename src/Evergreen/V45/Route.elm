module Evergreen.V45.Route exposing (..)

import Evergreen.V45.EmailAddress


type Route
    = HomepageRoute
    | Features
    | Notes
    | SignInRoute
    | Brillig
    | AdminRoute (Maybe String)
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V45.EmailAddress.EmailAddress)
    | PaymentCancelRoute
