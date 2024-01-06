module Backend exposing (app, init, subscriptions, update, updateFromFrontend)

import AssocList
import BackendHelper
import BiDict
import Dict
import Duration
import Email
import HttpHelpers
import Id exposing (Id)
import Lamdera exposing (ClientId, SessionId)
import LocalUUID
import Predicate
import Quantity
import Set exposing (Set)
import Stripe.PurchaseForm as PurchaseForm exposing (PurchaseFormValidated(..))
import Stripe.Stripe as Stripe exposing (PriceId, ProductId(..), StripeSessionId)
import Task
import Time
import Types exposing (BackendModel, BackendMsg(..), ToBackend(..), ToFrontend(..))
import Untrusted
import User


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }


init : ( BackendModel, Cmd BackendMsg )
init =
    ( { userDictionary = BackendHelper.testUserDictionary
      , sessions = BiDict.empty

      --STRIPE
      , orders = AssocList.empty
      , pendingOrder = AssocList.empty
      , expiredOrders = AssocList.empty
      , prices = AssocList.empty
      , time = Time.millisToPosix 0
      , randomAtmosphericNumbers = Nothing
      , localUuidData = Nothing
      , products =
            AssocList.fromList
                [ ( Id.fromString "prod_NwykP5NQq7KEJt"
                  , { name = "Basic Package"
                    , description = "100 image credits"
                    }
                  )
                , ( Id.fromString "prod_Nwym3t9YYdA0DD"
                  , { name = "Jumbo Package"
                    , description = "200 image credits"
                    }
                  )
                ]

      -- EXPERIMENTAL
      , keyValueStore =
            Dict.fromList
                [ ( "foo", { key = "foo", value = "1234", curator = "jxxcarson", created_at = Time.millisToPosix 1704555131, updated_at = Time.millisToPosix 1704555131 } )
                , ( "bar", { key = "bar", value = "5778", curator = "jxxcarson", created_at = Time.millisToPosix 1704555131, updated_at = Time.millisToPosix 1704555131 } )
                , ( "hubble1929", { key = "hubble1929", value = hubble1929, curator = "jxxcarson", created_at = Time.millisToPosix 1704555131, updated_at = Time.millisToPosix 1704555131 } )
                ]
      }
    , Cmd.batch
        [ Time.now |> Task.perform GotTime
        , Stripe.getPrices GotPrices
        , BackendHelper.getAtmosphericRandomNumbers
        ]
    )


hubble1929 =
    """# Hubble's 1929 redshift-distance data
# header: name,distance,red-shift
# units: Mpc,km/s
# ----------------------------------------
S.Mag,0.032,170
L.Mag,0.034,290
NGC.6822,0.214,-130
NGC.598,0.263,-70
NGC.221,0.275,-185
NGC.224,0.275,-220
NGC.5457,0.45,200
NGC.4736,0.5,290
NGC.5194,0.5,270
NGC.4449,0.63,200
NGC.4214,0.8,300
NGC.3031,0.9,-30
NGC.3627,0.9,650
NGC.4826,0.9,150
NGC.5236,0.9,500
NGC.1068,1.0,920
NGC.5055,1.1,450
NGC.7331,1.1,500
NGC.4258,1.4,500
NGC.4151,1.7,960
NGC.4382,2.0,500
NGC.4472,2.0,850
NGC.4486,2.0,800
NGC.4649,2.0,1090
"""


subscriptions : BackendModel -> Sub BackendMsg
subscriptions _ =
    Sub.batch
        [ Time.every (1000 * 60 * 15) GotTime
        , Lamdera.onConnect OnConnected
        ]


update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
update msg model =
    -- Replace existing randomAtmosphericNumber with a new one if possible
    (case msg of
        GotAtmosphericRandomNumbers tryRandomAtmosphericNumbers ->
            let
                ( numbers, data_ ) =
                    case tryRandomAtmosphericNumbers of
                        Err _ ->
                            ( model.randomAtmosphericNumbers, model.localUuidData )

                        Ok rns ->
                            let
                                parts =
                                    rns
                                        |> String.split "\t"
                                        |> List.map String.trim
                                        |> List.filterMap String.toInt

                                data =
                                    LocalUUID.initFrom4List parts
                            in
                            ( Just parts, data )
            in
            ( { model
                | randomAtmosphericNumbers = numbers
                , localUuidData = data_
                , userDictionary =
                    if Dict.isEmpty model.userDictionary then
                        BackendHelper.testUserDictionary

                    else
                        model.userDictionary
              }
            , Cmd.none
            )

        GotWeatherData clientId result ->
            ( model, Lamdera.sendToFrontend clientId (Types.ReceivedWeatherData result) )

        GotTime time ->
            let
                ( expiredOrders, remainingOrders ) =
                    AssocList.partition
                        (\_ order -> Duration.from order.submitTime time |> Quantity.greaterThan (Duration.minutes 30))
                        model.pendingOrder
            in
            ( { model
                | time = time
                , pendingOrder = remainingOrders
                , expiredOrders = AssocList.union expiredOrders model.expiredOrders
              }
            , Cmd.batch
                [ Stripe.getPrices GotPrices
                , List.map
                    (\stripeSessionId ->
                        Stripe.expireSession stripeSessionId
                            |> Task.attempt (ExpiredStripeSession stripeSessionId)
                    )
                    (AssocList.keys expiredOrders)
                    |> Cmd.batch
                ]
            )

        GotPrices result ->
            case result of
                Ok prices ->
                    ( { model
                        | prices =
                            List.filterMap
                                (\price ->
                                    if price.isActive then
                                        Just ( price.productId, { priceId = price.priceId, price = price.price } )

                                    else
                                        Nothing
                                )
                                prices
                                |> AssocList.fromList
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( model, BackendHelper.errorEmail ("GotPrices failed: " ++ HttpHelpers.httpErrorToString error) )

        GotPrices2 clientId result ->
            case result of
                Ok prices ->
                    ( { model
                        | prices =
                            List.filterMap
                                (\price ->
                                    if price.isActive then
                                        Just ( price.productId, { priceId = price.priceId, price = price.price } )

                                    else
                                        Nothing
                                )
                                prices
                                |> AssocList.fromList
                      }
                    , Lamdera.sendToFrontend
                        clientId
                        (InitData
                            { prices = model.prices
                            , productInfo = model.products
                            }
                        )
                    )

                Err error ->
                    ( model, BackendHelper.errorEmail ("GotPrices failed: " ++ HttpHelpers.httpErrorToString error) )

        OnConnected sessionId clientId ->
            let
                maybeUsername =
                    BiDict.get sessionId model.sessions

                maybeUser =
                    Maybe.andThen (\username -> Dict.get username model.userDictionary) maybeUsername
            in
            ( model
            , Cmd.batch
                [ BackendHelper.getAtmosphericRandomNumbers
                , Lamdera.sendToFrontend clientId (UserSignedIn maybeUser)
                , Lamdera.sendToFrontend clientId (GotKeyValueStore model.keyValueStore)
                , Lamdera.sendToFrontend
                    clientId
                    (InitData
                        { prices = model.prices
                        , productInfo = model.products
                        }
                    )
                ]
            )

        CreatedCheckoutSession sessionId clientId priceId purchaseForm result ->
            case result of
                Ok ( stripeSessionId, submitTime ) ->
                    let
                        existingStripeSessions =
                            AssocList.filter
                                (\_ data -> data.sessionId == sessionId)
                                model.pendingOrder
                                |> AssocList.keys
                    in
                    ( { model
                        | pendingOrder =
                            AssocList.insert
                                stripeSessionId
                                { priceId = priceId
                                , submitTime = submitTime
                                , form = purchaseForm
                                , sessionId = sessionId
                                }
                                model.pendingOrder
                      }
                    , Cmd.batch
                        [ SubmitFormResponse (Ok stripeSessionId) |> Lamdera.sendToFrontend clientId
                        , List.map
                            (\stripeSessionId2 ->
                                Stripe.expireSession stripeSessionId2
                                    |> Task.attempt (ExpiredStripeSession stripeSessionId2)
                            )
                            existingStripeSessions
                            |> Cmd.batch
                        ]
                    )

                Err error ->
                    let
                        err =
                            "CreatedCheckoutSession failed: " ++ HttpHelpers.httpErrorToString error
                    in
                    ( model
                    , Cmd.batch
                        [ SubmitFormResponse (Err err) |> Lamdera.sendToFrontend clientId
                        , BackendHelper.errorEmail err
                        , Lamdera.sendToFrontend clientId (GotMessage err)
                        ]
                    )

        ExpiredStripeSession stripeSessionId result ->
            case result of
                Ok () ->
                    case AssocList.get stripeSessionId model.pendingOrder of
                        Just expired ->
                            ( { model
                                | pendingOrder = AssocList.remove stripeSessionId model.pendingOrder
                                , expiredOrders = AssocList.insert stripeSessionId expired model.expiredOrders
                              }
                            , Cmd.none
                            )

                        Nothing ->
                            ( model, Cmd.none )

                Err error ->
                    ( model, BackendHelper.errorEmail ("ExpiredStripeSession failed: " ++ HttpHelpers.httpErrorToString error ++ " stripeSessionId: " ++ Id.toString stripeSessionId) )

        ConfirmationEmailSent stripeSessionId result ->
            case AssocList.get stripeSessionId model.orders of
                Just order ->
                    case result of
                        Ok data ->
                            ( { model
                                | orders =
                                    AssocList.insert
                                        stripeSessionId
                                        { order | emailResult = Email.EmailSuccess data }
                                        model.orders
                              }
                            , Cmd.none
                            )

                        Err error ->
                            ( { model
                                | orders =
                                    AssocList.insert
                                        stripeSessionId
                                        { order | emailResult = Email.EmailFailed error }
                                        model.orders
                              }
                            , BackendHelper.errorEmail ("Confirmation email failed: " ++ HttpHelpers.httpErrorToString error)
                            )

                Nothing ->
                    ( model
                    , BackendHelper.errorEmail ("StripeSessionId not found for confirmation email: " ++ Id.toString stripeSessionId)
                    )

        ErrorEmailSent _ ->
            ( model, Cmd.none )
    )
        |> (\( newModel, cmd ) ->
                ( newModel, Cmd.batch [ cmd ] )
           )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        -- STRIPE
        RenewPrices ->
            ( model, Stripe.getPrices (GotPrices2 clientId) )

        SubmitFormRequest priceId a ->
            case Untrusted.purchaseForm a of
                Just purchaseForm ->
                    case BackendHelper.priceIdToProductId model priceId of
                        Just _ ->
                            let
                                validProductAndForm : Bool
                                -- TODO Very bad code! Get rid of it!!
                                validProductAndForm =
                                    True
                            in
                            if validProductAndForm then
                                ( model
                                , Time.now
                                    |> Task.andThen
                                        (\now ->
                                            Stripe.createCheckoutSession
                                                { priceId = priceId
                                                , emailAddress = PurchaseForm.billingEmail purchaseForm
                                                , now = now
                                                , expiresInMinutes = 30
                                                }
                                                |> Task.andThen (\res -> Task.succeed ( res, now ))
                                        )
                                    |> Task.attempt (CreatedCheckoutSession sessionId clientId priceId purchaseForm)
                                )

                            else
                                ( model, SubmitFormResponse (Err "Form was invalid, please fix the issues & try again.") |> Lamdera.sendToFrontend clientId )

                        _ ->
                            ( model, SubmitFormResponse (Err "Invalid product item, please refresh & try again.") |> Lamdera.sendToFrontend clientId )

                _ ->
                    ( model, Cmd.none )

        -- USER
        SignInRequest username password ->
            let
                maybeUser =
                    Dict.get username model.userDictionary

                addSession : String -> BackendModel -> BackendModel
                addSession username_ model_ =
                    { model_ | sessions = BiDict.insert sessionId username_ model_.sessions }
            in
            if Just password == Maybe.map .password maybeUser then
                ( model |> addSession username
                , Cmd.batch
                    [ Lamdera.sendToFrontend clientId (GotMessage "Sign in successful!")
                    , Lamdera.sendToFrontend clientId (UserSignedIn maybeUser)
                    ]
                )

            else
                ( model
                , Cmd.batch
                    [ Lamdera.sendToFrontend clientId (UserSignedIn Nothing)
                    , Lamdera.sendToFrontend clientId (GotMessage "Username and password do not match. ")
                    ]
                )

        SignOutRequest username ->
            let
                activeSessions : List SessionId
                activeSessions =
                    BiDict.getReverse username model.sessions
                        |> Set.toList

                removeSessions : List SessionId -> BackendModel -> BackendModel
                removeSessions activeSessions_ model_ =
                    List.foldl
                        (\sessionId_ model__ ->
                            { model__ | sessions = BiDict.remove sessionId_ model__.sessions }
                        )
                        model_
                        activeSessions_
            in
            ( model |> removeSessions activeSessions
            , Lamdera.sendToFrontend clientId (UserSignedIn Nothing)
            )

        SignUpRequest realname username email password ->
            case model.localUuidData of
                Nothing ->
                    ( model, Lamdera.sendToFrontend clientId (UserSignedIn Nothing) )

                -- TODO, need to signal & handle error
                Just uuidData ->
                    let
                        user =
                            { realname = realname
                            , username = username
                            , email = email
                            , password = password
                            , created_at = model.time
                            , updated_at = model.time
                            , id = LocalUUID.extractUUIDAsString uuidData
                            , role = User.UserRole
                            }
                    in
                    ( { model
                        | localUuidData = model.localUuidData |> Maybe.map LocalUUID.step
                        , userDictionary = Dict.insert username user model.userDictionary
                      }
                    , Lamdera.sendToFrontend clientId (UserSignedIn (Just user))
                    )

        -- STRIPE
        CancelPurchaseRequest ->
            case BackendHelper.sessionIdToStripeSessionId sessionId model of
                Just stripeSessionId ->
                    ( model
                    , Stripe.expireSession stripeSessionId |> Task.attempt (ExpiredStripeSession stripeSessionId)
                    )

                Nothing ->
                    ( model, Cmd.none )

        AdminInspect maybeUser ->
            --if Predicate.isAdmin maybeUser then
            --    ( model, Lamdera.sendToFrontend clientId (AdminInspectResponse model) )
            --
            --else
            --    ( model, Cmd.none )
            ( model, Lamdera.sendToFrontend clientId (AdminInspectResponse model) )

        -- EXAMPLES
        GetWeatherData city ->
            ( model, BackendHelper.getNewWeatherByCity clientId city )

        -- DATA
        GetKeyValueStore ->
            ( model, Lamdera.sendToFrontend clientId (GotKeyValueStore model.keyValueStore) )
