module Weather exposing (WeatherData, weatherDataDecoder)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)


type alias Coordinate =
    { lon : Float
    , lat : Float
    }


type alias Weather =
    { id : Int
    , main : String
    , description : String
    , icon : String
    }


type alias Main =
    { temp : Float
    , feels_like : Float
    , temp_min : Float
    , temp_max : Float
    , pressure : Int
    , humidity : Int
    }


type alias Wind =
    { speed : Float
    , deg : Int

    -- TODO, fix this -- , gust : Float
    }


type alias Clouds =
    { all : Int
    }


type alias Sys =
    { type_ : Int
    , id : Int
    , country : String
    , sunrise : Int
    , sunset : Int
    }


type alias WeatherData =
    { coord : Coordinate
    , weather : List Weather
    , base : String
    , main : Main
    , visibility : Int
    , wind : Wind
    , clouds : Clouds
    , dt : Int
    , sys : Sys
    , timezone : Int
    , id : Int
    , name : String
    , cod : Int
    }


type TemperatureScale
    = Centigrade
    | Fahrenheit



{-

   https://api.openweathermap.org/data/2.5/weather?q=New York City&APPID=b0dadd61e9751e297ed9519af39ec7bc

-}
-- DECODERS


coordinateDecoder : Decoder Coordinate
coordinateDecoder =
    Decode.succeed Coordinate
        |> required "lon" Decode.float
        |> required "lat" Decode.float


weatherDecoder : Decoder Weather
weatherDecoder =
    Decode.succeed Weather
        |> required "id" Decode.int
        |> required "main" Decode.string
        |> required "description" Decode.string
        |> required "icon" Decode.string


mainDecoder : Decoder Main
mainDecoder =
    Decode.succeed Main
        |> required "temp" Decode.float
        |> required "feels_like" Decode.float
        |> required "temp_min" Decode.float
        |> required "temp_max" Decode.float
        |> required "pressure" Decode.int
        |> required "humidity" Decode.int


windDecoder : Decoder Wind
windDecoder =
    Decode.succeed Wind
        |> required "speed" Decode.float
        |> required "deg" Decode.int



--TODO: fix this |> required "gust" Decode.float


cloudsDecoder : Decoder Clouds
cloudsDecoder =
    Decode.succeed Clouds
        |> required "all" Decode.int


sysDecoder : Decoder Sys
sysDecoder =
    Decode.succeed Sys
        |> required "type" Decode.int
        |> required "id" Decode.int
        |> required "country" Decode.string
        |> required "sunrise" Decode.int
        |> required "sunset" Decode.int


weatherDataDecoder : Decoder WeatherData
weatherDataDecoder =
    Decode.succeed WeatherData
        |> required "coord" coordinateDecoder
        |> required "weather" (Decode.list weatherDecoder)
        |> required "base" Decode.string
        |> required "main" mainDecoder
        |> required "visibility" Decode.int
        |> required "wind" windDecoder
        |> required "clouds" cloudsDecoder
        |> required "dt" Decode.int
        |> required "sys" sysDecoder
        |> required "timezone" Decode.int
        |> required "id" Decode.int
        |> required "name" Decode.string
        |> required "cod" Decode.int
