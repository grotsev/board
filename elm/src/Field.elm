module Field exposing (..)

import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid.Col as Col
import Html as Html exposing (Html)
import Html.Attributes as Attr


type alias Field msg =
    { id : String
    , title : String
    , help : Maybe String
    , error : Maybe String
    , validation : Validation
    , input : String -> Validation -> Html msg
    }


type Validation
    = None
    | Success
    | Warning
    | Danger


text : (String -> msg) -> String -> (String -> Validation -> Html msg)
text toMsg value id validation =
    Input.text <|
        [ Input.id id
        , Input.value value
        , Input.onInput toMsg
        ]
            ++ inputOptions validation


password : (String -> msg) -> String -> (String -> Validation -> Html msg)
password toMsg value id validation =
    Input.password <|
        [ Input.id id
        , Input.value value
        , Input.onInput toMsg
        ]
            ++ inputOptions validation


group : Field msg -> Html msg
group { id, title, help, error, validation, input } =
    let
        options =
            case validation of
                None ->
                    []

                Success ->
                    [ Form.groupSuccess ]

                Warning ->
                    [ Form.groupWarning ]

                Danger ->
                    [ Form.groupDanger ]
    in
    Form.group options <|
        [ Form.label [ Attr.for id ] [ Html.text title ]
        , input id validation
        ]
            ++ wrap Form.validationText error
            ++ wrap Form.help help


row : Field msg -> Html msg
row { id, title, help, error, validation, input } =
    let
        options =
            case validation of
                None ->
                    []

                Success ->
                    [ Form.rowSuccess ]

                Warning ->
                    [ Form.rowWarning ]

                Danger ->
                    [ Form.rowDanger ]
    in
    Form.row options
        [ Form.colLabel
            [ Col.sm3
            , Col.attrs [ Attr.class "text-right" ]
            ]
            [ Form.label [ Attr.for id ] [ Html.text title ] ]
        , Form.col [ Col.sm9 ] <|
            [ input id validation ]
                ++ wrap Form.validationText error
                ++ wrap Form.help help
        ]


form : Bool -> msg -> String -> List (Field msg) -> Html msg
form active msg doText fields =
    let
        buttonOptions =
            if active && List.all (\r -> r.validation == Success || r.validation == None) fields then
                [ Button.attrs [ Attr.class "float-right" ]
                , Button.primary
                , Button.onClick msg
                ]
            else
                [ Button.attrs [ Attr.class "float-right" ]
                , Button.disabled True
                ]
    in
    Form.form [] <|
        List.map row fields
            ++ [ Button.button buttonOptions [ Html.text doText ] ]



-- TODO loader spinner


wrap : (List (Html.Attribute msg) -> List (Html msg) -> Html msg) -> Maybe String -> List (Html msg)
wrap f s =
    case s of
        Nothing ->
            []

        Just s ->
            [ f [] [ Html.text s ] ]


inputOptions : Validation -> List (Input.Option msg)
inputOptions validation =
    case validation of
        None ->
            []

        Success ->
            [ Input.success ]

        Warning ->
            [ Input.warning ]

        Danger ->
            [ Input.danger ]



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
