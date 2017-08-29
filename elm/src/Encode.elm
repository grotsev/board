module Encode exposing (..)

import Date exposing (Date)
import Date.Extra as Date
import Json.Encode as Encode


date : Date -> Encode.Value
date =
    Date.toFormattedString "yyyy-MM-dd" >> Encode.string
