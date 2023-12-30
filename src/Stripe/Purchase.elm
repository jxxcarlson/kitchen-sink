module Stripe.Purchase exposing (..)

import AssocList
import Element exposing (Element)
import Element.Background as Background
import Element.Border
import Element.Font as Font
import Element.Input
import Id exposing (Id(..))
import Stripe.Helpers
import Stripe.Stripe exposing (Price, PriceId, ProductId)
import Types exposing (..)
import View.Color
import View.Utility


type alias Ticket =
    { name : String
    , description : String
    , image : String
    , productId : String
    }


viewForm : LoadedModel -> Element FrontendMsg
viewForm model =
    Element.column
        [ Element.width (Element.px 600)

        --, if Predicate.isAdmin model.currentUser then
        --    Element.height (Element.px 560)
        --
        --  else
        --    Element.height (Element.px 340)
        , Element.spacing 24
        , Element.paddingXY 36 48
        , Background.color View.Color.darkGray
        ]
        [ Element.el [ Font.size 24, Font.color View.Color.lightGray ] (Element.text "Purchase image credits")
        , viewProducts model Env.productList
        , Element.row [ Element.width Element.fill, Element.spacing 16 ]
            [ cancelButton
            , case model.productToPurchase of
                Nothing ->
                    submitButton (Id "a") (Id "b")

                Just product ->
                    submitButton (Id product.productId) (Id product.priceId)
            ]
        , Element.column
            [ Element.paddingEach { left = 0, right = 0, top = 36, bottom = 0 }
            , Element.spacing 12
            , Font.color View.Color.lightGray
            ]
            (Element.text "Debug Data"
                :: List.map viewPrice (model.prices |> AssocList.toList)
            )
        , Element.column
            [ Element.paddingEach { left = 0, right = 0, top = 36, bottom = 0 }
            , Element.spacing 12
            , Font.color View.Color.lightGray
            ]
            (Element.text "Validated Debug Data"
                :: List.map viewPrice (model.prices |> Stripe.Helpers.validatePrices model |> AssocList.toList)
            )
        , Element.el [ Font.italic, Font.color View.Color.lightGray ] (Element.text "Difficulties? Email jxxcarlson@gmail.com")
        ]


viewProducts : LoadedModel -> List Product -> Element FrontendMsg
viewProducts model products =
    Element.column [ Element.spacing 24, Font.color View.Color.lightGray ]
        (List.map (viewProduct model.productToPurchase) products)


viewPrice : ( Id ProductId, Price2 ) -> Element msg
viewPrice ( productId, { priceId } ) =
    Element.row [ Element.spacing 11 ]
        [ viewId productId, viewId priceId ]


viewId : Id a -> Element msg
viewId idx =
    Element.el [ Element.width (Element.px 200) ] (Element.text (Id.toString idx))


viewProductData : { a | prices : List Price2 } -> Element msg
viewProductData model =
    Element.paragraph
        [ Font.size 14, Element.paddingXY 8 0 ]
        [ Element.text (List.map Types.price2ToString model.prices |> String.join "; ")
        ]


viewProduct : Maybe Product -> Product -> Element FrontendMsg
viewProduct maybeSelectedProduct product =
    let
        bgColor =
            case maybeSelectedProduct of
                Just selectedProduct ->
                    if selectedProduct.productId == product.productId then
                        View.Color.orange

                    else
                        View.Color.darkGray

                Nothing ->
                    View.Color.darkGray
    in
    Element.row
        [ Element.spacing 18
        , Font.size 14
        , Element.paddingEach { left = 8, right = 0, top = 0, bottom = 0 }
        , Background.color bgColor
        ]
        [ Element.el [ Element.width (Element.px 60) ] (Element.text product.name)
        , Element.el [ Element.width (Element.px 100) ] (Element.text product.description)
        , Element.el [ Element.width (Element.px 60) ] (Element.text <| displayPrice product.price)
        , Button.selectItem product
        ]


displayPrice : Float -> String
displayPrice x =
    "$" ++ String.fromFloat x


submitButton productId priceId =
    Element.Input.button
        normalButtonAttributes
        { onPress = Just (PressedSubmitForm productId priceId)
        , label =
            Element.paragraph
                [ Font.center ]
                [ Element.text "Purchase "
                ]
        }


cancelButton =
    Element.Input.button
        normalButtonAttributes
        { onPress = Just PressedCancelForm
        , label = Element.el [ Element.centerX ] (Element.text "Cancel")
        }


normalButtonAttributes =
    [ Element.width Element.fill
    , Background.color (Element.rgb255 255 255 255)
    , Element.padding 16
    , Element.Border.rounded 8
    , Element.alignBottom
    , Element.Border.shadow { offset = ( 0, 1 ), size = 0, blur = 2, color = Element.rgba 0 0 0 0.1 }
    , Font.semiBold
    ]


errorText : String -> Element msg
errorText error =
    Element.paragraph [ Font.color (Element.rgb255 150 0 0) ] [ Element.text error ]
