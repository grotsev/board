module Register exposing (Model, Msg(..), init, update, view)

import Bootstrap.Grid as Grid
import Date exposing (Date)
import DateTimePicker
import Field
import Html exposing (..)
import Html.Attributes as Attr
import RemoteData exposing (RemoteData(..), WebData)
import Rpc.Register


type alias Model =
    { login : String
    , password : String
    , passwordAgain : String
    , surname : String
    , name : String
    , dobState : DateTimePicker.State
    , dob : Maybe Date
    , loginData : WebData Rpc.Register.Out
    }


type Msg
    = LoginMsg String
    | PasswordMsg String
    | PasswordAgainMsg String
    | SurnameMsg String
    | NameMsg String
    | DobMsg DateTimePicker.State (Maybe Date)
    | RegisterRequestMsg
    | RegisterResponseMsg (WebData Rpc.Register.Out)


init : Model
init =
    -- TODO set login from cookies
    { login = ""
    , password = ""
    , passwordAgain = ""
    , surname = ""
    , name = ""
    , dobState = DateTimePicker.initialState
    , dob = Just <| Date.fromTime 0 -- TODO Nothing
    , loginData = NotAsked
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoginMsg login ->
            ( { model | login = login }, Cmd.none )

        PasswordMsg password ->
            ( { model | password = password }, Cmd.none )

        PasswordAgainMsg passwordAgain ->
            ( { model | passwordAgain = passwordAgain }, Cmd.none )

        SurnameMsg surname ->
            ( { model | surname = surname }, Cmd.none )

        NameMsg name ->
            ( { model | name = name }, Cmd.none )

        DobMsg dobState dob ->
            ( { model | dobState = dobState, dob = dob }, Cmd.none )

        RegisterRequestMsg ->
            ( { model | loginData = Loading }
            , { model | dob = Maybe.withDefault (Date.fromTime 0) model.dob }
                |> Rpc.Register.call
                |> Cmd.map RegisterResponseMsg
            )

        RegisterResponseMsg loginData ->
            ( { model | loginData = loginData }, Cmd.none )


view : Model -> Html Msg
view { login, password, passwordAgain, surname, name, dobState, dob, loginData } =
    let
        loginField =
            { id = "register-login"
            , title = "Логин"
            , help = Just "Уникальный идентификатор пользователя"
            , validation = Field.filled login
            , input = Field.text LoginMsg login
            }

        passwordField =
            { id = "register-password"
            , title = "Пароль"
            , help = Nothing
            , validation = Field.secure password
            , input = Field.password PasswordMsg password
            }

        passwordAgainField =
            let
                validation =
                    if password == passwordAgain then
                        Field.Validation Field.Success Nothing
                    else
                        Field.Validation Field.Danger <| Just "Пароли должны совпадать"
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
            , validation = Field.filled surname
            , input = Field.text SurnameMsg surname
            }

        nameField =
            { id = "name"
            , title = "Имя"
            , help = Nothing
            , validation = Field.none
            , input = Field.text NameMsg name
            }

        dobField =
            { id = "dob"
            , title = "Дата рождения"
            , help = Nothing
            , validation = Field.required dob

            -- TODO use validation
            , input = \id validation -> DateTimePicker.datePicker DobMsg [ Attr.id id ] dobState dob
            }
    in
    Grid.container [ Attr.class "mt-sm-5" ]
        [ Field.form (not <| RemoteData.isLoading loginData)
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
