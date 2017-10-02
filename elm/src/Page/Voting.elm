module Page.Voting exposing (..)

import Html exposing (Html)
import Http
import Postgrest as Pg
import Resource
import Rocket exposing ((=>))
import Uuid exposing (Uuid)


-- MODEL --


type alias Voting =
    { voting : Uuid
    , title : String
    }


type alias Option =
    { option : Uuid
    , title : String
    , staff : List Staff
    }


type alias Staff =
    { name : String
    , surname : String
    }


type alias State =
    { voting : Maybe Voting
    }


votingCmd : String -> Uuid -> Cmd Msg
votingCmd token voting =
    let
        optionQuery =
            Pg.query Resource.option Option
    in
    Pg.query Resource.voting Voting
        |> Pg.select .voting
        |> Pg.select .title
        |> Pg.filter [ .voting |> Pg.eq voting ]
        |> Pg.first "http://localhost:3001/" (Just token)
        |> Http.send Fetch


init : String -> Uuid -> ( State, Cmd Msg )
init token voting =
    { voting = Nothing } => votingCmd token voting



-- VIEW --


view : State -> List (Html msg)
view model =
    [ Html.h2 [] [ Html.text "Ok" ]
    ]



-- UPDATE --


type Msg
    = Fetch (Result Http.Error (Maybe Voting))


update : Msg -> State -> ( State, Cmd Msg )
update msg state =
    case msg of
        Fetch (Ok (Just voting)) ->
            { state | voting = Just voting } => Cmd.none

        _ ->
            state => Cmd.none
