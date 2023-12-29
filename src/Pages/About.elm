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
- Ports: an example (not started)
- Authentication (not started)
- Custom element (not started)
- RPC: (note started)
- Markdown: .(in progress – style)

The template is based on a stripped-down version of
Mario Rogic's realworld example.
For additional information, see the **Notes** tab.


"""
        |> MarkdownThemed.renderFull
