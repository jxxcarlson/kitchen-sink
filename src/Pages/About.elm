module Pages.About exposing (view)

import Element exposing (Element)
import MarkdownThemed
import Types exposing (..)


view : LoadedModel -> Element msg
view model =
    """
# About the Template

The kitchen sink app is a starting point for your
Lamdera projects.  It comes with a number of
built-in features:

- Page routing (done)
- Stripe (in progress)
- Ports: an example (Stripe)
- Authentication (not started)
- Custom element (not started)
- RPC: (not started)
- Markdown: (done)

The template is based on a stripped-down version of
Mario Rogic's [realworld](https://github.com/supermario/lamdera-realworld) code.
For additional information, see the **Notes** tab.


"""
        |> MarkdownThemed.renderFull
