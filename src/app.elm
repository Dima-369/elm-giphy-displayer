port module Main exposing (..)

import Html exposing (Html, div, input, text, button, h1, h2, img, p, a, form, ul, li)
import Html.Attributes exposing (placeholder, type_, style, src, href, target, value)
import Html.Events exposing (onInput, onClick, onSubmit)
import Style exposing (..)
import Time exposing (Time, second)
import Task exposing (perform)
import Http
import Json.Encode
import Json.Decode
import Regex

port save : String -> Cmd msg
port load : (String -> msg) -> Sub msg
port doload : () -> Cmd msg

main =
  Html.program
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }


-- Model

type alias Model =
  { topic : String
  , gifUrl : String
  , giphyUrl : String
  , gifHistory : List GifHistoryModel
  , loadingDisplay: Bool
  , showLoadError: Bool
  }
type alias GifHistoryModel =
  { imageUrl : String
  , giphyUrl : String
  }
type alias LocalStorageModel =
  { topic : String
  , gifUrl : String
  }
type alias GiphyJsonDecodeModel =
  { gifUrl : String
  , lowResImageUrl : String
  , giphyUrl : String
  }

init : (Model, Cmd Msg)
init = (Model "math" "" "" [] True False, Task.perform InitialLoad Time.now)

modelAsJsonEasy model =
  modelAsJson model model.topic

-- topic required because the Msg is getting updated in the pipeline
modelAsJson model topic =
  Json.Encode.object
  [ ("topic", Json.Encode.string topic)
  , ("gifUrl", Json.Encode.string model.gifUrl)
  ]

modelDecoder : Json.Decode.Decoder LocalStorageModel
modelDecoder =
  Json.Decode.map2 LocalStorageModel
    (Json.Decode.at [ "topic" ] Json.Decode.string)
    (Json.Decode.at [ "gifUrl" ] Json.Decode.string)

giphyJsonDecoder : Json.Decode.Decoder GiphyJsonDecodeModel
giphyJsonDecoder =
  Json.Decode.map3 GiphyJsonDecodeModel
    (Json.Decode.at [ "data", "image_url" ] Json.Decode.string)
    (Json.Decode.at [ "data", "fixed_width_small_url" ] Json.Decode.string)
    (Json.Decode.at [ "data", "url" ] Json.Decode.string)

-- [model] is required in case of parsing errors
decodeModelFromLocalStorage model fromStorage =
  case Json.Decode.decodeString modelDecoder fromStorage of
    Ok json ->
      { model | topic = json.topic, gifUrl = json.gifUrl }
    Err _ ->
      let _ = Debug.log("error parsing")
      in model

fireMorePleaseIfLocalStorageEmpty fromStorage =
  if fromStorage == "" then
    Task.perform MorePleaseOnTimer Time.now
  else
    Cmd.none

-- Update

type Msg
  = MorePlease
  | MorePleaseOnTimer Time
  | InitialLoad Time
  | NewGif (Result Http.Error GiphyJsonDecodeModel)
  | TopicChange String
  | FinishedLoading
  | LoadLocalStorage String

getRandomGif : String -> Cmd Msg
getRandomGif topic =
  let
    giphyTopic = replace " " "+" topic
    url = "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ giphyTopic
    request = Http.get url giphyJsonDecoder
  in
    Http.send NewGif request

loadFromLocalStorage : Cmd msg
loadFromLocalStorage = doload()

update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        InitialLoad _ ->
            model ! []
              |> addCmd loadFromLocalStorage
        FinishedLoading ->
          ( { model | loadingDisplay = False, showLoadError = False },
            save (Json.Encode.encode 0 (modelAsJsonEasy model)))
        MorePlease ->
          (model, getRandomGif model.topic)
        MorePleaseOnTimer _ ->
          (model, getRandomGif model.topic)
        TopicChange newTopic ->
          ( { model | topic = newTopic }, save (Json.Encode.encode 0 (modelAsJson model newTopic)))
        NewGif (Ok new) ->
          ( { model | gifUrl = new.gifUrl
                    , giphyUrl = new.giphyUrl
                    , loadingDisplay = True
                    , showLoadError = False
                    , gifHistory = (GifHistoryModel new.lowResImageUrl new.giphyUrl) :: model.gifHistory
            }, Cmd.none)
        NewGif (Err _) ->
          ( { model | showLoadError = True }, Cmd.none)
        LoadLocalStorage modelInStorage ->
          ( (decodeModelFromLocalStorage model modelInStorage)
          , fireMorePleaseIfLocalStorageEmpty modelInStorage)


-- Helpers

-- from https://github.com/elm-community/string-extra
{-| Replace all occurrences of the search string with the substitution string.

    replace "Mary" "Sue" "Hello, Mary" == "Hello, Sue"
-}
replace : String -> String -> String -> String
replace search substitution string =
    string
        |> Regex.replace Regex.All (Regex.regex (Regex.escape search)) (\_ -> substitution)


-- from https://github.com/ccapndave/elm-update-extra
{-| Allows you to attach a Cmd to an update pipeline.

    update msg model = model ! []
      |> andThen update AMessage
      |> addCmd doSomethingWithASideEffect
-}
addCmd : Cmd msg -> ( model, Cmd msg ) -> ( model, Cmd msg )
addCmd cmd_ ( model, cmd ) =
    ( model, Cmd.batch [ cmd, cmd_ ] )


-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch [load LoadLocalStorage, Time.every (Time.second * 6) MorePleaseOnTimer]


-- View

imageHeight = "550px"

basicStyle =
  [ marginTop "3rem"
  , width "800px"
  , margin "0 auto"
  , textAlign center ]

fontStyle =
  [ fontFamily ("-apple-system, '.SFNSText-Regular', San Francisco, Roboto, Segoe UI, " ++
      "Open Sans, sans-serif")
  ]

imageContainer =
  [ margin "0 auto"
  , width "100%"
  , height imageHeight
  , display "flex"
  , alignItems center
  , justifyContent center]

imageStyle =
  [ display block
  , height imageHeight
  ]

inputStyle =
  [ width "30%"
  , padding "6px 6px"
  , color "#111"
  , margin "0 auto"
  , marginTop "2rem"
  , marginBottom "2rem" ]

loadingStyle =
  [ color "#eee"
  ]

showLayoutStyle = style
  [ ("display", "initial")
  ]

hideLayoutStyle = style
  [ ("display", "none")
  ]

hideStyle = style
  [ ("visibility", "hidden")
  ]

showStyle = style
  [ ("visibility", "visible")
  ]

gifHistoryItemImage =
  [ width "100px"
  , height "100px"
  , padding "3px" ]

gifHistoryItem item =
  a [href item.giphyUrl, target "_blank"]
    [ img [src item.imageUrl, style gifHistoryItemImage] []
    ]

historyLinkUlStyle =
  [ marginTop "10rem" ]

historyListStyle =
  [ marginTop "7rem"
  , marginBottom "3rem"
  , display "flex"
  , flexWrap wrap
  , justifyContent center ]

renderHistoryList gifHistory =
  div [style historyListStyle] (List.map gifHistoryItem gifHistory)

view: Model -> Html Msg
view model =
    div [style fontStyle]
      [ div [style basicStyle ]
        [ form [onSubmit MorePlease]
          [ input [ style (inputStyle ++ fontStyle)
                  , type_ "text"
                  , onInput TopicChange
                  , placeholder "Topic..."
                  , value model.topic] []
          ]
        , div [style imageContainer]
          [ img [ style imageStyle
                , if model.showLoadError then hideLayoutStyle else showLayoutStyle
                , src model.gifUrl
                , Html.Events.on "load" (Json.Decode.succeed FinishedLoading)
                , onClick MorePlease] []
          , p [ if model.showLoadError then showLayoutStyle else hideLayoutStyle ]
              [text "Can't find any image for that topic!"]
          ]
        , p [ style loadingStyle
            , if model.loadingDisplay then showStyle else hideStyle ] [text "Loading..."]
        , renderHistoryList model.gifHistory
        ]
      ]

