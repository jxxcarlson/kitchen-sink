module Evergreen.V138.Route exposing (..)

import Evergreen.V138.EmailAddress


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
    | PaymentSuccessRoute (Maybe Evergreen.V138.EmailAddress.EmailAddress)
    | PaymentCancelRoute
