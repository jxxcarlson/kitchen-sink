module Evergreen.V55.Route exposing (..)

import Evergreen.V55.EmailAddress


type Route
    = HomepageRoute
    | Features
    | Notes
    | SignInRoute
    | Brillig
    | AdminRoute
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V55.EmailAddress.EmailAddress)
    | PaymentCancelRoute
