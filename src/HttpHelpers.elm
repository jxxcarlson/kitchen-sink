module HttpHelpers exposing (customError, customErrorEffect, expectJson_, httpErrorToString, httpErrorToStringEffect, jsonResolver, jsonResolverEffect, parseError)

import Http
import Json.Decode as D


{-| The default Http.expectJson / Http.expectString don't allow you to see any body
returned in an error (i.e. 403) states. The following docs;
<https://package.elm-lang.org/packages/elm/http/latest/Http#expectStringResponse>
describe our sitution perfectly, so that's that code below, with a modified
Http.BadStatus\_ handler to map it to BadBody String instead of BadStatus Int
so we can actually see the error message.
-}
expectJson_ : (Result Http.Error a -> msg) -> D.Decoder a -> Http.Expect msg
expectJson_ toMsg decoder =
    Http.expectStringResponse toMsg <|
        \response ->
            case response of
                Http.BadUrl_ url ->
                    Err (Http.BadUrl url)

                Http.Timeout_ ->
                    Err Http.Timeout

                Http.NetworkError_ ->
                    Err Http.NetworkError

                Http.BadStatus_ metadata body ->
                    Err (Http.BadBody (String.fromInt metadata.statusCode ++ ": " ++ body))

                Http.GoodStatus_ metadata body ->
                    case D.decodeString decoder body of
                        Ok value ->
                            Ok value

                        Err err ->
                            Err (Http.BadBody (D.errorToString err))



-- From https://github.com/krisajenkins/remotedata/issues/28


parseError : String -> Maybe String
parseError =
    D.decodeString (D.field "error" D.string) >> Result.toMaybe


httpErrorToString : Http.Error -> String
httpErrorToString err =
    case err of
        Http.BadUrl url ->
            "HTTP malformed url: " ++ url

        Http.Timeout ->
            "HTTP timeout exceeded"

        Http.NetworkError ->
            "HTTP network error"

        Http.BadStatus code ->
            "Unexpected HTTP response code: " ++ String.fromInt code

        Http.BadBody text ->
            "HTTP error: " ++ text


httpErrorToStringEffect : Http.Error -> String
httpErrorToStringEffect err =
    case err of
        Http.BadUrl url ->
            "HTTP malformed url: " ++ url

        Http.Timeout ->
            "HTTP timeout exceeded"

        Http.NetworkError ->
            "HTTP network error"

        Http.BadStatus code ->
            "Unexpected HTTP response code: " ++ String.fromInt code

        Http.BadBody text ->
            "HTTP error: " ++ text


customError : String -> Http.Error
customError s =
    Http.BadBody <| "Error: " ++ s


customErrorEffect : String -> Http.Error
customErrorEffect s =
    Http.BadBody <| "Error: " ++ s


jsonResolver : D.Decoder a -> Http.Resolver Http.Error a
jsonResolver decoder =
    Http.stringResolver <|
        \response ->
            case response of
                Http.GoodStatus_ _ body ->
                    D.decodeString decoder body
                        |> Result.mapError D.errorToString
                        |> Result.mapError Http.BadBody

                Http.BadUrl_ message ->
                    Err (Http.BadUrl message)

                Http.Timeout_ ->
                    Err Http.Timeout

                Http.NetworkError_ ->
                    Err Http.NetworkError

                Http.BadStatus_ metadata body ->
                    Err (Http.BadBody (String.fromInt metadata.statusCode ++ ": " ++ body))


jsonResolverEffect : D.Decoder a -> Http.Resolver Http.Error a
jsonResolverEffect decoder =
    Http.stringResolver <|
        \response ->
            case response of
                Http.GoodStatus_ _ body ->
                    D.decodeString decoder body
                        |> Result.mapError D.errorToString
                        |> Result.mapError Http.BadBody

                Http.BadUrl_ message ->
                    Err (Http.BadUrl message)

                Http.Timeout_ ->
                    Err Http.Timeout

                Http.NetworkError_ ->
                    Err Http.NetworkError

                Http.BadStatus_ metadata body ->
                    Err (Http.BadBody (String.fromInt metadata.statusCode ++ ": " ++ body))
