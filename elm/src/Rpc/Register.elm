module Rpc.Register exposing (..)

import Date exposing (Date)
import Encode as Encode
import Json.Decode as Decode
import Json.Decode.Pipeline as DP
import Json.Encode as Encode
import Postgrest exposing (Rpc, rpc)
import RemoteData exposing (WebData)
import Uuid exposing (Uuid)


type alias In a =
    { a
        | login : String
        , password : String
        , surname : String
        , name : String
        , dob : Date
    }


type alias Out =
    { staff : Uuid
    , role : String
    , exp : Int
    , surname : String
    , name : String
    , token : String
    }


call : In a -> Cmd (WebData Out)
call =
    rpc
        { url = "http://localhost:3001/rpc/register"
        , encoder =
            \{ login, password, surname, name, dob } ->
                Encode.object
                    [ ( "login", Encode.string login )
                    , ( "password", Encode.string password )
                    , ( "surname", Encode.string surname )
                    , ( "name", Encode.string name )
                    , ( "dob", Encode.date dob )
                    ]
        , decoder =
            DP.decode Out
                |> DP.required "staff" Uuid.decoder
                |> DP.required "role" Decode.string
                |> DP.required "exp" Decode.int
                |> DP.required "surname" Decode.string
                |> DP.required "name" Decode.string
                |> DP.required "token" Decode.string
        }
