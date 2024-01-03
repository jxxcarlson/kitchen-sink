module Pages.Home exposing (view)

import Element exposing (Element)
import Html.Attributes
import MarkdownThemed
import Theme
import Types exposing (..)
import View.Button
import View.CustomElement


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
            , Element.el [ Element.paddingXY 0 0 ]
                (View.CustomElement.timeFormatted
                    [ Html.Attributes.attribute "id" "elem"
                    , Html.Attributes.attribute "hour" "numeric"
                    , Html.Attributes.attribute "minute" "numeric"
                    , Html.Attributes.attribute "second" "numeric"
                    , Html.Attributes.attribute "time-zone-name" "short"
                    ]
                    []
                    |> Element.html
                )
            ]
        ]



-- <time-formatted id="elem" hour="numeric" minute="numeric" second="numeric"></time-formatted>
--, Element.column
--    [ Element.Background.color View.Color.white
--    , Element.paddingXY 20 20
--    , Element.paddingEach { left = 0, right = 0, top = 60, bottom = 0 }
--    ]
--    [ Element.row [ Element.Font.color View.Color.darkBlue, Element.Font.size 20 ]
--        [ Element.el [ Element.paddingXY 20 20 ] (Element.text "Calendar")
--        , View.CustomElement.fullCalendar
--            [ Html.Attributes.style "width" "400px"
--            , Html.Attributes.style "height" "300px"
--            ]
--            [ Html.text "Hello" ]
--            |> Element.html
--        ]
--    ]


content : Element msg
content =
    """
# Kitchen Sink

This is app is a template for Lamdera projects.
The repo is at  [github.com/jxxcarlson/kitchen-sink](https://github.com/jxxcarlson/kitchen-sink).

See the **Features** and **Note** tabs for more information. The first
of these lists the main features of the template and their status. The
 second gives details on their implementation. The **Purchase** tab
 allows you to make fake purchases using Stripe.  Your credit card
 will not be charged — this is all done in test mode.

 During the testing phase, the app comes preloaded with two users, `jxxcarlson`
 and `aristotle`, both with password `1234`. Use the **Sign in** tab for these.
 You can also sign up for your own account.

 Note that you can play administrator by signing in as `jxxcarlson`. When signed
 is as an administrator, the **Admin** tab appears.  Using it, you
 can display the current users, Stripe data, a key-value store, and a log of events.

 *In this initial phase, I will sometimes do destructive migrations. Consequently
 all data except that which is preloaded will be lost.*

 Below are three short examples: (a) play a sound,  (b) copy text to the clipboard, and
 (c) display the current time and time zone.  The first two use ports, the last
 is a simple, self-contained custom element.  See the `Ports` and `View.CustomElement`
 modules for more information.
        """
        |> MarkdownThemed.renderFull
