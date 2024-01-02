module Evergreen.V48.Route exposing (..)

import Evergreen.V48.EmailAddress


type Route
    = HomepageRoute
    | Features
    | Notes
    | SignInRoute
    | Brillig
    | AdminRoute (Maybe String)
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V48.EmailAddress.EmailAddress)
    | PaymentCancelRoute
