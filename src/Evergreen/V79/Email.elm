module Evergreen.V79.Email exposing (..)

import Http


type alias PostmarkSendResponse =
    { to : String
    , submittedAt : String
    , messageId : String
    , errorCode : Int
    , message : String
    }


type EmailResult
    = SendingEmail
    | EmailSuccess PostmarkSendResponse
    | EmailFailed Http.Error
