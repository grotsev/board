module Field exposing (..)

import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Error
import Html as Html exposing (Html)
import Html.Attributes as Attr
import I18n.Error
import RemoteData exposing (RemoteData, WebData)
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


rowOptions : Validate.Status -> List (Row.Option msg)
rowOptions status =
    case status of
        Validate.None ->
            []

        Validate.Success ->
            [ Form.rowSuccess ]

        Validate.Warning ->
            [ Form.rowWarning ]

        Validate.Danger ->
            [ Form.rowDanger ]


row : Field msg -> Html msg
row { id, title, help, validation, input } =
    Form.row (rowOptions validation.status)
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


form : WebData a -> msg -> String -> List (Field msg) -> Html msg
form data msg doText fields =
    let
        dataReady =
            not <| RemoteData.isLoading data

        allFieldsValid =
            List.all (\r -> r.validation.status /= Validate.Danger) fields

        buttonOptions =
            if dataReady && allFieldsValid then
                [ Button.primary
                , Button.onClick msg
                ]
            else
                [ Button.disabled True
                ]

        buttonGroup =
            [ Button.button buttonOptions [ Html.text doText ] ]
                ++ (Error.parseData data
                        |> Maybe.map I18n.Error.i18n
                        |> wrap Form.validationText
                   )

        rowOptions =
            case data of
                RemoteData.NotAsked ->
                    []

                RemoteData.Loading ->
                    []

                RemoteData.Success _ ->
                    [ Form.rowSuccess ]

                RemoteData.Failure _ ->
                    [ Form.rowDanger ]
    in
    Form.form [] <|
        List.map row fields
            ++ [ Form.row rowOptions
                    [ Form.colLabel [ Col.sm3 ] []
                    , Form.col [ Col.sm9 ] buttonGroup
                    ]
               ]



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
