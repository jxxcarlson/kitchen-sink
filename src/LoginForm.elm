module LoginForm exposing
    ( LoginForm
    , Msg(..)
    , emailInputId
    , init
    , invalidCode
    , loginCodeInputId
    , loginCodeLength
    , maxLoginAttempts
    , rateLimited
    , submitEmailButtonId
    , update
    , view
    )

-- import Command as Command exposing (Command, FrontendOnly)

import Config
import Dict exposing (Dict)
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Events
import Element.Font
import Element.Input
import EmailAddress exposing (EmailAddress)
import Env
import Html.Attributes
import Martin
import Route exposing (Route)
import View.MyElement as MyElement


type Msg
    = PressedSubmitEmail
    | PressedCancelLogin
    | TypedLoginFormEmail String
    | TypedLoginCode String


type LoginForm
    = EnterEmail EnterEmail2
    | EnterLoginCode EnterLoginCode2


type alias EnterEmail2 =
    { email : String
    , pressedSubmitEmail : Bool
    , rateLimited : Bool
    }


type alias EnterLoginCode2 =
    { sentTo : EmailAddress, loginCode : String, attempts : Dict Int LoginCodeStatus }


type LoginCodeStatus
    = Checking
    | NotValid


update :
    Bool
    -> (EmailAddress -> Cmd Msg)
    -> (Int -> Cmd Msg)
    -> Msg
    -> LoginForm
    -> Maybe ( LoginForm, Cmd Msg )
update isLoadingBackend onSubmitEmail onSubmitLoginCode msg model =
    case msg of
        PressedSubmitEmail ->
            (if isLoadingBackend then
                ( model, Cmd.none )

             else
                case model of
                    EnterEmail loginForm ->
                        case EmailAddress.fromString loginForm.email of
                            Just email ->
                                ( EnterLoginCode { sentTo = email, loginCode = "", attempts = Dict.empty }
                                , onSubmitEmail email
                                )

                            Nothing ->
                                ( EnterEmail { loginForm | pressedSubmitEmail = True }, Cmd.none )

                    EnterLoginCode _ ->
                        ( model, Cmd.none )
            )
                |> Just

        TypedLoginFormEmail text ->
            (case model of
                EnterEmail loginForm ->
                    ( EnterEmail { loginForm | email = text }, Cmd.none )

                EnterLoginCode _ ->
                    ( model, Cmd.none )
            )
                |> Just

        PressedCancelLogin ->
            Nothing

        TypedLoginCode loginCodeText ->
            (case model of
                EnterEmail _ ->
                    ( model, Cmd.none )

                EnterLoginCode enterLoginCode ->
                    case validateLoginCode loginCodeText of
                        Ok loginCode ->
                            if Dict.member loginCode enterLoginCode.attempts then
                                ( EnterLoginCode
                                    { enterLoginCode | loginCode = String.left loginCodeLength loginCodeText }
                                , Cmd.none
                                )

                            else
                                ( EnterLoginCode
                                    { enterLoginCode
                                        | loginCode = String.left loginCodeLength loginCodeText
                                        , attempts =
                                            Dict.insert loginCode Checking enterLoginCode.attempts
                                    }
                                , onSubmitLoginCode loginCode
                                )

                        Err _ ->
                            ( EnterLoginCode { enterLoginCode | loginCode = String.left loginCodeLength loginCodeText }
                            , Cmd.none
                            )
            )
                |> Just


validateLoginCode : String -> Result String Int
validateLoginCode text =
    if String.any (\char -> Char.isDigit char |> not) text then
        Err "Must only contain digits 0-9"

    else if String.length text == loginCodeLength then
        case String.toInt text of
            Just int ->
                Ok int

            Nothing ->
                Err "Invalid code"

    else
        Err ""


loginCodeLength : number
loginCodeLength =
    8


emailInput : msg -> (String -> msg) -> String -> String -> Maybe String -> Element msg
emailInput onSubmit onChange text labelText maybeError =
    let
        label =
            MyElement.label
                (Martin.idToString emailInputId)
                [ Element.Font.bold ]
                (Element.text labelText)
    in
    Element.column
        [ Element.spacing 4 ]
        [ Element.column
            []
            [ label.element
            , Element.Input.email
                [ -- Element.Events.onKey Element.Events.enter onSubmit
                  -- TODO: it is doubtful that the below is correct
                  MyElement.onEnter onSubmit
                , case maybeError of
                    Just _ ->
                        Element.Border.color MyElement.errorColor

                    Nothing ->
                        Martin.noAttr
                ]
                { text = text
                , onChange = onChange
                , placeholder = Nothing
                , label = label.id
                }
            ]
        , Maybe.map errorView maybeError |> Maybe.withDefault Element.none
        ]


errorView : String -> Element msg
errorView errorMessage =
    Element.paragraph
        [ Element.width Element.shrink
        , Element.Font.color MyElement.errorColor
        , Element.Font.medium
        ]
        [ Element.text errorMessage ]


view : Bool -> LoginForm -> Element Msg
view backendIsLoading loginForm =
    Element.column
        [ Element.padding 16
        , Element.centerX
        , Element.centerY

        -- TODO:, Element.widthMax 520
        , Element.spacing 24
        ]
        [ case loginForm of
            EnterEmail enterEmail2 ->
                enterEmailView backendIsLoading enterEmail2

            EnterLoginCode enterLoginCode ->
                enterLoginCodeView enterLoginCode
        , Element.paragraph
            [ Element.Font.center ]
            [ Element.text "If you're having trouble logging in, we can be reached at "
            , MyElement.emailAddressLink Config.contactEmail
            ]
        ]


enterLoginCodeView : EnterLoginCode2 -> Element Msg
enterLoginCodeView model =
    let
        -- label : MyElement.Label
        label =
            MyElement.label
                (Martin.idToString loginCodeInputId)
                []
                (Element.column
                    [ Element.Font.center ]
                    [ Element.paragraph
                        [ Element.Font.size 30, Element.Font.bold ]
                        [ Element.text "Check your email for a code" ]
                    , Element.paragraph
                        [ Element.width Element.shrink ]
                        [ Element.text "An email has been sent to "
                        , Element.el
                            [ Element.Font.bold ]
                            (Element.text (EmailAddress.toString model.sentTo))
                        , Element.text " containing a code. Please enter that code here."
                        ]
                    ]
                )
    in
    Element.column
        [ Element.spacing 24 ]
        [ label.element
        , Element.column
            [ Element.spacing 6, Element.centerX, Element.width Element.shrink, Element.moveRight 18 ]
            [ Element.el
                [ Element.Font.size 36
                , Element.paragraph
                    [ Element.Font.letterSpacing 26
                    , Element.paddingXY 0 6
                    , Element.Font.family [ Element.Font.monospace ]
                    , Martin.noPointerEvents
                    ]
                    (List.range 0 (loginCodeLength - 1)
                        |> List.map
                            (\index ->
                                Element.el
                                    [ Element.paddingXY -1 -1
                                    , Element.behindContent
                                        (Element.el
                                            [ Element.height (Element.px 54)
                                            , Element.paddingXY 0 24
                                            , Element.width (Element.px 32)
                                            , Element.Font.color (Element.rgba 0 0 0 1)
                                            , if index == (loginCodeLength - 1) // 2 then
                                                Element.onRight
                                                    (Element.el
                                                        [ Element.Border.widthEach
                                                            { left = 0
                                                            , right = 0
                                                            , top = 1
                                                            , bottom = 1
                                                            }
                                                        , Element.moveRight 3
                                                        , Element.centerY
                                                        , Element.width (Element.px 9)
                                                        ]
                                                        Element.none
                                                    )

                                              else
                                                Martin.noAttr
                                            , Element.Border.width 1
                                            , Element.Border.rounded 8
                                            , Element.Border.color MyElement.gray
                                            , Element.Border.shadow { offset = ( 0, 1 ), blur = 2, size = 0, color = Element.rgba 0 0 0 0.2 }
                                            , Martin.noPointerEvents
                                            ]
                                            Element.none
                                        )
                                    , Element.Font.color (Element.rgba 0 0 0 0)
                                    , Martin.noPointerEvents
                                    ]
                                    (Element.text "_")
                            )
                    )
                    |> Element.behindContent
                , Element.width (Element.px 400)
                ]
                (Element.Input.text
                    [ Element.Font.letterSpacing 26
                    , Element.paddingEach { left = 6, right = 0, top = 0, bottom = 8 }
                    , Element.Font.family [ Element.Font.monospace ]
                    , Html.Attributes.attribute "inputmode" "numeric" |> Element.htmlAttribute
                    , Html.Attributes.type_ "number" |> Element.htmlAttribute
                    , Element.Border.width 0
                    , Element.Background.color (Element.rgba 0 0 0 0)
                    ]
                    { onChange = TypedLoginCode
                    , text = model.loginCode
                    , placeholder = Nothing
                    , label = label.id
                    }
                )
            , if Dict.size model.attempts < maxLoginAttempts then
                case validateLoginCode model.loginCode of
                    Ok loginCode ->
                        case Dict.get loginCode model.attempts of
                            Just NotValid ->
                                errorView "Incorrect code"

                            _ ->
                                Element.paragraph
                                    []
                                    [ Element.text "Submitting..." ]

                    Err error ->
                        errorView error

              else
                Element.text "Too many incorrect attempts. Please refresh the page and try again."
            ]
        ]


emailInputId : Martin.HtmlId
emailInputId =
    Martin.HtmlId "loginForm_emailInput"


submitEmailButtonId : Martin.HtmlId
submitEmailButtonId =
    Martin.HtmlId "loginForm_loginButton"


cancelButtonId : Martin.HtmlId
cancelButtonId =
    Martin.HtmlId "loginForm_cancelButton"


loginCodeInputId : Martin.HtmlId
loginCodeInputId =
    Martin.HtmlId "loginForm_loginCodeInput"


maxLoginAttempts : number
maxLoginAttempts =
    10


rateLimited : LoginForm -> LoginForm
rateLimited loginForm =
    case loginForm of
        EnterEmail enterEmail ->
            EnterEmail { enterEmail | rateLimited = True }

        EnterLoginCode enterLoginCode ->
            EnterEmail
                { email = EmailAddress.toString enterLoginCode.sentTo
                , pressedSubmitEmail = False
                , rateLimited = True
                }


invalidCode : Int -> LoginForm -> LoginForm
invalidCode loginCode loginForm =
    case loginForm of
        EnterEmail _ ->
            loginForm

        EnterLoginCode enterLoginCode ->
            { enterLoginCode | attempts = Dict.insert loginCode NotValid enterLoginCode.attempts }
                |> EnterLoginCode


enterEmailView : Bool -> EnterEmail2 -> Element Msg
enterEmailView backendIsLoading model =
    Element.column
        [ Element.spacing 16 ]
        [ emailInput
            PressedSubmitEmail
            TypedLoginFormEmail
            model.email
            "Enter your email address"
            (case ( model.pressedSubmitEmail, validateEmail model.email ) of
                ( True, Err error ) ->
                    Just error

                _ ->
                    Nothing
            )
        , Element.paragraph
            []
            [ Element.text "By continuing, you agree to our "

            -- TODO: below, Route,HomepageRoute is a p
            , MyElement.routeLinkNewTab Route.HomepageRoute Route.TermsOfServiceRoute
            , Element.text "."
            ]
        , Element.row
            [ Element.spacing 16 ]
            [ MyElement.secondaryButton
                [ Martin.elementId cancelButtonId ]
                PressedCancelLogin
                "Cancel"
            , if backendIsLoading then
                Element.none

              else
                MyElement.primaryButton submitEmailButtonId PressedSubmitEmail "Login"
            ]
        , if backendIsLoading then
            errorView
                (if Env.isProduction then
                    "Loading backend data..."

                 else
                    "Loading backend data. Please don't refresh the page."
                )

          else
            Element.none
        , if model.rateLimited then
            errorView "Too many login attempts have been made. Please try again later."

          else
            Element.none
        ]



--routeLinkNewTab : Route -> String -> Element msg
--routeLinkNewTab route label =
--    Element.el
--        [ Element.linkNewTab (Route.encode route)
--        , Element.Font.underline
--        ]
--        (Element.text label)


validateEmail : String -> Result String EmailAddress
validateEmail text =
    EmailAddress.fromString text
        |> Result.fromMaybe
            (if String.isEmpty text then
                "Enter your email first"

             else
                "Invalid email address"
            )


init : LoginForm
init =
    EnterEmail
        { email = ""
        , pressedSubmitEmail = False
        , rateLimited = False
        }