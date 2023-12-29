module Pages.About exposing (..)

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

- Page routing
- Stripe
- Ports: an example to ...
- Authentication
- RPC: ...
- Markdown: ...

For additional information, see the **Notes** tab.


"""
        |> MarkdownThemed.renderFull
