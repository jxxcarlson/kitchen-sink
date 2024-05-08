module Evergreen.V141.Route exposing (..)

import Evergreen.V141.EmailAddress


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
    | PaymentSuccessRoute (Maybe Evergreen.V141.EmailAddress.EmailAddress)
    | PaymentCancelRoute
