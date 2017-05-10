module Update exposing (..)

import Ports
import Helper exposing (replace)
import Model exposing (..)
import Http
import Json.Encode as Encode
import Time exposing (Time)
import Task


init : ( Model, Cmd Msg )
init =
    ( Model "math" "" "" [] True False, Task.perform InitialLoad Time.now )


fireMorePleaseIfLocalStorageEmpty fromStorage =
    if fromStorage == "" then
        Task.perform MorePleaseOnTimer Time.now
    else
        Cmd.none


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
        giphyTopic =
            replace " " "+" topic

        url =
            "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ giphyTopic

        request =
            Http.get url giphyJsonDecoder
    in
        Http.send NewGif request


loadFromLocalStorage : Cmd msg
loadFromLocalStorage =
    Ports.handleLocalStorageLoad ()


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitialLoad _ ->
            ( model, loadFromLocalStorage )

        FinishedLoading ->
            ( { model | loadingDisplay = False, showLoadError = False }
            , Ports.saveToLocalStorage (Encode.encode 0 (modelAsJsonEasy model))
            )

        MorePlease ->
            ( model, getRandomGif model.topic )

        MorePleaseOnTimer _ ->
            ( model, getRandomGif model.topic )

        TopicChange newTopic ->
            ( { model | topic = newTopic }
            , Ports.saveToLocalStorage (Encode.encode 0 (modelAsJson model newTopic))
            )

        NewGif (Ok new) ->
            ( { model
                | gifUrl = new.gifUrl
                , giphyUrl = new.giphyUrl
                , loadingDisplay = True
                , showLoadError = False
                , gifHistory = (GifHistoryModel new.lowResImageUrl new.giphyUrl) :: model.gifHistory
              }
            , Cmd.none
            )

        NewGif (Err _) ->
            ( { model | showLoadError = True }, Cmd.none )

        LoadLocalStorage modelInStorage ->
            ( (decodeModelFromLocalStorage model modelInStorage)
            , fireMorePleaseIfLocalStorageEmpty modelInStorage
            )
