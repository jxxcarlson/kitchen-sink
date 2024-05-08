module Evergreen.V143.Route exposing (..)

import Evergreen.V143.EmailAddress


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
    | PaymentSuccessRoute (Maybe Evergreen.V143.EmailAddress.EmailAddress)
    | PaymentCancelRoute
