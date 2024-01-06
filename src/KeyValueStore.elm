module KeyValueStore exposing
    ( KVDatum
    , KVVerbosity(..)
    , KVViewType(..)
    , defaultKVDatum
    , encodeKey
    , rowsAndColumns
    )

import Element exposing (Element, text)
import Element.Font
import Json.Encode
import Time


type alias KVDatum =
    { key : String
    , value : String
    , curator : String
    , created_at : Time.Posix
    , updated_at : Time.Posix
    }


defaultKVDatum : KVDatum
defaultKVDatum =
    { key = "Unknown"
    , value = "Unknown"
    , curator = "Unknown"
    , created_at = Time.millisToPosix 0
    , updated_at = Time.millisToPosix 0
    }


type KVViewType
    = KVRaw
    | KVVSummary
    | KVVKey


type KVVerbosity
    = KVVerbose
    | KVQuiet



-- DATA (JC)


encodeKey : String -> Json.Encode.Value
encodeKey key =
    Json.Encode.object
        [ ( "key", Json.Encode.string key )
        ]


rowsAndColumns : String -> Element msg
rowsAndColumns value =
    let
        dataLines =
            value
                |> String.lines
                |> List.filter (\line -> String.trim line /= "" && String.left 1 line /= "#")
                |> List.filter (\line -> String.left 1 line /= "#")

        rows =
            dataLines
                |> List.length
                |> String.fromInt

        columns =
            dataLines
                |> List.head
                |> Maybe.map (\line -> String.split "," line)
                |> Maybe.withDefault []
                |> List.length
                |> String.fromInt
    in
    Element.el [ Element.Font.italic ] (text <| "rows = " ++ rows ++ ", columns = " ++ columns)
