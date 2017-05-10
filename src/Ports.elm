port module Ports exposing (..)


port saveToLocalStorage : String -> Cmd msg


port processLocalStorage : (String -> msg) -> Sub msg


port handleLocalStorageLoad : () -> Cmd msg
