module Evergreen.V50.Route exposing (..)

import Evergreen.V50.EmailAddress


type Route
    = HomepageRoute
    | UnconferenceFormatRoute
    | VenueAndAccessRoute
    | CodeOfConductRoute
    | AdminRoute (Maybe String)
    | PaymentSuccessRoute (Maybe Evergreen.V50.EmailAddress.EmailAddress)
    | PaymentCancelRoute
    | LiveScheduleRoute
