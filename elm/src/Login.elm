module Login exposing (..)

import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode
import RemoteData exposing (RemoteData(..), WebData)
import Uuid exposing (Uuid)


type alias Model =
    { surname : String
    , password : String
    , auth : WebData Auth
    }


type alias Auth =
    { surname : String
    , name : String
    , staff : Uuid
    }


type Msg
    = SurnameInput String
    | PasswordInput String
    | LogIn
    | AuthResponse (WebData Auth)
    | LogOut


init : String -> ( Model, Cmd Msg )
init surname =
    { surname = surname, password = "", auth = NotAsked } ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SurnameInput surname ->
            { model | surname = surname } ! []

        PasswordInput password ->
            { model | password = password } ! []

        LogIn ->
            { model | auth = Loading } ! [ getAuth ]

        AuthResponse auth ->
            { model | auth = auth } ! []

        LogOut ->
            { model | auth = NotAsked } ! []


decodeAuth : Decode.Decoder Auth
decodeAuth =
    Debug.crash "TODO"


getAuth : Cmd Msg
getAuth =
    Http.get "/rpc/login" decodeAuth
        -- TODO args
        |> RemoteData.sendRequest
        |> Cmd.map AuthResponse


view : (Msg -> msg) -> Model -> Html msg
view toMsg model =
    let
        surnameGroup =
            \() ->
                Form.group []
                    [ Form.label [ for "surname" ] [ text "Фамилия" ]
                    , Input.text [ Input.onInput (toMsg << SurnameInput) ]
                    ]

        passwordGroup =
            \() ->
                Form.group []
                    [ Form.label [ for "password" ] [ text "Пароль" ]
                    , Input.password [ Input.onInput (toMsg << PasswordInput) ]
                    ]
    in
    case model.auth of
        NotAsked ->
            Form.form []
                [ surnameGroup ()
                , passwordGroup ()
                , Button.button [ Button.primary, Button.onClick <| toMsg LogIn ] [ text "Войти" ]
                ]

        Loading ->
            Form.form []
                [ surnameGroup ()
                , passwordGroup ()
                , Button.button [ Button.disabled True ] [ text "Войти" ] -- TODO loader spinner
                ]

        Failure err ->
            Form.form []
                [ surnameGroup ()
                , passwordGroup ()
                , Button.button [ Button.primary, Button.onClick <| toMsg LogIn ] [ text "Войти" ]
                ]

        Success auth ->
            Form.form []
                [ text auth.surname
                , text auth.name
                , Button.button [ Button.onClick <| toMsg LogOut ] [ text "Выйти" ]
                ]
