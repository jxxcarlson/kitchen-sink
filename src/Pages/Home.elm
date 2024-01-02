module Pages.Home exposing (view)

import Element exposing (Element)
import Element.Font
import Html.Attributes
import MarkdownThemed
import Pages.Parts
import Theme
import Types exposing (..)
import View.Button
import View.CustomElement
import View.Utility


view : LoadedModel -> Element FrontendMsg
view model =
    Element.column [ Element.paddingXY 0 30 ]
        [ Element.column Theme.contentAttributes [ content ]
        , Element.row
            ([ Element.spacing 20
             ]
                ++ Theme.contentAttributes
            )
            [ View.Button.playSound
            , View.Button.copyTextToClipboard "Copy Pi to Clipboard" "3.141592653589793238462643383279502884197169399375105820974944592307816406286"
            ]
        , View.CustomElement.datePicker
            [ Html.Attributes.style "width" "400px"
            , Html.Attributes.style "height" "300px"
            ]
            []
            |> Element.html
        ]


content : Element msg
content =
    """
# Kitchen Sink

This is app is a template for Lamdera projects.
The repo is at  [github.com/jxxcarlson/kitchen-sink](https://github.com/jxxcarlson/kitchen-sink).

See the **Features** and **Note** tabs for more information. The first
of these lists the main features of the template and their status. The
 second gives details on thier implementation

 *During the testing phase, the app comes preloaded with two users, `jxxcarlson`
 and `aristotle`, both with password `1234`.  Some Stripe data is also preloaded.
 You can add more users if you
 wish, and you can play administrator by signing in as `jxxcarlson`.  Do note
 that in this initial phase, I am doing destructive migrations. Consequently
 all data except that which is preloaded is lost.*

 Below are examples of how one uses ports to (a) play a sound and (b) copy text to the clipboard.
        """
        |> MarkdownThemed.renderFull
