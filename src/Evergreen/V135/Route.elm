module Evergreen.V135.Route exposing (..)

import Evergreen.V135.EmailAddress


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
    | PaymentSuccessRoute (Maybe Evergreen.V135.EmailAddress.EmailAddress)
    | PaymentCancelRoute
