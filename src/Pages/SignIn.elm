module Pages.SignIn exposing (..)

import Element exposing (Element)
import Element.Font
import Types exposing (..)
import View.Button
import View.Input


view : LoadedModel -> Element FrontendMsg
view model =
    case model.signInState of
        SignedOut ->
            signIn model

        SignedIn ->
            Element.text <| "Signed in (" ++ model.username ++ ")"

        SignUp ->
            signUp model


signIn : LoadedModel -> Element FrontendMsg
signIn model =
    Element.column [ Element.spacing 18, topPadding ]
        [ Element.el [ Element.Font.bold, Element.Font.size 24 ] (Element.text "Sign in")
        , Element.el [ Element.Font.size 18 ] (Element.text "(( Mock-up: not working ))")
        , View.Input.template "User Name" model.username InputUsername
        , View.Input.template "Password" model.password InputPassword
        , Element.row [ Element.spacing 18 ]
            [ View.Button.signIn
            , View.Button.setSignInState "Need an account?" SignUp
            ]
        ]


signUp : LoadedModel -> Element FrontendMsg
signUp model =
    Element.column [ Element.spacing 18, topPadding ]
        [ Element.el [ Element.Font.bold, Element.Font.size 24 ] (Element.text "Sign up")
        , Element.el [ Element.Font.size 18 ] (Element.text "(( Mock-up: not working ))")
        , View.Input.template "Real Name" model.realname InputRealname
        , View.Input.template "User Name" model.username InputUsername
        , View.Input.template "Password" model.password InputPassword
        , View.Input.template "Password again" model.password InputPasswordConfirmation
        , Element.row [ Element.spacing 18 ]
            [ View.Button.signUp
            , View.Button.setSignInState "Cancel" SignedOut
            ]
        ]


topPadding =
    Element.paddingEach { left = 0, right = 0, top = 48, bottom = 0 }
