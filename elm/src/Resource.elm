module Resource exposing (..)

import Postgrest as Pg exposing (resource, string, uuid)
import Uuid exposing (Uuid)


type Voting
    = Voting


voting :
    Pg.Resource Voting
        { title : Pg.Field String
        , voting : Pg.Field Uuid.Uuid
        }
voting =
    resource Voting "voting" <|
        { voting = uuid "voting"
        , title = string "title"
        }
