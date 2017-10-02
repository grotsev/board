module Page.Voting exposing (..)

import Html exposing (Html)
import Http
import Postgrest as Pg
import Resource
import Uuid exposing (Uuid)


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


type alias Model =
    Maybe Option


votingCmd : Maybe String -> Cmd Msg
votingCmd maybeToken =
    let
        optionQuery =
            Pg.query Resource.option Option
    in
    Pg.query Resource.voting Voting
        |> Pg.select .voting
        |> Pg.select .title
        |> Pg.first "http://localhost:3001/" maybeToken
        |> Http.send Fetch


init : Model
init =
    Nothing


initCmd : Cmd msg
initCmd =
    Cmd.none


view : Model -> List (Html msg)
view model =
    [ Html.h2 [] [ Html.text "Ok" ]
    ]



-- UPDATE --


type Msg
    = Fetch (Result Http.Error (Maybe Voting))
