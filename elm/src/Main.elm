module Main exposing (main)

import Auth
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Navbar as Navbar
import Data.Auth as Auth exposing (Auth)
import Html exposing (Html)
import Html.Attributes as Attr
import Json.Decode as Decode exposing (Value)
import Navigation exposing (Location)
import Page.Home
import Page.NotFound
import Page.Voting
import Page.VotingList
import Rocket exposing ((=>))
import Route exposing (Route)


type Page
    = Home
    | NotFound
    | VotingList Page.VotingList.State
    | Voting Page.Voting.Model



-- MODEL --


type alias Model =
    { navbarState : Navbar.State
    , maybeRoute : Maybe Route
    , page : Page
    , authState : Auth.State
    }


init : Value -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg

        ( model, pageCmd ) =
            routeToPage
                { navbarState = navbarState
                , maybeRoute = Route.fromLocation location
                , page = Home
                , authState = Auth.init
                }
    in
    model ! [ navbarCmd, pageCmd ]



-- VIEW --


view : Model -> Html Msg
view model =
    case Auth.fromState model.authState of
        Just auth ->
            Html.div []
                [ viewNavbar model.navbarState auth
                , viewPage model.page auth
                ]

        Nothing ->
            Auth.view model.authState |> Html.map AuthMsg


viewNavbar : Navbar.State -> Auth -> Html Msg
viewNavbar navbarState auth =
    Navbar.config NavbarMsg
        |> Navbar.withAnimation
        |> Navbar.container
        |> Navbar.brand [ Attr.href "#" ] [ Html.text "greetgo! Board" ]
        |> Navbar.items
            [ Navbar.itemLink [ Route.href Route.VotingList ] [ Html.text "Голосования" ]
            ]
        |> Navbar.customItems
            [ Navbar.textItem [ Attr.class "mr-sm-2" ] [ Html.text <| auth.surname ]
            , Navbar.textItem [ Attr.class "mr-sm-3" ] [ Html.text <| auth.name ]
            , Navbar.formItem []
                [ Button.button [ Button.small, Button.onClick LogoutMsg ] [ Html.text "Выйти" ]
                ]
            ]
        |> Navbar.view navbarState


viewPage : Page -> Auth -> Html Msg
viewPage page auth =
    Grid.containerFluid [ Attr.class "mt-sm-5" ] <|
        case page of
            Home ->
                Page.Home.view

            NotFound ->
                Page.NotFound.view

            VotingList subModel ->
                Page.VotingList.view subModel

            Voting subModel ->
                Page.Voting.view subModel



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        pageSubscriptions =
            case model.page of
                Home ->
                    Sub.none

                NotFound ->
                    Sub.none

                VotingList _ ->
                    Sub.none

                Voting _ ->
                    Sub.none
    in
    Sub.batch
        [ pageSubscriptions
        , Navbar.subscriptions model.navbarState NavbarMsg
        ]



-- UPDATE --


type Msg
    = SetRoute (Maybe Route)
    | NavbarMsg Navbar.State
    | AuthMsg Auth.Msg
    | LogoutMsg
    | VotingListMsg Page.VotingList.Msg


routeToPage : Model -> ( Model, Cmd Msg )
routeToPage model =
    case model.maybeRoute of
        Nothing ->
            { model | page = NotFound } => Cmd.none

        Just Route.Home ->
            { model | page = Home } => Cmd.none

        Just Route.VotingList ->
            let
                ( votingListModel, votingListCmd ) =
                    Page.VotingList.init <| Maybe.map .token <| Auth.fromState model.authState
            in
            { model | page = VotingList votingListModel } => Cmd.map VotingListMsg votingListCmd

        Just (Route.Voting voting) ->
            { model | page = Voting Page.Voting.init } => Page.Voting.initCmd


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetRoute maybeRoute ->
            routeToPage { model | maybeRoute = maybeRoute }

        NavbarMsg state ->
            { model | navbarState = state } => Cmd.none

        AuthMsg subMsg ->
            let
                ( authState, authCmd ) =
                    Auth.update subMsg model.authState

                ( routeModel, routeCmd ) =
                    routeToPage { model | authState = authState }
            in
            routeModel ! [ Cmd.map AuthMsg authCmd, routeCmd ]

        LogoutMsg ->
            { model | authState = Auth.init } => Cmd.none

        VotingListMsg subMsg ->
            case model.page of
                VotingList subState ->
                    let
                        ( newSubState, subCmd ) =
                            Page.VotingList.update subMsg subState
                    in
                    { model | page = VotingList newSubState } => Cmd.map VotingListMsg subCmd

                _ ->
                    model => Cmd.none



-- MAIN --


main : Program Value Model Msg
main =
    Navigation.programWithFlags (SetRoute << Route.fromLocation)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
