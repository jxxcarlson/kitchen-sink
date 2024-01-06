module Evergreen.V126.Route exposing (..)

import Evergreen.V126.EmailAddress


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
    | PaymentSuccessRoute (Maybe Evergreen.V126.EmailAddress.EmailAddress)
    | PaymentCancelRoute
