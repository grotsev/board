module Login exposing (Auth, State, init, view)

import Bootstrap.Alert as Alert
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import RemoteData exposing (RemoteData(..), WebData)
import Uuid exposing (Uuid)


type alias State =
    { login : String
    , password : String
    }


type alias Auth =
    { staff : Uuid
    , role : String
    , exp : Int
    , surname : String
    , name : String
    , token : String
    }


init : State
init =
    { login = "", password = "" }


view : (State -> WebData Auth -> msg) -> State -> WebData Auth -> Html msg
view onChange state auth =
    let
        loginGroup _ =
            Form.group []
                [ Form.label [ for "login" ] [ text "Логин" ]
                , Input.text
                    [ Input.value state.login
                    , Input.onInput <| \login -> onChange { state | login = login } auth
                    ]
                ]

        passwordGroup _ =
            Form.group []
                [ Form.label [ for "password" ] [ text "Пароль" ]
                , Input.password
                    [ Input.value state.password
                    , Input.onInput <| \password -> onChange { state | password = password } auth
                    ]
                ]

        loginButton active =
            let
                options =
                    if active then
                        [ Button.primary, Button.onClick <| onChange state Loading ]
                    else
                        [ Button.disabled True ]
            in
            Button.button options [ text "Войти" ]

        onLogOut _ =
            Button.onClick <| onChange { state | password = "" } NotAsked

        errDescription err =
            case err of
                Http.BadPayload _ _ ->
                    "Неверный логин и пароль"

                _ ->
                    "Внутренняя ошибка"
    in
    case auth of
        NotAsked ->
            Form.form []
                [ loginGroup ()
                , passwordGroup ()
                , loginButton True
                ]

        Loading ->
            Form.form []
                [ loginGroup ()
                , passwordGroup ()
                , loginButton False -- TODO loader spinner
                ]

        Failure err ->
            div []
                [ Form.form []
                    [ loginGroup ()
                    , passwordGroup ()
                    , loginButton True
                    ]
                , Alert.warning [ text <| errDescription err ]
                ]

        Success auth ->
            Button.button [ onLogOut () ] [ text "Выйти" ]
