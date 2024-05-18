module Session exposing
    ( Interaction(..)
    , SessionInfo
    , Sessions
    , Username
    , add
    , remove
    )

import Auth.Common
import BiDict
import Dict exposing (Dict)
import Lamdera exposing (SessionId)
import Set
import Time


type alias SessionInfo =
    Dict.Dict SessionId Interaction


type Interaction
    = ISignIn Time.Posix
    | ISignOut Time.Posix
    | ISignUp Time.Posix


type alias Username =
    String


add : SessionId -> Username -> Interaction -> ( Sessions, SessionInfo ) -> ( Sessions, SessionInfo )
add sessionId username interaction ( sessions, sessionInfo ) =
    case Dict.get sessionId sessions of
        Just userInfo ->
            let
                newUserInfo =
                    { userInfo | username = Just username }
            in
            ( Dict.insert sessionId newUserInfo sessions, Dict.insert sessionId interaction sessionInfo )

        Nothing ->
            ( sessions, sessionInfo )


type alias Sessions =
    Dict SessionId Auth.Common.UserInfo


filterSessions : Username -> Sessions -> Sessions
filterSessions username sessions =
    let
        isGood : Username -> Auth.Common.UserInfo -> Bool
        isGood name userInfo =
            case userInfo.username of
                Just username_ ->
                    username_ /= name

                Nothing ->
                    True
    in
    Dict.filter (\k v -> isGood username v) sessions


remove : Username -> ( Sessions, SessionInfo ) -> ( Sessions, SessionInfo )
remove username ( sessions, sessionInfo ) =
    let
        filterSessionInfo : List SessionId -> SessionInfo -> SessionInfo
        filterSessionInfo activeSessions_ sessionInfo_ =
            Dict.filter
                (\sessionId_ _ ->
                    not (List.member sessionId_ activeSessions_)
                )
                sessionInfo_
    in
    ( filterSessions username sessions
    , filterSessionInfo (Dict.keys sessions) sessionInfo
    )


removeStaleSessions : Time.Posix -> ( Sessions, SessionInfo ) -> ( Sessions, SessionInfo )
removeStaleSessions currentTime ( sessions, sessionInfo ) =
    let
        staleSessions : List SessionId
        staleSessions =
            Dict.toList sessionInfo
                |> List.filterMap
                    (\( sessionId, interaction ) ->
                        case interaction of
                            ISignIn time ->
                                if diffTimeInHours currentTime time > 24 then
                                    Just sessionId

                                else
                                    Nothing

                            ISignOut time ->
                                if diffTimeInHours currentTime time > 24 then
                                    Just sessionId

                                else
                                    Nothing

                            ISignUp time ->
                                if diffTimeInHours currentTime time > 24 then
                                    Just sessionId

                                else
                                    Nothing
                    )
    in
    ( List.foldl
        (\sessionId sessions_ ->
            Dict.remove sessionId sessions_
        )
        sessions
        staleSessions
    , Dict.filter
        (\sessionId _ ->
            not (List.member sessionId staleSessions)
        )
        sessionInfo
    )


diffTimeInMinutes : Time.Posix -> Time.Posix -> Int
diffTimeInMinutes time1 time2 =
    let
        t1 =
            Time.posixToMillis time1

        t2 =
            Time.posixToMillis time2
    in
    t2 - t1 |> toFloat |> (/) 60000 |> round


diffTimeInHours : Time.Posix -> Time.Posix -> Int
diffTimeInHours time1 time2 =
    let
        t1 =
            Time.posixToMillis time1

        t2 =
            Time.posixToMillis time2
    in
    t2 - t1 |> toFloat |> (/) (1000 * 60 * 60) |> round
