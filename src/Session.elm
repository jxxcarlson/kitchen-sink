module Session exposing
    ( Interaction(..)
    , SessionInfo
    , Sessions
    , Username
    , add
    , remove
    )

import BiDict
import Dict
import Lamdera exposing (SessionId)
import Set
import Time


type alias Sessions =
    BiDict.BiDict SessionId Username


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
    ( BiDict.insert sessionId username sessions, Dict.insert sessionId interaction sessionInfo )


remove : Username -> ( Sessions, SessionInfo ) -> ( Sessions, SessionInfo )
remove username ( sessions, sessionInfo ) =
    let
        activeSessions : List SessionId
        activeSessions =
            BiDict.getReverse username sessions
                |> Set.toList

        removeSessions : List SessionId -> Sessions -> Sessions
        removeSessions activeSessions_ sessions_ =
            List.foldl
                (\sessionId_ sessions__ ->
                    BiDict.remove sessionId_ sessions__
                )
                sessions_
                activeSessions_

        filterSessionInfo : List SessionId -> SessionInfo -> SessionInfo
        filterSessionInfo activeSessions_ sessionInfo_ =
            Dict.filter
                (\sessionId_ _ ->
                    not (List.member sessionId_ activeSessions_)
                )
                sessionInfo_
    in
    ( removeSessions activeSessions sessions
    , filterSessionInfo activeSessions sessionInfo
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
            BiDict.remove sessionId sessions_
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
