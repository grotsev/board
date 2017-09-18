module Rpc exposing (..)

import Data.Auth as Auth exposing (Auth)
import Date exposing (Date)
import Encode as Encode
import Json.Decode as Decode
import Json.Encode as Encode
import Postgrest


login :
    (Postgrest.Result Auth -> msg)
    -> Maybe String
    ->
        { a
            | login : String
            , password : String
        }
    -> Cmd msg
login =
    Postgrest.send
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
    (Postgrest.Result Bool -> msg)
    -> Maybe String
    ->
        { a
            | login : String
        }
    -> Cmd msg
loginExists =
    Postgrest.send
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
    (Postgrest.Result Auth -> msg)
    -> Maybe String
    ->
        { a
            | login : String
            , password : String
            , surname : String
            , name : String
            , dob : Date
        }
    -> Cmd msg
register =
    Postgrest.send
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
