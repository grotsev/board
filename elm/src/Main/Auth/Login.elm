module Main.Auth.Login exposing (Model, Msg, State, update, view)

import Bootstrap.Grid as Grid
import Field
import Html exposing (Html)
import Html.Attributes as Attr
import RemoteData exposing (RemoteData, WebData)
import Rpc.Login
import Rpc.LoginExists
import Validate exposing (Validation)


type alias State a =
    { a
        | login : String
        , password : String
        , loginExistsData : WebData Bool
    }


type alias Model =
    WebData Rpc.Login.Out


type Msg
    = LoginMsg String
    | PasswordMsg String
    | LoginRequestMsg
    | LoginResponseMsg (WebData Rpc.Login.Out)
    | LoginExistsResponseMsg (WebData Bool)


update : Msg -> State a -> Model -> ( State a, Model, Cmd Msg )
update msg state model =
    case msg of
        LoginMsg login ->
            ( { state | login = login }, model, Rpc.LoginExists.call { login = login } |> Cmd.map LoginExistsResponseMsg )

        PasswordMsg password ->
            ( { state | password = password }, model, Cmd.none )

        LoginRequestMsg ->
            ( state, RemoteData.Loading, Rpc.Login.call state |> Cmd.map LoginResponseMsg )

        LoginResponseMsg authData ->
            ( state, authData, Cmd.none )

        LoginExistsResponseMsg loginExistsData ->
            ( { state | loginExistsData = loginExistsData }, model, Cmd.none )


view : State a -> Model -> Html Msg
view { login, password, loginExistsData } authData =
    let
        loginExistsValidation =
            case loginExistsData of
                RemoteData.Success True ->
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
        [ Field.form authData
            LoginRequestMsg
            "Войти"
            [ loginField
            , passwordField
            ]
        ]
