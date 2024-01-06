module View.Color exposing
    ( black
    , blue
    , buttonHighlight
    , darkBlue
    , darkGray
    , darkGreen
    , darkRed
    , iconColor
    , lightBlue
    , lightGray
    , medBlue
    , medGray
    , messageGreen
    , offWhite
    , orange
    , paleBlue
    , red
    , veryDarkBlue
    , white
    , yellow
    )

import Element as E


orange : E.Color
orange =
    E.rgb 1.0 0.7 0.0


blue : E.Color
blue =
    -- used
    E.rgb255 64 64 109


messageGreen : E.Color
messageGreen =
    E.rgb 0.2 0.7 0.2


yellow : E.Color
yellow =
    E.rgb 1.0 0.9 0.7


white : E.Color
white =
    E.rgb 255 255 255


offWhite : E.Color
offWhite =
    gray 0.9


lightGray : E.Color
lightGray =
    gray 0.8


medGray : E.Color
medGray =
    gray 0.6


darkGray : E.Color
darkGray =
    gray 0.2


black : E.Color
black =
    E.rgb 0 0 0


red : E.Color
red =
    E.rgb255 255 0 0


darkRed : E.Color
darkRed =
    E.rgb255 140 0 0


veryDarkBlue : E.Color
veryDarkBlue =
    gray 0.2


darkBlue : E.Color
darkBlue =
    E.rgb255 0 0 190


medBlue : E.Color
medBlue =
    E.rgb255 120 120 220


lightBlue : E.Color
lightBlue =
    E.rgb255 120 120 200


buttonHighlight : E.Color
buttonHighlight =
    E.rgb255 100 80 255


paleBlue : E.Color
paleBlue =
    E.rgb255 200 200 255


iconColor =
    E.rgb 0.45 0.4 0.9


darkGreen : E.Color
darkGreen =
    E.rgb255 50 130 55


veryPaleBlue : E.Color
veryPaleBlue =
    E.rgb255 140 140 150


transparentBlue : E.Color
transparentBlue =
    E.rgba 0.9 0.9 1 0.9


paleViolet : E.Color
paleViolet =
    E.rgb255 230 230 255


gray : Float -> E.Color
gray g =
    E.rgb g g g
