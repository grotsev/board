module Rpc exposing (..)

import Data.Auth as Auth exposing (Auth)
import Date exposing (Date)
import Encode as Encode
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Postgrest


login :
    Maybe String
    ->
        { a
            | login : String
            , password : String
        }
    -> Http.Request Auth
login =
    Postgrest.rpc
        { url = "http://localhost:3001/rpc/login"
        , single = True
        , encode =
            \{ login, password } ->
                Encode.object
                    [ ( "login", Encode.string login )
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
        , single = True
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
            | login : String
            , password : String
            , surname : String
            , name : String
            , dob : Date
        }
    -> Http.Request Auth
register =
    Postgrest.rpc
        { url = "http://localhost:3001/rpc/register"
        , single = True
        , encode =
            \{ login, password, surname, name, dob } ->
                Encode.object
                    [ ( "login", Encode.string login )
                    , ( "password", Encode.string password )
                    , ( "surname", Encode.string surname )
                    , ( "name", Encode.string name )
                    , ( "dob", Encode.date dob )
                    ]
        , decoder = Auth.decoder
        }
