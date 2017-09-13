module Route exposing (Route(..), fromLocation, href)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Navigation exposing (Location)
import UrlParser as Url exposing ((</>), s)
import Uuid exposing (Uuid)


-- CORE --


type Route
    = Home
    | VotingList
    | Voting Uuid


parser : Url.Parser (Route -> a) a
parser =
    Url.oneOf
        [ Url.map Home (s "")
        , Url.map VotingList (s "voting")
        , Url.map Voting (s "voting" </> uuid)
        ]


toString : Route -> String
toString route =
    let
        pieces =
            case route of
                Home ->
                    [ "" ]

                VotingList ->
                    [ "voting" ]

                Voting uuid ->
                    [ "voting", Uuid.toString uuid ]
    in
    "#/" ++ String.join "/" pieces



-- INTERNAL HELPERS --


uuid : Url.Parser (Uuid -> a) a
uuid =
    Url.custom "UUID" (Result.fromMaybe "Not UUID" << Uuid.fromString)



-- PUBLIC HELPERS --


href : Route -> Attribute msg
href route =
    Attr.href (toString route)


fromLocation : Location -> Maybe Route
fromLocation location =
    if String.isEmpty location.hash then
        Just Home
    else
        Url.parseHash parser location
