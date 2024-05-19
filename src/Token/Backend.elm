module Token.Backend exposing
    ( addUser
    , checkLogin
    , loginWithToken
    , requestSignUp
    , sendLoginEmail
    , signOut
    )

import AssocList
import Backend.Session
import BackendHelper
import BiDict
import Config
import Dict
import Duration
import Email.Html
import Email.Html.Attributes
import EmailAddress exposing (EmailAddress)
import Hex
import Http
import Id exposing (Id)
import Lamdera exposing (ClientId, SessionId)
import List.Extra
import List.Nonempty
import LocalUUID
import Postmark
import Process
import Quantity
import Sha256
import String.Nonempty exposing (NonemptyString)
import Task
import Time
import Token.LoginForm
import Token.Types
import Types exposing (BackendModel, BackendMsg(..), ToBackend(..), ToFrontend(..))
import User


sentLoginEmail : BackendModel -> SessionId -> ClientId -> ( BackendModel, Cmd BackendMsg )
sentLoginEmail model sessionId clientId =
    let
        _ =
            ( sessionId, clientId )

        maybeUsername : Maybe String
        maybeUsername =
            BiDict.get sessionId model.sessions

        maybeUserData : Maybe User.LoginData
        maybeUserData =
            Maybe.andThen (\username -> Dict.get username model.users) maybeUsername
                |> Maybe.map User.loginDataOfUser
    in
    ( model
    , Cmd.batch
        [ BackendHelper.getAtmosphericRandomNumbers
        , Backend.Session.reconnect model sessionId clientId
        , Lamdera.sendToFrontend clientId (GotKeyValueStore model.keyValueStore)

        ---, Lamdera.sendToFrontend sessionId (GotMessage "Connected")
        , Lamdera.sendToFrontend
            clientId
            (InitData
                { prices = model.prices
                , productInfo = model.products
                }
            )
        , case AssocList.get sessionId model.sessionDict of
            Just username ->
                case Dict.get username model.users of
                    Just user ->
                        -- Lamdera.sendToFrontend sessionId (LoginWithTokenResponse <| Ok <| Debug.log "@##! send loginDATA" <| User.loginDataOfUser user)
                        Process.sleep 60 |> Task.perform (always (AutoLogin sessionId (User.loginDataOfUser user)))

                    Nothing ->
                        Lamdera.sendToFrontend clientId (SignInWithTokenResponse (Err 0))

            Nothing ->
                Lamdera.sendToFrontend clientId (SignInWithTokenResponse (Err 1))
        ]
    )



-- requestSignUp : BackendModel -> ClientId -> g -> comparable -> String -> ( { a | localUuidData : Maybe LocalUUID.Data, time : b, users : Dict.Dict comparable { realname : c, username : d, email : EmailAddress, created_at : e, updated_at : e, id : String, role : User.Role, recentLoginEmails : List f } }, Cmd backendMsg )


requestSignUp model clientId realname username email =
    case model.localUuidData of
        Nothing ->
            ( model, Lamdera.sendToFrontend clientId (UserSignedIn Nothing) )

        -- TODO, need to signal & handle error
        Just uuidData ->
            case EmailAddress.fromString email of
                Nothing ->
                    ( model, Lamdera.sendToFrontend clientId (UserSignedIn Nothing) )

                Just validEmail ->
                    let
                        user =
                            { realname = realname
                            , username = username
                            , email = validEmail
                            , created_at = model.time
                            , updated_at = model.time
                            , id = LocalUUID.extractUUIDAsString uuidData
                            , role = User.UserRole
                            , recentLoginEmails = []
                            }
                    in
                    ( { model
                        | localUuidData = model.localUuidData |> Maybe.map LocalUUID.step
                        , users = Dict.insert username user model.users
                      }
                    , Lamdera.sendToFrontend clientId (UserSignedIn (Just user))
                    )


checkLogin model clientId sessionId =
    ( model
    , if Dict.isEmpty model.users then
        Cmd.batch
            [ Err Types.Sunny |> CheckSignInResponse |> Lamdera.sendToFrontend clientId
            ]

      else
        case getUserFromSessionId sessionId model of
            Just ( userId, user ) ->
                getLoginData userId user model
                    |> CheckSignInResponse
                    |> Lamdera.sendToFrontend clientId

            Nothing ->
                CheckSignInResponse (Err Types.LoadedBackendData) |> Lamdera.sendToFrontend clientId
    )


getLoginData : User.Id -> User.User -> Types.BackendModel -> Result Types.BackendDataStatus User.LoginData
getLoginData userId user_ model =
    User.loginDataOfUser user_ |> Ok


getUserFromSessionId : SessionId -> BackendModel -> Maybe ( User.Id, User.User )
getUserFromSessionId sessionId model =
    AssocList.get sessionId model.sessionDict
        |> Maybe.andThen (\userId -> Dict.get userId model.users |> Maybe.map (Tuple.pair userId))


loginWithToken :
    Time.Posix
    -> SessionId
    -> ClientId
    -> Int
    -> BackendModel
    -> ( BackendModel, Cmd BackendMsg )
loginWithToken time sessionId clientId loginCode model =
    case AssocList.get sessionId model.sessionDict of
        Just username ->
            case Dict.get username model.users of
                Just user ->
                    ( model, Lamdera.sendToFrontend sessionId (SignInWithTokenResponse <| Ok <| User.loginDataOfUser user) )

                Nothing ->
                    ( model, Lamdera.sendToFrontend clientId (SignInWithTokenResponse (Err loginCode)) )

        Nothing ->
            case AssocList.get sessionId model.pendingLogins of
                Just pendingLogin ->
                    if
                        (pendingLogin.loginAttempts < Token.LoginForm.maxLoginAttempts)
                            && (Duration.from pendingLogin.creationTime time |> Quantity.lessThan Duration.hour)
                    then
                        if loginCode == pendingLogin.loginCode then
                            case
                                Dict.toList model.users
                                    |> List.Extra.find (\( _, user ) -> user.email == pendingLogin.emailAddress)
                            of
                                Just ( userId, user ) ->
                                    ( { model
                                        | sessionDict = AssocList.insert sessionId userId model.sessionDict
                                        , pendingLogins = AssocList.remove sessionId model.pendingLogins
                                      }
                                    , User.loginDataOfUser user
                                        |> Ok
                                        |> SignInWithTokenResponse
                                        |> Lamdera.sendToFrontend sessionId
                                    )

                                Nothing ->
                                    ( model
                                    , Err loginCode
                                        |> SignInWithTokenResponse
                                        |> Lamdera.sendToFrontend clientId
                                    )

                        else
                            ( { model
                                | pendingLogins =
                                    AssocList.insert
                                        sessionId
                                        { pendingLogin | loginAttempts = pendingLogin.loginAttempts + 1 }
                                        model.pendingLogins
                              }
                            , Err loginCode |> SignInWithTokenResponse |> Lamdera.sendToFrontend clientId
                            )

                    else
                        ( model, Err loginCode |> SignInWithTokenResponse |> Lamdera.sendToFrontend clientId )

                Nothing ->
                    ( model, Err loginCode |> SignInWithTokenResponse |> Lamdera.sendToFrontend clientId )


addUser model clientId email realname username =
    case EmailAddress.fromString email of
        Nothing ->
            ( model, Lamdera.sendToFrontend clientId (SignInError <| "Invalid email: " ++ email) )

        Just validEmail ->
            addUser1 model clientId validEmail realname username


addUser1 model clientId email realname username =
    if emailNotRegistered email model.users then
        case Dict.get username model.users of
            Just _ ->
                ( model, Lamdera.sendToFrontend clientId (RegistrationError "That username is already registered") )

            Nothing ->
                addUser2 model clientId email realname username

    else
        ( model, Lamdera.sendToFrontend clientId (RegistrationError "That email is already registered") )


addUser2 model clientId email realname username =
    case model.localUuidData of
        Nothing ->
            let
                _ =
                    Nothing
            in
            ( model, Lamdera.sendToFrontend clientId (UserSignedIn Nothing) )

        Just uuidData ->
            let
                user =
                    { realname = realname
                    , username = username
                    , email = email
                    , created_at = model.time
                    , updated_at = model.time
                    , id = LocalUUID.extractUUIDAsString uuidData
                    , role = User.UserRole
                    , recentLoginEmails = []
                    }
            in
            ( { model
                | localUuidData = model.localUuidData |> Maybe.map LocalUUID.step
                , users = Dict.insert username user model.users
              }
            , Lamdera.sendToFrontend clientId (UserRegistered user)
            )


signOut model clientId userData =
    case userData of
        Just user ->
            ( { model | sessionDict = model.sessionDict |> AssocList.filter (\_ name -> name /= user.username) }
            , Lamdera.sendToFrontend clientId (UserSignedIn Nothing)
            )

        Nothing ->
            ( model, Cmd.none )


emailNotRegistered : EmailAddress -> Dict.Dict String User.User -> Bool
emailNotRegistered email users =
    Dict.filter (\_ user -> user.email == email) users |> Dict.isEmpty


userNameNotFound : String -> Dict.Dict String User.User -> Bool
userNameNotFound username users =
    case Dict.get username users of
        Nothing ->
            True

        Just _ ->
            False


sendLoginEmail : Types.BackendModel -> ClientId -> SessionId -> EmailAddress -> ( BackendModel, Cmd BackendMsg )
sendLoginEmail model clientId sessionId email =
    if emailNotRegistered email model.users then
        ( model, Lamdera.sendToFrontend clientId (SignInError "Sorry, you are not registered — please sign up for an account") )

    else
        registerAndSendLoginEmail model clientId sessionId email


registerAndSendLoginEmail : Types.BackendModel -> ClientId -> SessionId -> EmailAddress -> ( BackendModel, Cmd BackendMsg )
registerAndSendLoginEmail model clientId sessionId email =
    let
        ( model2, result ) =
            getLoginCode model.time model
    in
    case ( List.Extra.find (\( _, user ) -> user.email == email) (Dict.toList model.users), result ) of
        ( Just ( userId, user ), Ok loginCode ) ->
            if BackendHelper.shouldRateLimit model.time user then
                handleWithRateLimit model2 userId clientId

            else
                handleWithoutRateLimit model2 user userId email sessionId loginCode

        ( Nothing, Ok _ ) ->
            ( model, Lamdera.sendToFrontend clientId (SignInError "Sorry, you are not registered — please sign up for an account") )

        ( _, Err () ) ->
            addLog model.time (Token.Types.FailedToCreateLoginCode model.secretCounter) model


handleWithoutRateLimit model user userId email sessionId loginCode =
    ( { model
        | pendingLogins =
            AssocList.insert
                sessionId
                { creationTime = model.time, emailAddress = email, loginAttempts = 0, loginCode = loginCode }
                model.pendingLogins
        , users =
            Dict.insert
                userId
                { user | recentLoginEmails = model.time :: List.take 100 user.recentLoginEmails }
                model.users
      }
    , sendLoginEmail_ (SentLoginEmail model.time email) email loginCode
    )


handleWithRateLimit model2 userId clientId =
    let
        ( model3, cmd ) =
            addLog model2.time (Token.Types.LoginsRateLimited userId) model2
    in
    ( model3
    , Cmd.batch [ cmd, Lamdera.sendToFrontend clientId GetLoginTokenRateLimited ]
    )


getLoginCode : Time.Posix -> { a | secretCounter : Int } -> ( { a | secretCounter : Int }, Result () Int )
getLoginCode time model =
    case getUniqueId time model of
        ( model2, id ) ->
            ( model2, loginCodeFromId id )


loginCodeFromId : Id String -> Result () Int
loginCodeFromId id =
    case Id.toString id |> String.left Token.LoginForm.loginCodeLength |> Hex.fromString of
        Ok int ->
            case String.fromInt int |> String.left Token.LoginForm.loginCodeLength |> String.toInt of
                Just int2 ->
                    Ok int2

                Nothing ->
                    Err ()

        Err _ ->
            Err ()


getUniqueId : Time.Posix -> { a | secretCounter : Int } -> ( { a | secretCounter : Int }, Id String )
getUniqueId time model =
    ( { model | secretCounter = model.secretCounter + 1 }
    , Config.secretKey
        ++ ":"
        ++ String.fromInt model.secretCounter
        ++ ":"
        ++ String.fromInt (Time.posixToMillis time)
        |> Sha256.sha256
        |> Id.fromString
    )


sendLoginEmail_ :
    (Result Http.Error Postmark.PostmarkSendResponse -> backendMsg)
    -> EmailAddress
    -> Int
    -> Cmd backendMsg
sendLoginEmail_ msg emailAddress loginCode =
    { from = { name = "", email = noReplyEmailAddress }
    , to = List.Nonempty.fromElement { name = "", email = emailAddress }
    , subject = loginEmailSubject
    , body =
        Postmark.BodyBoth
            (loginEmailContent loginCode)
            ("Here is your code " ++ String.fromInt loginCode ++ "\n\nPlease type it in the XXX login page you were previously on.\n\nIf you weren't expecting this email you can safely ignore it.")
    , messageStream = "outbound"
    }
        |> Postmark.sendEmail msg Config.postmarkApiKey


loginEmailContent : Int -> Email.Html.Html
loginEmailContent loginCode =
    Email.Html.div
        [ Email.Html.Attributes.padding "8px" ]
        [ Email.Html.div [] [ Email.Html.text "Here is your code." ]
        , Email.Html.div
            [ Email.Html.Attributes.fontSize "36px"
            , Email.Html.Attributes.fontFamily "monospace"
            ]
            (String.fromInt loginCode
                |> String.toList
                |> List.map
                    (\char ->
                        Email.Html.span
                            [ Email.Html.Attributes.padding "0px 3px 0px 4px" ]
                            [ Email.Html.text (String.fromChar char) ]
                    )
                |> (\a ->
                        List.take (Token.LoginForm.loginCodeLength // 2) a
                            ++ [ Email.Html.span
                                    [ Email.Html.Attributes.backgroundColor "black"
                                    , Email.Html.Attributes.padding "0px 4px 0px 5px"
                                    , Email.Html.Attributes.style "vertical-align" "middle"
                                    , Email.Html.Attributes.fontSize "2px"
                                    ]
                                    []
                               ]
                            ++ List.drop (Token.LoginForm.loginCodeLength // 2) a
                   )
            )
        , Email.Html.text "Please type it in the login page you were previously on."
        , Email.Html.br [] []
        , Email.Html.br [] []
        , Email.Html.text "If you weren't expecting this email you can safely ignore it."
        ]


loginEmailSubject : NonemptyString
loginEmailSubject =
    String.Nonempty.NonemptyString 'L' "ogin code"


noReplyEmailAddress : EmailAddress
noReplyEmailAddress =
    EmailAddress.EmailAddress
        { localPart = "hello"
        , tags = []
        , domain = "elm-kitchen-sink.lamdera"
        , tld = [ "app" ]
        }


addLog : Time.Posix -> Token.Types.LogItem -> Types.BackendModel -> ( Types.BackendModel, Cmd msg )
addLog time logItem model =
    ( { model | log = model.log ++ [ ( time, logItem ) ] }, Cmd.none )
