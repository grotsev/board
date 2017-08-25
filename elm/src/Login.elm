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



-- TODO String -> -- login
-- TODO Config


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

        onLogIn _ =
            Button.onClick <| onChange state Loading

        {- Http.request
           { method = "POST"
           , headers = [ Http.header "Accept" "application/vnd.pgrst.object+json" ]
           , url = "http://localhost:3001/rpc/login"
           , body = body state
           , expect = Http.expectJson decodeAuth
           , timeout = Nothing
           , withCredentials = False
           }
           |> RemoteData.sendRequest
           |> Cmd.map AuthResponse
           |> onChange state Loading
        -}
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
                , Button.button [ Button.primary, onLogIn () ] [ text "Войти" ]
                ]

        Loading ->
            Form.form []
                [ loginGroup ()
                , passwordGroup ()
                , Button.button [ Button.disabled True ] [ text "Войти" ] -- TODO loader spinner
                ]

        Failure err ->
            div []
                [ Form.form []
                    [ loginGroup ()
                    , passwordGroup ()
                    , Button.button [ Button.primary, onLogIn () ] [ text "Войти" ]
                    ]
                , Alert.warning [ text <| errDescription err ]
                ]

        Success auth ->
            Form.form []
                [ text auth.surname
                , text auth.name
                , Button.button [ onLogOut () ] [ text "Выйти" ]
                ]
