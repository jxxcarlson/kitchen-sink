module Pages.SignIn exposing (..)

import Element exposing (Element)
import MarkdownThemed
import Types exposing (..)


view : LoadedModel -> Element msg
view model =
    """
# Sign In

*This is a dummy sign in page.*


"""
        |> MarkdownThemed.renderFull
