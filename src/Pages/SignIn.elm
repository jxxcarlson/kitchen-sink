module Pages.SignIn exposing (..)

import Element exposing (Element)
import MarkdownThemed
import Types exposing (..)
import View.Input


view : LoadedModel -> Element msg
view model =
    Element.column []
        --[ View.Input.template "Email" model.email
        --        --]
        []


foo =
    """
# Sign In

*This is a dummy sign in page.*


"""
        |> MarkdownThemed.renderFull
