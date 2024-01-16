module Backend.Session exposing (reconnect, removeSessions, updateSession)

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
            Dict.get username model.userDictionary

        ( newSessions_, newSessionInfo_ ) =
            case maybeUser of
                Just user ->
                    Session.add sessionId user.username (Session.ISignIn model.time) ( model.sessions, model.sessionInfo )

                Nothing ->
                    ( model.sessions, model.sessionInfo )
    in
    { model | sessions = newSessions_, sessionInfo = newSessionInfo_ }


removeSessions : String -> Types.BackendModel -> Types.BackendModel
removeSessions username model =
    let
        ( sessions, sessionInfo ) =
            Session.remove username ( model.sessions, model.sessionInfo )
    in
    { model | sessions = sessions, sessionInfo = sessionInfo }


reconnect : Types.BackendModel -> Lamdera.SessionId -> Lamdera.ClientId -> Cmd backendMsg
reconnect model sessionId clientId =
    let
        maybeUsername =
            BiDict.get sessionId model.sessions |> Debug.log "@@ OnConnected maybeUsername"

        maybeUser =
            Maybe.andThen (\username -> Dict.get username model.userDictionary) maybeUsername
    in
    Lamdera.sendToFrontend clientId (Types.UserSignedIn maybeUser)
