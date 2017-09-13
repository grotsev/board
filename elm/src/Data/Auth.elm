module Data.Auth exposing (..)

import Uuid exposing (Uuid)


type alias Auth =
    { staff : Uuid
    , role : String
    , exp : Int
    , surname : String
    , name : String
    , token : String
    }
