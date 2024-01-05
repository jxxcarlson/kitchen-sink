module Route exposing (Route(..), decode, encode)

import EmailAddress exposing (EmailAddress)
import Stripe.Stripe as Stripe exposing (StripeSessionId(..))
import Url exposing (Url)
import Url.Builder
import Url.Parser exposing ((</>), (<?>))
import Url.Parser.Query


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
    | PaymentSuccessRoute (Maybe EmailAddress)
    | PaymentCancelRoute


decode : Url -> Route
decode url =
    Url.Parser.oneOf
        [ Url.Parser.top |> Url.Parser.map HomepageRoute
        , Url.Parser.s "features" |> Url.Parser.map Features
        , Url.Parser.s "admin" |> Url.Parser.map AdminRoute
        , Url.Parser.s "datastore" |> Url.Parser.map DataStore
        , Url.Parser.s "editdata" |> Url.Parser.map EditData
        , Url.Parser.s "notes" |> Url.Parser.map Notes
        , Url.Parser.s "purchase" |> Url.Parser.map Purchase
        , Url.Parser.s "signin" |> Url.Parser.map SignInRoute
        , Url.Parser.s "brillig" |> Url.Parser.map Brillig
        , Url.Parser.s Stripe.successPath <?> parseEmail |> Url.Parser.map PaymentSuccessRoute
        , Url.Parser.s Stripe.cancelPath |> Url.Parser.map PaymentCancelRoute
        ]
        |> (\a -> Url.Parser.parse a url |> Maybe.withDefault HomepageRoute)


parseEmail : Url.Parser.Query.Parser (Maybe EmailAddress)
parseEmail =
    Url.Parser.Query.map
        (Maybe.andThen EmailAddress.fromString)
        (Url.Parser.Query.string Stripe.emailAddressParameter)


parseAdminPass : Url.Parser.Query.Parser (Maybe String)
parseAdminPass =
    Url.Parser.Query.string "pass"


encode : Route -> String
encode route =
    Url.Builder.absolute
        (case route of
            HomepageRoute ->
                []

            Features ->
                [ "features" ]

            DataStore ->
                [ "datastore" ]

            EditData ->
                [ "editdata" ]

            Notes ->
                [ "notes" ]

            SignInRoute ->
                [ "signin" ]

            Brillig ->
                [ "brillig" ]

            AdminRoute ->
                [ "admin" ]

            Purchase ->
                [ "purchase" ]

            PaymentSuccessRoute _ ->
                [ Stripe.successPath ]

            PaymentCancelRoute ->
                [ Stripe.cancelPath ]
        )
        (case route of
            HomepageRoute ->
                []

            Features ->
                []

            DataStore ->
                []

            EditData ->
                []

            Notes ->
                []

            SignInRoute ->
                []

            Brillig ->
                []

            AdminRoute ->
                []

            Purchase ->
                []

            PaymentSuccessRoute maybeEmailAddress ->
                case maybeEmailAddress of
                    Just emailAddress ->
                        [ Url.Builder.string Stripe.emailAddressParameter (EmailAddress.toString emailAddress) ]

                    Nothing ->
                        []

            PaymentCancelRoute ->
                []
        )
