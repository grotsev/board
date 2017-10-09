module Rpc exposing (..)

import Data.Auth as Auth exposing (Auth)
import Date exposing (Date)
import Encode as Encode
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Postgrest
import Uuid exposing (Uuid)


seanceChannel :
    Maybe String
    ->
        { a
            | seance : Uuid
        }
    -> Http.Request String
seanceChannel =
    Postgrest.rpc
        { url = "http://localhost:3001/rpc/seance_channel"
        , encode =
            \{ seance } ->
                Encode.object
                    [ ( "seance", Uuid.encode seance )
                    ]
        , decoder = Decode.at [ "seance_channel" ] Decode.string
        }


login :
    Maybe String
    ->
        { a
            | seance : Uuid
            , login : String
            , password : String
        }
    -> Http.Request Auth
login =
    Postgrest.rpc
        { url = "http://localhost:3001/rpc/login"
        , encode =
            \{ seance, login, password } ->
                Encode.object
                    [ ( "seance", Uuid.encode seance )
                    , ( "login", Encode.string login )
                    , ( "password", Encode.string password )
                    ]
        , decoder = Auth.decoder
        }


loginExists :
    Maybe String
    ->
        { a
            | login : String
        }
    -> Http.Request Bool
loginExists =
    Postgrest.rpc
        { url = "http://localhost:3001/rpc/login_exists"
        , encode =
            \{ login } ->
                Encode.object
                    [ ( "login", Encode.string login )
                    ]
        , decoder =
            Decode.bool
        }


register :
    Maybe String
    ->
        { a
            | seance : Uuid
            , login : String
            , password : String
            , surname : String
            , name : String
            , dob : Date
        }
    -> Http.Request Auth
register =
    Postgrest.rpc
        { url = "http://localhost:3001/rpc/register"
        , encode =
            \{ seance, login, password, surname, name, dob } ->
                Encode.object
                    [ ( "seance", Uuid.encode seance )
                    , ( "login", Encode.string login )
                    , ( "password", Encode.string password )
                    , ( "surname", Encode.string surname )
                    , ( "name", Encode.string name )
                    , ( "dob", Encode.date dob )
                    ]
        , decoder = Auth.decoder
        }
