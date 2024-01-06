module Evergreen.V92.Route exposing (..)

import Evergreen.V92.EmailAddress


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
    | PaymentSuccessRoute (Maybe Evergreen.V92.EmailAddress.EmailAddress)
    | PaymentCancelRoute
