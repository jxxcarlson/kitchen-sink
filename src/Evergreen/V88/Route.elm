module Evergreen.V88.Route exposing (..)

import Evergreen.V88.EmailAddress


type Route
    = HomepageRoute
    | DataStore
    | Features
    | Notes
    | SignInRoute
    | Brillig
    | AdminRoute
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V88.EmailAddress.EmailAddress)
    | PaymentCancelRoute
