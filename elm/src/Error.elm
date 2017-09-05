module Error exposing (Error(..), parseData)

import Http
import Json.Decode as Decode
import Postgrest
import RemoteData exposing (RemoteData, WebData)


type Error
    = InvalidFormat
    | Decode
    | YetExists
    | InvalidPassword
    | UndefinedPostgrest
    | Undefined


parseData : WebData a -> Maybe Error
parseData data =
    case data of
        RemoteData.Failure err ->
            Just <| parseHttpError err

        _ ->
            Nothing


parseHttpError : Http.Error -> Error
parseHttpError err =
    let
        log =
            Debug.log (toString err)
    in
    case err of
        Http.BadPayload _ _ ->
            log InvalidFormat

        Http.BadStatus { url, status, headers, body } ->
            body
                |> Decode.decodeString Postgrest.errorDecoder
                |> Result.map postgrest
                |> Result.withDefault (log Decode)

        _ ->
            log Undefined


postgrest : Postgrest.Error -> Error
postgrest { hint, detail, code, message } =
    case code of
        -- unique_violation
        -- TODO extract table from message fk_ and value from detail
        Just "23505" ->
            YetExists

        Just "A0001" ->
            InvalidPassword

        _ ->
            UndefinedPostgrest
