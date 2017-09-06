module Encode exposing (date)

import Date exposing (Date)
import Date.Extra.Config.Config_ru_ru exposing (config)
import Date.Extra.Format as Date
import Json.Encode as Encode


date : Date -> Encode.Value
date =
    Date.format config Date.isoDateFormat >> Encode.string
