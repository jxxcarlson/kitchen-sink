module Evergreen.V142.Route exposing (..)

import Evergreen.V142.EmailAddress


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
    | PaymentSuccessRoute (Maybe Evergreen.V142.EmailAddress.EmailAddress)
    | PaymentCancelRoute
