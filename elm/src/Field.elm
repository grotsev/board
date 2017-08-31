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


group : String -> String -> String -> (String -> Html msg) -> Html msg
group prefix id title input =
    let
        pid =
            prefix ++ id
    in
    Form.group []
        [ Form.label [ Attr.for pid, Attr.class "text-capitalize" ] [ Html.text title ]
        , input pid
        ]


row : String -> String -> String -> (String -> Html msg) -> Html msg
row prefix id title input =
    let
        pid =
            prefix ++ id
    in
    Form.row []
        [ Form.colLabel
            [ Col.sm3
            , Col.attrs [ Attr.class "text-right", Attr.class "text-capitalize" ]
            ]
            [ Form.label [ Attr.for pid ] [ Html.text title ] ]
        , Form.col [ Col.sm9 ] [ input pid ]
        ]



-- TODO refactor


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
