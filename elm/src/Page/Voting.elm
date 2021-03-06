module Page.Voting exposing (..)

import Bootstrap.Badge as Badge
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.ListGroup as ListGroup
import Html exposing (Html)
import Html.Attributes as Attr
import Http
import Postgrest as Pg
import Resource
import Rocket exposing ((=>))
import Uuid exposing (Uuid)


-- MODEL --


type alias Voting =
    { voting : Uuid
    , title : String
    , option : List Option
    }


type alias Option =
    { option : Uuid
    , title : String
    , vote : List Vote
    }


type alias Vote =
    { staff : Maybe Staff
    }


type alias Staff =
    { staff : Uuid
    , name : String
    , surname : String
    }


type alias State =
    { voting : Maybe Voting
    }


votingCmd : String -> Uuid -> Cmd Msg
votingCmd token voting =
    let
        votingQuery =
            Pg.query Resource.voting Voting
                |> Pg.select .voting
                |> Pg.select .title
                |> Pg.includeMany .option Pg.noLimit optionQuery
                |> Pg.filter [ .voting |> Pg.eq voting ]

        optionQuery =
            Pg.query Resource.option Option
                |> Pg.select .option
                |> Pg.select .title
                |> Pg.includeMany .vote Pg.noLimit voteQuery

        voteQuery =
            Pg.query Resource.vote Vote
                |> Pg.include .staff staffQuery

        staffQuery =
            Pg.query Resource.staff Staff
                |> Pg.select .staff
                |> Pg.select .name
                |> Pg.select .surname
    in
    votingQuery
        |> Pg.first "http://localhost:3001/" (Just token)
        |> Http.send Fetch


init : String -> Uuid -> ( State, Cmd Msg )
init token voting =
    { voting = Nothing } => votingCmd token voting



-- VIEW --


view : State -> List (Html msg)
view state =
    case state.voting of
        Nothing ->
            [ Html.text "Loading" ]

        Just voting ->
            [ Html.h2 [] [ Html.text "Ok" ]
            , ListGroup.ul <| List.map viewOption voting.option
            ]


viewOption : Option -> ListGroup.Item msg
viewOption option =
    let
        isMe x =
            True

        -- TODO
    in
    ListGroup.li []
        [ Checkbox.checkbox [ Checkbox.checked <| List.any isMe <| List.filterMap .staff <| option.vote ] ""
        , viewPill option.vote
        , Html.text option.title
        ]


viewPill : List Vote -> Html msg
viewPill listVote =
    Badge.pill
        [ Attr.class "mx-sm-3"
        , listVote
            |> List.filterMap .staff
            |> List.map fullName
            |> String.join ", "
            |> Attr.title
        ]
        [ listVote
            |> List.length
            |> Basics.toString
            |> Html.text
        ]


fullName : Staff -> String
fullName staff =
    String.join " " [ staff.surname, staff.name ]



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
