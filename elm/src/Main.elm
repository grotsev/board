module Main exposing (..)

import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Modal as Modal
import Bootstrap.Navbar as Navbar
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Login
import Navigation exposing (Location)
import Route exposing (Route(..))


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
    , navState : Navbar.State
    , modalState : Modal.State
    , loginModel : Login.Model
    }


init : Location -> ( Model, Cmd Msg )
init location =
    let
        ( navState, navCmd ) =
            Navbar.initialState NavMsg

        ( model, urlCmd ) =
            urlUpdate location
                { navState = navState
                , route = Home
                , modalState = Modal.hiddenState
                , loginModel = Login.init
                }
    in
    model ! [ urlCmd, navCmd ]


type Msg
    = UrlChange Location
    | NavMsg Navbar.State
    | ModalMsg Modal.State
    | LoginMsg Login.Msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Navbar.subscriptions model.navState NavMsg


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

        LoginMsg msg ->
            let
                ( loginModel, cmd ) =
                    Login.update msg model.loginModel
            in
            ( { model | loginModel = loginModel }, Cmd.map LoginMsg cmd )


urlUpdate : Navigation.Location -> Model -> ( Model, Cmd Msg )
urlUpdate location model =
    ( { model | route = Route.decode location }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ menu model
        , mainContent model
        , modal model
        ]


menu : Model -> Html Msg
menu model =
    Navbar.config NavMsg
        |> Navbar.withAnimation
        |> Navbar.container
        |> Navbar.brand [ href "#" ] [ text "greetgo! Board" ]
        |> Navbar.items
            [ Navbar.itemLink [ href <| Route.encode VotingList ] [ text "Голосования" ]
            ]
        {- |> Navbar.customItems
           [ Navbar.formItem []
               (Login.view LoginMsg model.loginModel)
           ]
        -}
        |> Navbar.view model.navState


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
    [ h1 [] [ text "Not found" ]
    , text "SOrry couldn't find that route"
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