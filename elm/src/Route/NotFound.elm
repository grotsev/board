module Route.NotFound exposing (..)

import Html exposing (..)


view : List (Html msg)
view =
    [ h1 [] [ text "Страница не найдена" ]
    , text "Страница где-то рядом"
    ]
