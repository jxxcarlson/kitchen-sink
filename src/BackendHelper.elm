module BackendHelper exposing
    ( errorEmail
    , getAtmosphericRandomNumbers
    , getNewWeatherByCity
    , getValueWithKey
    , priceIdToProductId
    , purchaseSupportAddres
    , putKVPair
    , sessionIdToStripeSessionId
    , testUserDictionary
    )

import AssocList
import Dict
import EmailAddress
import Env
import Http
import Id
import Json.Encode
import Lamdera
import List.Extra
import List.Nonempty
import LocalUUID
import Postmark
import String.Nonempty
import Stripe.Stripe as Stripe exposing (PriceId, ProductId(..), StripeSessionId)
import Time
import Types
import Unsafe
import User
import Weather



-- DATA (JC)


putKVPair : String -> String -> Cmd Types.FrontendMsg
putKVPair key value =
    Http.post
        { url = Env.dataSource Env.mode ++ "/_r/putKeyValuePair"
        , body = Http.jsonBody <| encodeKVPair key value
        , expect = Http.expectWhatever Types.DataUploaded
        }


getValueWithKey : String -> Cmd Types.FrontendMsg
getValueWithKey key =
    Http.post
        { url = Env.dataSource Env.mode ++ "/_r/getKeyValuePair"
        , body = Http.jsonBody <| encodeKey key
        , expect = Http.expectString Types.GotValue
        }


encodeKVPair : String -> String -> Json.Encode.Value
encodeKVPair key value =
    Json.Encode.object
        [ ( "key", Json.Encode.string key )
        , ( "value", Json.Encode.string value )
        ]


encodeKey : String -> Json.Encode.Value
encodeKey key =
    Json.Encode.object
        [ ( "key", Json.Encode.string key )
        ]



-- OTHER


getNewWeatherByCity : Lamdera.ClientId -> String -> Cmd Types.BackendMsg
getNewWeatherByCity clientId city =
    Http.get
        { url = "https://api.openweathermap.org/data/2.5/weather?q=" ++ city ++ "&APPID=" ++ Env.weatherAPIKey
        , expect = Http.expectJson (Types.GotWeatherData clientId) Weather.weatherDataDecoder
        }


testUserDictionary : Dict.Dict String User.User
testUserDictionary =
    Dict.fromList
        [ ( "jxxcarlson"
          , { realname = "Jim Carlson"
            , username = "jxxcarlson"
            , email = "jxxcarlson@gmail.com"
            , password = "1234"
            , id = "661b76d8-eee8-42fb-a28d-cf8ada73f869"
            , created_at = Time.millisToPosix 1704237963000
            , updated_at = Time.millisToPosix 1704237963000
            , role = User.AdminRole
            }
          )
        , ( "aristotle"
          , { realname = "Aristotle"
            , username = "aristotle"
            , email = "aritotle@gmail.com"
            , password = "1234"
            , id = "38952d62-9772-4e5d-a927-b8e41b6ef2ed"
            , created_at = Time.millisToPosix 1704237963000
            , updated_at = Time.millisToPosix 1704237963000
            , role = User.UserRole
            }
          )
        ]


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
                { from = { name = "elm-camp", email = purchaseSupportAddres }
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


purchaseSupportAddres : EmailAddress.EmailAddress
purchaseSupportAddres =
    Unsafe.emailAddress "team@elm.camp"
