module Token.Lib exposing (addUser, sendLoginEmail)

import AssocList
import BackendHelper
import Config
import Dict
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
import Sha256
import String.Nonempty exposing (NonemptyString)
import Time
import Token.LoginForm
import Token.Types
import Types exposing (BackendModel, BackendMsg(..), ToBackend(..), ToFrontend(..))
import User


addUser model clientId email realname username =
    if emailNotRegistered email model.userDictionary then
        addUser2 model clientId email realname username

    else
        ( model, Lamdera.sendToFrontend clientId (RegistrationError "That email is already registered") )


addUser2 model clientId email realname username =
    case model.localUuidData of
        Nothing ->
            let
                _ =
                    Debug.log "@## AddUser (1)" Nothing
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


emailNotRegistered : EmailAddress -> Dict.Dict String User.User -> Bool
emailNotRegistered email userDictionary =
    Dict.filter (\_ user -> user.email == email) userDictionary |> Debug.log "@## DICT" |> Dict.isEmpty


sendLoginEmail : Types.BackendModel -> ClientId -> SessionId -> EmailAddress -> ( BackendModel, Cmd BackendMsg )
sendLoginEmail model clientId sessionId email =
    if emailNotRegistered email model.userDictionary then
        let
            _ =
                Debug.log "@## REGISTERED" False
        in
        ( model, Lamdera.sendToFrontend clientId (SignInError "Sorry, you are not registered — please sign up for an account") )

    else
        let
            _ =
                Debug.log "@## REGISTERED" True
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
                        Debug.log "@## BRANCH" 1

                    ( model3, cmd ) =
                        BackendHelper.addLog model.time (Token.Types.LoginsRateLimited userId) model
                in
                ( model3
                , Cmd.batch [ cmd, Lamdera.sendToFrontend clientId GetLoginTokenRateLimited ]
                )

            else
                let
                    _ =
                        Debug.log "@## BRANCH" 2
                in
                ( { model2
                    | pendingLogins =
                        AssocList.insert
                            sessionId
                            { creationTime = model.time, emailAddress = email, loginAttempts = 0, loginCode = loginCode }
                            model2.pendingLogins
                            |> Debug.log "@## pendingLogins"
                    , userDictionary =
                        Dict.insert
                            userId
                            { user | recentLoginEmails = model.time :: List.take 100 user.recentLoginEmails }
                            model.userDictionary
                            |> Debug.log "@## userDictionary"
                  }
                , sendLoginEmail_ (SentLoginEmail model.time email) email loginCode
                )

        ( Nothing, Ok _ ) ->
            let
                _ =
                    Debug.log "@## BRANCH" 3
            in
            ( model, Lamdera.sendToFrontend clientId (SignInError "Sorry, you are not registered — please sign up for an account" |> Debug.log "@## AddUser (2)") )

        ( _, Err () ) ->
            let
                _ =
                    Debug.log "@## BRANCH" 4
            in
            BackendHelper.addLog model.time (Token.Types.FailedToCreateLoginCode model.secretCounter) model


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
            Debug.log "@## sendLoginEmail" loginCode
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
