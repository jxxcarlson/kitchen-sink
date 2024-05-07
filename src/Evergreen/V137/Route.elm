module Evergreen.V137.Route exposing (..)

import Evergreen.V137.EmailAddress


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
    | PaymentSuccessRoute (Maybe Evergreen.V137.EmailAddress.EmailAddress)
    | PaymentCancelRoute
