module Evergreen.V125.Route exposing (..)

import Evergreen.V125.EmailAddress


type Route
    = HomepageRoute
    | DataStore
    | EditData
    | Features
    | Notes
    | SignInRoute
    | Brillig
    | AdminRoute
    | Purchase
    | PaymentSuccessRoute (Maybe Evergreen.V125.EmailAddress.EmailAddress)
    | PaymentCancelRoute
