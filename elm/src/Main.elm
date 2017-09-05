module Main exposing (..)

import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Modal as Modal
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import LoginRegister
import Main.Menu
import Navigation exposing (Location)
import RemoteData exposing (WebData)
import Route exposing (Route(..))
import Route.Home
import Route.NotFound


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
    , loginRegisterModel : LoginRegister.Model
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
                , loginRegisterModel = LoginRegister.init
                }
    in
    model ! [ urlCmd, navCmd ]


type Msg
    = UrlChange Location
    | NavMsg Main.Menu.State
    | ModalMsg Modal.State
    | LoginRegisterMsg LoginRegister.Msg
    | LogOutMsg


subscriptions : Model -> Sub Msg
subscriptions model =
    Main.Menu.subscriptions model.navState NavMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange location ->
            urlUpdate location model

        NavMsg state ->
            ( { model | navState = state }, Cmd.none )

        ModalMsg state ->
            ( { model | modalState = state }, Cmd.none )

        LoginRegisterMsg subMsg ->
            let
                ( subModel, subCmd ) =
                    LoginRegister.update subMsg model.loginRegisterModel
            in
            ( { model | loginRegisterModel = subModel }, Cmd.map LoginRegisterMsg subCmd )

        LogOutMsg ->
            ( { model | loginRegisterModel = LoginRegister.init }, Cmd.none )


urlUpdate : Navigation.Location -> Model -> ( Model, Cmd Msg )
urlUpdate location model =
    ( { model | route = Route.decode location }, Cmd.none )


view : Model -> Html Msg
view model =
    case model.loginRegisterModel.registerModel.loginData of
        RemoteData.Success auth ->
            let
                logoutButton =
                    Button.button [ Button.onClick LogOutMsg ] [ text "Выйти" ]
            in
            div []
                [ Main.Menu.view NavMsg model.navState auth logoutButton
                , mainContent model
                , modal model
                ]

        _ ->
            LoginRegister.view model.loginRegisterModel |> Html.map LoginRegisterMsg


mainContent : Model -> Html Msg
mainContent model =
    Grid.containerFluid [ Attr.class "mt-sm-5" ] <|
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
