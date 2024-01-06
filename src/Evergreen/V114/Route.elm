module Evergreen.V114.Route exposing (..)

import Evergreen.V114.EmailAddress


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
    | PaymentSuccessRoute (Maybe Evergreen.V114.EmailAddress.EmailAddress)
    | PaymentCancelRoute
