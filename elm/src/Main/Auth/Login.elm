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
        , loginResponse : Postgrest.Response Auth
        , loginLoading : Bool
        , loginExistsResponse : Postgrest.Response Bool
    }


type Msg
    = LoginMsg String
    | PasswordMsg String
    | LoginRequest
    | LoginResult (Postgrest.Result Auth)
    | LoginExistsResult (Postgrest.Result Bool)


update : Msg -> State a -> ( State a, Maybe Auth, Cmd Msg )
update msg state =
    let
        maybeAuth =
            state.loginResponse |> Maybe.andThen Result.toMaybe
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

        LoginRequest ->
            ( { state | loginLoading = True }
            , maybeAuth
            , Rpc.login LoginResult Nothing state
            )

        LoginResult result ->
            ( { state | loginLoading = False, loginResponse = Just result, loginExistsResponse = Nothing }
            , Result.toMaybe result
            , Cmd.none
            )

        LoginExistsResult result ->
            ( { state | loginExistsResponse = Just result }
            , maybeAuth
            , Cmd.none
            )


view : State a -> Html Msg
view { login, password, loginResponse, loginLoading, loginExistsResponse } =
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
        [ Field.form loginLoading
            loginResponse
            LoginRequest
            "Войти"
            [ loginField
            , passwordField
            ]
        ]
