module Evergreen.V139.Route exposing (..)

import Evergreen.V139.EmailAddress


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
    | PaymentSuccessRoute (Maybe Evergreen.V139.EmailAddress.EmailAddress)
    | PaymentCancelRoute
