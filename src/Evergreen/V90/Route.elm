module Evergreen.V90.Route exposing (..)

import Evergreen.V90.EmailAddress


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
    | PaymentSuccessRoute (Maybe Evergreen.V90.EmailAddress.EmailAddress)
    | PaymentCancelRoute
