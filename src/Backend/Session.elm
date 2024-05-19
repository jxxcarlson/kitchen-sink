module Backend.Session exposing (reconnect)

import Auth.Common
import BiDict
import Dict
import Lamdera
import Session
import Types
import User


updateSession : String -> String -> Types.BackendModel -> Types.BackendModel
updateSession sessionId username model =
    let
        maybeUser : Maybe User.User
        maybeUser =
            Dict.get username model.users

        ( newSessions_, newSessionInfo_ ) =
            case maybeUser of
                Just user ->
                    Session.add sessionId user.username (Session.ISignIn model.time) ( model.sessions, model.sessionInfo )

                Nothing ->
                    ( model.sessions, model.sessionInfo )
    in
    { model | sessions = newSessions_, sessionInfo = newSessionInfo_ }


removeSession : String -> Types.BackendModel -> Types.BackendModel
removeSession username model =
    let
        ( sessions, sessionInfo ) =
            Session.remove username ( model.sessions, model.sessionInfo )
    in
    { model | sessions = sessions, sessionInfo = sessionInfo }


reconnect : Types.BackendModel -> Lamdera.SessionId -> Lamdera.ClientId -> Cmd backendMsg
reconnect model sessionId clientId =
    let
        userInfo : Maybe Auth.Common.UserInfo
        userInfo =
            Dict.get sessionId model.sessions

        maybeUser =
            case Maybe.map .username userInfo of
                Just mu ->
                    case mu of
                        Just username ->
                            Dict.get username model.users

                        Nothing ->
                            Nothing

                Nothing ->
                    Nothing
    in
    Lamdera.sendToFrontend clientId (Types.UserSignedIn maybeUser)
