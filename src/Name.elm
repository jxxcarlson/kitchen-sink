module Name exposing
    ( Error(..)
    , Name(..)
    , anonymous
    , codec
    , errorToString
    , fromString
    , maxLength
    , nameToString
    , toString
    )

import Codec exposing (Codec)


type Name
    = Name String


nameToString : Name -> String
nameToString (Name name) =
    name


type Error
    = NameTooShort
    | NameTooLong


minLength : number
minLength =
    1


maxLength : number
maxLength =
    100


fromString : String -> Result Error Name
fromString text =
    let
        trimmed =
            String.trim text
    in
    if String.length trimmed < minLength then
        Err NameTooShort

    else if String.length trimmed > maxLength then
        Err NameTooLong

    else
        Ok (Name trimmed)


errorToString : Error -> String
errorToString error =
    case error of
        NameTooShort ->
            "Please enter a name"

        NameTooLong ->
            "Name too long"


toString : Name -> String
toString (Name groupName) =
    groupName


anonymous : Name
anonymous =
    Name "Anonymous"


codec : Codec Name
codec =
    Codec.andThen
        (\text ->
            case fromString text of
                Ok name ->
                    Codec.succeed name

                Err _ ->
                    Codec.fail ("Invalid name: " ++ text)
        )
        toString
        Codec.string
