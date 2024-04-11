module Evergreen.V134.Route exposing (..)

import Evergreen.V134.EmailAddress


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
    | PaymentSuccessRoute (Maybe Evergreen.V134.EmailAddress.EmailAddress)
    | PaymentCancelRoute
