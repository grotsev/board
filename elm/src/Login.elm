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
        tab activeLoginButton =
            let
                options =
                    if activeLoginButton then
                        [ Button.primary, Button.onClick <| onLogin state Loading ]
                    else
                        [ Button.disabled True ]

                form =
                    Form.form []
                        [ Field.input
                            "login"
                            "логин"
                            (\x -> onLogin { state | login = x } authData)
                            state.login
                        , Field.password
                            "password"
                            "пароль"
                            (\x -> onLogin { state | password = x } authData)
                            state.password
                        , Button.button options [ text "войти" ] -- TODO loader spinner
                        , Field.password
                            "passwordAgain"
                            "ещё раз пароль"
                            (\x -> onLogin { state | passwordAgain = x } authData)
                            state.passwordAgain
                        , Field.input
                            "surname"
                            "фамилия"
                            (\x -> onLogin { state | surname = x } authData)
                            state.surname
                        , Field.input
                            "name"
                            "имя"
                            (\x -> onLogin { state | name = x } authData)
                            state.name
                        , Field.input
                            "dob"
                            "дата рождения"
                            (\x -> onLogin { state | dob = x } authData)
                            state.dob
                        , Button.button options [ text "зарегистрироваться" ] -- TODO loader spinner
                        ]
            in
            Tab.config (\x -> onLogin { state | tabState = x } authData)
                |> Tab.items
                    [ Tab.item
                        { id = "tab1"
                        , link = Tab.link [] [ text "Tab 1" ]
                        , pane = Tab.pane [] [ form ]
                        }
                    , Tab.item
                        { id = "tab2"
                        , link = Tab.link [] [ text "Tab 2" ]
                        , pane = Tab.pane [] [ form ]
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
