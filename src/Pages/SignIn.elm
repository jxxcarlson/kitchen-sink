module Pages.SignIn exposing (..)

import Element exposing (Element)
import MarkdownThemed
import Types exposing (..)
import View.Input


view : LoadedModel -> Element FrontendMsg
view model =
    Element.column [ Element.spacing 18 ]
        [ View.Input.template "Real Name" model.realname InputRealname
        , View.Input.template "User Name" model.username InputUsername
        , View.Input.template "Password" model.password InputPassword
        , View.Input.template "Password again" model.password InputPasswordConfirmation
        ]


foo =
    """
# Sign In

*This is a dummy sign in page.*


"""
        |> MarkdownThemed.renderFull
