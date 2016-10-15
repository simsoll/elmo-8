{-| PICO-8's Hello.lua redone in ELMO-8

-}

import Elmo8.Console as Console

type alias Model = {
    t : Int
}

init : Model
init = { t = 0 }

update : Model -> Model
update model =
    { model | t = model.t + 1 }

draw_letter : Int -> Int -> Int -> List Console.Command
draw_letter t i j0 =
    let
        j = 7 - j0
        col = 7 + j
        t1 = t + i*4 - j*2
        -- x = cos(t) * 5
        -- Bug in PICO-8 example, cos(nil) * 5 -> 1 * 5
        x = 5
        y = 38 + j + cos(t1/3.5) * 5
    in
        [ Console.palette 7 col
        , Console.sprite (16+i) (8+i*8 + x)  (round y)
        , Console.putPixel 0 0 5
        , Console.putPixel 7 7 5
        , Console.putPixel 8 8 5
        , Console.putPixel 10 10 5
        , Console.putPixel 12 12 5
        , Console.putPixel 14 14 5
        , Console.putPixel 16 16 5
        , Console.putPixel 63 63 5
        , Console.putPixel 64 64 5
        , Console.putPixel 126 126 5
        , Console.putPixel 127 127 5
        , Console.putPixel 128 128 5
        ]

draw : Console.Console Model -> Model ->  List Console.Command
draw console model =
    List.map2 (\i j -> draw_letter model.t i j) [1..11] [0..7]
        |> List.concat

main : Program Never
main =
 Console.boot
    { draw = draw
    , init = init
    , update = update
    , spritesUri = "/birdwatching.png"
    }
