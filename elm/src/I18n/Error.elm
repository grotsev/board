module I18n.Error exposing (..)

import Http
import Json.Decode as Decode
import Postgrest


postgrest : Postgrest.Error -> Result String String
postgrest { hint, detail, code, message } =
    case code of
        -- unique_violation
        -- TODO extract table from message fk_ and value from detail
        -- TODO server side
        Just "23505" ->
            Ok "Уже существует"

        Just "X0001" ->
            Ok "Неверный логин и пароль"

        _ ->
            Err "Неизвестная ошибка"


default : a -> String
default err =
    Debug.log (toString err) "Внутренняя ошибка "


http : Http.Error -> String
http err =
    case err of
        Http.BadPayload _ _ ->
            Debug.log (toString err) "Неверный формат ответа"

        Http.BadStatus { url, status, headers, body } ->
            body
                |> Decode.decodeString Postgrest.errorDecoder
                |> Result.andThen postgrest
                |> Result.withDefault (default err)

        _ ->
            default err
