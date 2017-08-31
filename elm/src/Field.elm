module Field exposing (..)

import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid.Col as Col
import Html as Html exposing (Html)
import Html.Attributes exposing (..)


text : (String -> msg) -> String -> (String -> Html msg)
text toMsg value id =
    Input.text
        [ Input.id id
        , Input.value value
        , Input.onInput toMsg
        ]


password : (String -> msg) -> String -> (String -> Html msg)
password toMsg value id =
    Input.password
        [ Input.id id
        , Input.value value
        , Input.onInput toMsg
        ]


group : String -> String -> (String -> Html msg) -> Html msg
group id title input =
    Form.group []
        [ Form.label [ for id ] [ Html.text title ]
        , input id
        ]


rowInput : String -> String -> (String -> msg) -> String -> Html msg
rowInput id title toMsg state =
    Form.row []
        [ Form.colLabel [ Col.sm2 ] [ Html.text title ]
        , Form.col [ Col.sm10 ]
            [ Input.text
                [ Input.id id
                , Input.value state
                , Input.onInput toMsg
                ]
            ]
        ]


int : String -> String -> (Maybe Int -> msg) -> String -> Html msg
int id title toMsg state =
    Form.group []
        [ Form.label [ for id ] [ Html.text title ]
        , Input.text
            [ Input.id id
            , Input.value state
            , Input.onInput (String.toInt >> Result.toMaybe >> toMsg)
            ]
        ]
