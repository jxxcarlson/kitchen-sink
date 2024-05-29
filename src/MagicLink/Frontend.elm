module MagicLink.Frontend exposing
    ( enterEmail
    , handleRegistrationError
    , handleSignInError
    , signInWithCode
    , signInWithTokenResponseC
    , signInWithTokenResponseM
    , signOut
    , submitEmailForSignin
    , submitSignUp
    , userRegistered
    )

import Dict
import EmailAddress
import Helper
import KeyValueStore
import Lamdera
import MagicLink.LoginForm
import MagicLink.Types exposing (SiginForm(..))
import Route exposing (Route(..))
import Stripe.PurchaseForm as PurchaseForm
    exposing
        ( PressedSubmit(..)
        , PurchaseForm
        , PurchaseFormValidated(..)
        , SubmitStatus(..)
        )
import Types
    exposing
        ( AdminDisplay(..)
        , BackendModel
        , FrontendModel(..)
        , FrontendMsg(..)
        , LoadedModel
        , LoadingModel
        , SignInState(..)
        , ToBackend(..)
        , ToFrontend(..)
        )
import User


submitEmailForSignin model =
    case model.signinForm of
        EnterEmail signinForm ->
            case EmailAddress.fromString signinForm.email of
                Just email ->
                    let
                        model2 =
                            { model | signinForm = EnterSigninCode { sentTo = email, loginCode = "", attempts = Dict.empty } }
                    in
                    ( model2, Helper.trigger <| AuthSigninRequested { methodId = "EmailMagicLink", email = Just signinForm.email } )

                Nothing ->
                    ( { model | signinForm = EnterEmail { signinForm | pressedSubmitEmail = True } }, Cmd.none )

        EnterSigninCode _ ->
            ( model, Cmd.none )


enterEmail model email =
    case model.signinForm of
        EnterEmail signinForm_ ->
            let
                signinForm =
                    { signinForm_ | email = email }
            in
            ( { model | signinForm = EnterEmail signinForm }, Cmd.none )

        EnterSigninCode loginCode_ ->
            -- TODO: complete this
            --  EnterLoginCode{ sentTo : EmailAddress, loginCode : String, attempts : Dict Int LoginCodeStatus }
            ( model, Cmd.none )


handleRegistrationError model str =
    ( { model | signInStatus = MagicLink.Types.ErrorNotRegistered str }, Cmd.none )


handleSignInError model message =
    ( { model | loginErrorMessage = Just message, signInStatus = MagicLink.Types.ErrorNotRegistered message }, Cmd.none )


signInWithTokenResponseM : User.LoginData -> LoadedModel -> LoadedModel
signInWithTokenResponseM signInData model =
    { model | currentUserData = Just signInData, route = HomepageRoute }


signInWithTokenResponseC : User.LoginData -> Cmd msg
signInWithTokenResponseC signInData =
    if List.member User.AdminRole signInData.roles then
        Lamdera.sendToBackend GetBackendModel

    else
        Cmd.none


signOut model =
    ( { model
        | showTooltip = False
        , form =
            { submitStatus = NotSubmitted NotPressedSubmit
            , name = ""
            , billingEmail = ""
            , country = ""
            }

        -- TOKEN
        , signinForm = MagicLink.LoginForm.init
        , loginErrorMessage = Nothing
        , signInStatus = MagicLink.Types.NotSignedIn

        -- USER
        , currentUserData = Nothing
        , currentUser = Nothing
        , realname = ""
        , username = ""
        , email = ""
        , password = ""
        , passwordConfirmation = ""
        , signInState = SignedOut

        -- ADMIN
        , adminDisplay = ADUser

        --
        , backendModel = Nothing
        , message = ""

        -- EXAMPLES
        , language = "en-US"
        , inputCity = ""
        , weatherData = Nothing

        -- DATA
        , currentKVPair = Nothing
        , inputKey = ""
        , inputValue = ""
        , inputFilterData = ""
        , kvViewType = KeyValueStore.KVVSummary
        , kvVerbosity = KeyValueStore.KVQuiet
      }
    , Lamdera.sendToBackend (SignOutRequest model.currentUserData)
    )


submitSignUp model =
    ( model, Lamdera.sendToBackend (AddUser model.realname model.username model.email) )


userRegistered model user =
    ( { model
        | currentUser = Just user
        , signInStatus = MagicLink.Types.SuccessfulRegistration user.username (EmailAddress.toString user.email)
      }
    , Cmd.none
    )



-- HELPERS


signInWithCode : LoadedModel -> String -> ( LoadedModel, Cmd msg )
signInWithCode model signInCode =
    case model.signinForm of
        MagicLink.Types.EnterEmail _ ->
            ( model, Cmd.none )

        EnterSigninCode enterLoginCode ->
            case MagicLink.LoginForm.validateLoginCode signInCode of
                Ok loginCode ->
                    if Dict.member loginCode enterLoginCode.attempts then
                        ( { model
                            | signinForm =
                                EnterSigninCode
                                    { enterLoginCode | loginCode = String.left MagicLink.LoginForm.loginCodeLength signInCode }
                          }
                        , Cmd.none
                        )

                    else
                        ( { model
                            | signinForm =
                                EnterSigninCode
                                    { enterLoginCode
                                        | loginCode = String.left MagicLink.LoginForm.loginCodeLength signInCode
                                        , attempts =
                                            Dict.insert loginCode MagicLink.Types.Checking enterLoginCode.attempts
                                    }
                          }
                        , Lamdera.sendToBackend (SigInWithToken loginCode)
                        )

                Err _ ->
                    ( { model | signinForm = EnterSigninCode { enterLoginCode | loginCode = String.left MagicLink.LoginForm.loginCodeLength signInCode } }
                    , Cmd.none
                    )
