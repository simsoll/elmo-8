module Elmo8.Display exposing (..)

{-| The display (the thing you look at)

Takes layers (pixels, sprites, etc) and renders them using WebGL.

-}

import Html
import Html.Attributes
import WebGL
import Window
import Elmo8.Layers.Common exposing (CanvasSize)
-- import Elmo8.Layers.Layer exposing (Layer, renderLayer, createDefaultLayers)
import Elmo8.Layers.Pixels
import Elmo8.Layers.Text
import Elmo8.Layers.Sprites

type alias Model =
    { windowSize : Window.Size
    , canvasSize: CanvasSize
    , pixels : Elmo8.Layers.Pixels.Model
    , text : Elmo8.Layers.Text.Model
    , sprites : Elmo8.Layers.Sprites.Model
    }

type Msg
    = PixelsMsg Elmo8.Layers.Pixels.Msg
    | TextMsg Elmo8.Layers.Text.Msg
    | SpritesMsg Elmo8.Layers.Sprites.Msg

setPixel : Model -> Int -> Int -> Int -> Model
setPixel model x y colour =
    { model | pixels = Elmo8.Layers.Pixels.setPixel model.pixels x y colour }

getPixel : Model -> Int -> Int -> Int
getPixel model x y =
    Elmo8.Layers.Pixels.getPixel model.pixels x y

init : String -> (Model, Cmd Msg)
init spritesUri =
    let
        (pixels, pixelsCmd) = Elmo8.Layers.Pixels.init
        (text, textCmd) = Elmo8.Layers.Text.init
        (sprites, spritesCmd) = Elmo8.Layers.Sprites.init spritesUri
    in
        { windowSize = { width = 0, height = 0 }
        , canvasSize = { width = 512.0, height = 512.0}
        , pixels = pixels
        , text = text
        , sprites = sprites
        }
        !
        [ Cmd.map PixelsMsg pixelsCmd
        , Cmd.map TextMsg textCmd
        , Cmd.map SpritesMsg spritesCmd
        ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        PixelsMsg pixelsMsg ->
            let
                (pixels, cmd) = Elmo8.Layers.Pixels.update pixelsMsg model.pixels
            in
                { model | pixels = pixels } ! [ Cmd.map PixelsMsg cmd ]
        TextMsg sms ->
            let
                (text, cmd) = Elmo8.Layers.Text.update sms model.text
            in
                { model | text = text } ! [ Cmd.map TextMsg cmd ]
        SpritesMsg spritesMsg ->
            let
                (sprites, cmd) = Elmo8.Layers.Sprites.update spritesMsg model.sprites
            in
                { model | sprites = sprites } ! [ Cmd.map SpritesMsg cmd ]

getRenderables : Model -> List WebGL.Renderable
getRenderables model =
    List.concat
    [ Elmo8.Layers.Text.render model.canvasSize model.text
    , Elmo8.Layers.Pixels.render model.canvasSize model.pixels
    , Elmo8.Layers.Sprites.render model.canvasSize model.sprites
    ]

view : Model -> Html.Html Msg
view model =
    WebGL.toHtmlWith
        [ WebGL.Enable WebGL.Blend
        , WebGL.BlendFunc (WebGL.One, WebGL.OneMinusSrcAlpha)
        ]
        [ Html.Attributes.width (round model.canvasSize.width)
        , Html.Attributes.height (round model.canvasSize.height)
        , Html.Attributes.style
            [ ("display", "block")
            -- , ("margin-left", "auto")
            -- , ("margin-right", "auto")
            -- , ("border", "1px solid red")
            ]
        ]
        (getRenderables model)
