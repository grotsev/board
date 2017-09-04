module Field exposing (..)

import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Html as Html exposing (Html)
import Html.Attributes as Attr


type Validation
    = None
    | Success
    | Warning
    | Danger


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


rowValidation : Validation -> List (Row.Option msg)
rowValidation validation =
    case validation of
        None ->
            []

        Success ->
            [ Form.rowSuccess ]

        Warning ->
            [ Form.rowWarning ]

        Danger ->
            [ Form.rowDanger ]



{- TODO push request Bootstrap.Form exposing (Option)
   groupValidation : Validation -> List (Form.Option msg)
   groupValidation validation =
       case validation of
           None ->
               []

           Success ->
               [ Form.groupSuccess ]

           Warning ->
               [ Form.groupWarning ]

           Danger ->
               [ Form.groupDanger ]
-}


wrap : (List (Html.Attribute msg) -> List (Html msg) -> Html msg) -> Maybe String -> List (Html msg)
wrap f s =
    case s of
        Nothing ->
            []

        Just s ->
            [ f [] [ Html.text s ] ]


row : String -> String -> Maybe String -> Maybe String -> Validation -> (String -> Html msg) -> Html msg
row id title help error validation input =
    Form.row (rowValidation validation)
        [ Form.colLabel
            [ Col.sm3
            , Col.attrs [ Attr.class "text-right" ]
            ]
            [ Form.label [ Attr.for id ] [ Html.text title ] ]
        , Form.col [ Col.sm9 ] <|
            [ input id ]
                ++ wrap Form.validationText error
                ++ wrap Form.help help
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
