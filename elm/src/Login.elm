module Login exposing (Auth, Mode(..), State, init, view)

-- TODO import Date exposing (Date)

import Bootstrap.Alert as Alert
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Tab as Tab
import Date exposing (Date)
import DateTimePicker
import Field
import Html exposing (..)
import Html.Attributes as Attr
import I18n.Error as Error
import RemoteData exposing (RemoteData(..), WebData)
import Uuid exposing (Uuid)


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
    -- TODO set from cookies
    { login = ""
    , password = ""
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
                [ Button.attrs [ Attr.class "float-right" ]
                , Button.primary
                , Button.onClick <| onLogin state mode Loading
                ]
            else
                [ Button.attrs [ Attr.class "float-right" ]
                , Button.disabled True
                ]

        login prefix =
            { id = prefix ++ "login"
            , title = "Логин"
            , help = Just "Уникальный идентификатор пользователя"
            , validation = Field.filled state.login
            , input =
                Field.text
                    (\x -> onLogin { state | login = x } Login authData)
                    state.login
            }

        password prefix =
            { id = prefix ++ "password"
            , title = "Пароль"
            , help = Nothing
            , validation = Field.secure state.password
            , input =
                Field.password
                    (\x -> onLogin { state | password = x } Login authData)
                    state.password
            }

        passwordAgain =
            let
                validation =
                    if state.password == state.passwordAgain then
                        Field.Validation Field.Success Nothing
                    else
                        Field.Validation Field.Danger <| Just "Пароли должны совпадать"
            in
            { id = "passwordAgain"
            , title = "Ещё раз пароль"
            , help = Nothing
            , validation = validation
            , input =
                Field.password
                    (\x -> onLogin { state | passwordAgain = x } Login authData)
                    state.passwordAgain
            }

        surname =
            { id = "surname"
            , title = "Фамилия"
            , help = Nothing
            , validation = Field.filled state.surname
            , input =
                Field.text
                    (\x -> onLogin { state | surname = x } Login authData)
                    state.surname
            }

        name =
            { id = "name"
            , title = "Имя"
            , help = Nothing
            , validation = Field.none
            , input =
                Field.text
                    (\x -> onLogin { state | name = x } Login authData)
                    state.name
            }

        dob =
            { id = "dob"
            , title = "Дата рождения"
            , help = Nothing
            , validation = Field.required state.dob
            , input =
                \id validation ->
                    -- TODO use validation
                    DateTimePicker.datePicker
                        (\s d -> onLogin { state | dobState = s, dob = d } Login authData)
                        [ Attr.id id ]
                        state.dobState
                        state.dob
            }

        loginForm active =
            Grid.container [ Attr.class "mt-sm-5" ]
                [ Field.form active
                    (onLogin state Login Loading)
                    "Войти"
                    [ login "login-"
                    , password "login-"
                    ]
                ]

        registerForm active =
            Grid.container [ Attr.class "mt-sm-5" ]
                [ Field.form active
                    (onLogin state Register Loading)
                    "Зарегистрироваться"
                    [ login "register-"
                    , password "register-"
                    , passwordAgain
                    , surname
                    , name
                    , dob
                    ]
                ]

        content active =
            Grid.container [ Attr.class "mt-sm-5" ]
                [ Grid.row []
                    [ Grid.col []
                        [ Tab.config
                            (\x -> onLogin { state | tabState = x } Login authData)
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
                        ]
                    ]
                ]
    in
    case authData of
        NotAsked ->
            content True

        Loading ->
            content False

        Failure err ->
            div []
                [ content True
                , Alert.warning [ text <| Error.http err ]
                ]

        Success auth ->
            Button.button
                [ Button.onClick <| onLogin init Login NotAsked
                ]
                [ text "Выйти" ]
