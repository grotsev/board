module Main.Menu exposing (State, initialState, subscriptions, view)

import Bootstrap.Navbar as Navbar
import Html exposing (Html)
import Html.Attributes as Attr
import Route exposing (Route)
import Rpc.Register


type alias State =
    Navbar.State


initialState : (State -> msg) -> ( State, Cmd msg )
initialState =
    Navbar.initialState


subscriptions : State -> (State -> msg) -> Sub msg
subscriptions navState toMsg =
    Navbar.subscriptions navState toMsg


view : (State -> msg) -> State -> Rpc.Register.Out -> Html msg -> Html msg
view navMsg navState registerOut logoutButton =
    Navbar.config navMsg
        |> Navbar.withAnimation
        |> Navbar.container
        |> Navbar.brand [ Attr.href "#" ] [ Html.text "greetgo! Board" ]
        |> Navbar.items
            [ Navbar.itemLink [ Attr.href <| Route.encode Route.VotingList ] [ Html.text "Голосования" ]
            ]
        |> Navbar.customItems
            [ Navbar.textItem [ Attr.class "mr-sm-2" ] [ Html.text <| registerOut.surname ]
            , Navbar.textItem [ Attr.class "mr-sm-3" ] [ Html.text <| registerOut.name ]
            , Navbar.formItem [] [ logoutButton ]
            ]
        |> Navbar.view navState
