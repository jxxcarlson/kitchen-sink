module Evergreen.V101.Route exposing (..)

import Evergreen.V101.EmailAddress


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
    | PaymentSuccessRoute (Maybe Evergreen.V101.EmailAddress.EmailAddress)
    | PaymentCancelRoute
