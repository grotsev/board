module Main.Menu exposing (..)

import Bootstrap.Navbar as Navbar
import Html exposing (..)
import Html.Attributes exposing (..)
import Route exposing (Route(..))


type alias State =
    Navbar.State


initialState : (State -> msg) -> ( State, Cmd msg )
initialState =
    Navbar.initialState


subscriptions : State -> (State -> msg) -> Sub msg
subscriptions navState toMsg =
    Navbar.subscriptions navState toMsg


view : (State -> msg) -> State -> { surname : String, name : String } -> Html msg -> Html msg
view navMsg navState { surname, name } logoutButton =
    Navbar.config navMsg
        |> Navbar.withAnimation
        |> Navbar.container
        |> Navbar.brand [ href "#" ] [ text "greetgo! Board" ]
        |> Navbar.items
            [ Navbar.itemLink [ href <| Route.encode VotingList ] [ text "Голосования" ]
            ]
        |> Navbar.customItems
            [ Navbar.formItem []
                [ text surname
                , text name
                , logoutButton
                ]
            ]
        |> Navbar.view navState
