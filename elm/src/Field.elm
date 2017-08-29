module Field exposing (..)

import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Html exposing (..)
import Html.Attributes exposing (..)


type alias Msg a =
    { target : a
    , value : Value
    }


type Value
    = IntValue (Result String Int)
    | StringValue String -- TODO shorter rename


type alias Field a =
    { id : a
    , title : String
    }


view : (Msg a -> msg) -> Field a -> Value -> Html msg
view toMsg { id, title } value =
    let
        pack : { value : String, parse : String -> Value }
        pack =
            case value of
                IntValue r ->
                    { value =
                        case r of
                            Result.Ok i ->
                                toString i

                            Result.Err s ->
                                s
                    , parse = String.toInt >> IntValue
                    }

                StringValue s ->
                    { value = s
                    , parse = StringValue
                    }
    in
    Form.group []
        [ Form.label [ for <| toString id ] [ text title ]
        , Input.text
            [ Input.id <| toString id
            , Input.value pack.value
            , Input.onInput <| \x -> toMsg { target = id, value = pack.parse x }
            ]
        ]



{- TODO remove
   form : (Msg -> msg) -> List Field -> Html msg
   form toMsg fields =
       Form.form [] <| List.map (field toMsg) fields
-}


update : Msg a -> Field a -> Value -> Value
update { target, value } { id, title } oldValue =
    if id == target then
        value
    else
        oldValue
