module Validate exposing (Status(..), Validation, concat, filled, length, none, required, secure)


type Status
    = None
    | Success
    | Warning
    | Danger


type alias Validation =
    { status : Status
    , error : Maybe String
    }


required : Maybe a -> Validation
required maybe =
    case maybe of
        Nothing ->
            Validation Danger <| Just "Обязательное поле"

        Just _ ->
            Validation Success Nothing


length : Int -> String -> Validation
length base s =
    let
        l =
            String.length s
    in
    if l < base then
        Validation Danger <| Just "Короткая длина"
    else
        Validation Success Nothing


filled : String -> Validation
filled s =
    if String.isEmpty s then
        Validation Danger <| Just "Обязательное поле"
    else
        Validation Success Nothing


secure : String -> Validation
secure s =
    let
        l =
            String.length s
    in
    if l < 6 then
        Validation Danger <| Just "Слишком короткий пароль"
    else if l < 12 then
        Validation Warning <| Just "Лучше пароль ещё длиннее"
    else
        Validation Success Nothing


none : Validation
none =
    Validation None Nothing


weight : Status -> Int
weight status =
    case status of
        None ->
            0

        Success ->
            1

        Warning ->
            2

        Danger ->
            3


max : Validation -> Validation -> Validation
max x y =
    if weight x.status >= weight y.status then
        x
    else
        y


concat : List Validation -> Validation
concat list =
    case list of
        x :: y :: xs ->
            concat <| max x y :: xs

        x :: [] ->
            x

        [] ->
            none
