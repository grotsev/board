module I18n.Error exposing (i18n)

import Error exposing (Error)


i18n : Error -> String
i18n error =
    case error of
        Error.InvalidFormat ->
            "Неверный формат ответа"

        Error.Decode ->
            "Ошибка декодирования"

        Error.YetExists ->
            "Уже существует"

        Error.InvalidPassword ->
            "Неверный пароль"

        Error.UndefinedPostgrest ->
            "Неизвестная ошибка Postgrest"

        Error.Undefined ->
            "Неизвестная ошибка"
