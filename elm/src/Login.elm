module Login exposing (Auth, Mode(..), State, init, view)

-- TODO import Date exposing (Date)

import Bootstrap.Alert as Alert
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Tab as Tab
import Date exposing (Date)
import DateTimePicker
import Field
import Html exposing (..)
import Html.Attributes as Attr
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
    , dobState : DateTimePicker.State
    , dob : Maybe Date -- TODO Maybe Date and DatePicker
    , tabState : Tab.State
    }


type Mode
    = Login
    | Register


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
    , dobState = DateTimePicker.initialState
    , dob = Just <| Date.fromTime 0 -- TODO Nothing
    , tabState = Tab.initialState
    }


view : (State -> Mode -> WebData Auth -> msg) -> State -> WebData Auth -> Html msg
view onLogin state authData =
    let
        buttonOptions active mode =
            if active then
                [ Button.primary, Button.onClick <| onLogin state mode Loading ]
            else
                [ Button.disabled True ]

        login =
            Field.input
                "login"
                "логин"
                (\x -> onLogin { state | login = x } Login authData)
                state.login

        password =
            Field.password
                "password"
                "пароль"
                (\x -> onLogin { state | password = x } Login authData)
                state.password

        passwordAgain =
            Field.password
                "passwordAgain"
                "ещё раз пароль"
                (\x -> onLogin { state | passwordAgain = x } Login authData)
                state.passwordAgain

        surname =
            Field.input
                "surname"
                "фамилия"
                (\x -> onLogin { state | surname = x } Login authData)
                state.surname

        name =
            Field.input
                "name"
                "имя"
                (\x -> onLogin { state | name = x } Login authData)
                state.name

        dob =
            Form.group []
                [ Form.label [ Attr.for "dob" ] [ text "дата рождения" ]
                , DateTimePicker.datePicker
                    (\s d -> onLogin { state | dobState = s, dob = d } Login authData)
                    [ Attr.id "dob" ]
                    state.dobState
                    state.dob
                ]

        loginForm active =
            Form.form []
                [ login
                , password
                , Button.button (buttonOptions active Login) [ text "войти" ] -- TODO loader spinner
                ]

        registerForm active =
            Form.form []
                [ login
                , password
                , passwordAgain
                , surname
                , name
                , dob
                , Button.button (buttonOptions active Register) [ text "зарегистрироваться" ] -- TODO loader spinner
                ]

        tab active =
            Tab.config (\x -> onLogin { state | tabState = x } Login authData)
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

                Http.BadStatus { url, status, headers, body } ->
                    let
                        { code, message } =
                            status
                    in
                    case message of
                        "Conflict" ->
                            "Такой пользователь уже существует"

                        _ ->
                            "Внутренняя ошибка" ++ toString err

                _ ->
                    "Внутренняя ошибка" ++ toString err
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
                [ Button.onClick <| onLogin { state | password = "" } Login NotAsked
                ]
                [ text "Выйти" ]
