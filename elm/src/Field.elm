module Field exposing (..)

import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid.Col as Col
import Html as Html exposing (Html)
import Html.Attributes as Attr


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
        [ Form.label [ Attr.for id ] [ Html.text title ]
        , input id
        ]


row : String -> String -> (String -> Html msg) -> Html msg
row id title input =
    Form.row []
        [ Form.colLabel
            [ Col.sm3
            , Col.attrs [ Attr.class "text-right" ]
            ]
            [ Form.label [ Attr.for id ] [ Html.text title ] ]
        , Form.col [ Col.sm9 ] [ input id ]
        ]


int : String -> String -> (Maybe Int -> msg) -> String -> Html msg
int id title toMsg state =
    Form.group []
        [ Form.label [ Attr.for id ] [ Html.text title ]
        , Input.text
            [ Input.id id
            , Input.value state
            , Input.onInput (String.toInt >> Result.toMaybe >> toMsg)
            ]
        ]
