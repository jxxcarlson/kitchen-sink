module Evergreen.V107.Route exposing (..)

import Evergreen.V107.EmailAddress


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
    | PaymentSuccessRoute (Maybe Evergreen.V107.EmailAddress.EmailAddress)
    | PaymentCancelRoute
