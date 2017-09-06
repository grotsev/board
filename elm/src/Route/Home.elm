module Route.Home exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Route exposing (Route)


view : List (Html msg)
view =
    [ Html.h2 [] [ Html.text "Что такое Board" ]
    , Html.p []
        [ Html.text "Board упрощает коммуникации по мелким бизнес-процессам внутри компании, для которых почта менее удобна."
        ]
    , Html.h2 [] [ Html.text "Какие бизнес-процессы" ]
    , Html.ul []
        [ Html.li []
            [ Html.a [ Attr.href <| Route.encode Route.VotingList ] [ Html.text "голосование" ]
            , Html.ul []
                [ Html.li [] [ Html.text "подарок ко дню рождения" ]
                , Html.li [] [ Html.text "общий вопрос" ]
                ]
            ]
        , Html.li [] [ Html.text "заказ обеда" ]
        ]
    ]
