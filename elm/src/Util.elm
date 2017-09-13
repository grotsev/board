module Util exposing (pair, viewIf)

import Html exposing (Html)


pair : a -> b -> ( a, b )
pair =
    (,)


viewIf : Bool -> Html msg -> Html msg
viewIf condition content =
    if condition then
        content
    else
        Html.text ""
