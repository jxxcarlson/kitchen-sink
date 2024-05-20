module MagicToken.Frontend exposing
    ( enterEmail
    , handleRegistrationError
    , handleSignInError
    , signInWithCode
    , signInWithTokenResponse
    , signOut
    , submitEmailForToken
    , submitSignUp
    , userRegistered
    )

import AssocList
import Browser exposing (UrlRequest(..))
import Browser.Dom
import Browser.Events
import Browser.Navigation
import Dict
import EmailAddress
import Env
import Json.Decode
import Json.Encode
import KeyValueStore
import Lamdera
import MagicToken.LoginForm
import MagicToken.Types exposing (LoginForm(..))
import Ports
import RPC
import Route exposing (Route(..))
import Stripe.Product as Tickets exposing (Product_)
import Stripe.PurchaseForm as PurchaseForm
    exposing
        ( PressedSubmit(..)
        , PurchaseForm
        , PurchaseFormValidated(..)
        , SubmitStatus(..)
        )
import Stripe.Stripe as Stripe
import Stripe.View
import Task
import Time
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
import Untrusted
import Url
import Url.Parser exposing ((</>), (<?>))
import Url.Parser.Query as Query
import User
import View.Main


enterEmail model email =
    case model.loginForm of
        EnterEmail loginForm_ ->
            let
                loginForm =
                    { loginForm_ | email = email }
            in
            ( { model | loginForm = EnterEmail loginForm }, Cmd.none )

        EnterLoginCode loginCode_ ->
            -- TODO: complete this
            --  EnterLoginCode{ sentTo : EmailAddress, loginCode : String, attempts : Dict Int LoginCodeStatus }
            ( model, Cmd.none )


handleRegistrationError model str =
    ( { model | signInStatus = MagicToken.Types.ErrorNotRegistered str }, Cmd.none )


handleSignInError model message =
    ( { model | loginErrorMessage = Just message, signInStatus = MagicToken.Types.ErrorNotRegistered message }, Cmd.none )


signInWithTokenResponse model result =
    case result of
        Err _ ->
            ( { model | loginErrorMessage = Just "Invalid login code" }, Cmd.none )

        Ok signInData ->
            let
                adminCommand =
                    case signInData.role of
                        User.AdminRole ->
                            Lamdera.sendToBackend GetBackendModel

                        User.UserRole ->
                            Cmd.none
            in
            ( { model | currentUserData = Just signInData, route = HomepageRoute }, adminCommand )


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
        , loginForm = MagicToken.LoginForm.init
        , loginErrorMessage = Nothing
        , signInStatus = MagicToken.Types.NotSignedIn

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
        , signInStatus = MagicToken.Types.SuccessfulRegistration user.username (EmailAddress.toString user.email)
      }
    , Cmd.none
    )


submitEmailForToken : LoadedModel -> ( LoadedModel, Cmd FrontendMsg )
submitEmailForToken model =
    case model.loginForm of
        EnterEmail loginForm ->
            case EmailAddress.fromString loginForm.email of
                Just email ->
                    ( { model | loginForm = EnterLoginCode { sentTo = email, loginCode = "", attempts = Dict.empty } }
                    , Lamdera.sendToBackend (RequestMagicToken email)
                    )

                Nothing ->
                    ( { model | loginForm = EnterEmail { loginForm | pressedSubmitEmail = True } }, Cmd.none )

        EnterLoginCode _ ->
            -- TODO: handle EnterLoginCode with parameter loginCode instead of _ ??
            ( model, Cmd.none )



-- HELPERS


signInWithCode model signInCode =
    case model.loginForm of
        MagicToken.Types.EnterEmail _ ->
            ( model, Cmd.none )

        EnterLoginCode enterLoginCode ->
            case MagicToken.LoginForm.validateLoginCode signInCode of
                Ok loginCode ->
                    if Dict.member loginCode enterLoginCode.attempts then
                        ( { model
                            | loginForm =
                                EnterLoginCode
                                    { enterLoginCode | loginCode = String.left MagicToken.LoginForm.loginCodeLength signInCode }
                          }
                        , Cmd.none
                        )

                    else
                        ( { model
                            | loginForm =
                                EnterLoginCode
                                    { enterLoginCode
                                        | loginCode = String.left MagicToken.LoginForm.loginCodeLength signInCode
                                        , attempts =
                                            Dict.insert loginCode MagicToken.Types.Checking enterLoginCode.attempts
                                    }
                          }
                        , Lamdera.sendToBackend (SigInWithTokenRequest loginCode)
                        )

                Err _ ->
                    ( { model | loginForm = EnterLoginCode { enterLoginCode | loginCode = String.left MagicToken.LoginForm.loginCodeLength signInCode } }
                    , Cmd.none
                    )
