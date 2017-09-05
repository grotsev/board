module Main.Auth.Register exposing (Model, Msg, State, init, update, view)

import Bootstrap.Grid as Grid
import Date exposing (Date)
import DateTimePicker
import Field
import Html exposing (..)
import Html.Attributes as Attr
import RemoteData exposing (RemoteData, WebData)
import Rpc.Register
import Validate


type alias State =
    { login : String
    , password : String
    , passwordAgain : String
    , surname : String
    , name : String
    , dobState : DateTimePicker.State
    , dob : Maybe Date
    }


type alias Model =
    WebData Rpc.Register.Out


type Msg
    = LoginMsg String
    | PasswordMsg String
    | PasswordAgainMsg String
    | SurnameMsg String
    | NameMsg String
    | DobMsg DateTimePicker.State (Maybe Date)
    | RegisterRequestMsg
    | RegisterResponseMsg (WebData Rpc.Register.Out)


init : State
init =
    -- TODO set login from cookies
    { login = ""
    , password = ""
    , passwordAgain = ""
    , surname = ""
    , name = ""
    , dobState = DateTimePicker.initialState
    , dob = Just <| Date.fromTime 0 -- TODO Nothing
    }


update : Msg -> State -> Model -> ( State, Model, Cmd Msg )
update msg state model =
    case msg of
        LoginMsg login ->
            ( { state | login = login }, model, Cmd.none )

        PasswordMsg password ->
            ( { state | password = password }, model, Cmd.none )

        PasswordAgainMsg passwordAgain ->
            ( { state | passwordAgain = passwordAgain }, model, Cmd.none )

        SurnameMsg surname ->
            ( { state | surname = surname }, model, Cmd.none )

        NameMsg name ->
            ( { state | name = name }, model, Cmd.none )

        DobMsg dobState dob ->
            ( { state | dobState = dobState, dob = dob }, model, Cmd.none )

        RegisterRequestMsg ->
            ( state
            , RemoteData.Loading
            , { state | dob = Maybe.withDefault (Date.fromTime 0) state.dob }
                |> Rpc.Register.call
                |> Cmd.map RegisterResponseMsg
            )

        RegisterResponseMsg authData ->
            ( state, authData, Cmd.none )


view : State -> Model -> Html Msg
view { login, password, passwordAgain, surname, name, dobState, dob } authData =
    let
        loginField =
            { id = "register-login"
            , title = "Логин"
            , help = Just "Уникальный идентификатор пользователя"
            , validation = Validate.filled login
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
        [ Field.form authData
            RegisterRequestMsg
            "Зарегистрироваться"
            [ loginField
            , passwordField
            , passwordAgainField
            , surnameField
            , nameField
            , dobField
            ]
        ]
