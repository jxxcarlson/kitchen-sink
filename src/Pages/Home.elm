module Pages.Home exposing (view)

import Element exposing (Element)
import Element.Font
import Html.Attributes
import MarkdownThemed
import Theme
import Types exposing (..)
import View.Button
import View.CustomElement
import View.Input
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
            , Element.row [ Element.spacing 8 ]
                [ Element.el [ Element.Font.bold, Element.paddingEach { left = 24, right = 0, top = 0, bottom = 0 } ] (Element.text "Weather")
                , View.Input.templateWithAttr
                    [ Element.width (Element.px 140)
                    , View.Utility.onEnter (RequestWeatherData model.inputCity)
                    ]
                    "City"
                    model.inputCity
                    InputCity
                , case model.weatherData of
                    Nothing ->
                        Element.el [] (Element.text "No data")

                    Just data ->
                        Element.el [] (Element.text <| String.fromFloat (data.main.temp - 273.15 |> View.Utility.roundTo 1) ++ " C")
                ]
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
can display the current users, Stripe data, and a key-value store.  You can
put data into and get data out of the key-value store using remote
procedure calls (RPCs).

Below are four short examples: (a) the first button plays a sound,
(b) the second copies some hidden text to the clipboard, (c)
the third displays the current temperature in of the city
that you type into the white box (press `Enter` when done).
The fourth displays the current local time
using a simple, self-contained custom element (web component).
The first two example use ports, while the second relies
on an outbound Http request to [openweathermap.org](https://openweathermap.org/)
from the backend.  See the `Ports`, `Weather`, and `View.CustomElement` modules for code
and for more information.

**NOTE.** *The "Raw Data" and "Edit Data" tabs are for another project
(a curated public data service for science and education) and will be removed when this project is complete.*
        """
        |> MarkdownThemed.renderFull
