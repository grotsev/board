module Register exposing (..)

import Date exposing (Date)


type alias Model =
    { login : String
    , password : String
    , passwordAgain : String
    , surname : String
    , name : String
    , dob : Date
    }


type Msg
    = LoginInput String
    | PasswordInput String
    | PasswordAgainInput String
    | SurnameInput String
    | NameInput String
    | DobInput String
