module Main exposing (..)

import Bootstrap.Button as Button
import Bootstrap.Card as Card
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
    Grid.container [] <|
        case model.route of
            Home ->
                routeHome model

            VotingList ->
                routeGettingStarted model

            NotFound ->
                routeNotFound

            _ ->
                Debug.crash "TODO"


routeHome : Model -> List (Html Msg)
routeHome model =
    [ h1 [] [ text "Home" ]
    , Grid.row []
        [ Grid.col []
            [ Card.config [ Card.outlinePrimary ]
                |> Card.headerH4 [] [ text "Getting started" ]
                |> Card.block []
                    [ Card.text [] [ text "Getting started is real easy. Just click the start button." ]
                    , Card.custom <|
                        Button.linkButton
                            [ Button.primary, Button.attrs [ href "#getting-started" ] ]
                            [ text "Start" ]
                    ]
                |> Card.view
            ]
        , Grid.col []
            [ Card.config [ Card.outlineDanger ]
                |> Card.headerH4 [] [ text "Modules" ]
                |> Card.block []
                    [ Card.text [] [ text "Check out the modules overview" ]
                    , Card.custom <|
                        Button.linkButton
                            [ Button.primary, Button.attrs [ href "#modules" ] ]
                            [ text "Module" ]
                    ]
                |> Card.view
            ]
        ]
    ]


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


routeNotFound : List (Html Msg)
routeNotFound =
    [ h1 [] [ text "Страница не найдена" ]
    , text "Страница где-то рядом"
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
