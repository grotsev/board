module Page.NotFound exposing (view)

import Html exposing (Html)


view : List (Html msg)
view =
    [ Html.h1 [] [ Html.text "Страница не найдена" ]
    , Html.text "Страница где-то рядом"
    ]
