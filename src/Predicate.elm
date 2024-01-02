module Predicate exposing (isAdmin)

import User


isAdmin : Maybe User.User -> Bool
isAdmin currentUser =
    case currentUser of
        Just user ->
            user.username == "jxxcarlson"

        Nothing ->
            False
