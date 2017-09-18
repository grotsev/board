module Main.Auth exposing (Msg, State, fromState, init, update, view)

import Bootstrap.Grid as Grid
import Bootstrap.Tab as Tab
import Data.Auth exposing (Auth)
import Date exposing (Date)
import DateTimePicker
import Field
import Html exposing (Html)
import Html.Attributes as Attr
import Postgrest
import Rocket exposing ((=>))
import Rpc
import Validate exposing (Validation)


type alias State =
    { login : String
    , password : String
    , passwordAgain : String
    , surname : String
    , name : String
    , dobState : DateTimePicker.State
    , dob : Maybe Date

    --
    , authResponse : Postgrest.Response Auth
    , authLoading : Bool
    , loginExistsResponse : Postgrest.Response Bool

    --
    , tabState : Tab.State
    }


type Msg
    = LoginMsg String
    | PasswordMsg String
    | PasswordAgainMsg String
    | SurnameMsg String
    | NameMsg String
    | DobMsg DateTimePicker.State (Maybe Date)
      --
    | LoginRequest
    | RegisterRequest
    | AuthResult (Postgrest.Result Auth)
    | LoginExistsResult (Postgrest.Result Bool)
      --
    | TabMsg Tab.State


init : State
init =
    { login = ""
    , password = ""
    , passwordAgain = ""
    , surname = ""
    , name = ""
    , dobState = DateTimePicker.initialState
    , dob = Just <| Date.fromTime 0 -- TODO Nothing

    --
    , authResponse = Nothing
    , authLoading = False
    , loginExistsResponse = Nothing

    --
    , tabState = Tab.initialState
    }


update : Msg -> State -> ( State, Cmd Msg )
update msg state =
    case msg of
        LoginMsg login ->
            ( { state | login = login, loginExistsResponse = Nothing }
            , Rpc.loginExists LoginExistsResult Nothing state
            )

        PasswordMsg password ->
            { state | password = password } => Cmd.none

        PasswordAgainMsg passwordAgain ->
            { state | passwordAgain = passwordAgain } => Cmd.none

        SurnameMsg surname ->
            { state | surname = surname } => Cmd.none

        NameMsg name ->
            { state | name = name } => Cmd.none

        DobMsg dobState dob ->
            { state | dob = dob, dobState = dobState } => Cmd.none

        LoginRequest ->
            ( { state | authLoading = True }
            , Rpc.login AuthResult Nothing state
            )

        RegisterRequest ->
            ( { state | authLoading = True }
            , Rpc.register AuthResult Nothing <|
                { state | dob = Maybe.withDefault (Date.fromTime 0) state.dob }
            )

        AuthResult result ->
            { state | authLoading = False, authResponse = Just result } => Cmd.none

        LoginExistsResult result ->
            { state | loginExistsResponse = Just result } => Cmd.none

        TabMsg tabState ->
            { state | tabState = tabState } => Cmd.none


view : State -> Html Msg
view state =
    Grid.container [ Attr.class "mt-sm-5" ]
        [ Grid.row []
            [ Grid.col []
                [ Tab.config TabMsg
                    |> Tab.items
                        [ Tab.item
                            { id = "loginTab"
                            , link = Tab.link [] [ Html.text "Вход" ]
                            , pane = Tab.pane [] [ viewLogin state ]
                            }
                        , Tab.item
                            { id = "registerTab"
                            , link = Tab.link [] [ Html.text "Регистрация" ]
                            , pane = Tab.pane [] [ viewRegister state ]
                            }
                        ]
                    |> Tab.view state.tabState
                ]
            ]
        ]


viewLogin : State -> Html Msg
viewLogin { login, password, passwordAgain, surname, name, dobState, dob, authResponse, authLoading, loginExistsResponse, tabState } =
    let
        loginExistsValidation =
            case loginExistsResponse of
                Just (Ok True) ->
                    Validate.none

                _ ->
                    Validation Validate.Danger <| Just "Нет такого логина"

        loginField =
            { id = "login-login"
            , title = "Логин"
            , help = Just "Уникальный идентификатор пользователя"
            , validation =
                Validate.concat
                    [ Validate.filled login
                    , loginExistsValidation
                    ]
            , input = Field.text LoginMsg login
            }

        passwordField =
            { id = "login-password"
            , title = "Пароль"
            , help = Nothing
            , validation = Validate.secure password
            , input = Field.password PasswordMsg password
            }
    in
    Grid.container [ Attr.class "mt-sm-5" ]
        [ Field.form authLoading authResponse LoginRequest "Войти" <|
            [ loginField
            , passwordField
            ]
        ]


viewRegister : State -> Html Msg
viewRegister { login, password, passwordAgain, surname, name, dobState, dob, authResponse, authLoading, loginExistsResponse, tabState } =
    let
        loginNotExistsValidation =
            case loginExistsResponse of
                Just (Ok False) ->
                    Validate.none

                _ ->
                    Validation Validate.Danger <| Just "Логин уже существует"

        loginField =
            { id = "register-login"
            , title = "Логин"
            , help = Just "Уникальный идентификатор пользователя"
            , validation =
                Validate.concat
                    [ Validate.filled login
                    , loginNotExistsValidation
                    ]
            , input = Field.text LoginMsg login
            }

        passwordField =
            { id = "register-password"
            , title = "Пароль"
            , help = Nothing
            , validation = Validate.secure password
            , input = Field.password PasswordMsg password
            }

        passwordAgainField =
            let
                validation =
                    if password == passwordAgain then
                        Validate.Validation Validate.Success Nothing
                    else
                        Validate.Validation Validate.Danger <| Just "Пароли должны совпадать"
            in
            { id = "passwordAgain"
            , title = "Ещё раз пароль"
            , help = Nothing
            , validation = validation
            , input = Field.password PasswordAgainMsg passwordAgain
            }

        surnameField =
            { id = "surname"
            , title = "Фамилия"
            , help = Nothing
            , validation = Validate.filled surname
            , input = Field.text SurnameMsg surname
            }

        nameField =
            { id = "name"
            , title = "Имя"
            , help = Nothing
            , validation = Validate.none
            , input = Field.text NameMsg name
            }

        dobField =
            { id = "dob"
            , title = "Дата рождения"
            , help = Nothing
            , validation = Validate.required dob

            -- TODO use validation
            , input = \id validation -> DateTimePicker.datePicker DobMsg [ Attr.id id ] dobState dob
            }
    in
    Grid.container [ Attr.class "mt-sm-5" ]
        [ Field.form authLoading authResponse RegisterRequest "Зарегистрироваться" <|
            [ loginField
            , passwordField
            , passwordAgainField
            , surnameField
            , nameField
            , dobField
            ]
        ]


fromState : State -> Maybe Auth
fromState state =
    state.authResponse |> Maybe.andThen Result.toMaybe
