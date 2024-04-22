module Pages.SignIn exposing (view)

import Element exposing (Element)
import Element.Font
import Token.LoginForm
import Token.Types
import Types exposing (FrontendMsg(..), LoadedModel, SignInState(..))
import View.Button
import View.Color
import View.Input
import View.Utility


testInput : Token.Types.EnterEmail2
testInput =
    { email = "jxxcarlson@gmail.com"
    , pressedSubmitEmail = False
    , rateLimited = False
    }


view : LoadedModel -> Element FrontendMsg
view model =
    case model.currentUserData of
        Nothing ->
            signInView model

        Just _ ->
            signedInView model


signedInView : LoadedModel -> Element FrontendMsg
signedInView model =
    Element.column []
        [ View.Button.signOut
        ]


signInView : LoadedModel -> Element FrontendMsg
signInView model =
    Element.column []
        [ Element.el [ Element.Font.semiBold, Element.Font.size 24 ] (Element.text "Sign in")
        , Token.LoginForm.view model model.loginForm
        , signUp model
        ]


signUp : LoadedModel -> Element FrontendMsg
signUp model =
    Element.column [ Element.spacing 18, topPadding ]
        [ Element.el [ Element.Font.semiBold, Element.Font.size 24 ] (Element.text "Sign up")
        , Element.column [ Element.spacing 8, Element.Font.italic ]
            [ Element.el [ Element.Font.size 14 ] (Element.text "Testing ...")
            ]
        , View.Input.template "Real Name" model.realname InputRealname
        , View.Input.template "User Name" model.username InputUsername
        , View.Input.template "Email" model.email InputEmail
        , Element.row [ Element.spacing 18 ]
            [ View.Button.signUp
            , View.Button.cancelSignUp
            ]
        , Element.el [ Element.Font.size 14, Element.Font.italic, Element.Font.color View.Color.darkGray ] (Element.text model.message)
        ]


topPadding =
    Element.paddingEach { left = 0, right = 0, top = 48, bottom = 0 }
