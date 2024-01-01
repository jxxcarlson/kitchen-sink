module Evergreen.V42.Route exposing (..)

import Evergreen.V42.EmailAddress


type Route
    = HomepageRoute
    | Features
    | Notes
    | SignInRoute
    | Brillig
    | AdminRoute (Maybe String)
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V42.EmailAddress.EmailAddress)
    | PaymentCancelRoute
