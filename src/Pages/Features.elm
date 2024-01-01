module Pages.Features exposing (view)

import Element exposing (Element)
import MarkdownThemed
import Types exposing (..)


view : LoadedModel -> Element msg
view model =
    """
# Features

The kitchen sink app provides the features listed below.

- Page routing
- Stripe (See *the *Purchase** tab)
- Ports (Stripe, Chirp and Copy Pi buttons on the home page)
- Basic admin page (not started)
- User module (not started)
- Authentication (not started)
- Custom element (not started)
- RPC: (used in the Stripe interface)
- Markdown (used in this document)

The template is based on a stripped-down version of
Mario Rogic's [Elm Camp Website](https://github.com/elm-camp/website) code.
For additional information, see the **Notes** tab.


"""
        |> MarkdownThemed.renderFull