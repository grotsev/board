module Postgrest exposing (Data, Error(..), Response, Rpc, send)

import Http
import Json.Decode exposing (Decoder, decodeString, nullable, string)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode exposing (Value)


type Error
    = InvalidFormat
    | Decode
    | YetExists
    | InvalidPassword
    | UndefinedPostgrest
    | Undefined


type alias Rpc input output =
    { url : String
    , single : Bool
    , encode : input -> Value
    , decoder : Decoder output
    }


type alias Response output =
    Result Error output


type alias Data output =
    Maybe (Response output)



-- INTERNAL ERROR RESPONSE --


type alias ErrorResponse =
    { hint : Maybe String
    , detail : Maybe String
    , code : Maybe String
    , message : Maybe String
    }


errorResponseDecoder : Decoder ErrorResponse
errorResponseDecoder =
    decode ErrorResponse
        |> required "hint" (nullable string)
        |> required "details" (nullable string)
        |> required "code" (nullable string)
        |> required "message" (nullable string)


fromErrorResponse : ErrorResponse -> Error
fromErrorResponse { hint, detail, code, message } =
    case code of
        -- unique_violation
        -- TODO extract table from message fk_ and value from detail
        Just "23505" ->
            YetExists

        Just "A0001" ->
            InvalidPassword

        _ ->
            UndefinedPostgrest



-- INTERNAL --


fromHttpError : Http.Error -> Error
fromHttpError err =
    let
        log =
            Debug.log (toString err)

        withLazyDefault d e =
            case e of
                Err _ ->
                    log d

                Ok err ->
                    err
    in
    case err of
        Http.BadPayload _ _ ->
            log InvalidFormat

        Http.BadStatus { url, status, headers, body } ->
            body
                |> decodeString errorResponseDecoder
                |> Result.map fromErrorResponse
                |> withLazyDefault Decode

        _ ->
            log Undefined


rpcRequest : Rpc input output -> Maybe String -> input -> Http.Request output
rpcRequest { url, single, encode, decoder } token input =
    let
        accept =
            case single of
                False ->
                    []

                True ->
                    [ Http.header "Accept" "application/vnd.pgrst.object+json" ]

        authorization =
            case token of
                Maybe.Nothing ->
                    []

                Just token ->
                    [ Http.header "Authorization" <| "Bearer " ++ token ]
    in
    Http.request
        { method = "POST"
        , headers = accept ++ authorization
        , url = url
        , body = Http.jsonBody (encode input)
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }



-- PUBLIC --


send : Rpc input output -> (Response output -> msg) -> Maybe String -> input -> Cmd msg
send rpc onResponse token input =
    Http.send
        (Result.mapError fromHttpError >> onResponse)
        (rpcRequest rpc token input)
