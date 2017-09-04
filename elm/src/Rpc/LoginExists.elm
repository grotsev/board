module Rpc.LoginExists exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode
import Postgrest exposing (Rpc, rpc)
import RemoteData exposing (WebData)


type alias In a =
    { a
        | login : String
    }


type alias Out =
    Bool


call : In a -> Cmd (WebData Out)
call =
    rpc
        { url = "http://localhost:3001/rpc/login"
        , encoder =
            \{ login } ->
                Encode.object
                    [ ( "login", Encode.string login )
                    ]
        , decoder =
            Decode.bool
        }
