module Route exposing (Route(..), SubPage(..), decode, encode)

import EmailAddress exposing (EmailAddress)
import Id exposing (Id)
import Stripe exposing (StripeSessionId(..))
import Url exposing (Url)
import Url.Builder
import Url.Parser exposing ((</>), (<?>))
import Url.Parser.Query


type Route
    = HomepageRoute
    | UnconferenceFormatRoute
    | VenueAndAccessRoute
    | CodeOfConductRoute
    | AdminRoute (Maybe String)
    | PaymentSuccessRoute (Maybe EmailAddress)
    | PaymentCancelRoute
    | LiveScheduleRoute



type SubPage
    = Home
    | Artifacts





decode : Url -> Route
decode url =
    Url.Parser.oneOf
        [ Url.Parser.top |> Url.Parser.map HomepageRoute
        , Url.Parser.s "unconference-format" |> Url.Parser.map UnconferenceFormatRoute
        , Url.Parser.s "venue-and-access" |> Url.Parser.map VenueAndAccessRoute
        , Url.Parser.s "code-of-conduct" |> Url.Parser.map CodeOfConductRoute
        , Url.Parser.s "admin" <?> parseAdminPass |> Url.Parser.map AdminRoute
        , Url.Parser.s Stripe.successPath <?> parseEmail |> Url.Parser.map PaymentSuccessRoute
        , Url.Parser.s Stripe.cancelPath |> Url.Parser.map PaymentCancelRoute
        , Url.Parser.s liveSchedulePath |> Url.Parser.map LiveScheduleRoute


        ]
        |> (\a -> Url.Parser.parse a url |> Maybe.withDefault HomepageRoute)


liveSchedulePath =
    "live"


parseEmail : Url.Parser.Query.Parser (Maybe EmailAddress)
parseEmail =
    Url.Parser.Query.map
        (Maybe.andThen EmailAddress.fromString)
        (Url.Parser.Query.string Stripe.emailAddressParameter)


parseAdminPass : Url.Parser.Query.Parser (Maybe String)
parseAdminPass =
    Url.Parser.Query.string "pass"


parseStripeSessionId : Url.Parser.Query.Parser (Maybe (Id StripeSessionId))
parseStripeSessionId =
    Url.Parser.Query.map (Maybe.map Id.fromString) (Url.Parser.Query.string Stripe.stripeSessionIdParameter)


encode : Route -> String
encode route =
    Url.Builder.absolute
        (case route of
            HomepageRoute ->
                []

            UnconferenceFormatRoute ->
                [ "unconference-format" ]

            VenueAndAccessRoute ->
                [ "venue-and-access" ]

            CodeOfConductRoute ->
                [ "code-of-conduct" ]

            AdminRoute passM ->
                [ "admin" ]

            PaymentSuccessRoute _ ->
                [ Stripe.successPath ]

            PaymentCancelRoute ->
                [ Stripe.cancelPath ]

            LiveScheduleRoute ->
                [ liveSchedulePath ]


        )
        (case route of
            HomepageRoute ->
                []

            UnconferenceFormatRoute ->
                []

            VenueAndAccessRoute ->
                []

            CodeOfConductRoute ->
                []

            AdminRoute passM ->
                []

            PaymentSuccessRoute maybeEmailAddress ->
                case maybeEmailAddress of
                    Just emailAddress ->
                        [ Url.Builder.string Stripe.emailAddressParameter (EmailAddress.toString emailAddress) ]

                    Nothing ->
                        []

            PaymentCancelRoute ->
                []

            LiveScheduleRoute ->
                []


        )
