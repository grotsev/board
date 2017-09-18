module Main.Auth.Register exposing (Msg, State, init, update, view)

import Bootstrap.Grid as Grid
import Data.Auth exposing (Auth)
import Date exposing (Date)
import DateTimePicker
import Field
import Html exposing (Html)
import Html.Attributes as Attr
import Postgrest
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
    , registerResponse : Postgrest.Response Auth
    , registerLoading : Bool
    , loginExistsResponse : Postgrest.Response Bool
    }


type Msg
    = LoginMsg String
    | PasswordMsg String
    | PasswordAgainMsg String
    | SurnameMsg String
    | NameMsg String
    | DobMsg DateTimePicker.State (Maybe Date)
    | RegisterRequest
    | RegisterResult (Postgrest.Result Auth)
    | LoginExistsResult (Postgrest.Result Bool)


init : State
init =
    { login = ""
    , password = ""
    , passwordAgain = ""
    , surname = ""
    , name = ""
    , dobState = DateTimePicker.initialState
    , dob = Just <| Date.fromTime 0 -- TODO Nothing
    , registerResponse = Nothing
    , registerLoading = False
    , loginExistsResponse = Nothing
    }


update : Msg -> State -> ( State, Maybe Auth, Cmd Msg )
update msg state =
    let
        maybeAuth =
            state.registerResponse |> Maybe.andThen Result.toMaybe
    in
    case msg of
        LoginMsg login ->
            ( { state | login = login, loginExistsResponse = Nothing }
            , maybeAuth
            , Rpc.loginExists LoginExistsResult Nothing state
            )

        PasswordMsg password ->
            ( { state | password = password }
            , maybeAuth
            , Cmd.none
            )

        PasswordAgainMsg passwordAgain ->
            ( { state | passwordAgain = passwordAgain }
            , maybeAuth
            , Cmd.none
            )

        SurnameMsg surname ->
            ( { state | surname = surname }
            , maybeAuth
            , Cmd.none
            )

        NameMsg name ->
            ( { state | name = name }
            , maybeAuth
            , Cmd.none
            )

        DobMsg dobState dob ->
            ( { state | dobState = dobState, dob = dob }
            , maybeAuth
            , Cmd.none
            )

        RegisterRequest ->
            ( { state | registerLoading = True }
            , maybeAuth
            , Rpc.register RegisterResult
                Nothing
                { state | dob = Maybe.withDefault (Date.fromTime 0) state.dob }
            )

        RegisterResult result ->
            ( { state | registerLoading = False, registerResponse = Just result, loginExistsResponse = Nothing }
            , Result.toMaybe result
            , Cmd.none
            )

        LoginExistsResult result ->
            ( { state | loginExistsResponse = Just result }
            , maybeAuth
            , Cmd.none
            )


view : State -> Html Msg
view { login, password, passwordAgain, surname, name, dobState, dob, registerResponse, registerLoading, loginExistsResponse } =
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
        [ Field.form registerLoading
            registerResponse
            RegisterRequest
            "Зарегистрироваться"
            [ loginField
            , passwordField
            , passwordAgainField
            , surnameField
            , nameField
            , dobField
            ]
        ]
