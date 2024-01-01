module Evergreen.V38.Route exposing (..)

import Evergreen.V38.EmailAddress


type Route
    = HomepageRoute
    | Features
    | Notes
    | SignIn
    | Brillig
    | AdminRoute (Maybe String)
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V38.EmailAddress.EmailAddress)
    | PaymentCancelRoute
