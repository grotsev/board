module Main.Auth.Login exposing (Model, Msg(..), update, view)

-- TODO import Date exposing (Date)

import Bootstrap.Grid as Grid
import Field
import Html exposing (..)
import Html.Attributes as Attr
import RemoteData exposing (RemoteData(..), WebData)
import Rpc.Login


type alias Model a =
    { a
        | login : String
        , password : String
        , authData : WebData Rpc.Login.Out
    }


type Msg
    = LoginMsg String
    | PasswordMsg String
    | LoginRequestMsg
    | LoginResponseMsg (WebData Rpc.Login.Out)


update : Msg -> Model a -> ( Model a, Cmd Msg )
update msg model =
    case msg of
        LoginMsg login ->
            ( { model | login = login }, Cmd.none )

        PasswordMsg password ->
            ( { model | password = password }, Cmd.none )

        LoginRequestMsg ->
            ( { model | authData = Loading }, Rpc.Login.call model |> Cmd.map LoginResponseMsg )

        LoginResponseMsg authData ->
            ( { model | authData = authData }, Cmd.none )


view : Model a -> Html Msg
view { login, password, authData } =
    let
        loginField =
            { id = "login-login"
            , title = "Логин"
            , help = Just "Уникальный идентификатор пользователя"
            , validation = Field.filled login
            , input = Field.text LoginMsg login
            }

        passwordField =
            { id = "login-password"
            , title = "Пароль"
            , help = Nothing
            , validation = Field.secure password -- TODO error
            , input = Field.password PasswordMsg password
            }
    in
    Grid.container [ Attr.class "mt-sm-5" ]
        [ Field.form (not <| RemoteData.isLoading authData)
            LoginRequestMsg
            "Войти"
            [ loginField
            , passwordField
            ]
        ]
