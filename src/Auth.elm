module Auth exposing (backendConfig, config, handleAuthSuccess, logout, renewSession, signin, updateFromBackend)

import Auth.Common exposing (Method(..), UserInfo)
import Auth.Flow exposing (signInRequested)
import Auth.Method.EmailMagicLink
import Dict exposing (Dict)
import Dict.Extra as Dict
import Env
import Lamdera exposing (ClientId, SessionId)
import Time
import Types exposing (..)


config : Auth.Common.Config FrontendMsg ToBackend BackendMsg ToFrontend FrontendModel BackendModel
config =
    { toBackend = AuthToBackend
    , toFrontend = AuthToFrontend
    , backendMsg = AuthBackendMsg
    , sendToFrontend = Lamdera.sendToFrontend
    , sendToBackend = Lamdera.sendToBackend
    , renewSession = renewSession
    , methods =
        [-- Auth.Method.EmailMagicLink.configuration placeHolder
        ]
    }


placeHolder =
    { initiateSignin = Debug.todo "initiateSignin", onAuthCallbackReceived = Debug.todo "onAuthCallbackReceived" }


yada =
    Debug.todo "foobar"



--onAuthCallbackReceived :
--        SessionId
--        -> ClientId
--        -> Url
--        -> AuthCode
--        -> State
--        -> Time.Posix
--        -> (BackendMsg -> backendMsg)
--        -> backendModel
--        -> ( backendModel, Cmd backendMsg )
--    }
--    ->
--        Method
--            frontendMsg
--            backendMsg
--            { frontendModel | authFlow : Flow, authRedirectBaseUrl : Url }
--            backendModel
----onAuthCallbackReceived sessionId clientId url authCode state time toBackendMsg { authFlow, authRedirectBaseUrl } backendModel =
----    case authFlow of
----        AuthFlowEmailMagicLink ->
----            Auth.Method.EmailMagicLink.onAuthCallbackReceived sessionId clientId url authCode state time toBackendMsg authRedirectBaseUrl backendModel


initiateSignin :
    SessionId
    -> ClientId
    -> backendModel
    -> { username : Maybe String }
    -> Time.Posix
    -> ( backendModel, Cmd backendMsg )
initiateSignin sessionId clientId model { username } _ =
    case username of
        -- TODO: this is a placeholder
        Just email ->
            ( model, Cmd.none )

        Nothing ->
            --  ( model, Auth.Flow.setError model "No email provided" )
            ( model, Cmd.none )


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


signin model userEmail =
    signInRequested "OAuthGoogle" model userEmail


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
