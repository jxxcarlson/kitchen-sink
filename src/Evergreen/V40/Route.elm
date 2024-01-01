module Evergreen.V40.Route exposing (..)

import Evergreen.V40.EmailAddress


type Route
    = HomepageRoute
    | Features
    | Notes
    | SignInRoute
    | Brillig
    | AdminRoute (Maybe String)
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V40.EmailAddress.EmailAddress)
    | PaymentCancelRoute
