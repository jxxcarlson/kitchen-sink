module Pages.Features exposing (view)

import Element exposing (Element)
import MarkdownThemed
import Types exposing (..)


view : LoadedModel -> Element msg
view model =
    """
# Features

The kitchen sink app provides the features listed below.
Some features are still in-progress.  If there is a feature you
think should be part of this template app, please let me know.
I am jxxcarlsn  on slack, discourse, discord, and email (gm..l).

*I am looking for good port and custom element examples, especially
the latter.*

- Page routing
- Stripe (See *the *Purchase** tab)
- Ports (Stripe, Chirp and Copy Pi buttons on the home page)
- Basic admin page (started, accessible if the user is the signed-in admin)
- User module (mock-up of user sign-in/up/out stuff, see the *Sign In* tab)
- Authentication (started by rob_soko (Rob Sokolowski))
- UUIDs (generate on backend and provide as service)
- Custom elements (live local time display. *I need something more
  substantial. Suggestions, code, and help are welcome.  A calendar element would be
  especially nice.*)
- RPC (Stripe interface, example of a backend service to post and get key-value pairs)
- Markdown (used in this document and others)

The template is based on a stripped-down version of
Mario Rogic's [Elm Camp Website](https://github.com/elm-camp/website) code.
For additional information, see the **Notes** tab.


"""
        |> MarkdownThemed.renderFull
