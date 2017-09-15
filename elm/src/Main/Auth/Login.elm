module Main.Auth.Login exposing (Msg, State, update, view)

import Bootstrap.Grid as Grid
import Data.Auth exposing (Auth)
import Field
import Html exposing (Html)
import Html.Attributes as Attr
import Postgrest
import Rpc
import Validate exposing (Validation)


type alias State a =
    { a
        | login : String
        , password : String
        , loginData : Postgrest.Data Auth
        , loginLoading : Bool
        , loginExists : Bool
    }


type Msg
    = LoginMsg String
    | PasswordMsg String
    | LoginRequestMsg
    | LoginResponseMsg (Postgrest.Response Auth)
    | LoginExistsResponseMsg (Postgrest.Response Bool)


update : Msg -> State a -> ( State a, Maybe Auth, Cmd Msg )
update msg state =
    let
        maybeAuth =
            state.loginData |> Maybe.andThen Result.toMaybe
    in
    case msg of
        LoginMsg login ->
            ( { state | login = login, loginExists = False }
            , maybeAuth
            , Rpc.loginExists LoginExistsResponseMsg Nothing state
            )

        PasswordMsg password ->
            ( { state | password = password }
            , maybeAuth
            , Cmd.none
            )

        LoginRequestMsg ->
            ( { state | loginLoading = True }
            , maybeAuth
            , Rpc.login LoginResponseMsg Nothing state
            )

        LoginResponseMsg response ->
            ( { state | loginLoading = False, loginData = Just response }
            , Result.toMaybe response
            , Cmd.none
            )

        LoginExistsResponseMsg response ->
            ( { state | loginExists = response |> Result.toMaybe |> Maybe.withDefault False }
            , maybeAuth
            , Cmd.none
            )


view : State a -> Html Msg
view { login, password, loginData, loginLoading, loginExists } =
    let
        loginExistsValidation =
            case loginExists of
                True ->
                    Validate.none

                False ->
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
        [ Field.form loginLoading
            loginData
            LoginRequestMsg
            "Войти"
            [ loginField
            , passwordField
            ]
        ]
