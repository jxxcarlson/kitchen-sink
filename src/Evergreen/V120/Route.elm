module Evergreen.V120.Route exposing (..)

import Evergreen.V120.EmailAddress


type Route
    = HomepageRoute
    | DataStore
    | EditData
    | Features
    | Notes
    | SignInRoute
    | Brillig
    | AdminRoute
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V120.EmailAddress.EmailAddress)
    | PaymentCancelRoute
