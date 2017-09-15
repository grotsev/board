module Data.Auth exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as DP
import Uuid exposing (Uuid)


type alias Auth =
    { staff : Uuid
    , role : String
    , exp : Int
    , surname : String
    , name : String
    , token : String
    }


decoder : Decoder Auth
decoder =
    DP.decode Auth
        |> DP.required "staff" Uuid.decoder
        |> DP.required "role" Decode.string
        |> DP.required "exp" Decode.int
        |> DP.required "surname" Decode.string
        |> DP.required "name" Decode.string
        |> DP.required "token" Decode.string
