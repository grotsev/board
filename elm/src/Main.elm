module Main exposing (..)

import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Modal as Modal
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Login
import Main.Menu
import Navigation exposing (Location)
import RemoteData exposing (WebData)
import Route exposing (Route(..))
import Route.Home
import Route.NotFound
import Rpc.Login


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { view = view
        , update = update
        , subscriptions = subscriptions
        , init = init
        }


type alias Model =
    { route : Route
    , navState : Main.Menu.State
    , modalState : Modal.State
    , loginState : Login.State
    , authData : WebData Login.Auth
    }


init : Location -> ( Model, Cmd Msg )
init location =
    let
        ( navState, navCmd ) =
            Main.Menu.initialState NavMsg

        ( model, urlCmd ) =
            urlUpdate location
                { navState = navState
                , route = Home
                , modalState = Modal.hiddenState
                , loginState = Login.init
                , authData = RemoteData.NotAsked
                }
    in
    model ! [ urlCmd, navCmd ]


type Msg
    = UrlChange Location
    | NavMsg Main.Menu.State
    | ModalMsg Modal.State
    | LoginMsg Login.State (WebData Login.Auth)
    | LoginResponse (WebData Login.Auth)


subscriptions : Model -> Sub Msg
subscriptions model =
    Main.Menu.subscriptions model.navState NavMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange location ->
            urlUpdate location model

        NavMsg state ->
            ( { model | navState = state }
            , Cmd.none
            )

        ModalMsg state ->
            ( { model | modalState = state }
            , Cmd.none
            )

        LoginMsg state authData ->
            ( { model | loginState = state, authData = authData }
            , case authData of
                RemoteData.Loading ->
                    Cmd.map LoginResponse (Rpc.Login.call state)

                _ ->
                    Cmd.none
            )

        LoginResponse authData ->
            ( { model | authData = authData }
            , Cmd.none
            )


urlUpdate : Navigation.Location -> Model -> ( Model, Cmd Msg )
urlUpdate location model =
    ( { model | route = Route.decode location }, Cmd.none )


view : Model -> Html Msg
view model =
    case model.authData of
        RemoteData.Success auth ->
            let
                logoutButton =
                    Login.view LoginMsg model.loginState model.authData
            in
            div []
                [ Main.Menu.view NavMsg model.navState auth logoutButton
                , mainContent model
                , modal model
                ]

        _ ->
            Login.view LoginMsg model.loginState model.authData


mainContent : Model -> Html Msg
mainContent model =
    Grid.container [ class "mt-sm-5" ] <|
        case model.route of
            Home ->
                Route.Home.view

            VotingList ->
                routeGettingStarted model

            NotFound ->
                Route.NotFound.view

            _ ->
                Debug.crash "TODO"


routeGettingStarted : Model -> List (Html Msg)
routeGettingStarted model =
    [ h2 [] [ text "Getting started" ]
    , Button.button
        [ Button.success
        , Button.large
        , Button.block
        , Button.attrs [ onClick <| ModalMsg Modal.visibleState ]
        ]
        [ text "Click me" ]
    ]


modal : Model -> Html Msg
modal model =
    Modal.config ModalMsg
        |> Modal.small
        |> Modal.h4 [] [ text "Getting started ?" ]
        |> Modal.body []
            [ Grid.containerFluid []
                [ Grid.row []
                    [ Grid.col
                        [ Col.xs6 ]
                        [ text "Col 1" ]
                    , Grid.col
                        [ Col.xs6 ]
                        [ text "Col 2" ]
                    ]
                ]
            ]
        |> Modal.view model.modalState
