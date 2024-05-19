module Util exposing (composeUpdateFunctions, applyUpdateFunction



composeUpdateFunctions : (model -> ( model, Cmd msg )) -> (model -> ( model, Cmd msg )) -> model -> ( model, Cmd msg )
composeUpdateFunctions f g model =
    let
        ( model1, cmd1 ) =
            f model

        ( model2, cmd2 ) =
            g model1
    in
    ( model2, Cmd.batch [ cmd1, cmd2 ] )


applyUpdateFunction : (model -> ( model, Cmd msg )) -> ( model, Cmd msg ) -> ( model, Cmd msg )
applyUpdateFunction f ( model, cmd ) =
    let
        ( model2, cmd2 ) =
            f model
    in
    ( model2, Cmd.batch [ cmd, cmd2 ] )
