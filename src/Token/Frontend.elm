module Token.Frontend exposing (useReceivedCodeToSignIn)

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
import Token.LoginForm
import Token.Types exposing (LoginForm(..))
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


useReceivedCodeToSignIn model loginCodeText =
    case model.loginForm of
        EnterEmail loginForm_ ->
            let
                loginForm =
                    { loginForm_ | email = loginCodeText }
            in
            ( { model | loginForm = EnterEmail loginForm }, Cmd.none )

        EnterLoginCode loginCode_ ->
            -- TODO: complete this
            --  EnterLoginCode{ sentTo : EmailAddress, loginCode : String, attempts : Dict Int LoginCodeStatus }
            ( model, Cmd.none )
