module KeyValueStore exposing (KVViewType(..), rowsAndColumns)

import Element exposing (Element, text)
import Element.Font


type KVViewType
    = KVRaw
    | KVVSummary
    | KVVKey


rowsAndColumns : String -> Element msg
rowsAndColumns value =
    let
        dataLines =
            value
                |> String.lines
                |> List.filter (\line -> String.left 1 line /= "#" && String.trim line /= "")

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
