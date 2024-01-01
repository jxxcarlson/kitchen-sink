module Evergreen.V33.Route exposing (..)

import Evergreen.V33.EmailAddress


type Route
    = HomepageRoute
    | Features
    | Notes
    | Brillig
    | AdminRoute (Maybe String)
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V33.EmailAddress.EmailAddress)
    | PaymentCancelRoute
