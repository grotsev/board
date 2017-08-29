module Field exposing (..)

import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Html exposing (..)
import Html.Attributes exposing (..)


input : String -> String -> (String -> msg) -> String -> Html msg
input id title toMsg state =
    Form.group []
        [ Form.label [ for id ] [ text title ]
        , Input.text
            [ Input.id id
            , Input.value state
            , Input.onInput toMsg
            ]
        ]


password : String -> String -> (String -> msg) -> String -> Html msg
password id title toMsg state =
    Form.group []
        [ Form.label [ for id ] [ text title ]
        , Input.password
            [ Input.id id
            , Input.value state
            , Input.onInput toMsg
            ]
        ]


int : String -> String -> (Maybe Int -> msg) -> String -> Html msg
int id title toMsg state =
    Form.group []
        [ Form.label [ for id ] [ text title ]
        , Input.text
            [ Input.id id
            , Input.value state
            , Input.onInput (String.toInt >> Result.toMaybe >> toMsg)
            ]
        ]
