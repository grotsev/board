module Main.Auth.Login exposing (Model, Msg, State, update, view)

import Bootstrap.Grid as Grid
import Field
import Html exposing (..)
import Html.Attributes as Attr
import RemoteData exposing (RemoteData, WebData)
import Rpc.Login
import Validate


type alias State a =
    { a
        | login : String
        , password : String
    }


type alias Model =
    WebData Rpc.Login.Out


type Msg
    = LoginMsg String
    | PasswordMsg String
    | LoginRequestMsg
    | LoginResponseMsg (WebData Rpc.Login.Out)


update : Msg -> State a -> Model -> ( State a, Model, Cmd Msg )
update msg state model =
    case msg of
        LoginMsg login ->
            ( { state | login = login }, model, Cmd.none )

        PasswordMsg password ->
            ( { state | password = password }, model, Cmd.none )

        LoginRequestMsg ->
            ( state, RemoteData.Loading, Rpc.Login.call state |> Cmd.map LoginResponseMsg )

        LoginResponseMsg authData ->
            ( state, authData, Cmd.none )


view : State a -> Model -> Html Msg
view { login, password } authData =
    let
        loginField =
            { id = "login-login"
            , title = "Логин"
            , help = Just "Уникальный идентификатор пользователя"
            , validation = Validate.filled login
            , input = Field.text LoginMsg login
            }

        passwordField =
            { id = "login-password"
            , title = "Пароль"
            , help = Nothing
            , validation = Validate.secure password -- TODO show RemoteData Err
            , input = Field.password PasswordMsg password
            }
    in
    Grid.container [ Attr.class "mt-sm-5" ]
        [ Field.form authData
            LoginRequestMsg
            "Войти"
            [ loginField
            , passwordField
            ]
        ]
