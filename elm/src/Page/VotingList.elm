module Page.VotingList exposing (..)

import Bootstrap.Table as Table
import Html exposing (Html)


type alias Voting =
    String


type alias Model =
    { votingList : List Voting
    }


init : Model
init =
    { votingList = [ "zzz", "aaa" ]
    }


view : Model -> List (Html msg)
view { votingList } =
    [ Table.table
        { options = [ Table.striped, Table.hover ]
        , thead =
            Table.simpleThead
                [ Table.th [] [ Html.text "Название" ] ]
        , tbody = Table.tbody [] <| List.map row votingList
        }
    ]


row : Voting -> Table.Row msg
row voting =
    Table.tr []
        [ Table.td [] [ Html.text voting ]
        ]
