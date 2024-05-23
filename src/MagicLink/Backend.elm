module MagicLink.Backend exposing
    ( addNewUser
    , addUser
    , checkLogin
    , getLoginCode
    , requestSignUp
    , sendLoginEmail_
    , setMagicLink
    , setMagicLink_
    , signInWithMagicToken
    , signOut
    )

import AssocList
import Auth.Common
import Config
import Dict
import Duration
import Email.Html
import Email.Html.Attributes
import EmailAddress exposing (EmailAddress)
import Helper
import Hex
import Http
import Id exposing (Id)
import Lamdera exposing (ClientId, SessionId)
import List.Extra
import List.Nonempty
import LocalUUID
import MagicLink.LoginForm
import MagicLink.Types
import Postmark
import Quantity
import Sha256
import String.Nonempty exposing (NonemptyString)
import Time
import Types exposing (BackendModel, BackendMsg(..), ToBackend(..), ToFrontend(..))
import User


setMagicLink : BackendModel -> ClientId -> SessionId -> Auth.Common.ToBackend -> ( BackendModel, Cmd BackendMsg )
setMagicLink model clientId sessionId authMsg =
    case authMsg of
        Auth.Common.AuthSigninInitiated { methodId, baseUrl, username } ->
            case username of
                Just email_ ->
                    case EmailAddress.fromString email_ of
                        Just emailAddress ->
                            setMagicLink_ clientId sessionId email_ emailAddress model

                        Nothing ->
                            ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


addUser : BackendModel -> ClientId -> String -> String -> String -> ( BackendModel, Cmd BackendMsg )
addUser model clientId email realname username =
    case EmailAddress.fromString email of
        Nothing ->
            ( model, Lamdera.sendToFrontend clientId (SignInError <| "Invalid email: " ++ email) )

        Just validEmail ->
            addUser1 model clientId email validEmail realname username


checkLogin : BackendModel -> ClientId -> SessionId -> ( BackendModel, Cmd BackendMsg )
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


{-|

    Use magicToken, an Int, to sign in a user.

-}
signInWithMagicToken :
    Time.Posix
    -> SessionId
    -> ClientId
    -> Int
    -> BackendModel
    -> ( BackendModel, Cmd BackendMsg )
signInWithMagicToken time sessionId clientId magicToken model =
    case Dict.get sessionId model.pendingEmailAuths of
        Just pendingAuth ->
            handleExistingSession model pendingAuth.username sessionId clientId magicToken

        Nothing ->
            handleNoSession model time sessionId clientId magicToken


requestSignUp : BackendModel -> ClientId -> String -> String -> String -> ( BackendModel, Cmd BackendMsg )
requestSignUp model clientId fullname username email =
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
                            { fullname = fullname
                            , username = username
                            , email = validEmail
                            , emailString = email
                            , created_at = model.time
                            , updated_at = model.time
                            , id = LocalUUID.extractUUIDAsString uuidData
                            , roles = [ User.UserRole ]
                            , recentLoginEmails = []
                            }
                    in
                    ( { model
                        | localUuidData = model.localUuidData |> Maybe.map LocalUUID.step
                      }
                        |> addNewUser email user
                    , Lamdera.sendToFrontend clientId (UserSignedIn (Just user))
                    )


addNewUser email user model =
    { model
        | users = Dict.insert email user model.users
        , userNameToEmailString = Dict.insert user.username email model.userNameToEmailString
    }


getUserWithUsername : BackendModel -> User.Username -> Maybe User.User
getUserWithUsername model username =
    Dict.get username model.userNameToEmailString
        |> Maybe.andThen (\email -> Dict.get email model.users)


setMagicLink_ : ClientId -> SessionId -> User.EmailString -> EmailAddress -> BackendModel -> ( BackendModel, Cmd BackendMsg )
setMagicLink_ clientId sessionId emailString emailAddress model =
    -- TODO: is this safe?
    if emailNotRegistered emailString model.users then
        ( model, Lamdera.sendToFrontend clientId (SignInError "Sorry, you are not registered — please sign up for an account") )

    else
        setMagicTokenAndSendEmailToUser model clientId sessionId emailAddress


signOut : BackendModel -> ClientId -> Maybe User.LoginData -> ( BackendModel, Cmd BackendMsg )
signOut model clientId userData =
    case userData of
        Just user ->
            ( { model | sessionDict = model.sessionDict |> AssocList.filter (\_ name -> name /= user.username) }
            , Lamdera.sendToFrontend clientId (UserSignedIn Nothing)
            )

        Nothing ->
            ( model, Cmd.none )



-- HELPERS


handleExistingSession : BackendModel -> String -> SessionId -> ClientId -> Int -> ( BackendModel, Cmd BackendMsg )
handleExistingSession model username sessionId clientId magicToken =
    let
        _ =
            Debug.log "(4.3) @@handleExistingSession, username" <| getUserWithUsername model username
    in
    case getUserWithUsername model username of
        Just user ->
            ( model
            , Cmd.batch
                [ Lamdera.sendToFrontend sessionId
                    (SignInWithTokenResponse (Ok <| User.loginDataOfUser user))
                ]
            )

        Nothing ->
            ( model, Lamdera.sendToFrontend clientId (SignInWithTokenResponse (Err magicToken)) )


handleNoSession : BackendModel -> Time.Posix -> SessionId -> ClientId -> Int -> ( BackendModel, Cmd BackendMsg )
handleNoSession model time sessionId clientId magicToken =
    case AssocList.get sessionId model.pendingLogins of
        Just pendingLogin ->
            if
                (pendingLogin.loginAttempts < MagicLink.LoginForm.maxLoginAttempts)
                    && (Duration.from pendingLogin.creationTime time |> Quantity.lessThan Duration.hour)
            then
                if magicToken == pendingLogin.loginCode then
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
                            , Err magicToken
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
                    , Err magicToken |> SignInWithTokenResponse |> Lamdera.sendToFrontend clientId
                    )

            else
                ( model, Err magicToken |> SignInWithTokenResponse |> Lamdera.sendToFrontend clientId )

        Nothing ->
            ( model, Err magicToken |> SignInWithTokenResponse |> Lamdera.sendToFrontend clientId )


getLoginData : User.Id -> User.User -> Types.BackendModel -> Result Types.BackendDataStatus User.LoginData
getLoginData userId user_ model =
    User.loginDataOfUser user_ |> Ok


getUserFromSessionId : SessionId -> BackendModel -> Maybe ( User.Id, User.User )
getUserFromSessionId sessionId model =
    AssocList.get sessionId model.sessionDict
        |> Maybe.andThen (\userId -> Dict.get userId model.users |> Maybe.map (Tuple.pair userId))



-- HELPERS FOR ADDUSER


addUser1 : BackendModel -> ClientId -> User.EmailString -> EmailAddress -> String -> String -> ( BackendModel, Cmd BackendMsg )
addUser1 model clientId emailString emailAddress realname username =
    if emailNotRegistered emailString model.users then
        case Dict.get username model.users of
            Just _ ->
                ( model, Lamdera.sendToFrontend clientId (RegistrationError "That username is already registered") )

            Nothing ->
                addUser2 model clientId emailString emailAddress realname username

    else
        ( model, Lamdera.sendToFrontend clientId (RegistrationError "That email is already registered") )


addUser2 model clientId emailString emailAddress realname username =
    case model.localUuidData of
        Nothing ->
            ( model, Lamdera.sendToFrontend clientId (UserSignedIn Nothing) )

        Just uuidData ->
            let
                user =
                    { fullname = realname
                    , username = username
                    , email = emailAddress
                    , emailString = emailString
                    , created_at = model.time
                    , updated_at = model.time
                    , id = LocalUUID.extractUUIDAsString uuidData
                    , roles = [ User.UserRole ]
                    , recentLoginEmails = []
                    }
            in
            ( { model
                | localUuidData = model.localUuidData |> Maybe.map LocalUUID.step
              }
                |> addNewUser emailString user
            , Lamdera.sendToFrontend clientId (UserRegistered user)
            )



-- STUFF


emailNotRegistered : User.EmailString -> Dict.Dict String User.User -> Bool
emailNotRegistered email users =
    case Dict.get email users of
        Nothing ->
            True

        Just _ ->
            False


userNameNotFound : String -> Dict.Dict String User.User -> Bool
userNameNotFound username users =
    case Dict.get username users of
        Nothing ->
            True

        Just _ ->
            False


setMagicTokenAndSendEmailToUser : Types.BackendModel -> ClientId -> SessionId -> EmailAddress -> ( BackendModel, Cmd BackendMsg )
setMagicTokenAndSendEmailToUser model clientId sessionId email =
    let
        ( model2, result ) =
            getLoginCode model.time model
    in
    case ( List.Extra.find (\( _, user ) -> user.email == email) (Dict.toList model.users), result ) of
        ( Just ( userId, user ), Ok loginCode ) ->
            if Helper.shouldRateLimit model.time user then
                -- TODO: does this branch do what it should?
                handleWithRateLimit model2 userId clientId

            else
                handleWithoutRateLimit model2 user userId email sessionId loginCode

        ( Nothing, Ok _ ) ->
            ( model, Lamdera.sendToFrontend clientId (SignInError "Sorry, you are not registered — please sign up for an account") )

        ( _, Err () ) ->
            addLog model.time (MagicLink.Types.FailedToCreateLoginCode model.secretCounter) model


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
            addLog model2.time (MagicLink.Types.LoginsRateLimited userId) model2
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
    case Id.toString id |> String.left MagicLink.LoginForm.loginCodeLength |> Hex.fromString of
        Ok int ->
            case String.fromInt int |> String.left MagicLink.LoginForm.loginCodeLength |> String.toInt of
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
    , to = List.Nonempty.fromElement { name = "", email = emailAddress } |> Debug.log "@@TO-FIELD"
    , subject = loginEmailSubject
    , body =
        Postmark.BodyBoth
            (loginEmailContent loginCode)
            ("Here is your code " ++ (String.fromInt loginCode |> Debug.log "@@LOGIN-CODE") ++ "\n\nPlease type it in the XXX login page you were previously on.\n\nIf you weren't expecting this email you can safely ignore it.")
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
                        List.take (MagicLink.LoginForm.loginCodeLength // 2) a
                            ++ [ Email.Html.span
                                    [ Email.Html.Attributes.backgroundColor "black"
                                    , Email.Html.Attributes.padding "0px 4px 0px 5px"
                                    , Email.Html.Attributes.style "vertical-align" "middle"
                                    , Email.Html.Attributes.fontSize "2px"
                                    ]
                                    []
                               ]
                            ++ List.drop (MagicLink.LoginForm.loginCodeLength // 2) a
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


addLog : Time.Posix -> MagicLink.Types.LogItem -> Types.BackendModel -> ( Types.BackendModel, Cmd msg )
addLog time logItem model =
    ( { model | log = model.log ++ [ ( time, logItem ) ] }, Cmd.none )
