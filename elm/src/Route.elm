module Route exposing (Route(..), fromLocation, href)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Maybe.Extra as Maybe
import Navigation exposing (Location)
import UrlParser as Url exposing ((</>), s)
import Uuid exposing (Uuid)


--


type R
    = HomeR (Maybe VotingsR)


type VotingsR
    = VotingsR (Maybe VotingR)


type VotingR
    = VotingR Int (Maybe VotingEditR)


type VotingEditR
    = VotingEdit
    | VotingDelete


h : R
h =
    HomeR Nothing


vs : R
vs =
    HomeR <//> VotingsR Nothing


v : R
v =
    HomeR <//> VotingsR <//> VotingR 1 <//> VotingEdit


infixr 7 <//>
(<//>) : (Maybe a -> b) -> a -> b
(<//>) x y =
    x <| Just y


toStr : R -> String
toStr r =
    let
        cont =
            Maybe.unwrap []

        home (HomeR x) =
            "#" :: cont votings x

        votings (VotingsR x) =
            "voting" :: cont voting x

        voting (VotingR uuid x) =
            Basics.toString uuid :: cont votingEdit x

        votingEdit ve =
            case ve of
                VotingEdit ->
                    [ "edit" ]

                VotingDelete ->
                    [ "delete" ]
    in
    String.join "/" <| home r



{-
   --


   type RootT =
       RootT

   r: RootT
   r =

   type VotingsT =
       VotingsT RootT
-}
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
