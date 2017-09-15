module I18n.Rus exposing (postgrestError)

import Postgrest exposing (Error(..))


postgrestError : Error -> String
postgrestError error =
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
