module Route exposing (Route(..), decode, encode)

import Navigation exposing (Location)
import UrlParser as Url exposing ((</>), s)
import Uuid exposing (Uuid)


type Route
    = Home
    | VotingList
    | Voting Uuid
    | NotFound


decode : Location -> Route
decode location =
    Url.parseHash routeParser location
        |> Maybe.withDefault NotFound


routeParser : Url.Parser (Route -> a) a
routeParser =
    Url.oneOf
        [ Url.map Home Url.top
        , Url.map VotingList <| s "voting"
        , Url.map Voting <| s "voting" </> uuid
        ]


encode : Route -> String
encode route =
    "#"
        ++ (case route of
                Home ->
                    ""

                VotingList ->
                    "voting"

                Voting uuid ->
                    "voting/" ++ Uuid.toString uuid

                NotFound ->
                    "not-found"
           )


uuid : Url.Parser (Uuid -> a) a
uuid =
    Url.custom "UUID" (Result.fromMaybe "Not UUID" << Uuid.fromString)
