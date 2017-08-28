module Route.Home exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Route exposing (Route(..))


view : List (Html msg)
view =
    [ h2 [] [ text "Что такое Board" ]
    , p []
        [ text "Board упрощает коммуникации по мелким бизнес-процессам внутри компании, для которых почта менее удобна."
        ]
    , h2 [] [ text "Какие бизнес-процессы" ]
    , ul []
        [ li []
            [ a [ href <| Route.encode VotingList ] [ text "голосование" ]
            , ul []
                [ li [] [ text "подарок ко дню рождения" ]
                , li [] [ text "общий вопрос" ]
                ]
            ]
        , li [] [ text "заказ обеда" ]
        ]
    ]
