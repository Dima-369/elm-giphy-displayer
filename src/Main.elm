module Main exposing (..)

import Ports
import Html
import View exposing (view)
import Update exposing (..)
import Model exposing (..)
import Time exposing (Time)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.processLocalStorage LoadLocalStorage
        , Time.every (Time.second * 6) MorePleaseOnTimer
        ]
