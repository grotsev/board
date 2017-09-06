module Main.Auth exposing (Model, Msg, init, update, view)

import Bootstrap.Grid as Grid
import Bootstrap.Tab as Tab
import Html exposing (Html)
import Html.Attributes as Attr
import Main.Auth.Login as Login
import Main.Auth.Register as Register
import RemoteData exposing (RemoteData, WebData)


type alias Model =
    { authState : Register.State
    , authModel : Register.Model
    , loginModel : Login.Model
    , registerModel : Register.Model
    , tabState : Tab.State
    }


type Msg
    = TabMsg Tab.State
    | LoginMsg Login.Msg
    | RegisterMsg Register.Msg


init : Model
init =
    { authState = Register.init
    , authModel = RemoteData.NotAsked
    , loginModel = RemoteData.NotAsked
    , registerModel = RemoteData.NotAsked
    , tabState = Tab.initialState
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TabMsg tabState ->
            ( { model | tabState = tabState }, Cmd.none )

        LoginMsg subMsg ->
            let
                ( subState, subModel, subCmd ) =
                    Login.update subMsg model.authState model.loginModel
            in
            ( { model | authState = subState, authModel = subModel, loginModel = subModel }, Cmd.map LoginMsg subCmd )

        RegisterMsg subMsg ->
            let
                ( subState, subModel, subCmd ) =
                    Register.update subMsg model.authState model.registerModel
            in
            ( { model | authState = subState, authModel = subModel, registerModel = subModel }, Cmd.map RegisterMsg subCmd )


view : Model -> Html Msg
view { authState, authModel, loginModel, registerModel, tabState } =
    Grid.container [ Attr.class "mt-sm-5" ]
        [ Grid.row []
            [ Grid.col []
                [ Tab.config TabMsg
                    |> Tab.items
                        [ Tab.item
                            { id = "loginTab"
                            , link = Tab.link [] [ Html.text "Вход" ]
                            , pane = Tab.pane [] [ Login.view authState loginModel |> Html.map LoginMsg ]
                            }
                        , Tab.item
                            { id = "registerTab"
                            , link = Tab.link [] [ Html.text "Регистрация" ]
                            , pane = Tab.pane [] [ Register.view authState registerModel |> Html.map RegisterMsg ]
                            }
                        ]
                    |> Tab.view tabState
                ]
            ]
        ]
