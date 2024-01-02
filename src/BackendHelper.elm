module BackendHelper exposing
    ( elmCampEmailAddress
    , errorEmail
    , getAtmosphericRandomNumbers
    , priceIdToProductId
    , sessionIdToStripeSessionId
    )

import AssocList
import EmailAddress
import Env
import Http
import Id
import Lamdera
import List.Extra
import List.Nonempty
import LocalUUID
import Postmark
import String.Nonempty
import Stripe.Stripe as Stripe exposing (PriceId, ProductId(..), StripeSessionId)
import Types
import Unsafe


getAtmosphericRandomNumbers : Cmd Types.BackendMsg
getAtmosphericRandomNumbers =
    Http.get
        { url = LocalUUID.randomNumberUrl 4 9
        , expect = Http.expectString Types.GotAtmosphericRandomNumbers
        }



-- STRIPE


sessionIdToStripeSessionId : Lamdera.SessionId -> Types.BackendModel -> Maybe (Id.Id StripeSessionId)
sessionIdToStripeSessionId sessionId model =
    AssocList.toList model.pendingOrder
        |> List.Extra.findMap
            (\( stripeSessionId, data ) ->
                if data.sessionId == sessionId then
                    Just stripeSessionId

                else
                    Nothing
            )


priceIdToProductId : Types.BackendModel -> Id.Id PriceId -> Maybe (Id.Id ProductId)
priceIdToProductId model priceId =
    AssocList.toList model.prices
        |> List.Extra.findMap
            (\( productId, prices ) ->
                if prices.priceId == priceId then
                    Just productId

                else
                    Nothing
            )


errorEmail : String -> Cmd Types.BackendMsg
errorEmail errorMessage =
    case List.Nonempty.fromList Env.developerEmails of
        Just to ->
            Postmark.sendEmail
                Types.ErrorEmailSent
                Env.postmarkApiKey
                { from = { name = "elm-camp", email = elmCampEmailAddress }
                , to = List.Nonempty.map (\email -> { name = "", email = email }) to
                , subject =
                    String.Nonempty.NonemptyString 'E'
                        ("rror occurred "
                            ++ (if Env.isProduction then
                                    "(prod)"

                                else
                                    "(dev)"
                               )
                        )
                , body = Postmark.BodyText errorMessage
                , messageStream = "outbound"
                }

        Nothing ->
            Cmd.none


elmCampEmailAddress : EmailAddress.EmailAddress
elmCampEmailAddress =
    Unsafe.emailAddress "team@elm.camp"
