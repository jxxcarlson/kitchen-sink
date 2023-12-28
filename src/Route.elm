module Route exposing (Route(..), SubPage(..), decode, encode)

import EmailAddress exposing (EmailAddress)
import Id exposing (Id)
import Stripe.Stripe as Stripe exposing (StripeSessionId(..))
import Url exposing (Url)
import Url.Builder
import Url.Parser exposing ((</>), (<?>))
import Url.Parser.Query


type Route
    = HomepageRoute
    | About
    | Brillig
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
        , Url.Parser.s "about" |> Url.Parser.map About
        , Url.Parser.s "brillig" |> Url.Parser.map Brillig
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

            About ->
                [ "about" ]

            Brillig ->
                [ "brillig" ]

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

            About ->
                []

            Brillig ->
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
