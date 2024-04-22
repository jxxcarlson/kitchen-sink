module Evergreen.Migrate.V135 exposing (..)

{-| This migration file was automatically generated by the lamdera compiler.

It includes:

  - A migration for each of the 6 Lamdera core types that has changed
  - A function named `migrate_ModuleName_TypeName` for each changed/custom type

Expect to see:

  - `Unimplementеd` values as placeholders wherever I was unable to figure out a clear migration path for you
  - `@NOTICE` comments for things you should know about, i.e. new custom type constructors that won't get any
    value mappings from the old type by default

You can edit this file however you wish! It won't be generated again.

See <https://dashboard.lamdera.app/docs/evergreen> for more info.

-}

import AssocList
import Dict
import Evergreen.V134.Email
import Evergreen.V134.EmailAddress
import Evergreen.V134.Id
import Evergreen.V134.KeyValueStore
import Evergreen.V134.Name
import Evergreen.V134.Route
import Evergreen.V134.Session
import Evergreen.V134.Stripe.Codec
import Evergreen.V134.Stripe.Product
import Evergreen.V134.Stripe.PurchaseForm
import Evergreen.V134.Stripe.Stripe
import Evergreen.V134.Token.Types
import Evergreen.V134.Types
import Evergreen.V134.Untrusted
import Evergreen.V134.User
import Evergreen.V135.Email
import Evergreen.V135.EmailAddress
import Evergreen.V135.Id
import Evergreen.V135.KeyValueStore
import Evergreen.V135.Name
import Evergreen.V135.Route
import Evergreen.V135.Session
import Evergreen.V135.Stripe.Codec
import Evergreen.V135.Stripe.Product
import Evergreen.V135.Stripe.PurchaseForm
import Evergreen.V135.Stripe.Stripe
import Evergreen.V135.Token.Types
import Evergreen.V135.Types
import Evergreen.V135.Untrusted
import Evergreen.V135.User
import Lamdera.Migrations exposing (..)
import List
import Maybe


frontendModel : Evergreen.V134.Types.FrontendModel -> ModelMigration Evergreen.V135.Types.FrontendModel Evergreen.V135.Types.FrontendMsg
frontendModel old =
    ModelMigrated ( migrate_Types_FrontendModel old, Cmd.none )


backendModel : Evergreen.V134.Types.BackendModel -> ModelMigration Evergreen.V135.Types.BackendModel Evergreen.V135.Types.BackendMsg
backendModel old =
    ModelUnchanged


frontendMsg : Evergreen.V134.Types.FrontendMsg -> MsgMigration Evergreen.V135.Types.FrontendMsg Evergreen.V135.Types.FrontendMsg
frontendMsg old =
    MsgMigrated ( migrate_Types_FrontendMsg old, Cmd.none )


toBackend : Evergreen.V134.Types.ToBackend -> MsgMigration Evergreen.V135.Types.ToBackend Evergreen.V135.Types.BackendMsg
toBackend old =
    MsgMigrated ( migrate_Types_ToBackend old, Cmd.none )


backendMsg : Evergreen.V134.Types.BackendMsg -> MsgMigration Evergreen.V135.Types.BackendMsg Evergreen.V135.Types.BackendMsg
backendMsg old =
    MsgMigrated ( migrate_Types_BackendMsg old, Cmd.none )


toFrontend : Evergreen.V134.Types.ToFrontend -> MsgMigration Evergreen.V135.Types.ToFrontend Evergreen.V135.Types.FrontendMsg
toFrontend old =
    MsgUnchanged


migrate_AssocList_Dict : (a_old -> a_new) -> (b_old -> b_new) -> AssocList.Dict a_old b_old -> AssocList.Dict a_new b_new
migrate_AssocList_Dict migrate_a migrate_b old =
    old
        |> AssocList.toList
        |> List.map (Tuple.mapBoth migrate_a migrate_b)
        |> AssocList.fromList


migrate_EmailAddress_EmailAddress : Evergreen.V134.EmailAddress.EmailAddress -> Evergreen.V135.EmailAddress.EmailAddress
migrate_EmailAddress_EmailAddress old =
    case old of
        Evergreen.V134.EmailAddress.EmailAddress p0 ->
            Evergreen.V135.EmailAddress.EmailAddress p0


migrate_Email_EmailResult : Evergreen.V134.Email.EmailResult -> Evergreen.V135.Email.EmailResult
migrate_Email_EmailResult old =
    case old of
        Evergreen.V134.Email.SendingEmail ->
            Evergreen.V135.Email.SendingEmail

        Evergreen.V134.Email.EmailSuccess p0 ->
            Evergreen.V135.Email.EmailSuccess (p0 |> migrate_Email_PostmarkSendResponse)

        Evergreen.V134.Email.EmailFailed p0 ->
            Evergreen.V135.Email.EmailFailed p0


migrate_Email_PostmarkSendResponse : Evergreen.V134.Email.PostmarkSendResponse -> Evergreen.V135.Email.PostmarkSendResponse
migrate_Email_PostmarkSendResponse old =
    old


migrate_Id_Id : (a_old -> a_new) -> Evergreen.V134.Id.Id a_old -> Evergreen.V135.Id.Id a_new
migrate_Id_Id migrate_a old =
    case old of
        Evergreen.V134.Id.Id p0 ->
            Evergreen.V135.Id.Id p0


migrate_KeyValueStore_KVDatum : Evergreen.V134.KeyValueStore.KVDatum -> Evergreen.V135.KeyValueStore.KVDatum
migrate_KeyValueStore_KVDatum old =
    old


migrate_KeyValueStore_KVVerbosity : Evergreen.V134.KeyValueStore.KVVerbosity -> Evergreen.V135.KeyValueStore.KVVerbosity
migrate_KeyValueStore_KVVerbosity old =
    case old of
        Evergreen.V134.KeyValueStore.KVVerbose ->
            Evergreen.V135.KeyValueStore.KVVerbose

        Evergreen.V134.KeyValueStore.KVQuiet ->
            Evergreen.V135.KeyValueStore.KVQuiet


migrate_KeyValueStore_KVViewType : Evergreen.V134.KeyValueStore.KVViewType -> Evergreen.V135.KeyValueStore.KVViewType
migrate_KeyValueStore_KVViewType old =
    case old of
        Evergreen.V134.KeyValueStore.KVRaw ->
            Evergreen.V135.KeyValueStore.KVRaw

        Evergreen.V134.KeyValueStore.KVVSummary ->
            Evergreen.V135.KeyValueStore.KVVSummary

        Evergreen.V134.KeyValueStore.KVVKey ->
            Evergreen.V135.KeyValueStore.KVVKey


migrate_Name_Name : Evergreen.V134.Name.Name -> Evergreen.V135.Name.Name
migrate_Name_Name old =
    case old of
        Evergreen.V134.Name.Name p0 ->
            Evergreen.V135.Name.Name p0


migrate_Route_Route : Evergreen.V134.Route.Route -> Evergreen.V135.Route.Route
migrate_Route_Route old =
    case old of
        Evergreen.V134.Route.HomepageRoute ->
            Evergreen.V135.Route.HomepageRoute

        Evergreen.V134.Route.DataStore ->
            Evergreen.V135.Route.DataStore

        Evergreen.V134.Route.EditData ->
            Evergreen.V135.Route.EditData

        Evergreen.V134.Route.Features ->
            Evergreen.V135.Route.Features

        Evergreen.V134.Route.TermsOfServiceRoute ->
            Evergreen.V135.Route.TermsOfServiceRoute

        Evergreen.V134.Route.Notes ->
            Evergreen.V135.Route.Notes

        Evergreen.V134.Route.SignInRoute ->
            Evergreen.V135.Route.SignInRoute

        Evergreen.V134.Route.Brillig ->
            Evergreen.V135.Route.Brillig

        Evergreen.V134.Route.AdminRoute ->
            Evergreen.V135.Route.AdminRoute

        Evergreen.V134.Route.Purchase ->
            Evergreen.V135.Route.Purchase

        Evergreen.V134.Route.PaymentSuccessRoute p0 ->
            Evergreen.V135.Route.PaymentSuccessRoute (p0 |> Maybe.map migrate_EmailAddress_EmailAddress)

        Evergreen.V134.Route.PaymentCancelRoute ->
            Evergreen.V135.Route.PaymentCancelRoute


migrate_Session_Interaction : Evergreen.V134.Session.Interaction -> Evergreen.V135.Session.Interaction
migrate_Session_Interaction old =
    case old of
        Evergreen.V134.Session.ISignIn p0 ->
            Evergreen.V135.Session.ISignIn p0

        Evergreen.V134.Session.ISignOut p0 ->
            Evergreen.V135.Session.ISignOut p0

        Evergreen.V134.Session.ISignUp p0 ->
            Evergreen.V135.Session.ISignUp p0


migrate_Session_SessionInfo : Evergreen.V134.Session.SessionInfo -> Evergreen.V135.Session.SessionInfo
migrate_Session_SessionInfo old =
    old |> Dict.map (\k -> migrate_Session_Interaction)


migrate_Stripe_Codec_Order : Evergreen.V134.Stripe.Codec.Order -> Evergreen.V135.Stripe.Codec.Order
migrate_Stripe_Codec_Order old =
    { priceId = old.priceId |> migrate_Id_Id migrate_Stripe_Stripe_PriceId
    , submitTime = old.submitTime
    , form = old.form |> migrate_Stripe_PurchaseForm_PurchaseFormValidated
    , emailResult = old.emailResult |> migrate_Email_EmailResult
    }


migrate_Stripe_Codec_PendingOrder : Evergreen.V134.Stripe.Codec.PendingOrder -> Evergreen.V135.Stripe.Codec.PendingOrder
migrate_Stripe_Codec_PendingOrder old =
    { priceId = old.priceId |> migrate_Id_Id migrate_Stripe_Stripe_PriceId
    , submitTime = old.submitTime
    , form = old.form |> migrate_Stripe_PurchaseForm_PurchaseFormValidated
    , sessionId = old.sessionId
    }


migrate_Stripe_Codec_Price2 : Evergreen.V134.Stripe.Codec.Price2 -> Evergreen.V135.Stripe.Codec.Price2
migrate_Stripe_Codec_Price2 old =
    { priceId = old.priceId |> migrate_Id_Id migrate_Stripe_Stripe_PriceId
    , price = old.price |> migrate_Stripe_Stripe_Price
    }


migrate_Stripe_Product_Product_ : Evergreen.V134.Stripe.Product.Product_ -> Evergreen.V135.Stripe.Product.Product_
migrate_Stripe_Product_Product_ old =
    old


migrate_Stripe_PurchaseForm_PressedSubmit : Evergreen.V134.Stripe.PurchaseForm.PressedSubmit -> Evergreen.V135.Stripe.PurchaseForm.PressedSubmit
migrate_Stripe_PurchaseForm_PressedSubmit old =
    case old of
        Evergreen.V134.Stripe.PurchaseForm.PressedSubmit ->
            Evergreen.V135.Stripe.PurchaseForm.PressedSubmit

        Evergreen.V134.Stripe.PurchaseForm.NotPressedSubmit ->
            Evergreen.V135.Stripe.PurchaseForm.NotPressedSubmit


migrate_Stripe_PurchaseForm_PurchaseData : Evergreen.V134.Stripe.PurchaseForm.PurchaseData -> Evergreen.V135.Stripe.PurchaseForm.PurchaseData
migrate_Stripe_PurchaseForm_PurchaseData old =
    { billingName = old.billingName |> migrate_Name_Name
    , billingEmail = old.billingEmail |> migrate_EmailAddress_EmailAddress
    }


migrate_Stripe_PurchaseForm_PurchaseForm : Evergreen.V134.Stripe.PurchaseForm.PurchaseForm -> Evergreen.V135.Stripe.PurchaseForm.PurchaseForm
migrate_Stripe_PurchaseForm_PurchaseForm old =
    { submitStatus = old.submitStatus |> migrate_Stripe_PurchaseForm_SubmitStatus
    , name = old.name
    , billingEmail = old.billingEmail
    , country = old.country
    }


migrate_Stripe_PurchaseForm_PurchaseFormValidated : Evergreen.V134.Stripe.PurchaseForm.PurchaseFormValidated -> Evergreen.V135.Stripe.PurchaseForm.PurchaseFormValidated
migrate_Stripe_PurchaseForm_PurchaseFormValidated old =
    case old of
        Evergreen.V134.Stripe.PurchaseForm.ImageCreditPurchase p0 ->
            Evergreen.V135.Stripe.PurchaseForm.ImageCreditPurchase (p0 |> migrate_Stripe_PurchaseForm_PurchaseData)

        Evergreen.V134.Stripe.PurchaseForm.ImageLibraryPackagePurchase p0 ->
            Evergreen.V135.Stripe.PurchaseForm.ImageLibraryPackagePurchase (p0 |> migrate_Stripe_PurchaseForm_PurchaseData)


migrate_Stripe_PurchaseForm_SubmitStatus : Evergreen.V134.Stripe.PurchaseForm.SubmitStatus -> Evergreen.V135.Stripe.PurchaseForm.SubmitStatus
migrate_Stripe_PurchaseForm_SubmitStatus old =
    case old of
        Evergreen.V134.Stripe.PurchaseForm.NotSubmitted p0 ->
            Evergreen.V135.Stripe.PurchaseForm.NotSubmitted (p0 |> migrate_Stripe_PurchaseForm_PressedSubmit)

        Evergreen.V134.Stripe.PurchaseForm.Submitting ->
            Evergreen.V135.Stripe.PurchaseForm.Submitting

        Evergreen.V134.Stripe.PurchaseForm.SubmitBackendError p0 ->
            Evergreen.V135.Stripe.PurchaseForm.SubmitBackendError p0


migrate_Stripe_Stripe_Price : Evergreen.V134.Stripe.Stripe.Price -> Evergreen.V135.Stripe.Stripe.Price
migrate_Stripe_Stripe_Price old =
    old


migrate_Stripe_Stripe_PriceData : Evergreen.V134.Stripe.Stripe.PriceData -> Evergreen.V135.Stripe.Stripe.PriceData
migrate_Stripe_Stripe_PriceData old =
    { priceId = old.priceId |> migrate_Id_Id migrate_Stripe_Stripe_PriceId
    , price = old.price |> migrate_Stripe_Stripe_Price
    , productId = old.productId |> migrate_Id_Id migrate_Stripe_Stripe_ProductId
    , isActive = old.isActive
    , createdAt = old.createdAt
    }


migrate_Stripe_Stripe_PriceId : Evergreen.V134.Stripe.Stripe.PriceId -> Evergreen.V135.Stripe.Stripe.PriceId
migrate_Stripe_Stripe_PriceId old =
    case old of
        Evergreen.V134.Stripe.Stripe.PriceId p0 ->
            Evergreen.V135.Stripe.Stripe.PriceId p0


migrate_Stripe_Stripe_ProductId : Evergreen.V134.Stripe.Stripe.ProductId -> Evergreen.V135.Stripe.Stripe.ProductId
migrate_Stripe_Stripe_ProductId old =
    case old of
        Evergreen.V134.Stripe.Stripe.ProductId p0 ->
            Evergreen.V135.Stripe.Stripe.ProductId p0


migrate_Stripe_Stripe_ProductInfo : Evergreen.V134.Stripe.Stripe.ProductInfo -> Evergreen.V135.Stripe.Stripe.ProductInfo
migrate_Stripe_Stripe_ProductInfo old =
    old


migrate_Stripe_Stripe_ProductInfoDict : Evergreen.V134.Stripe.Stripe.ProductInfoDict -> Evergreen.V135.Stripe.Stripe.ProductInfoDict
migrate_Stripe_Stripe_ProductInfoDict old =
    old |> migrate_AssocList_Dict (migrate_Id_Id migrate_Stripe_Stripe_ProductId) migrate_Stripe_Stripe_ProductInfo


migrate_Stripe_Stripe_StripeSessionId : Evergreen.V134.Stripe.Stripe.StripeSessionId -> Evergreen.V135.Stripe.Stripe.StripeSessionId
migrate_Stripe_Stripe_StripeSessionId old =
    case old of
        Evergreen.V134.Stripe.Stripe.StripeSessionId p0 ->
            Evergreen.V135.Stripe.Stripe.StripeSessionId p0


migrate_Token_Types_EnterEmail2 : Evergreen.V134.Token.Types.EnterEmail2 -> Evergreen.V135.Token.Types.EnterEmail2
migrate_Token_Types_EnterEmail2 old =
    old


migrate_Token_Types_EnterLoginCode2 : Evergreen.V134.Token.Types.EnterLoginCode2 -> Evergreen.V135.Token.Types.EnterLoginCode2
migrate_Token_Types_EnterLoginCode2 old =
    { sentTo = old.sentTo |> migrate_EmailAddress_EmailAddress
    , loginCode = old.loginCode
    , attempts = old.attempts |> Dict.map (\k -> migrate_Token_Types_LoginCodeStatus)
    }


migrate_Token_Types_Log : Evergreen.V134.Token.Types.Log -> Evergreen.V135.Token.Types.Log
migrate_Token_Types_Log old =
    old |> List.map (Tuple.mapSecond migrate_Token_Types_LogItem)


migrate_Token_Types_LogItem : Evergreen.V134.Token.Types.LogItem -> Evergreen.V135.Token.Types.LogItem
migrate_Token_Types_LogItem old =
    case old of
        Evergreen.V134.Token.Types.LoginsRateLimited p0 ->
            Evergreen.V135.Token.Types.LoginsRateLimited p0

        Evergreen.V134.Token.Types.FailedToCreateLoginCode p0 ->
            Evergreen.V135.Token.Types.FailedToCreateLoginCode p0


migrate_Token_Types_LoginCodeStatus : Evergreen.V134.Token.Types.LoginCodeStatus -> Evergreen.V135.Token.Types.LoginCodeStatus
migrate_Token_Types_LoginCodeStatus old =
    case old of
        Evergreen.V134.Token.Types.Checking ->
            Evergreen.V135.Token.Types.Checking

        Evergreen.V134.Token.Types.NotValid ->
            Evergreen.V135.Token.Types.NotValid


migrate_Token_Types_LoginForm : Evergreen.V134.Token.Types.LoginForm -> Evergreen.V135.Token.Types.LoginForm
migrate_Token_Types_LoginForm old =
    case old of
        Evergreen.V134.Token.Types.EnterEmail p0 ->
            Evergreen.V135.Token.Types.EnterEmail (p0 |> migrate_Token_Types_EnterEmail2)

        Evergreen.V134.Token.Types.EnterLoginCode p0 ->
            Evergreen.V135.Token.Types.EnterLoginCode (p0 |> migrate_Token_Types_EnterLoginCode2)


migrate_Types_AdminDisplay : Evergreen.V134.Types.AdminDisplay -> Evergreen.V135.Types.AdminDisplay
migrate_Types_AdminDisplay old =
    case old of
        Evergreen.V134.Types.ADStripe ->
            Evergreen.V135.Types.ADStripe

        Evergreen.V134.Types.ADUser ->
            Evergreen.V135.Types.ADUser

        Evergreen.V134.Types.ADKeyValues ->
            Evergreen.V135.Types.ADKeyValues


migrate_Types_BackendModel : Evergreen.V134.Types.BackendModel -> Evergreen.V135.Types.BackendModel
migrate_Types_BackendModel old =
    { randomAtmosphericNumbers = old.randomAtmosphericNumbers
    , localUuidData = old.localUuidData
    , time = old.time
    , secretCounter = old.secretCounter
    , sessionDict = old.sessionDict
    , pendingLogins =
        old.pendingLogins
            |> migrate_AssocList_Dict identity
                (\rec ->
                    { loginAttempts = rec.loginAttempts
                    , emailAddress = rec.emailAddress |> migrate_EmailAddress_EmailAddress
                    , creationTime = rec.creationTime
                    , loginCode = rec.loginCode
                    }
                )
    , log = old.log |> migrate_Token_Types_Log
    , userDictionary = old.userDictionary |> Dict.map (\k -> migrate_User_User)
    , sessions = old.sessions
    , sessionInfo = old.sessionInfo |> migrate_Session_SessionInfo
    , orders = old.orders |> migrate_AssocList_Dict (migrate_Id_Id migrate_Stripe_Stripe_StripeSessionId) migrate_Stripe_Codec_Order
    , pendingOrder = old.pendingOrder |> migrate_AssocList_Dict (migrate_Id_Id migrate_Stripe_Stripe_StripeSessionId) migrate_Stripe_Codec_PendingOrder
    , expiredOrders = old.expiredOrders |> migrate_AssocList_Dict (migrate_Id_Id migrate_Stripe_Stripe_StripeSessionId) migrate_Stripe_Codec_PendingOrder
    , prices = old.prices |> migrate_AssocList_Dict (migrate_Id_Id migrate_Stripe_Stripe_ProductId) migrate_Stripe_Codec_Price2
    , products = old.products |> migrate_Stripe_Stripe_ProductInfoDict
    , keyValueStore = old.keyValueStore
    }


migrate_Types_BackendMsg : Evergreen.V134.Types.BackendMsg -> Evergreen.V135.Types.BackendMsg
migrate_Types_BackendMsg old =
    case old of
        Evergreen.V134.Types.GotTime p0 ->
            Evergreen.V135.Types.GotSlowTick p0

        Evergreen.V134.Types.OnConnected p0 p1 ->
            Evergreen.V135.Types.OnConnected p0 p1

        Evergreen.V134.Types.GotAtmosphericRandomNumbers p0 ->
            Evergreen.V135.Types.GotAtmosphericRandomNumbers p0

        Evergreen.V134.Types.BackendGotTime p0 p1 p2 p3 ->
            Evergreen.V135.Types.BackendGotTime p0 p1 (p2 |> migrate_Types_ToBackend) p3

        Evergreen.V134.Types.SentLoginEmail p0 p1 p2 ->
            Evergreen.V135.Types.SentLoginEmail p0 (p1 |> migrate_EmailAddress_EmailAddress) p2

        Evergreen.V134.Types.AuthenticationConfirmationEmailSent p0 ->
            Evergreen.V135.Types.AuthenticationConfirmationEmailSent p0

        Evergreen.V134.Types.GotPrices p0 ->
            Evergreen.V135.Types.GotPrices (p0 |> Result.map (List.map migrate_Stripe_Stripe_PriceData))

        Evergreen.V134.Types.GotPrices2 p0 p1 ->
            Evergreen.V135.Types.GotPrices2 p0
                (p1 |> Result.map (List.map migrate_Stripe_Stripe_PriceData))

        Evergreen.V134.Types.CreatedCheckoutSession p0 p1 p2 p3 p4 ->
            Evergreen.V135.Types.CreatedCheckoutSession p0
                p1
                (p2 |> migrate_Id_Id migrate_Stripe_Stripe_PriceId)
                (p3 |> migrate_Stripe_PurchaseForm_PurchaseFormValidated)
                (p4 |> Result.map (Tuple.mapFirst (migrate_Id_Id migrate_Stripe_Stripe_StripeSessionId)))

        Evergreen.V134.Types.ExpiredStripeSession p0 p1 ->
            Evergreen.V135.Types.ExpiredStripeSession (p0 |> migrate_Id_Id migrate_Stripe_Stripe_StripeSessionId)
                p1

        Evergreen.V134.Types.ConfirmationEmailSent p0 p1 ->
            Evergreen.V135.Types.ConfirmationEmailSent (p0 |> migrate_Id_Id migrate_Stripe_Stripe_StripeSessionId)
                p1

        Evergreen.V134.Types.ErrorEmailSent p0 ->
            Evergreen.V135.Types.ErrorEmailSent p0

        Evergreen.V134.Types.GotWeatherData p0 p1 ->
            Evergreen.V135.Types.GotWeatherData p0 p1


migrate_Types_FrontendModel : Evergreen.V134.Types.FrontendModel -> Evergreen.V135.Types.FrontendModel
migrate_Types_FrontendModel old =
    case old of
        Evergreen.V134.Types.Loading p0 ->
            Evergreen.V135.Types.Loading (p0 |> migrate_Types_LoadingModel)

        Evergreen.V134.Types.Loaded p0 ->
            Evergreen.V135.Types.Loaded (p0 |> migrate_Types_LoadedModel)


migrate_Types_FrontendMsg : Evergreen.V134.Types.FrontendMsg -> Evergreen.V135.Types.FrontendMsg
migrate_Types_FrontendMsg old =
    case old of
        Evergreen.V134.Types.NoOp ->
            Evergreen.V135.Types.NoOp

        Evergreen.V134.Types.UrlClicked p0 ->
            Evergreen.V135.Types.UrlClicked p0

        Evergreen.V134.Types.UrlChanged p0 ->
            Evergreen.V135.Types.UrlChanged p0

        Evergreen.V134.Types.Tick p0 ->
            Evergreen.V135.Types.Tick p0

        Evergreen.V134.Types.GotWindowSize p0 p1 ->
            Evergreen.V135.Types.GotWindowSize p0 p1

        Evergreen.V134.Types.PressedShowTooltip ->
            Evergreen.V135.Types.PressedShowTooltip

        Evergreen.V134.Types.MouseDown ->
            Evergreen.V135.Types.MouseDown

        Evergreen.V134.Types.PressedSubmitEmail ->
            Evergreen.V135.Types.PressedSubmitEmail

        Evergreen.V134.Types.PressedCancelLogin ->
            Evergreen.V135.Types.PressedCancelLogin

        Evergreen.V134.Types.TypedLoginFormEmail p0 ->
            Evergreen.V135.Types.TypedLoginFormEmail p0

        Evergreen.V134.Types.TypedLoginCode p0 ->
            Evergreen.V135.Types.TypedLoginCode p0

        Evergreen.V134.Types.BuyProduct p0 p1 p2 ->
            Evergreen.V135.Types.BuyProduct (p0 |> migrate_Id_Id migrate_Stripe_Stripe_ProductId)
                (p1 |> migrate_Id_Id migrate_Stripe_Stripe_PriceId)
                (p2 |> migrate_Stripe_Product_Product_)

        Evergreen.V134.Types.PressedSelectTicket p0 p1 ->
            Evergreen.V135.Types.PressedSelectTicket (p0 |> migrate_Id_Id migrate_Stripe_Stripe_ProductId)
                (p1 |> migrate_Id_Id migrate_Stripe_Stripe_PriceId)

        Evergreen.V134.Types.FormChanged p0 ->
            Evergreen.V135.Types.FormChanged (p0 |> migrate_Stripe_PurchaseForm_PurchaseForm)

        Evergreen.V134.Types.PressedSubmitForm p0 p1 ->
            Evergreen.V135.Types.PressedSubmitForm (p0 |> migrate_Id_Id migrate_Stripe_Stripe_ProductId)
                (p1 |> migrate_Id_Id migrate_Stripe_Stripe_PriceId)

        Evergreen.V134.Types.PressedCancelForm ->
            Evergreen.V135.Types.PressedCancelForm

        Evergreen.V134.Types.AskToRenewPrices ->
            Evergreen.V135.Types.AskToRenewPrices

        Evergreen.V134.Types.SignIn ->
            Evergreen.V135.Types.NoOp

        Evergreen.V134.Types.SetSignInState p0 ->
            Evergreen.V135.Types.NoOp

        Evergreen.V134.Types.SubmitSignIn ->
            Evergreen.V135.Types.NoOp

        Evergreen.V134.Types.SubmitSignOut ->
            Evergreen.V135.Types.NoOp

        Evergreen.V134.Types.SubmitSignUp ->
            Evergreen.V135.Types.SubmitSignUp

        Evergreen.V134.Types.InputRealname p0 ->
            Evergreen.V135.Types.InputRealname p0

        Evergreen.V134.Types.InputUsername p0 ->
            Evergreen.V135.Types.InputUsername p0

        Evergreen.V134.Types.InputEmail p0 ->
            Evergreen.V135.Types.InputEmail p0

        Evergreen.V134.Types.InputPassword p0 ->
            Evergreen.V135.Types.NoOp

        Evergreen.V134.Types.InputPasswordConfirmation p0 ->
            Evergreen.V135.Types.NoOp

        Evergreen.V134.Types.SetAdminDisplay p0 ->
            Evergreen.V135.Types.SetAdminDisplay (p0 |> migrate_Types_AdminDisplay)

        Evergreen.V134.Types.SetViewport ->
            Evergreen.V135.Types.SetViewport

        Evergreen.V134.Types.LanguageChanged p0 ->
            Evergreen.V135.Types.LanguageChanged p0

        Evergreen.V134.Types.CopyTextToClipboard p0 ->
            Evergreen.V135.Types.CopyTextToClipboard p0

        Evergreen.V134.Types.Chirp ->
            Evergreen.V135.Types.Chirp

        Evergreen.V134.Types.RequestWeatherData p0 ->
            Evergreen.V135.Types.RequestWeatherData p0

        Evergreen.V134.Types.InputCity p0 ->
            Evergreen.V135.Types.InputCity p0

        Evergreen.V134.Types.InputKey p0 ->
            Evergreen.V135.Types.InputKey p0

        Evergreen.V134.Types.InputValue p0 ->
            Evergreen.V135.Types.InputValue p0

        Evergreen.V134.Types.InputFilterData p0 ->
            Evergreen.V135.Types.InputFilterData p0

        Evergreen.V134.Types.NewKeyValuePair ->
            Evergreen.V135.Types.NewKeyValuePair

        Evergreen.V134.Types.AddKeyValuePair p0 p1 ->
            Evergreen.V135.Types.AddKeyValuePair p0 (p1 |> migrate_KeyValueStore_KVDatum)

        Evergreen.V134.Types.GetValueWithKey p0 ->
            Evergreen.V135.Types.GetValueWithKey p0

        Evergreen.V134.Types.GotValue p0 ->
            Evergreen.V135.Types.GotValueFromKVStore p0

        Evergreen.V134.Types.DataUploaded p0 ->
            Evergreen.V135.Types.DataUploaded p0

        Evergreen.V134.Types.SetKVViewType p0 ->
            Evergreen.V135.Types.SetKVViewType (p0 |> migrate_KeyValueStore_KVViewType)

        Evergreen.V134.Types.CycleVerbosity p0 ->
            Evergreen.V135.Types.CycleVerbosity (p0 |> migrate_KeyValueStore_KVVerbosity)


migrate_Types_InitData2 : Evergreen.V134.Types.InitData2 -> Evergreen.V135.Types.InitData2
migrate_Types_InitData2 old =
    { prices =
        old.prices
            |> migrate_AssocList_Dict (migrate_Id_Id migrate_Stripe_Stripe_ProductId)
                (\rec ->
                    { priceId = rec.priceId |> migrate_Id_Id migrate_Stripe_Stripe_PriceId
                    , price = rec.price |> migrate_Stripe_Stripe_Price
                    }
                )
    , productInfo = old.productInfo |> migrate_AssocList_Dict (migrate_Id_Id migrate_Stripe_Stripe_ProductId) migrate_Stripe_Stripe_ProductInfo
    }


migrate_Types_LoadedModel : Evergreen.V134.Types.LoadedModel -> Evergreen.V135.Types.LoadedModel
migrate_Types_LoadedModel old =
    { key = old.key
    , now = old.now
    , window =
        old.window
            |> (\rec -> rec)
    , showTooltip = old.showTooltip
    , loginForm = old.loginForm |> migrate_Token_Types_LoginForm
    , loginErrorMessage = Nothing
    , currentUserData = Nothing
    , prices =
        old.prices
            |> migrate_AssocList_Dict (migrate_Id_Id migrate_Stripe_Stripe_ProductId)
                (\rec ->
                    { priceId = rec.priceId |> migrate_Id_Id migrate_Stripe_Stripe_PriceId
                    , price = rec.price |> migrate_Stripe_Stripe_Price
                    }
                )
    , productInfoDict = old.productInfoDict |> migrate_AssocList_Dict (migrate_Id_Id migrate_Stripe_Stripe_ProductId) migrate_Stripe_Stripe_ProductInfo
    , selectedProduct = old.selectedProduct |> Maybe.map (\( t1, t2, t3 ) -> ( t1 |> migrate_Id_Id migrate_Stripe_Stripe_ProductId, t2 |> migrate_Id_Id migrate_Stripe_Stripe_PriceId, t3 |> migrate_Stripe_Product_Product_ ))
    , form = old.form |> migrate_Stripe_PurchaseForm_PurchaseForm
    , currentUser = old.currentUser |> Maybe.map migrate_User_User
    , signInState = old.signInState |> migrate_Types_SignInState
    , realname = old.realname
    , username = old.username
    , email = old.email
    , password = old.password
    , passwordConfirmation = old.passwordConfirmation
    , adminDisplay = old.adminDisplay |> migrate_Types_AdminDisplay
    , backendModel = old.backendModel |> Maybe.map migrate_Types_BackendModel
    , route = old.route |> migrate_Route_Route
    , message = old.message
    , language = old.language
    , weatherData = old.weatherData
    , inputCity = old.inputCity
    , currentKVPair = old.currentKVPair
    , keyValueStore = old.keyValueStore
    , inputKey = old.inputKey
    , inputValue = old.inputValue
    , inputFilterData = old.inputFilterData
    , kvViewType = old.kvViewType |> migrate_KeyValueStore_KVViewType
    , kvVerbosity = old.kvVerbosity |> migrate_KeyValueStore_KVVerbosity
    }


migrate_Types_LoadingModel : Evergreen.V134.Types.LoadingModel -> Evergreen.V135.Types.LoadingModel
migrate_Types_LoadingModel old =
    { key = old.key
    , now = old.now
    , window = old.window
    , route = old.route |> migrate_Route_Route
    , initData = old.initData |> Maybe.map migrate_Types_InitData2
    }


migrate_Types_SignInState : Evergreen.V134.Types.SignInState -> Evergreen.V135.Types.SignInState
migrate_Types_SignInState old =
    case old of
        Evergreen.V134.Types.SignedOut ->
            Evergreen.V135.Types.SignedOut

        Evergreen.V134.Types.SignUp ->
            Evergreen.V135.Types.SignUp

        Evergreen.V134.Types.SignedIn ->
            Evergreen.V135.Types.SignedIn


migrate_Types_ToBackend : Evergreen.V134.Types.ToBackend -> Evergreen.V135.Types.ToBackend
migrate_Types_ToBackend old =
    case old of
        Evergreen.V134.Types.SubmitFormRequest p0 p1 ->
            Evergreen.V135.Types.SubmitFormRequest (p0 |> migrate_Id_Id migrate_Stripe_Stripe_PriceId)
                (p1 |> migrate_Untrusted_Untrusted migrate_Stripe_PurchaseForm_PurchaseFormValidated)

        Evergreen.V134.Types.CancelPurchaseRequest ->
            Evergreen.V135.Types.CancelPurchaseRequest

        Evergreen.V134.Types.AdminInspect p0 ->
            Evergreen.V135.Types.AdminInspect (p0 |> Maybe.map migrate_User_User)

        Evergreen.V134.Types.CheckLoginRequest ->
            Evergreen.V135.Types.CheckLoginRequest

        Evergreen.V134.Types.LoginWithTokenRequest p0 ->
            Evergreen.V135.Types.LoginWithTokenRequest p0

        Evergreen.V134.Types.GetLoginTokenRequest p0 ->
            Evergreen.V135.Types.GetLoginTokenRequest (p0 |> migrate_EmailAddress_EmailAddress)

        Evergreen.V134.Types.LogOutRequest ->
            Evergreen.V135.Types.LogOutRequest

        Evergreen.V134.Types.RenewPrices ->
            Evergreen.V135.Types.RenewPrices

        Evergreen.V134.Types.SignInRequest p0 p1 ->
            Evergreen.V135.Types.SignInRequest p0 p1

        Evergreen.V134.Types.SignOutRequest p0 ->
            Evergreen.V135.Types.SignOutRequest p0

        Evergreen.V134.Types.SignUpRequest p0 p1 p2 p3 ->
            Evergreen.V135.Types.SignUpRequest p0 p1 p2 p3

        Evergreen.V134.Types.GetWeatherData p0 ->
            Evergreen.V135.Types.GetWeatherData p0

        Evergreen.V134.Types.GetKeyValueStore ->
            Evergreen.V135.Types.GetKeyValueStore


migrate_Untrusted_Untrusted : (a_old -> a_new) -> Evergreen.V134.Untrusted.Untrusted a_old -> Evergreen.V135.Untrusted.Untrusted a_new
migrate_Untrusted_Untrusted migrate_a old =
    case old of
        Evergreen.V134.Untrusted.Untrusted p0 ->
            Evergreen.V135.Untrusted.Untrusted (p0 |> migrate_a)


migrate_User_Role : Evergreen.V134.User.Role -> Evergreen.V135.User.Role
migrate_User_Role old =
    case old of
        Evergreen.V134.User.AdminRole ->
            Evergreen.V135.User.AdminRole

        Evergreen.V134.User.UserRole ->
            Evergreen.V135.User.UserRole


migrate_User_User : Evergreen.V134.User.User -> Evergreen.V135.User.User
migrate_User_User old =
    { id = old.id
    , realname = old.realname
    , username = old.username
    , email = old.email |> migrate_EmailAddress_EmailAddress
    , created_at = old.created_at
    , updated_at = old.updated_at
    , role = old.role |> migrate_User_Role
    , recentLoginEmails = old.recentLoginEmails
    }
