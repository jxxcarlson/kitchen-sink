module Evergreen.V101.Weather exposing (..)


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
