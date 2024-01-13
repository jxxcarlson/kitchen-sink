module AuthImplementation exposing (backendConfig, config)

import Auth.Common
import Auth.Flow
import Auth.Method.OAuthGoogle
import Dict
import Dict.Extra as Dict
import Env
import Lamdera
import Task
import Time
import Types
    exposing
        ( BackendModel
        , BackendMsg(..)
        , FrontendMsg(..)
        , LoadedModel
        , ToBackend(..)
        , ToFrontend(..)
        )


googleOAuthClientId : String
googleOAuthClientId =
    "google-oauth-client-id"


googleOAuthClientSecret : String
googleOAuthClientSecret =
    "googleOAuthClientSecret"


config : Auth.Common.Config FrontendMsg ToBackend BackendMsg ToFrontend LoadedModel BackendModel
config =
    -- TODO: I believe I have to refactor to accept the custom type FrontendModel and not the LoadedModel record
    --       in order to properly handle loading case???
    { toBackend = Auth_ToBackend
    , toFrontend = Auth_ToFrontend
    , backendMsg = Auth_BackendMsg
    , sendToFrontend = Lamdera.sendToFrontend
    , sendToBackend = Lamdera.sendToBackend
    , methods =
        [ Auth.Method.OAuthGoogle.configuration googleOAuthClientId googleOAuthClientSecret

        -- TODO: GitHub provider
        --, Auth.Method.OAuthGithub.configuration Config.githubOAuthClientId Config.githubOAuthClientSecret
        ]
    , renewSession = renewSession

    --, logout = logout
    }


backendConfig model =
    { asToFrontend = Auth_ToFrontend
    , asBackendMsg = Auth_BackendMsg
    , sendToFrontend = Lamdera.sendToFrontend
    , backendModel = model
    , loadMethod = Auth.Flow.methodLoader config.methods
    , handleAuthSuccess = handleAuthSuccess model
    , isDev = Env.mode == Env.Development
    , renewSession = renewSession
    , logout = logout
    }


handleAuthSuccess :
    BackendModel
    -> Lamdera.SessionId
    -> Lamdera.ClientId
    -> Auth.Common.UserInfo
    -> Maybe Auth.Common.Token
    -> Time.Posix
    -> ( BackendModel, Cmd BackendMsg )
handleAuthSuccess backendModel sessionId clientId userInfo authToken now =
    ( backendModel, Cmd.none )


logout : String -> String -> BackendModel -> ( BackendModel, Cmd BackendMsg )
logout sessionId clientId model =
    ( model, Cmd.none )


renewSession : String -> String -> BackendModel -> ( BackendModel, Cmd BackendMsg )
renewSession sessionId clientId backendModel =
    ( backendModel, Cmd.none )



--updateFromBackend :
--    Auth.Common.ToFrontend
--    -> FrontendModel_Loaded
--    -> ( FrontendModel_Loaded, Cmd msg )
--updateFromBackend authToFrontendMsg model =
--    case authToFrontendMsg of
--        Auth.Common.AuthInitiateSignin url ->
--            Auth.Flow.startProviderSignin url model
--
--        Auth.Common.AuthError err ->
--            Auth.Flow.setError model err
--
--        Auth.Common.AuthSessionChallenge reason ->
--            -- TODO: I don't know what this is, but Mario's code had this todo statement, I'm putting a noop here in the meantime
--            --Debug.todo "Auth.Common.AuthSessionChallenge"
--            ( model, Cmd.none )
--
--
--handleAuthSuccess :
--    BackendModel
--    -> Lamdera.SessionId
--    -> Lamdera.ClientId
--    -> Auth.Common.UserInfo
--    -> Maybe Auth.Common.Token
--    -> Time.Posix
--    -> ( BackendModel, Cmd BackendMsg )
--handleAuthSuccess backendModel sessionId clientId userInfo authToken now =
--    let
--        renewSession_ email sid cid =
--            Time.now |> Task.perform (RenewSession email sid cid)
--    in
--    if backendModel.users |> Dict.any (\k u -> u.email == userInfo.email) then
--        let
--            ( response, cmd ) =
--                backendModel.users
--                    |> Dict.find (\k u -> u.email == userInfo.email)
--                    |> Maybe.map
--                        (\( k, u ) ->
--                            ( Success (Api.User.toUser u), renewSession_ u.id sessionId clientId )
--                        )
--                    |> Maybe.withDefault ( Failure [ "email or password is invalid" ], Cmd.none )
--        in
--        ( backendModel
--        , Cmd.batch
--            [ Lamdera.sendToFrontend clientId (PageMsg (Gen.Msg.Login__Provider___Callback (Pages.Login.Provider_.Callback.GotUser response)))
--            , cmd
--            ]
--        )
--
--    else
--        let
--            user_ : UserFull
--            user_ =
--                { id = Dict.size backendModel.users
--                , email = userInfo.email
--                , username = userInfo.username |> Maybe.withDefault "anonymous"
--                , bio = Nothing
--                , image = "https://static.productionready.io/images/smiley-cyrus.jpg"
--                }
--
--            response =
--                Success (Api.User.toUser user_)
--        in
--        ( { backendModel | users = backendModel.users |> Dict.insert user_.id user_ }
--        , Cmd.batch
--            [ renewSession_ user_.id sessionId clientId
--            , Lamdera.sendToFrontend clientId (PageMsg (Gen.Msg.Login__Provider___Callback (Pages.Login.Provider_.Callback.GotUser response)))
--            ]
--        )
--
--
--renewSession : String -> String -> BackendModel -> ( BackendModel, Cmd BackendMsg )
--renewSession sessionId clientId model =
--    model
--        |> getSessionUser sessionId
--        |> Maybe.map (\user -> ( model, Lamdera.sendToFrontend clientId (ActiveSession (Api.User.toUser user)) ))
--        |> Maybe.withDefault ( model, Cmd.none )
--
--
--logout sessionId clientId model =
--    ( { model | sessions = model.sessions |> Dict.remove sessionId }, Cmd.none )
--
--
--getSessionUser : Lamdera.SessionId -> BackendModel -> Maybe UserFull
--getSessionUser sid model =
--    model.sessions
--        |> Dict.get sid
--        |> Maybe.andThen (\session -> model.users |> Dict.get session.userId)
