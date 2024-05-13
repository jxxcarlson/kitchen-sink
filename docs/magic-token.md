# Authentication Using Magic Tokens

(D R A F T)

This document describes an authorization system using "magic-tokens"
and gives directions for the needed copy-paste work that needs to be
done to take the code from the demo app [elm-kitchen-sink.lamdera.app](https://elm-kitchen-sink.lamdera.app) 
and implant it in your app.  The code for the 
demo app is at [github.com/jxxcarlson/kitchen-sink](https://github.com/jxxcarlson/kitchen-sink).

## Operation

The magic token authentication system works as follows. First, a user must 
register with the system by providing an email address, full name, and a
user name.  To register, go to the **Sign in** page, click on the **Sign up**
button, and fill in the needed information.

Once you are registered, you may login.  First, enter your email address 
in the provided slot on the **Sign in** page.  Second, click on the 
**Sign in** button.  Doing this will cause an email to be sent to you
with an eight digit code.  When you get the email, copy the code, then
paste it in to the box provided for that purpose on the sign-in page.
You are now signed in.  You will remain signed in in the web browser 
that you have used for 30 days.  After that, you will need to repeat 
this process.  

You may close the app and re-open it whenever you wish in the 30-day
period.  If you do not seem to be siged in, refresh your browser.

If you wish to "disconnect" your access to the app for a while, click
on the **Sign out** button.

## Pros and Cons

An advantage of the magic token system is its security.  An app which 
uses it stores no confidential data, e.g., passwords.  The only things
it know about you are your full name, your username, and your email
address.  Consequenty, if the app and its data is compromised (hacked!),
the bad people will not be in a position to do much harm. 

A disadvantage is that the user has to occasionally refresh access to the
app by providing his email address, as described above.

# Implementing the Magic Token system in another app

The following additions must be made:

## Types

### FrontendMsg

```
| SubmitEmailForToken
| CancelSignIn
| TypedEmailInSignInForm String
| UseReceivedCodetoSignIn String
| SignOut
```    

### BackendMsg

```
| AutoLogin SessionId User.LoginData
| BackendGotTime SessionId ClientId ToBackend Time.Posix
| SentLoginEmail Time.Posix EmailAddress (Result Http.Error Postmark.PostmarkSendResponse)
| AuthenticationConfirmationEmailSent (Result Http.Error Postmark.PostmarkSendResponse)
```

### ToBackend

```
| CheckLoginRequest
| SigInWithTokenRequest Int
| GetSignInTokenRequest EmailAddress
| SignOutRequest (Maybe User.LoginData)
```

### ToFrontend

```
| CheckSignInResponse (Result BackendDataStatus User.LoginData)
| SignInWithTokenResponse (Result Int User.LoginData)
| GetLoginTokenRateLimited
| LoggedOutSession
| RegistrationError String
| SignInError String
```


### LoadedModel

```
, loginForm : Token.Types.LoginForm
, loginErrorMessage : Maybe String
, signInStatus : Token.Types.SignInStatus
, currentUserData : Maybe User.LoginData
```

### BackendModel

```
, secretCounter : Int
, sessionDict : AssocList.Dict SessionId String -- Dict sessionId usernames
, pendingLogins :
    AssocList.Dict
        SessionId
        { loginAttempts : Int
        , emailAddress : EmailAddress
        , creationTime : Time.Posix
        , loginCode : Int
        }
, log : Token.Types.Log
, userDictionary : Dict.Dict String User.User
, sessions : Session.Sessions
, sessionInfo : Session.SessionInfo
```

## Modules to add

```
Token.Types
Token.Backend
Token.Frontend
Token.LoginForm
Pages.SignIn -- attach this to your routing/page system
```

## Add to Backend

### Imports

```
import Token.Backend
```

### Function init

```
, secretCounter = 0
, sessionDict = AssocList.empty
, pendingLogins = AssocList.empty
, log = []
```
### Function update

```
SentLoginEmail _ _ _ ->
            -- TODO
            ( model, Cmd.none )

        AuthenticationConfirmationEmailSent _ ->
            -- TODO
            ( model, Cmd.none )

        AutoLogin sessionId loginData ->
            ( model, Lamdera.sendToFrontend sessionId (SignInWithTokenResponse <| Ok <| loginData) )

        OnConnected sessionId clientId ->
            let
                _ =
                    Debug.log "@##!OnConnected (1)" ( sessionId, clientId )

                maybeUsername : Maybe String
                maybeUsername =
                    BiDict.get sessionId model.sessions

                maybeUserData : Maybe User.LoginData
                maybeUserData =
                    Maybe.andThen (\username -> Dict.get username model.userDictionary) maybeUsername
                        |> Maybe.map User.loginDataOfUser
                        |> Debug.log "@##! OnConnected, loginDataOfUser (2)"
            in
            ( model
            , Cmd.batch
                [ BackendHelper.getAtmosphericRandomNumbers
                , Backend.Session.reconnect model sessionId clientId
                , Lamdera.sendToFrontend clientId (GotKeyValueStore model.keyValueStore)

                ---, Lamdera.sendToFrontend sessionId (GotMessage "Connected")
                , Lamdera.sendToFrontend
                    clientId
                    (InitData
                        { prices = model.prices
                        , productInfo = model.products
                        }
                    )
                , case AssocList.get sessionId model.sessionDict of
                    Just username ->
                        case Dict.get username model.userDictionary of
                            Just user ->
                                -- Lamdera.sendToFrontend sessionId (LoginWithTokenResponse <| Ok <| Debug.log "@##! send loginDATA" <| User.loginDataOfUser user)
                                Process.sleep 60 |> Task.perform (always (AutoLogin sessionId (User.loginDataOfUser user)))

                            Nothing ->
                                Lamdera.sendToFrontend clientId (SignInWithTokenResponse (Err 0))

                    Nothing ->
                        Lamdera.sendToFrontend clientId (SignInWithTokenResponse (Err 1))
                ]
            )
```

### Function updateFromFrontend

```
 AddUser realname username email ->
        Token.Backend.addUser model clientId email realname username

CheckLoginRequest ->
    Token.Backend.checkLogin model clientId sessionId

GetSignInTokenRequest email ->
    Token.Backend.sendLoginEmail model clientId sessionId email

RequestSignup realname username email ->
    Token.Backend.requestSignUp model clientId realname username email

SigInWithTokenRequest loginCode ->
    Token.Backend.loginWithToken model.time sessionId clientId loginCode model

SignOutRequest userData ->
    Token.Backend.signOut model clientId userData
```


    
## Add to Frontend

### Imports

```
import Token.Frontend
import Token.LoginForm
import Token.Types exposing (LoginForm(..))
```

### Function tryLoading

```
-- in (Loaded { ... }
    , loginForm = Token.LoginForm.init
    , loginErrorMessage = Nothing
    , signInStatus = Token.Types.NotSignedIn
```

```
-- in updateLoaded, case msg
 CancelSignIn ->
            ( { model | route = HomepageRoute }, Cmd.none )

        CancelSignUp ->
            ( { model | signInStatus = Token.Types.NotSignedIn }, Cmd.none )

        OpenSignUp ->
            ( { model | signInStatus = Token.Types.SigningUp }, Cmd.none )

        SubmitEmailForToken ->
            Token.Frontend.submitEmailForToken model

        TypedEmailInSignInForm email ->
            Token.Frontend.enterEmail model (Debug.log "@##" email)

        UseReceivedCodetoSignIn loginCode ->
            Token.Frontend.signInWithCode model loginCode

        SubmitSignUp ->
            Token.Frontend.submitSignUp model

        SignOut ->
            Token.Frontend.signOut model

        InputRealname str ->
            ( { model | realname = str }, Cmd.none )

        InputUsername str ->
            ( { model | username = str }, Cmd.none )

        InputEmail str ->
            ( { model | email = str }, Cmd.none )
```

### Function updateFromBackendLoaded

```
SignInError message ->
    Token.Frontend.handleSignInError model message

RegistrationError str ->
    Token.Frontend.handleRegistrationError model str

CheckSignInResponse _ ->
    ( model, Cmd.none )

SignInWithTokenResponse result ->
    Token.Frontend.signInWithTokenResponse model result

GetLoginTokenRateLimited ->
    ( model, Cmd.none )

LoggedOutSession ->
    ( model, Cmd.none )

UserRegistered user ->
    Token.Frontend.userRegistered model user

UserSignedIn maybeUser ->
    ( { model | signInStatus = Token.Types.NotSignedIn }, Cmd.none )
```


    