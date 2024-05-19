module MagicToken.Auth exposing
    ( backendConfig
    , config
    , handleAuthSuccess
    , logout
    , renewSession
    , updateFromBackend
    )

import Auth.Common exposing (Method(..), UserInfo)
import Auth.Flow exposing (signInRequested)
import Auth.Method.EmailMagicLink
import Dict exposing (Dict)
import Dict.Extra as Dict
import Email.Html
import Email.Html.Attributes
import EmailAddress exposing (EmailAddress)
import Env
import Http
import Lamdera exposing (ClientId, SessionId)
import List.Nonempty
import MagicToken.Backend
import MagicToken.LoginForm
import Postmark
import SHA1
import String.Nonempty
import Task
import Time
import Types exposing (..)
import Url
import User


config : Auth.Common.Config FrontendMsg ToBackend BackendMsg ToFrontend FrontendModel BackendModel
config =
    { toBackend = AuthToBackend
    , toFrontend = AuthToFrontend
    , backendMsg = AuthBackendMsg
    , sendToFrontend = Lamdera.sendToFrontend
    , sendToBackend = Lamdera.sendToBackend
    , renewSession = renewSession
    , methods =
        [ Auth.Method.EmailMagicLink.configuration
            { initiateSignin = initiateEmailSignin
            , onAuthCallbackReceived = onEmailAuthCallbackReceived
            }
        ]
    }



--config : Auth.Common.Config FrontendMsg ToBackend BackendMsg ToFrontend FrontendModel BackendModel
--config =
--    { toBackend = AuthToBackend
--    , toFrontend = AuthToFrontend
--    , backendMsg = AuthBackendMsg
--    , sendToFrontend = Lamdera.sendToFrontend
--    , sendToBackend = Lamdera.sendToBackend
--    , methods =
--        [ Auth.Method.EmailMagicLink.configuration
--            { initiateSignin = initiateEmailSignin
--            , onAuthCallbackReceived = onEmailAuthCallbackReceived
--            }
--        , Auth.Method.OAuthGithub.configuration Config.githubAppClientId Config.githubAppClientSecret
--        , Auth.Method.OAuthGoogle.configuration Env.googleAppClientId Env.googleAppClientSecret
--        ]
--    , renewSession = renewSession
--    }


loginResponse : ClientId -> Cmd backendMsg
loginResponse clientId =
    Lamdera.sendToFrontend clientId
        (UserAuthResponse (Ok "An email has been sent if this account exists."))


initiateEmailSignin : SessionId -> ClientId -> BackendModel -> { f | username : Maybe String } -> Time.Posix -> ( BackendModel, Cmd BackendMsg )
initiateEmailSignin sessionId clientId model login now =
    case login.username of
        Nothing ->
            ( model, loginResponse clientId )

        Just username_ ->
            let
                username =
                    String.toLower username_
            in
            case model.users |> Dict.get username of
                Just user ->
                    ( { model
                        | pendingEmailAuths =
                            model.pendingEmailAuths
                                |> Dict.insert sessionId
                                    { created = now
                                    , sessionId = sessionId
                                    , username = user.username
                                    , fullname = user.fullname
                                    , token = "loginToken" -- TODO implement this
                                    }
                      }
                    , Cmd.batch
                        [ -- TODO: replace 1234 by the actual loginCode
                          MagicToken.Backend.sendLoginEmail_ (SentLoginEmail model.time user.email) user.email 1234
                        , loginResponse clientId
                        ]
                    )

                Nothing ->
                    ( model, loginResponse clientId )


onEmailAuthCallbackReceived :
    Auth.Common.SessionId
    -> Auth.Common.ClientId
    -> Url.Url
    -> Auth.Common.AuthCode
    -> Auth.Common.State
    -> Time.Posix
    -> (Auth.Common.BackendMsg -> BackendMsg)
    -> BackendModel
    -> ( BackendModel, Cmd BackendMsg )
onEmailAuthCallbackReceived sessionId clientId receivedUrl code state now asBackendMsg backendModel =
    case backendModel.pendingEmailAuths |> Dict.find (\k p -> p.token == code) of
        Just ( sessionIdRequester, pendingAuth ) ->
            { backendModel | pendingEmailAuths = backendModel.pendingEmailAuths |> Dict.remove sessionIdRequester }
                |> findOrRegisterUser
                    { currentClientId = clientId
                    , requestingSessionId = pendingAuth.sessionId
                    , username = pendingAuth.username
                    , fullname = pendingAuth.fullname
                    , authTokenM = Nothing
                    , now = pendingAuth.created
                    }

        Nothing ->
            ( backendModel
            , Lamdera.sendToFrontend sessionId
                (AuthToFrontend <| Auth.Common.AuthSessionChallenge Auth.Common.AuthSessionMissing)
            )


findOrRegisterUser :
    { currentClientId : Lamdera.ClientId
    , requestingSessionId : Lamdera.SessionId
    , username : String -- TODO: alias this
    , fullname : String -- TODO: alias this
    , authTokenM : Maybe Auth.Common.Token
    , now : Time.Posix
    }
    -> BackendModel
    -> ( BackendModel, Cmd BackendMsg )
findOrRegisterUser { currentClientId, requestingSessionId, username, fullname, authTokenM, now } model =
    case model.users |> Dict.get username of
        Just user ->
            let
                newSession : Session
                newSession =
                    { id = requestingSessionId
                    , created = now
                    , username = user.username
                    , masqueradedFrom = Nothing
                    , focusedOwner = OwnerUser user.username
                    , authToken = authTokenM
                    }
            in
            ( { model
                | sessions = Data.Session.updateSessions model (sessionIdFromString requestingSessionId) newSession
              }
            , Command.batch
                [ sendAuthSuccessWithAccount (sessionIdFromString requestingSessionId) user newSession model
                , bumpLastActive user
                ]
            )

        Nothing ->
            let
                newUser : User.User
                newUser =
                    { created = now
                    , lastActive = Time.millisToPosix 0
                    , username = username
                    , fullname = fullname
                    , roles = []
                    }

                --type alias User =
                --    { id : String
                --    , fullname : String
                --    , username : String
                --    , email : EmailAddress
                --    , created_at : Time.Posix
                --    , updated_at : Time.Posix
                --    , role : Role
                --    , recentLoginEmails : List Time.Posix
                --    }
                newSession : Session
                newSession =
                    { id = requestingSessionId
                    , created = now
                    , username = newUser.username
                    , masqueradedFrom = Nothing
                    , focusedOwner = OwnerUser newUser.username
                    , authToken = authTokenM
                    }
            in
            ( { model
                | sessions = Data.Session.updateSessions model (sessionIdFromString requestingSessionId) newSession
                , users = upsert newUser.username newUser model.users
              }
            , Command.batch
                [ sendAuthSuccessWithAccount (sessionIdFromString requestingSessionId) newUser newSession model
                , bumpLastActive newUser
                ]
            )



-- Auth.Common.Config FrontendMsg ToBackend BackendMsg ToFrontend FrontendModel BackendModel
-- backendConfig : BackendModel -> Auth.Flow.BackendUpdateConfig FrontendMsg BackendMsg ToFrontend FrontendModel BackendModel
--type alias Config frontendMsg toBackend backendMsg toFrontend frontendModel backendModel =
--    { toBackend : ToBackend -> toBackend
--    , toFrontend : ToFrontend -> toFrontend
--    , backendMsg : BackendMsg -> backendMsg
--    , sendToFrontend : SessionId -> toFrontend -> Cmd backendMsg
--    , sendToBackend : toBackend -> Cmd frontendMsg
--    , methods : List (Method frontendMsg backendMsg frontendModel backendModel)
--    , renewSession : SessionId -> ClientId -> backendModel -> ( backendModel, Cmd backendMsg )
--    }


backendConfig : BackendModel -> Auth.Flow.BackendUpdateConfig FrontendMsg BackendMsg ToFrontend FrontendModel BackendModel
backendConfig model =
    { asToFrontend = AuthToFrontend
    , asBackendMsg = AuthBackendMsg
    , sendToFrontend = Lamdera.sendToFrontend
    , backendModel = model
    , loadMethod = Auth.Flow.methodLoader config.methods
    , handleAuthSuccess = handleAuthSuccess model
    , isDev = True
    , renewSession = renewSession
    , logout = logout
    }


logout : SessionId -> ClientId -> BackendModel -> ( BackendModel, Cmd msg )
logout sessionId _ model =
    ( { model | sessions = model.sessions |> Dict.remove sessionId }, Cmd.none )


updateFromBackend authToFrontendMsg model =
    case authToFrontendMsg of
        Auth.Common.AuthInitiateSignin url ->
            Auth.Flow.startProviderSignin url model

        Auth.Common.AuthError err ->
            Auth.Flow.setError model err

        Auth.Common.AuthSessionChallenge _ ->
            ( model, Cmd.none )


renewSession : Lamdera.SessionId -> Lamdera.ClientId -> BackendModel -> ( BackendModel, Cmd BackendMsg )
renewSession _ _ model =
    ( model, Cmd.none )


handleAuthSuccess :
    BackendModel
    -> SessionId
    -> ClientId
    -> Auth.Common.UserInfo
    -> Auth.Common.MethodId
    -> Maybe Auth.Common.Token
    -> Time.Posix
    -> ( BackendModel, Cmd BackendMsg )
handleAuthSuccess backendModel sessionId clientId userInfo _ _ _ =
    -- TODO handle renewing sessions if that is something you need
    let
        sessionsWithOutThisOne : Dict SessionId UserInfo
        sessionsWithOutThisOne =
            Dict.removeWhen (\_ { email } -> email == userInfo.email) backendModel.sessions

        newSessions =
            Dict.insert sessionId userInfo sessionsWithOutThisOne

        response =
            AuthSuccess userInfo
    in
    ( { backendModel | sessions = newSessions }
    , Cmd.batch
        [ -- renewSession_ user_.id sessionId clientId
          Lamdera.sendToFrontend clientId response
        ]
    )
