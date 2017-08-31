module Login exposing (Auth, Mode(..), State, init, view)

-- TODO import Date exposing (Date)

import Bootstrap.Alert as Alert
import Bootstrap.Button as Button
import Bootstrap.Form as Form
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
            Field.row "login" "логин" <|
                Field.text
                    (\x -> onLogin { state | login = x } Login authData)
                    state.login

        password =
            Field.row "password" "пароль" <|
                Field.password
                    (\x -> onLogin { state | password = x } Login authData)
                    state.password

        passwordAgain =
            Field.row "passwordAgain" "ещё раз пароль" <|
                Field.password
                    (\x -> onLogin { state | passwordAgain = x } Login authData)
                    state.passwordAgain

        surname =
            Field.row "surname" "фамилия" <|
                Field.text
                    (\x -> onLogin { state | surname = x } Login authData)
                    state.surname

        name =
            Field.row "name" "имя" <|
                Field.text
                    (\x -> onLogin { state | name = x } Login authData)
                    state.name

        dob =
            Field.row "dob" "дата рождения" <|
                \id ->
                    DateTimePicker.datePicker
                        (\s d -> onLogin { state | dobState = s, dob = d } Login authData)
                        [ Attr.id id ]
                        state.dobState
                        state.dob

        loginForm active =
            Grid.container [ Attr.class "mt-sm-5" ]
                [ Form.form []
                    [ login
                    , password
                    , Button.button (buttonOptions active Login) [ text "войти" ] -- TODO loader spinner
                    ]
                ]

        registerForm active =
            Grid.container [ Attr.class "mt-sm-5" ]
                [ Form.form []
                    [ login
                    , password
                    , passwordAgain
                    , surname
                    , name
                    , dob
                    , Button.button (buttonOptions active Register) [ text "зарегистрироваться" ] -- TODO loader spinner
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
                [ Button.onClick <| onLogin { state | password = "" } Login NotAsked
                ]
                [ text "Выйти" ]
