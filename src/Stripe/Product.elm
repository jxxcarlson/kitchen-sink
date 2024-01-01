module Stripe.Product exposing
    ( Product_
    , dict
    , viewDesktop
    , viewMobile
    )

import AssocList
import Element exposing (Element)
import Element.Font
import Element.Input
import Id exposing (Id)
import MarkdownThemed
import Money
import Stripe.Stripe as Stripe exposing (Price, ProductId(..))
import Theme



-- @TODO need to use pricing IDs here, not product IDs
-- but how do we figure out the right price given the current user? Is there a Stripe API for that?


type alias Product_ =
    { name : String
    , description : String
    , image : String
    , productId : String
    }


dict : AssocList.Dict (Id ProductId) Product_
dict =
    []
        |> List.map (\t -> ( Id.fromString t.productId, t ))
        |> AssocList.fromList


viewDesktop : msg -> Price -> Product_ -> Element msg
viewDesktop onPress price ticket =
    Theme.panel []
        [ Element.image [ Element.width (Element.px 120) ] { src = ticket.image, description = "Illustration of a camp" }
        , Element.paragraph [ Element.Font.semiBold, Element.Font.size 20 ] [ Element.text ticket.name ]
        , MarkdownThemed.renderFull ticket.description
        , Element.el
            [ Element.Font.bold, Element.Font.size 36, Element.alignBottom ]
            (Element.text (Theme.priceText price))
        , Element.Input.button
            Theme.submitButtonAttributes
            { onPress = Just onPress
            , label =
                Element.el
                    [ Element.centerX, Element.Font.semiBold, Element.Font.color (Element.rgb 1 1 1) ]
                    (Element.text "Select")
            }
        ]


viewMobile : msg -> Price -> Product_ -> Element msg
viewMobile onPress { currency, amount } ticket =
    Theme.panel []
        [ Element.row
            [ Element.spacing 16 ]
            [ Element.column
                [ Element.width Element.fill, Element.spacing 16 ]
                [ Element.paragraph [ Element.Font.semiBold, Element.Font.size 20 ] [ Element.text ticket.name ]
                , MarkdownThemed.renderFull ticket.description
                , Element.el
                    [ Element.Font.bold, Element.Font.size 36, Element.alignBottom ]
                    (Element.text (Money.toNativeSymbol currency ++ String.fromInt (amount // 100)))
                ]
            , Element.image
                [ Element.width (Element.px 80), Element.alignTop ]
                { src = ticket.image, description = "Illustration of a camp" }
            ]
        , Element.Input.button
            Theme.submitButtonAttributes
            { onPress = Just onPress
            , label =
                Element.el
                    [ Element.centerX ]
                    (Element.text "Select")
            }
        ]
