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
import Jwt
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



-- TODO String -> -- surname


init : Model
init =
    { surname = "", password = "", auth = NotAsked }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SurnameInput surname ->
            { model | surname = surname } ! []

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
        |> required "surname" Decode.string
        |> required "name" Decode.string
        |> required "staff" Uuid.decoder
        |> Jwt.tokenDecoder


postAuth : Model -> Cmd Msg
postAuth model =
    Http.post "http://localhost:3001/rpc/login" (body model) decodeAuth
        |> RemoteData.sendRequest
        |> Cmd.map AuthResponse


body : Model -> Http.Body
body { surname, password } =
    Http.jsonBody <|
        Encode.object
            [ ( "surname", Encode.string surname )
            , ( "password", Encode.string password )
            ]


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
                , text <| toString err
                ]

        Success auth ->
            Form.form []
                [ text auth.surname
                , text auth.name
                , Button.button [ Button.onClick <| toMsg LogOut ] [ text "Выйти" ]
                ]
