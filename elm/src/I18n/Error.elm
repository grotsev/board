module I18n.Error exposing (..)

import Error exposing (Error(..))


i18n : Error -> String
i18n error =
    case error of
        InvalidFormat ->
            "Неверный формат ответа"

        Decode ->
            "Ошибка декодирования"

        YetExists ->
            "Уже существует"

        InvalidPassword ->
            "Неверный пароль"

        UndefinedPostgrest ->
            "Неизвестная ошибка Postgrest"

        Undefined ->
            "Неизвестная ошибка"
