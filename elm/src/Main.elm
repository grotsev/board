module Main exposing (main)

import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Navbar as Navbar
import Data.Auth as Auth exposing (Auth)
import Html exposing (Html)
import Html.Attributes as Attr
import Json.Decode as Decode exposing (Value)
import Main.AuthTab as AuthTab
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
    | VotingList Page.VotingList.Model
    | Voting Page.Voting.Model



-- MODEL --


type alias Model =
    { navbarState : Navbar.State
    , page : Page
    , authResult : Result AuthTab.Model Auth
    }


init : Value -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg

        ( model, pageCmd ) =
            setRoute (Route.fromLocation location)
                { navbarState = navbarState
                , page = Home
                , authResult = Err AuthTab.init
                }
    in
    model ! [ navbarCmd, pageCmd ]



-- VIEW --


view : Model -> Html Msg
view model =
    case model.authResult of
        Ok auth ->
            Html.div []
                [ viewNavbar model.navbarState auth
                , viewPage model.page auth
                ]

        Err authModel ->
            AuthTab.view authModel |> Html.map AuthTabMsg


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
    | AuthTabMsg AuthTab.Msg
    | LogoutMsg


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    case maybeRoute of
        Nothing ->
            { model | page = NotFound } => Cmd.none

        Just Route.Home ->
            { model | page = Home } => Cmd.none

        Just Route.VotingList ->
            { model | page = VotingList Page.VotingList.init } => Cmd.none

        Just (Route.Voting voting) ->
            { model | page = Voting Page.Voting.init } => Page.Voting.initCmd


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetRoute maybeRoute ->
            setRoute maybeRoute model

        NavbarMsg state ->
            ( { model | navbarState = state }, Cmd.none )

        AuthTabMsg subMsg ->
            case model.authResult of
                Err authModel ->
                    let
                        ( subModel, subCmd ) =
                            AuthTab.update subMsg authModel
                    in
                    ( { model | authResult = Err subModel }, Cmd.map AuthTabMsg subCmd )

                Ok _ ->
                    ( model, Cmd.none )

        LogoutMsg ->
            ( { model | authResult = Err AuthTab.init }, Cmd.none )



-- MAIN --


main : Program Value Model Msg
main =
    Navigation.programWithFlags (SetRoute << Route.fromLocation)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
