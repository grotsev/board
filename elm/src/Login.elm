module Login exposing (Auth, State, init, view)

-- TODO import Date exposing (Date)

import Bootstrap.Alert as Alert
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Tab as Tab
import Field
import Html exposing (..)
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
    , dob : String -- TODO Maybe Date and DatePicker
    , tabState : Tab.State
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
    , tabState = Tab.initialState
    }


view : (State -> WebData Auth -> msg) -> State -> WebData Auth -> Html msg
view onLogin state authData =
    let
        buttonOptions active =
            if active then
                [ Button.primary, Button.onClick <| onLogin state Loading ]
            else
                [ Button.disabled True ]

        login =
            Field.input
                "login"
                "логин"
                (\x -> onLogin { state | login = x } authData)
                state.login

        password =
            Field.password
                "password"
                "пароль"
                (\x -> onLogin { state | password = x } authData)
                state.password

        passwordAgain =
            Field.password
                "passwordAgain"
                "ещё раз пароль"
                (\x -> onLogin { state | passwordAgain = x } authData)
                state.passwordAgain

        surname =
            Field.input
                "surname"
                "фамилия"
                (\x -> onLogin { state | surname = x } authData)
                state.surname

        name =
            Field.input
                "name"
                "имя"
                (\x -> onLogin { state | name = x } authData)
                state.name

        dob =
            Field.input
                "dob"
                "дата рождения"
                (\x -> onLogin { state | dob = x } authData)
                state.dob

        loginForm active =
            Form.form []
                [ login
                , password
                , Button.button (buttonOptions active) [ text "войти" ] -- TODO loader spinner
                ]

        registerForm active =
            Form.form []
                [ login
                , password
                , passwordAgain
                , surname
                , name
                , dob
                , Button.button (buttonOptions active) [ text "зарегистрироваться" ] -- TODO loader spinner
                ]

        tab active =
            Tab.config (\x -> onLogin { state | tabState = x } authData)
                |> Tab.items
                    [ Tab.item
                        { id = "loginTab"
                        , link = Tab.link [] [ text "Вход" ]
                        , pane = Tab.pane [] [ loginForm active ]
                        }
                    , Tab.item
                        { id = "registerTab"
                        , link = Tab.link [] [ text "Регистрация" ]
                        , pane = Tab.pane [] [ registerForm active ]
                        }
                    ]
                |> Tab.view state.tabState

        errDescription err =
            case err of
                Http.BadPayload _ _ ->
                    "Неверный логин и пароль"

                _ ->
                    "Внутренняя ошибка"
    in
    case authData of
        NotAsked ->
            tab True

        Loading ->
            tab False

        Failure err ->
            div []
                [ tab True
                , Alert.warning [ text <| errDescription err ]
                ]

        Success auth ->
            Button.button
                [ Button.onClick <| onLogin { state | password = "" } NotAsked
                ]
                [ text "Выйти" ]
