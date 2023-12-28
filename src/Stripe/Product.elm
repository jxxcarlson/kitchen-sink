module Stripe.Product exposing (..)

import Env


ticket : { campFire : String, camp : String, couplesCamp : String }
ticket =
    case Env.mode of
        Env.Production ->
            { campFire = "prod_NWZAQ3eQgK0XlF"
            , camp = "prod_NWZ5JHXspU1l8p"
            , couplesCamp = "prod_NWZ8FJ1Ckl9fIc"
            }

        Env.Development ->
            { campFire = "prod_NZEShNjlWMPhTA"
            , camp = "prod_NZEQV1gtsmmSbR"
            , couplesCamp = "prod_NZERuXB2me9wRw"
            }


sponsorship : { silver : String, gold : String, platinum : String }
sponsorship =
    case Env.mode of
        Env.Production ->
            { silver = "prod_NfXP14FBQBsK1z"
            , gold = "prod_NfXQ32t5vx7Sik"
            , platinum = "prod_NfXRgLoadOXG6n"
            }

        Env.Development ->
            { silver = "prod_NfgZ9Lztw4rqY1"
            , gold = "prod_NfgaDIHFcTZaXO"
            , platinum = "prod_NfgasPyftxzylU"
            }


type alias Sponsorship =
    { name : String, price : Int, productId : String, description : String, features : List String }


sponsorshipItems =
    [ { name = "Silver"
      , price = 1000
      , productId = sponsorship.silver
      , description = "You will be a major supporter of Elm Camp Europe 2023."
      , features =
            [ "Thank you tweet"
            , "Logo on webpage"
            , "Small logo on shared slide, displayed during breaks"
            ]
      }
    , { name = "Gold"
      , price = 2500
      , productId = sponsorship.gold
      , description = "You will be a pivotal supporter of Elm Camp Europe 2023."
      , features =
            [ "Thank you tweet"
            , "Rollup or poster inside the venue (provided by you)"
            , "Logo on webpage"
            , "Medium logo on shared slide, displayed during breaks"
            , "1 free campfire ticket"
            ]
      }
    , { name = "Platinum"
      , price = 5000
      , productId = sponsorship.platinum
      , description = "You will be principal sponsor and guarantee that Elm Camp Europe 2023 is a success."
      , features =
            [ "Thank you tweet"
            , "Rollup or poster inside the venue (provided by you)"
            , "Self-written snippet on shared web page about use of Elm at your company"
            , "Logo on webpage"
            , "2 free campfire tickets or 1 free camp ticket"
            , "Big logo on shared slide, displayed during breaks"
            , "Honorary mention in opening and closing talks"
            ]
      }
    ]
