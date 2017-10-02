module Resource exposing (..)

import Postgrest as Pg exposing (resource, string, uuid)
import Uuid exposing (Uuid)


type Voting
    = Voting


voting :
    Pg.Resource Voting
        { voting : Pg.Field Uuid.Uuid
        , title : Pg.Field String
        , option : Pg.Relation Pg.HasMany Option
        }
voting =
    resource Voting "voting" <|
        { voting = uuid "voting"
        , title = string "title"
        , option = Pg.hasMany Option
        }


type Option
    = Option


option :
    Pg.Resource Option
        { voting : Pg.Field Uuid.Uuid
        , option : Pg.Field Uuid.Uuid
        , title : Pg.Field String
        , vote : Pg.Relation Pg.HasMany Vote
        }
option =
    resource Option "option" <|
        { voting = uuid "voting"
        , option = uuid "option"
        , title = string "title"
        , vote = Pg.hasMany Vote
        }


type Vote
    = Vote


vote :
    Pg.Resource Vote
        { staff : Pg.Relation Pg.HasMany Staff
        }
vote =
    resource Vote "vote" <|
        { staff = Pg.hasMany Staff
        }


type Staff
    = Staff


staff :
    Pg.Resource Staff
        { staff : Pg.Field Uuid.Uuid
        , login : Pg.Field String
        , surname : Pg.Field String
        , name : Pg.Field String
        }
staff =
    resource Staff "staff" <|
        { staff = uuid "staff"
        , login = string "login"
        , surname = string "surname"
        , name = string "name"

        --, dob = date "dob" --TODO
        }
