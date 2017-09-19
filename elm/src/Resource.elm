module Resource exposing (..)

import PostgRest exposing (resource, string)
import Postgrest exposing (uuid)
import Uuid exposing (Uuid)


type Voting
    = Voting


voting :
    PostgRest.Resource Voting
        { title : PostgRest.Field String
        , voting : PostgRest.Field Uuid.Uuid
        }
voting =
    resource Voting "voting" <|
        { voting = uuid "voting"
        , title = string "title"
        }
