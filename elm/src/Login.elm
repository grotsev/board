module Login exposing (Auth, State, init, view)

-- TODO import Date exposing (Date)

import Bootstrap.Alert as Alert
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import RemoteData exposing (RemoteData(..), WebData)
import Uuid exposing (Uuid)


-- TODO tab registration


type alias State =
    { login : String
    , password : String
    , passwordAgain : String
    , surname : String
    , name : String
    , dob : String -- TODO Maybe Date
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
    { login = "pet"
    , password = "secret"
    , passwordAgain = ""
    , surname = ""
    , name = ""
    , dob = "" -- TODO Nothing
    }


view : (State -> WebData Auth -> msg) -> State -> WebData Auth -> Html msg
view onLogin state authData =
    let
        form activeLoginButton =
            let
                options =
                    if activeLoginButton then
                        [ Button.primary, Button.onClick <| onLogin state Loading ]
                    else
                        [ Button.disabled True ]
            in
            Form.form []
                [ Form.group []
                    [ Form.label [ for "login" ] [ text "логин" ]
                    , Input.text
                        [ Input.value state.login
                        , Input.onInput <| \login -> onLogin { state | login = login } authData
                        ]
                    ]
                , Form.group []
                    [ Form.label [ for "password" ] [ text "пароль" ]
                    , Input.password
                        [ Input.value state.password
                        , Input.onInput <| \password -> onLogin { state | password = password } authData
                        ]
                    ]
                , Button.button options [ text "войти" ] -- TODO loader spinner
                , Form.group []
                    [ Form.label [ for "passwordAgain" ] [ text "ещё раз пароль" ]
                    , Input.password
                        [ Input.value state.passwordAgain
                        , Input.onInput <| \passwordAgain -> onLogin { state | passwordAgain = passwordAgain } authData
                        ]
                    ]
                , Form.group []
                    [ Form.label [ for "surname" ] [ text "фамилия" ]
                    , Input.text
                        [ Input.value state.surname
                        , Input.onInput <| \surname -> onLogin { state | surname = surname } authData
                        ]
                    ]
                , Form.group []
                    [ Form.label [ for "name" ] [ text "имя" ]
                    , Input.text
                        [ Input.value state.name
                        , Input.onInput <| \name -> onLogin { state | name = name } authData
                        ]
                    ]
                , Form.group []
                    [ Form.label [ for "dob" ] [ text "дата рождения" ]
                    , Input.text
                        [ Input.value state.dob
                        , Input.onInput <| \dob -> onLogin { state | dob = dob } authData
                        ]
                    ]
                , Button.button options [ text "зарегистрироваться" ] -- TODO loader spinner
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
                [ Button.onClick <| onLogin { state | password = "" } NotAsked
                ]
                [ text "Выйти" ]
