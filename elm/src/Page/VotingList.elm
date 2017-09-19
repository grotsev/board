module Page.VotingList exposing (..)

import Bootstrap.Table as Table
import Html exposing (Html)
import Http
import Postgrest as Pg
import Resource
import Rocket exposing ((=>))
import Uuid exposing (Uuid)


type alias Voting =
    { voting : Uuid
    , title : String
    }


type alias State =
    { votingList : List Voting
    }


votingCmd : Cmd Msg
votingCmd =
    Pg.query Resource.voting Voting
        |> Pg.select .voting
        |> Pg.select .title
        |> Pg.list Pg.noLimit "http://localhost:3001/"
        |> Http.send Fetch


init : ( State, Cmd Msg )
init =
    { votingList = [] } => votingCmd


view : State -> List (Html msg)
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
        [ Table.td [] [ Html.text voting.title ]
        ]



-- UPDATE --


type Msg
    = Fetch (Result Http.Error (List Voting))


update : Msg -> State -> ( State, Cmd Msg )
update msg state =
    case msg of
        Fetch (Ok votingList) ->
            { state | votingList = votingList } => Cmd.none

        _ ->
            state => Cmd.none
