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
    , validation : Validation
    , input : String -> Status -> Html msg
    }


type Status
    = None
    | Success
    | Warning
    | Danger


type alias Validation =
    { status : Status
    , error : Maybe String
    }


text : (String -> msg) -> String -> (String -> Status -> Html msg)
text toMsg value id status =
    Input.text <|
        [ Input.id id
        , Input.value value
        , Input.onInput toMsg
        ]
            ++ inputOptions status


password : (String -> msg) -> String -> (String -> Status -> Html msg)
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
        , input id validation.status
        ]
            ++ wrap Form.validationText validation.error
            ++ wrap Form.help help


row : Field msg -> Html msg
row { id, title, help, validation, input } =
    let
        options =
            case validation.status of
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
            [ input id validation.status ]
                ++ wrap Form.validationText validation.error
                ++ wrap Form.help help
        ]


form : Bool -> msg -> String -> List (Field msg) -> Html msg
form active msg doText fields =
    let
        buttonOptions =
            if active && List.all (\r -> r.validation.status /= Danger) fields then
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


inputOptions : Status -> List (Input.Option msg)
inputOptions status =
    case status of
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


required : Maybe a -> Validation
required maybe =
    case maybe of
        Nothing ->
            Validation Danger <| Just "Обязательное поле"

        Just _ ->
            Validation Success Nothing


length : Int -> String -> Validation
length base s =
    let
        l =
            String.length s
    in
    if l < base then
        Validation Danger <| Just "Короткая длина"
    else
        Validation Success Nothing


filled : String -> Validation
filled s =
    if String.isEmpty s then
        Validation Danger <| Just "Обязательное поле"
    else
        Validation Success Nothing


secure : String -> Validation
secure s =
    let
        l =
            String.length s
    in
    if l < 8 then
        Validation Danger <| Just "Слишком короткий пароль"
    else if l < 12 then
        Validation Warning <| Just "Лучше пароль ещё длиннее"
    else
        Validation Success Nothing


none : Validation
none =
    Validation None Nothing
