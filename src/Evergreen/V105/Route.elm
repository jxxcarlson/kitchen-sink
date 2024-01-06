module Evergreen.V105.Route exposing (..)

import Evergreen.V105.EmailAddress


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
    | PaymentSuccessRoute (Maybe Evergreen.V105.EmailAddress.EmailAddress)
    | PaymentCancelRoute
