module Login exposing (..)

import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Html exposing (..)
import Html.Attributes exposing (for)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode exposing (Value)
import RemoteData exposing (RemoteData(..), WebData)
import Uuid exposing (Uuid)


type alias Model =
    { login : String
    , password : String
    , auth : WebData Auth
    }


type alias Auth =
    { staff : Uuid
    , role : String
    , exp : Int
    , surname : String
    , name : String
    , token : String
    }


type Msg
    = LoginInput String
    | PasswordInput String
    | LogIn
    | AuthResponse (WebData Auth)
    | LogOut



-- TODO String -> -- login


init : Model
init =
    { login = "", password = "", auth = NotAsked }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoginInput login ->
            { model | login = login } ! []

        PasswordInput password ->
            { model | password = password } ! []

        LogIn ->
            { model | auth = Loading } ! [ postAuth model ]

        AuthResponse auth ->
            { model | auth = auth } ! []

        LogOut ->
            { model | auth = NotAsked } ! []


decodeAuth : Decoder Auth
decodeAuth =
    decode Auth
        |> required "staff" Uuid.decoder
        |> required "role" Decode.string
        |> required "exp" Decode.int
        |> required "surname" Decode.string
        |> required "name" Decode.string
        |> required "token" Decode.string


postAuth : Model -> Cmd Msg
postAuth model =
    Http.request
        { method = "POST"
        , headers = [ Http.header "Accept" "application/vnd.pgrst.object+json" ]
        , url = "http://localhost:3001/rpc/login"
        , body = body model
        , expect = Http.expectJson decodeAuth
        , timeout = Nothing
        , withCredentials = False
        }
        |> RemoteData.sendRequest
        |> Cmd.map AuthResponse


body : Model -> Http.Body
body { login, password } =
    Http.jsonBody <|
        Encode.object
            [ ( "login", Encode.string login )
            , ( "password", Encode.string password )
            ]


view : (Msg -> msg) -> Model -> Html msg
view toMsg model =
    let
        loginGroup =
            \() ->
                Form.group []
                    [ Form.label [ for "login" ] [ text "Логин" ]
                    , Input.text [ Input.onInput (toMsg << LoginInput) ]
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
                [ loginGroup ()
                , passwordGroup ()
                , Button.button [ Button.primary, Button.onClick <| toMsg LogIn ] [ text "Войти" ]
                ]

        Loading ->
            Form.form []
                [ loginGroup ()
                , passwordGroup ()
                , Button.button [ Button.disabled True ] [ text "Войти" ] -- TODO loader spinner
                ]

        Failure err ->
            Form.form []
                [ loginGroup ()
                , passwordGroup ()
                , Button.button [ Button.primary, Button.onClick <| toMsg LogIn ] [ text "Войти" ]
                , text <| toString err
                ]

        Success auth ->
            Form.form []
                [ text auth.surname
                , text auth.name
                , Button.button [ Button.onClick <| toMsg LogOut ] [ text "Выйти" ]
                ]
