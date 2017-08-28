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
    -- TODO set to "" or from cookies
    { login = "pet", password = "secret" }


view : (State -> WebData Auth -> msg) -> State -> WebData Auth -> Html msg
view onChange state authData =
    let
        form activeLoginButton =
            let
                options =
                    if activeLoginButton then
                        [ Button.primary, Button.onClick <| onChange state Loading ]
                    else
                        [ Button.disabled True ]
            in
            Form.form []
                [ Form.group []
                    [ Form.label [ for "login" ] [ text "Логин" ]
                    , Input.text
                        [ Input.value state.login
                        , Input.onInput <| \login -> onChange { state | login = login } authData
                        ]
                    ]
                , Form.group []
                    [ Form.label [ for "password" ] [ text "Пароль" ]
                    , Input.password
                        [ Input.value state.password
                        , Input.onInput <| \password -> onChange { state | password = password } authData
                        ]
                    ]
                , Button.button options [ text "Войти" ] -- TODO loader spinner
                ]

        errDescription err =
            case err of
                Http.BadPayload _ _ ->
                    "Неверный логин и пароль"

                _ ->
                    "Внутренняя ошибка"
    in
    case authData of
        NotAsked ->
            form True

        Loading ->
            form False

        Failure err ->
            div []
                [ form True
                , Alert.warning [ text <| errDescription err ]
                ]

        Success auth ->
            Button.button
                [ Button.onClick <| onChange { state | password = "" } NotAsked
                ]
                [ text "Выйти" ]
