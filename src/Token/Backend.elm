module Token.Backend exposing
    ( addUser
    , checkLogin
    , loginWithToken
    , requestSignUp
    , sendLoginEmail
    , sentLoginEmail
    , signOut
    )

import AssocList
import Backend.Session
import BackendHelper
import BiDict
import Config
import Dict
import Duration
import Email.Html
import Email.Html.Attributes
import EmailAddress exposing (EmailAddress)
import Hex
import Http
import Id exposing (Id)
import Lamdera exposing (ClientId, SessionId)
import List.Extra
import List.Nonempty
import LocalUUID
import Postmark
import Process
import Quantity
import Sha256
import String.Nonempty exposing (NonemptyString)
import Task
import Time
import Token.LoginForm
import Token.Types
import Types exposing (BackendModel, BackendMsg(..), ToBackend(..), ToFrontend(..))
import User


sentLoginEmail : BackendModel -> SessionId -> ClientId -> ( BackendModel, Cmd BackendMsg )
sentLoginEmail model sessionId clientId =
    let
        _ =
            ( sessionId, clientId )

        maybeUsername : Maybe String
        maybeUsername =
            BiDict.get sessionId model.sessions

        maybeUserData : Maybe User.LoginData
        maybeUserData =
            Maybe.andThen (\username -> Dict.get username model.userDictionary) maybeUsername
                |> Maybe.map User.loginDataOfUser
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



-- requestSignUp : BackendModel -> ClientId -> g -> comparable -> String -> ( { a | localUuidData : Maybe LocalUUID.Data, time : b, userDictionary : Dict.Dict comparable { realname : c, username : d, email : EmailAddress, created_at : e, updated_at : e, id : String, role : User.Role, recentLoginEmails : List f } }, Cmd backendMsg )


requestSignUp model clientId realname username email =
    case model.localUuidData of
        Nothing ->
            ( model, Lamdera.sendToFrontend clientId (UserSignedIn Nothing) )

        -- TODO, need to signal & handle error
        Just uuidData ->
            case EmailAddress.fromString email of
                Nothing ->
                    ( model, Lamdera.sendToFrontend clientId (UserSignedIn Nothing) )

                Just validEmail ->
                    let
                        user =
                            { realname = realname
                            , username = username
                            , email = validEmail
                            , created_at = model.time
                            , updated_at = model.time
                            , id = LocalUUID.extractUUIDAsString uuidData
                            , role = User.UserRole
                            , recentLoginEmails = []
                            }
                    in
                    ( { model
                        | localUuidData = model.localUuidData |> Maybe.map LocalUUID.step
                        , userDictionary = Dict.insert username user model.userDictionary
                      }
                    , Lamdera.sendToFrontend clientId (UserSignedIn (Just user))
                    )


checkLogin model clientId sessionId =
    ( model
    , if Dict.isEmpty model.userDictionary then
        Cmd.batch
            [ Err Types.Sunny |> CheckSignInResponse |> Lamdera.sendToFrontend clientId
            ]

      else
        case getUserFromSessionId sessionId model of
            Just ( userId, user ) ->
                getLoginData userId user model
                    |> CheckSignInResponse
                    |> Lamdera.sendToFrontend clientId

            Nothing ->
                CheckSignInResponse (Err Types.LoadedBackendData) |> Lamdera.sendToFrontend clientId
    )


getLoginData : User.Id -> User.User -> Types.BackendModel -> Result Types.BackendDataStatus User.LoginData
getLoginData userId user_ model =
    User.loginDataOfUser user_ |> Ok


getUserFromSessionId : SessionId -> BackendModel -> Maybe ( User.Id, User.User )
getUserFromSessionId sessionId model =
    AssocList.get sessionId model.sessionDict
        |> Maybe.andThen (\userId -> Dict.get userId model.userDictionary |> Maybe.map (Tuple.pair userId))


loginWithToken :
    Time.Posix
    -> SessionId
    -> ClientId
    -> Int
    -> BackendModel
    -> ( BackendModel, Cmd BackendMsg )
loginWithToken time sessionId clientId loginCode model =
    case AssocList.get sessionId model.sessionDict of
        Just username ->
            case Dict.get username model.userDictionary of
                Just user ->
                    ( model, Lamdera.sendToFrontend sessionId (SignInWithTokenResponse <| Ok <| User.loginDataOfUser user) )

                Nothing ->
                    ( model, Lamdera.sendToFrontend clientId (SignInWithTokenResponse (Err loginCode)) )

        Nothing ->
            case AssocList.get sessionId model.pendingLogins of
                Just pendingLogin ->
                    if
                        (pendingLogin.loginAttempts < Token.LoginForm.maxLoginAttempts)
                            && (Duration.from pendingLogin.creationTime time |> Quantity.lessThan Duration.hour)
                    then
                        if loginCode == pendingLogin.loginCode then
                            case
                                Dict.toList model.userDictionary
                                    |> List.Extra.find (\( _, user ) -> user.email == pendingLogin.emailAddress)
                            of
                                Just ( userId, user ) ->
                                    ( { model
                                        | sessionDict = AssocList.insert sessionId userId model.sessionDict
                                        , pendingLogins = AssocList.remove sessionId model.pendingLogins
                                      }
                                    , User.loginDataOfUser user
                                        |> Ok
                                        |> SignInWithTokenResponse
                                        |> Lamdera.sendToFrontend sessionId
                                    )

                                Nothing ->
                                    ( model
                                    , Err loginCode
                                        |> SignInWithTokenResponse
                                        |> Lamdera.sendToFrontend clientId
                                    )

                        else
                            ( { model
                                | pendingLogins =
                                    AssocList.insert
                                        sessionId
                                        { pendingLogin | loginAttempts = pendingLogin.loginAttempts + 1 }
                                        model.pendingLogins
                              }
                            , Err loginCode |> SignInWithTokenResponse |> Lamdera.sendToFrontend clientId
                            )

                    else
                        ( model, Err loginCode |> SignInWithTokenResponse |> Lamdera.sendToFrontend clientId )

                Nothing ->
                    ( model, Err loginCode |> SignInWithTokenResponse |> Lamdera.sendToFrontend clientId )


addUser model clientId email realname username =
    case EmailAddress.fromString email of
        Nothing ->
            ( model, Lamdera.sendToFrontend clientId (SignInError <| "Invalid email: " ++ email) )

        Just validEmail ->
            addUser1 model clientId validEmail realname username


addUser1 model clientId email realname username =
    if emailNotRegistered email model.userDictionary then
        case Dict.get username model.userDictionary of
            Just _ ->
                ( model, Lamdera.sendToFrontend clientId (RegistrationError "That username is already registered") )

            Nothing ->
                addUser2 model clientId email realname username

    else
        ( model, Lamdera.sendToFrontend clientId (RegistrationError "That email is already registered") )


addUser2 model clientId email realname username =
    case model.localUuidData of
        Nothing ->
            let
                _ =
                    Nothing
            in
            ( model, Lamdera.sendToFrontend clientId (UserSignedIn Nothing) )

        Just uuidData ->
            let
                user =
                    { realname = realname
                    , username = username
                    , email = email
                    , created_at = model.time
                    , updated_at = model.time
                    , id = LocalUUID.extractUUIDAsString uuidData
                    , role = User.UserRole
                    , recentLoginEmails = []
                    }
            in
            ( { model
                | localUuidData = model.localUuidData |> Maybe.map LocalUUID.step
                , userDictionary = Dict.insert username user model.userDictionary
              }
            , Lamdera.sendToFrontend clientId (UserRegistered user)
            )


signOut model clientId userData =
    case userData of
        Just user ->
            ( { model | sessionDict = model.sessionDict |> AssocList.filter (\_ name -> name /= user.username) }
            , Lamdera.sendToFrontend clientId (UserSignedIn Nothing)
            )

        Nothing ->
            ( model, Cmd.none )


emailNotRegistered : EmailAddress -> Dict.Dict String User.User -> Bool
emailNotRegistered email userDictionary =
    Dict.filter (\_ user -> user.email == email) userDictionary |> Dict.isEmpty


userNameNotFound : String -> Dict.Dict String User.User -> Bool
userNameNotFound username userDictionary =
    case Dict.get username userDictionary of
        Nothing ->
            True

        Just _ ->
            False


sendLoginEmail : Types.BackendModel -> ClientId -> SessionId -> EmailAddress -> ( BackendModel, Cmd BackendMsg )
sendLoginEmail model clientId sessionId email =
    if emailNotRegistered email model.userDictionary then
        let
            _ =
                False
        in
        ( model, Lamdera.sendToFrontend clientId (SignInError "Sorry, you are not registered — please sign up for an account") )

    else
        let
            _ =
                True
        in
        sendLoginEmail2 model clientId sessionId email


sendLoginEmail2 : Types.BackendModel -> ClientId -> SessionId -> EmailAddress -> ( BackendModel, Cmd BackendMsg )
sendLoginEmail2 model clientId sessionId email =
    let
        ( model2, result ) =
            getLoginCode model.time model
    in
    case ( List.Extra.find (\( _, user ) -> user.email == email) (Dict.toList model.userDictionary), result ) of
        ( Just ( userId, user ), Ok loginCode ) ->
            if BackendHelper.shouldRateLimit model.time user then
                let
                    _ =
                        1

                    ( model3, cmd ) =
                        addLog model.time (Token.Types.LoginsRateLimited userId) model
                in
                ( model3
                , Cmd.batch [ cmd, Lamdera.sendToFrontend clientId GetLoginTokenRateLimited ]
                )

            else
                let
                    _ =
                        2
                in
                ( { model2
                    | pendingLogins =
                        AssocList.insert
                            sessionId
                            { creationTime = model.time, emailAddress = email, loginAttempts = 0, loginCode = loginCode }
                            model2.pendingLogins
                    , userDictionary =
                        Dict.insert
                            userId
                            { user | recentLoginEmails = model.time :: List.take 100 user.recentLoginEmails }
                            model.userDictionary
                  }
                , sendLoginEmail_ (SentLoginEmail model.time email) email loginCode
                )

        ( Nothing, Ok _ ) ->
            let
                _ =
                    3
            in
            ( model, Lamdera.sendToFrontend clientId (SignInError "Sorry, you are not registered — please sign up for an account") )

        ( _, Err () ) ->
            let
                _ =
                    4
            in
            addLog model.time (Token.Types.FailedToCreateLoginCode model.secretCounter) model


getLoginCode : Time.Posix -> { a | secretCounter : Int } -> ( { a | secretCounter : Int }, Result () Int )
getLoginCode time model =
    let
        ( model2, id ) =
            getUniqueId time model
    in
    ( model2
    , case Id.toString id |> String.left Token.LoginForm.loginCodeLength |> Hex.fromString of
        Ok int ->
            case String.fromInt int |> String.left Token.LoginForm.loginCodeLength |> String.toInt of
                Just int2 ->
                    Ok int2

                Nothing ->
                    Err ()

        Err _ ->
            Err ()
    )


getUniqueId : Time.Posix -> { a | secretCounter : Int } -> ( { a | secretCounter : Int }, Id b )
getUniqueId time model =
    ( { model | secretCounter = model.secretCounter + 1 }
    , Config.secretKey
        ++ ":"
        ++ String.fromInt model.secretCounter
        ++ ":"
        ++ String.fromInt (Time.posixToMillis time)
        |> Sha256.sha256
        |> Id.fromString
    )


sendLoginEmail_ :
    (Result Http.Error Postmark.PostmarkSendResponse -> backendMsg)
    -> EmailAddress
    -> Int
    -> Cmd backendMsg
sendLoginEmail_ msg emailAddress loginCode =
    let
        _ =
            loginCode
    in
    { from = { name = "", email = noReplyEmailAddress }
    , to = List.Nonempty.fromElement { name = "", email = emailAddress }
    , subject = loginEmailSubject
    , body =
        Postmark.BodyBoth
            (loginEmailContent loginCode)
            ("Here is your code " ++ String.fromInt loginCode ++ "\n\nPlease type it in the XXX login page you were previously on.\n\nIf you weren't expecting this email you can safely ignore it.")
    , messageStream = "outbound"
    }
        |> Postmark.sendEmail msg Config.postmarkApiKey


loginEmailContent : Int -> Email.Html.Html
loginEmailContent loginCode =
    Email.Html.div
        [ Email.Html.Attributes.padding "8px" ]
        [ Email.Html.div [] [ Email.Html.text "Here is your code." ]
        , Email.Html.div
            [ Email.Html.Attributes.fontSize "36px"
            , Email.Html.Attributes.fontFamily "monospace"
            ]
            (String.fromInt loginCode
                |> String.toList
                |> List.map
                    (\char ->
                        Email.Html.span
                            [ Email.Html.Attributes.padding "0px 3px 0px 4px" ]
                            [ Email.Html.text (String.fromChar char) ]
                    )
                |> (\a ->
                        List.take (Token.LoginForm.loginCodeLength // 2) a
                            ++ [ Email.Html.span
                                    [ Email.Html.Attributes.backgroundColor "black"
                                    , Email.Html.Attributes.padding "0px 4px 0px 5px"
                                    , Email.Html.Attributes.style "vertical-align" "middle"
                                    , Email.Html.Attributes.fontSize "2px"
                                    ]
                                    []
                               ]
                            ++ List.drop (Token.LoginForm.loginCodeLength // 2) a
                   )
            )
        , Email.Html.text "Please type it in the login page you were previously on."
        , Email.Html.br [] []
        , Email.Html.br [] []
        , Email.Html.text "If you weren't expecting this email you can safely ignore it."
        ]


loginEmailSubject : NonemptyString
loginEmailSubject =
    String.Nonempty.NonemptyString 'L' "ogin code"


noReplyEmailAddress : EmailAddress
noReplyEmailAddress =
    EmailAddress.EmailAddress
        { localPart = "hello"
        , tags = []
        , domain = "elm-kitchen-sink.lamdera"
        , tld = [ "app" ]
        }


addLog : Time.Posix -> Token.Types.LogItem -> Types.BackendModel -> ( Types.BackendModel, Cmd msg )
addLog time logItem model =
    ( { model | log = model.log ++ [ ( time, logItem ) ] }, Cmd.none )
