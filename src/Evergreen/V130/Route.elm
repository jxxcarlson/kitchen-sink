module Evergreen.V130.Route exposing (..)

import Evergreen.V130.EmailAddress


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
    | PaymentSuccessRoute (Maybe Evergreen.V130.EmailAddress.EmailAddress)
    | PaymentCancelRoute
