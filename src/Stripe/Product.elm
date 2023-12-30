module Stripe.Product exposing (ticket)

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
