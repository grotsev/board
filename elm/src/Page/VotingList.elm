module Page.VotingList exposing (..)

import Bootstrap.Table as Table
import Html exposing (Html)
import Http
import Postgrest as Pg
import Resource
import Rocket exposing ((=>))
import Route
import Uuid exposing (Uuid)


-- MODEL --


type alias Voting =
    { voting : Uuid
    , title : String
    }


type alias State =
    { votingList : List Voting
    }


votingListCmd : String -> Cmd Msg
votingListCmd token =
    Pg.query Resource.voting Voting
        |> Pg.select .voting
        |> Pg.select .title
        |> Pg.list Pg.noLimit "http://localhost:3001/" (Just token)
        |> Http.send Fetch


init : String -> ( State, Cmd Msg )
init token =
    { votingList = [] } => votingListCmd token



-- VIEW --


view : State -> List (Html msg)
view { votingList } =
    [ Table.table
        { options = [ Table.striped, Table.hover ]
        , thead =
            Table.simpleThead
                [ Table.th [] [ Html.text "Название" ] ]
        , tbody = Table.tbody [] <| List.map viewRow votingList
        }
    ]


viewRow : Voting -> Table.Row msg
viewRow voting =
    Table.tr []
        [ Table.td []
            [ Html.a [ Route.href <| Route.Voting voting.voting ] [ Html.text voting.title ]
            ]
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
