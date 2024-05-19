module Pages.SignIn exposing (view)

import Element exposing (Element)
import Element.Font
import MagicToken.LoginForm
import MagicToken.Types
import Types exposing (FrontendMsg(..), LoadedModel, SignInState(..))
import View.Button
import View.Color
import View.Input
import View.Utility


testInput : MagicToken.Types.EnterEmail2
testInput =
    { email = "jxxcarlson@gmail.com"
    , pressedSubmitEmail = False
    , rateLimited = False
    }


view : LoadedModel -> Element FrontendMsg
view model =
    case model.signInStatus of
        MagicToken.Types.NotSignedIn ->
            signInView model

        MagicToken.Types.SignedIn ->
            signedInView model

        MagicToken.Types.SigningUp ->
            signUp model

        MagicToken.Types.SuccessfulRegistration username email ->
            Element.column []
                [ signInAfterRegisteringView model
                , Element.el [ Element.Font.color (Element.rgb 0 0 1) ] (Element.text <| username ++ ", you are now registered as " ++ email)
                ]

        MagicToken.Types.ErrorNotRegistered message ->
            Element.column []
                [ signUp model
                , Element.el [ Element.Font.color (Element.rgb 1 0 0) ] (Element.text message)
                ]


signedInView : LoadedModel -> Element FrontendMsg
signedInView model =
    case model.currentUserData of
        Nothing ->
            Element.none

        Just userData ->
            View.Button.signOut userData.username


signInView : LoadedModel -> Element FrontendMsg
signInView model =
    Element.column []
        [ Element.el [ Element.Font.semiBold, Element.Font.size 24 ] (Element.text "Sign in")
        , MagicToken.LoginForm.view model model.loginForm

        --, Element.paragraph [ Element.Font.color (Element.rgb 1 0 0) ] [ Element.text (model.loginErrorMessage |> Maybe.withDefault "") ]
        , Element.row
            [ Element.spacing 12
            , Element.paddingEach { left = 18, right = 0, top = 0, bottom = 0 }
            ]
            [ Element.el [] (Element.text "Need to sign up?  "), View.Button.openSignUp ]
        ]


signInAfterRegisteringView : LoadedModel -> Element FrontendMsg
signInAfterRegisteringView model =
    Element.column []
        [ Element.el [ Element.Font.semiBold, Element.Font.size 24 ] (Element.text "Sign in")
        , MagicToken.LoginForm.view model model.loginForm
        ]


signUp : LoadedModel -> Element FrontendMsg
signUp model =
    Element.column [ Element.spacing 18, topPadding ]
        [ Element.el [ Element.Font.semiBold, Element.Font.size 24 ] (Element.text "Sign up")
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
