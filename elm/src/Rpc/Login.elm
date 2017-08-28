module Rpc.Login exposing (..)

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
        { url = "http://localhost:3001/rpc/login"
        , encoder =
            \{ login, password } ->
                Encode.object
                    [ ( "login", Encode.string login )
                    , ( "password", Encode.string password )
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
