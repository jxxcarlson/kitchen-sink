module Backend exposing (..)

import AssocList
import BackendHelper
import Dict
import Duration
import Email
import Env
import HttpHelpers
import Id exposing (Id)
import Lamdera exposing (ClientId, SessionId)
import LocalUUID
import Quantity
import Stripe.PurchaseForm as PurchaseForm exposing (PurchaseFormValidated(..))
import Stripe.Stripe as Stripe exposing (PriceId, ProductId(..), StripeSessionId)
import Task
import Time
import Types exposing (..)
import Untrusted


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }


init : ( BackendModel, Cmd BackendMsg )
init =
    ( { userDictionary = Dict.empty

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
      }
    , Cmd.batch
        [ Time.now |> Task.perform GotTime
        , Stripe.getPrices GotPrices
        , BackendHelper.getAtmosphericRandomNumbers
        ]
    )


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
                                        |> Debug.log "@@parts (1)"
                                        |> String.split "\t"
                                        |> List.map String.trim
                                        |> List.filterMap String.toInt
                                        |> Debug.log "@@parts (2)"

                                data =
                                    LocalUUID.initFrom4List parts
                            in
                            ( Just parts, data )
            in
            ( { model
                | randomAtmosphericNumbers = numbers |> Debug.log "@@RANDOM_NUMBERS"
                , localUuidData = data_ |> Debug.log "@@UUID_DATA"
              }
            , Cmd.none
            )

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
            let
                _ =
                    Debug.log "@@GotPrices" result
            in
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
            let
                _ =
                    Debug.log "@@GotPrices2" result
            in
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

        OnConnected _ clientId ->
            ( model
            , Cmd.batch
                [ BackendHelper.getAtmosphericRandomNumbers
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
            ( model, Cmd.none )

        SignUpRequest realname username email password ->
            ( model, Cmd.none )

        -- STRIPE
        CancelPurchaseRequest ->
            case BackendHelper.sessionIdToStripeSessionId sessionId model of
                Just stripeSessionId ->
                    ( model
                    , Stripe.expireSession stripeSessionId |> Task.attempt (ExpiredStripeSession stripeSessionId)
                    )

                Nothing ->
                    ( model, Cmd.none )

        AdminInspect pass ->
            if pass == Env.adminPassword then
                ( model, Lamdera.sendToFrontend clientId (AdminInspectResponse model) )

            else
                ( model, Cmd.none )
