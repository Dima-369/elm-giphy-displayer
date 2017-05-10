module Helper exposing (..)

import Regex


{-| Replace all occurrences of the search string with the substitution string.

    replace "Mary" "Sue" "Hello, Mary" == "Hello, Sue"

    from <https://github.com/elm-community/string-extra>

-}
replace : String -> String -> String -> String
replace search substitution string =
    string
        |> Regex.replace Regex.All (Regex.regex (Regex.escape search)) (\_ -> substitution)



-- from https://github.com/ccapndave/elm-update-extra


{-| Allows you to attach a Cmd to an update pipeline.

    update msg model =
        model
            ! []
            |> andThen update AMessage
            |> addCmd doSomethingWithASideEffect

-}
addCmd : Cmd msg -> ( model, Cmd msg ) -> ( model, Cmd msg )
addCmd cmd_ ( model, cmd ) =
    ( model, Cmd.batch [ cmd, cmd_ ] )
