module Model exposing (..)

import Ports
import Time exposing (Time, second)
import Task exposing (perform)
import Json.Encode as Encode
import Json.Decode as Decode


type alias Model =
    { topic : String
    , gifUrl : String
    , giphyUrl : String
    , gifHistory : List GifHistoryModel
    , loadingDisplay : Bool
    , showLoadError : Bool
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


modelAsJsonEasy model =
    modelAsJson model model.topic


{-| topic required because the Msg is getting updated in the pipeline
-}
modelAsJson model topic =
    Encode.object
        [ ( "topic", Encode.string topic )
        , ( "gifUrl", Encode.string model.gifUrl )
        ]


modelDecoder : Decode.Decoder LocalStorageModel
modelDecoder =
    Decode.map2 LocalStorageModel
        (Decode.at [ "topic" ] Decode.string)
        (Decode.at [ "gifUrl" ] Decode.string)


giphyJsonDecoder : Decode.Decoder GiphyJsonDecodeModel
giphyJsonDecoder =
    Decode.map3 GiphyJsonDecodeModel
        (Decode.at [ "data", "image_url" ] Decode.string)
        (Decode.at [ "data", "fixed_width_small_url" ] Decode.string)
        (Decode.at [ "data", "url" ] Decode.string)


{-| [model] is required in case of parsing errors
-}
decodeModelFromLocalStorage model fromStorage =
    case Decode.decodeString modelDecoder fromStorage of
        Ok json ->
            { model | topic = json.topic, gifUrl = json.gifUrl }

        Err _ ->
            model
