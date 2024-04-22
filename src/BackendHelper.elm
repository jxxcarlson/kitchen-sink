module BackendHelper exposing
    ( addLog
    , errorEmail
    , getAtmosphericRandomNumbers
    , getLoginData
    , getLoginData2
    , getNewWeatherByCity
    , priceIdToProductId
    , purchaseSupportAddres
    , sessionIdToStripeSessionId
    , shouldRateLimit
    , testUserDictionary
    )

import AssocList
import Config
import Dict
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
import Time
import Token.Types
import Types
import Unsafe
import User
import Weather



-- TOKEN


getLoginData : User.Id -> User.User -> Types.BackendModel -> Result Types.BackendDataStatus User.LoginData
getLoginData userId user_ model =
    User.loginDataOfUser user_ |> Ok



-- TODO: this is a hack based on a lack of understanding of what is going on.
-- in Martin's code.


getLoginData2 : User.Id -> User.User -> Types.BackendModel -> Result Int User.LoginData
getLoginData2 userId user_ model =
    User.loginDataOfUser user_ |> Ok



-- Ok { userId = userId }


addLog : Time.Posix -> Token.Types.LogItem -> Types.BackendModel -> ( Types.BackendModel, Cmd msg )
addLog time logItem model =
    ( { model | log = model.log ++ [ ( time, logItem ) ] }, Cmd.none )



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
            , email = EmailAddress.EmailAddress { domain = "gmail", localPart = "jxxcarlson", tags = [], tld = [ "com" ] }
            , id = "661b76d8-eee8-42fb-a28d-cf8ada73f869"
            , created_at = Time.millisToPosix 1704237963000
            , updated_at = Time.millisToPosix 1704237963000
            , role = User.AdminRole
            , recentLoginEmails = []
            }
          )
        , ( "aristotle"
          , { realname = "Aristotle"
            , username = "aristotle"
            , email = EmailAddress.EmailAddress { domain = "gmail", localPart = "aristotle", tags = [], tld = [ "com" ] }
            , id = "38952d62-9772-4e5d-a927-b8e41b6ef2ed"
            , created_at = Time.millisToPosix 1704237963000
            , updated_at = Time.millisToPosix 1704237963000
            , role = User.UserRole
            , recentLoginEmails = []
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
                Types.AuthenticationConfirmationEmailSent
                Config.postmarkApiKey
                { from = { name = "elm-camp", email = purchaseSupportAddres }
                , to = List.Nonempty.map (\email -> { name = "", email = email }) to
                , subject =
                    String.Nonempty.NonemptyString 'E' "rror occurred "
                , body = Postmark.BodyText errorMessage
                , messageStream = "outbound"
                }

        Nothing ->
            Cmd.none


purchaseSupportAddres : EmailAddress.EmailAddress
purchaseSupportAddres =
    Unsafe.emailAddress "team@elm.camp"


shouldRateLimit time user =
    False
