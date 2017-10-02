module Page.VotingList exposing (..)

import Bootstrap.Table as Table
import Html exposing (Html)
import Http
import Postgrest as Pg
import Resource
import Rocket exposing ((=>))
import Route
import Uuid exposing (Uuid)


type alias Voting =
    { voting : Uuid
    , title : String
    }


type alias State =
    { votingList : List Voting
    }


votingCmd : Maybe String -> Cmd Msg
votingCmd maybeToken =
    Pg.query Resource.voting Voting
        |> Pg.select .voting
        |> Pg.select .title
        |> Pg.list Pg.noLimit "http://localhost:3001/" maybeToken
        |> Http.send Fetch


init : Maybe String -> ( State, Cmd Msg )
init maybeToken =
    let
        cmd =
            case maybeToken of
                Nothing ->
                    Cmd.none

                Just _ ->
                    votingCmd maybeToken
    in
    { votingList = [] } => cmd


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
