module Main.Auth exposing (Model, Msg(..), init, update, view)

import Bootstrap.Grid as Grid
import Bootstrap.Tab as Tab
import Html exposing (..)
import Html.Attributes as Attr
import Main.Auth.Login as Login
import Main.Auth.Register as Register


type alias Model =
    { registerModel : Register.Model
    , tabState : Tab.State
    }


type Msg
    = TabMsg Tab.State
    | LoginMsg Login.Msg
    | RegisterMsg Register.Msg


init : Model
init =
    { registerModel = Register.init
    , tabState = Tab.initialState
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TabMsg tabState ->
            ( { model | tabState = tabState }, Cmd.none )

        LoginMsg subMsg ->
            let
                ( subModel, subCmd ) =
                    Login.update subMsg model.registerModel
            in
            ( { model | registerModel = subModel }, Cmd.map LoginMsg subCmd )

        RegisterMsg subMsg ->
            let
                ( subModel, subCmd ) =
                    Register.update subMsg model.registerModel
            in
            ( { model | registerModel = subModel }, Cmd.map RegisterMsg subCmd )


view : Model -> Html Msg
view { registerModel, tabState } =
    Grid.container [ Attr.class "mt-sm-5" ]
        [ Grid.row []
            [ Grid.col []
                [ Tab.config TabMsg
                    |> Tab.items
                        [ Tab.item
                            { id = "loginTab"
                            , link = Tab.link [] [ text "Вход" ]
                            , pane = Tab.pane [] [ Login.view registerModel |> Html.map LoginMsg ]
                            }
                        , Tab.item
                            { id = "registerTab"
                            , link = Tab.link [] [ text "Регистрация" ]
                            , pane = Tab.pane [] [ Register.view registerModel |> Html.map RegisterMsg ]
                            }
                        ]
                    |> Tab.view tabState
                ]
            ]
        ]
