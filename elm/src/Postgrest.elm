module Postgrest exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as DP
import Json.Encode as Encode exposing (Value)
import RemoteData exposing (WebData)


type alias Rpc a b =
    { url : String
    , encoder : a -> Encode.Value
    , decoder : Decode.Decoder b
    }


type alias Error =
    { hint : Maybe String
    , detail : Maybe String
    , code : Maybe String
    , message : Maybe String
    }


rpc : Rpc a b -> a -> Cmd (WebData b)
rpc { encoder, decoder, url } request =
    RemoteData.sendRequest <|
        Http.request
            { method = "POST"
            , headers = [ Http.header "Accept" "application/vnd.pgrst.object+json" ]
            , url = url
            , body = Http.jsonBody <| encoder request
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


rpcList : Rpc a b -> a -> Cmd (WebData (List b))
rpcList { encoder, decoder, url } request =
    RemoteData.sendRequest <|
        Http.post url
            (Http.jsonBody <| encoder request)
            (Decode.list decoder)


errorDecoder : Decode.Decoder Error
errorDecoder =
    DP.decode Error
        |> DP.required "hint" (Decode.nullable Decode.string)
        |> DP.required "detail" (Decode.nullable Decode.string)
        |> DP.required "code" (Decode.nullable Decode.string)
        |> DP.required "message" (Decode.nullable Decode.string)
