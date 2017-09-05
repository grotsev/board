module Field exposing (..)

import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid.Col as Col
import Html as Html exposing (Html)
import Html.Attributes as Attr
import Validate exposing (Validation)


type alias Field msg =
    { id : String
    , title : String
    , help : Maybe String
    , validation : Validation
    , input : String -> Validate.Status -> Html msg
    }


text : (String -> msg) -> String -> (String -> Validate.Status -> Html msg)
text toMsg value id status =
    Input.text <|
        [ Input.id id
        , Input.value value
        , Input.onInput toMsg
        ]
            ++ inputOptions status


password : (String -> msg) -> String -> (String -> Validate.Status -> Html msg)
password toMsg value id status =
    Input.password <|
        [ Input.id id
        , Input.value value
        , Input.onInput toMsg
        ]
            ++ inputOptions status


group : Field msg -> Html msg
group { id, title, help, validation, input } =
    let
        options =
            case validation.status of
                Validate.None ->
                    []

                Validate.Success ->
                    [ Form.groupSuccess ]

                Validate.Warning ->
                    [ Form.groupWarning ]

                Validate.Danger ->
                    [ Form.groupDanger ]
    in
    Form.group options <|
        [ Form.label [ Attr.for id ] [ Html.text title ]
        , input id validation.status
        ]
            ++ wrap Form.validationText validation.error
            ++ wrap Form.help help


row : Field msg -> Html msg
row { id, title, help, validation, input } =
    let
        options =
            case validation.status of
                Validate.None ->
                    []

                Validate.Success ->
                    [ Form.rowSuccess ]

                Validate.Warning ->
                    [ Form.rowWarning ]

                Validate.Danger ->
                    [ Form.rowDanger ]
    in
    Form.row options
        [ Form.colLabel
            [ Col.sm3
            , Col.attrs [ Attr.class "text-right" ]
            ]
            [ Form.label [ Attr.for id ] [ Html.text title ] ]
        , Form.col [ Col.sm9 ] <|
            [ input id validation.status ]
                ++ wrap Form.validationText validation.error
                ++ wrap Form.help help
        ]


form : Bool -> msg -> String -> List (Field msg) -> Html msg
form active msg doText fields =
    let
        buttonOptions =
            if active && List.all (\r -> r.validation.status /= Validate.Danger) fields then
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


inputOptions : Validate.Status -> List (Input.Option msg)
inputOptions status =
    case status of
        Validate.None ->
            []

        Validate.Success ->
            [ Input.success ]

        Validate.Warning ->
            [ Input.warning ]

        Validate.Danger ->
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
