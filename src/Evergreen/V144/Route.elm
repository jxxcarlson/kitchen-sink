module Evergreen.V144.Route exposing (..)

import Evergreen.V144.EmailAddress


type Route
    = HomepageRoute
    | DataStore
    | EditData
    | Features
    | TermsOfServiceRoute
    | Notes
    | SignInRoute
    | Brillig
    | AdminRoute
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V144.EmailAddress.EmailAddress)
    | PaymentCancelRoute
