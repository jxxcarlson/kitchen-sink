module Evergreen.V136.Route exposing (..)

import Evergreen.V136.EmailAddress


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
    | PaymentSuccessRoute (Maybe Evergreen.V136.EmailAddress.EmailAddress)
    | PaymentCancelRoute
