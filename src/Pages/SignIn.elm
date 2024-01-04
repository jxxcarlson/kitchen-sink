module Pages.SignIn exposing (signIn, signUp, signedIn, topPadding, view)

import Element exposing (Element)
import Element.Font
import Types exposing (..)
import View.Button
import View.Color
import View.Input
import View.Utility


view : LoadedModel -> Element FrontendMsg
view model =
    case model.signInState of
        SignedOut ->
            signIn model

        SignedIn ->
            signedIn model

        SignUp ->
            signUp model


signIn : LoadedModel -> Element FrontendMsg
signIn model =
    Element.column [ Element.spacing 18, topPadding ]
        [ Element.el [ Element.Font.bold, Element.Font.size 24 ] (Element.text "Sign in")
        , Element.column [ Element.spacing 8, Element.Font.italic ]
            [ Element.el [ Element.Font.size 14 ] (Element.text "This is a mock sign in page.")
            , Element.el [ Element.Font.size 14 ] (Element.text "Put in a throwaway password - NOT one you use elsewhere.")
            , Element.el [ Element.Font.size 14 ] (Element.text "There is ABSOLUTELY NO security here.")
            , Element.el [ Element.Font.size 14 ] (Element.text "This for initial testing only.")
            , Element.el [ Element.Font.size 14 ] (Element.text "From time to time the database will be reset and all will be lost.")
            , Element.el [ Element.Font.size 14 ] (Element.text "PS: sign in as jxxcarlson with password 1234 to play administrator")
            ]
        , View.Input.template "User Name" model.username InputUsername
        , View.Input.passwordTemplateWithAttr [ View.Utility.onEnter Types.SubmitSignIn ] "Password" model.password InputPassword
        , Element.row [ Element.spacing 18 ]
            [ View.Button.signIn
            , View.Button.setSignInState "Need an account?" SignUp
            ]
        , Element.el [] (Element.text model.message)
        ]


signedIn : LoadedModel -> Element FrontendMsg
signedIn model =
    Element.column [ Element.spacing 18, topPadding, Element.Font.size 24, Element.Font.color View.Color.darkGray ]
        [ Element.text <| "Signed in as " ++ (Maybe.map .username model.currentUser |> Maybe.withDefault "??")
        , View.Button.signOut
        ]


signUp : LoadedModel -> Element FrontendMsg
signUp model =
    Element.column [ Element.spacing 18, topPadding ]
        [ Element.el [ Element.Font.bold, Element.Font.size 24 ] (Element.text "Sign up")
        , Element.column [ Element.spacing 8, Element.Font.italic ]
            [ Element.el [ Element.Font.size 14 ] (Element.text "This is a mock sign up page.")
            , Element.el [ Element.Font.size 14 ] (Element.text "Put in a throwaway password - NOT one you use elsewhere.")
            , Element.el [ Element.Font.size 14 ] (Element.text "There is ABSOLUTELY NO security here.")
            , Element.el [ Element.Font.size 14 ] (Element.text "This for initial testing only.")
            , Element.el [ Element.Font.size 14 ] (Element.text "From time to time the database will be reset and all will be lost.")
            ]
        , View.Input.template "Real Name" model.realname InputRealname
        , View.Input.template "User Name" model.username InputUsername
        , View.Input.template "Email" model.email InputEmail
        , View.Input.template "Password" model.password InputPassword
        , View.Input.template "Password again" model.passwordConfirmation InputPasswordConfirmation
        , Element.row [ Element.spacing 18 ]
            [ View.Button.signUp
            , View.Button.setSignInState "Cancel" SignedOut
            ]
        , Element.el [ Element.Font.size 14, Element.Font.italic, Element.Font.color View.Color.darkGray ] (Element.text model.message)
        ]


topPadding =
    Element.paddingEach { left = 0, right = 0, top = 48, bottom = 0 }
