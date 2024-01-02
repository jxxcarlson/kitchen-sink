module Evergreen.V47.Route exposing (..)

import Evergreen.V47.EmailAddress


type Route
    = HomepageRoute
    | Features
    | Notes
    | SignInRoute
    | Brillig
    | AdminRoute (Maybe String)
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V47.EmailAddress.EmailAddress)
    | PaymentCancelRoute
