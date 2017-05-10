module View exposing (..)

import Model exposing (..)
import Update exposing (..)
import Html exposing (Html, div, input, text, button, h1, h2, img, p, a, form, ul, li)
import Html.Attributes exposing (placeholder, type_, style, src, href, target, value)
import Html.Events exposing (onInput, onClick, onSubmit)
import Style exposing (..)
import Json.Decode as Decode


imageHeight =
    "550px"


basicStyle =
    [ marginTop "3rem"
    , width "800px"
    , margin "0 auto"
    , textAlign center
    ]


fontStyle =
    [ fontFamily
        ("-apple-system, '.SFNSText-Regular', San Francisco, Roboto, Segoe UI, "
            ++ "Open Sans, sans-serif"
        )
    ]


imageContainer =
    [ margin "0 auto"
    , width "100%"
    , height imageHeight
    , display "flex"
    , alignItems center
    , justifyContent center
    ]


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
    , marginBottom "2rem"
    ]


loadingStyle =
    [ color "#eee"
    ]


showLayoutStyle =
    style
        [ ( "display", "initial" )
        ]


hideLayoutStyle =
    style
        [ ( "display", "none" )
        ]


hideStyle =
    style
        [ ( "visibility", "hidden" )
        ]


showStyle =
    style
        [ ( "visibility", "visible" )
        ]


gifHistoryItemImage =
    [ width "100px"
    , height "100px"
    , padding "3px"
    ]


gifHistoryItem item =
    a [ href item.giphyUrl, target "_blank" ]
        [ img [ src item.imageUrl, style gifHistoryItemImage ] []
        ]


historyLinkUlStyle =
    [ marginTop "10rem" ]


historyListStyle =
    [ marginTop "7rem"
    , marginBottom "3rem"
    , display "flex"
    , flexWrap wrap
    , justifyContent center
    ]


renderHistoryList gifHistory =
    div [ style historyListStyle ] (List.map gifHistoryItem gifHistory)


view : Model -> Html Msg
view model =
    div [ style fontStyle ]
        [ div [ style basicStyle ]
            [ form [ onSubmit MorePlease ]
                [ input
                    [ style (inputStyle ++ fontStyle)
                    , type_ "text"
                    , onInput TopicChange
                    , placeholder "Topic..."
                    , value model.topic
                    ]
                    []
                ]
            , div [ style imageContainer ]
                [ img
                    [ style imageStyle
                    , if model.showLoadError then
                        hideLayoutStyle
                      else
                        showLayoutStyle
                    , src model.gifUrl
                    , Html.Events.on "load" (Decode.succeed FinishedLoading)
                    , onClick MorePlease
                    ]
                    []
                , p
                    [ if model.showLoadError then
                        showLayoutStyle
                      else
                        hideLayoutStyle
                    ]
                    [ text "Can't find any image for that topic!" ]
                ]
            , p
                [ style loadingStyle
                , if model.loadingDisplay then
                    showStyle
                  else
                    hideStyle
                ]
                [ text "Loading..." ]
            , renderHistoryList model.gifHistory
            ]
        ]
