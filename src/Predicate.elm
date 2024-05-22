module Predicate exposing (isAdmin)

import User


isAdmin : Maybe User.LoginData -> Bool
isAdmin maybeLoginData =
    case maybeLoginData of
        Just loginData ->
            List.member User.AdminRole loginData.roles

        Nothing ->
            False
