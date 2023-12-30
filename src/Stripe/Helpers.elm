module Stripe.Helpers exposing (priceIdToProductId, validatePrices)

import AssocList
import Id exposing (Id)
import List.Extra
import Stripe.Stripe exposing (Price, PriceId, ProductId)
import Types


priceIdToProductId : Types.LoadedModel -> Id PriceId -> Maybe (Id ProductId)
priceIdToProductId model priceId =
    AssocList.toList model.prices
        |> List.Extra.findMap
            (\( productId, prices ) ->
                if prices.priceId == priceId then
                    Just productId

                else
                    Nothing
            )


validatePrices : Types.LoadedModel -> AssocList.Dict (Id ProductId) { priceId : Id PriceId, price : Price } -> AssocList.Dict (Id ProductId) { priceId : Id PriceId, price : Price }
validatePrices model prices =
    AssocList.toList prices
        |> List.filterMap
            (\( productId, price ) ->
                case priceIdToProductId model price.priceId of
                    Just _ ->
                        Just ( productId, price )

                    Nothing ->
                        Nothing
            )
        |> AssocList.fromList
