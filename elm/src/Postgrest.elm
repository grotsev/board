module Postgrest
    exposing
        ( Error(..)
        , Field
        , Filter
        , HasMany
        , HasOne
        , Limit
        , OrderBy
        , Page
        , Query
        , Relation
        , Resource
        , Response
        , Result
        , Rpc
        , asc
        , bool
        , desc
        , eq
        , field
        , filter
        , first
        , float
        , gt
        , gte
        , hardcoded
        , hasMany
        , hasOne
        , ilike
        , inList
        , include
        , includeMany
        , int
        , is
        , like
        , limitTo
        , list
        , lt
        , lte
        , noLimit
        , not
        , nullable
        , order
        , paginate
        , query
        , resource
        , rpc
        , rpcList
        , select
        , send
        , string
        , uuid
        )

{-| A query builder library for PostgREST.

I recommend looking at the [examples](https://github.com/john-kelly/elm-postgrest/blob/master/examples/Main.elm) before diving into the API or source code.


# Define a Resource

@docs Resource, resource


### Fields

@docs Field, string, int, float, bool, field, nullable


### Relations

@docs Relation, HasOne, hasOne, hasMany, HasMany


# Build a Query

@docs Query, query


### Selecting and Nesting

@docs select, hardcoded, include, includeMany


### Filtering

@docs Filter, filter, like, ilike, eq, gte, gt, lte, lt, inList, is, not


### Ordering

@docs OrderBy, order, asc, desc


### Limiting

@docs Limit, limitTo, noLimit


# Send a Query

@docs list, first


### Pagination

@docs Page, paginate

-}

import Dict
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode exposing (Value)
import Regex
import String
import Uuid exposing (Uuid)


{-| -}
type Resource uniq schema
    = Resource String schema


{-| -}
type Query uniq schema a
    = Query schema Parameters (Decode.Decoder a)


{-| -}
type Parameters
    = Parameters
        { name : String
        , select : List String
        , order : List OrderBy
        , filter : List Filter
        , limit : Limit
        , embedded : List Parameters
        }


{-| -}
type alias Page a =
    { data : List a
    , count : Int
    }


{-| -}
type Field a
    = Field (Decode.Decoder a) (a -> String) String


{-| -}
type OrderBy
    = Asc String
    | Desc String


{-| -}
type Limit
    = NoLimit
    | LimitTo Int


{-| -}
type Condition
    = Like String
    | ILike String
    | Eq String
    | Gte String
    | Gt String
    | Lte String
    | Lt String
    | In (List String)
    | Is String


{-| -}
type Filter
    = Filter Bool Condition String



-- https://wiki.haskell.org/Empty_type
-- https://wiki.haskell.org/Phantom_type


{-| -}
type HasMany
    = HasMany HasMany


{-| -}
type HasOne
    = HasOne HasOne


{-| -}
type Relation a uniq
    = Relation


{-| -}
hasOne : uniq -> Relation HasOne uniq
hasOne uniq =
    Relation


{-| -}
hasMany : uniq -> Relation HasMany uniq
hasMany uniq =
    Relation


{-| -}
resource : uniq -> String -> schema -> Resource uniq schema
resource uniq name schema =
    Resource name schema


{-| -}
field : Decode.Decoder a -> (a -> String) -> String -> Field a
field =
    Field


{-| -}
int : String -> Field Int
int =
    Field Decode.int toString


{-| -}
string : String -> Field String
string =
    Field Decode.string identity


{-| -}
float : String -> Field Float
float =
    Field Decode.float toString


{-| -}
bool : String -> Field Bool
bool =
    Field Decode.bool toString


uuid : String -> Field Uuid
uuid =
    Field Uuid.decoder Uuid.toString


{-| -}
nullable : Field a -> Field (Maybe a)
nullable (Field decoder urlEncoder name) =
    let
        fieldToString maybeVal =
            case maybeVal of
                Just val ->
                    urlEncoder val

                Nothing ->
                    "null"
    in
    Field (Decode.nullable decoder) fieldToString name


{-| -}
query : Resource uniq schema -> (a -> b) -> Query uniq schema (a -> b)
query (Resource name schema) ctor =
    Query schema
        (Parameters { name = name, select = [], filter = [], order = [], limit = NoLimit, embedded = [] })
        (Decode.succeed ctor)


{-| -}
include : (schema1 -> Relation HasOne uniq2) -> Query uniq2 schema2 a -> Query uniq1 schema1 (Maybe a -> b) -> Query uniq1 schema1 b
include _ (Query _ (Parameters subParams) subDecoder) (Query schema (Parameters params) decoder) =
    Query schema
        (Parameters { params | embedded = Parameters subParams :: params.embedded })
        (apply decoder (Decode.nullable (Decode.field subParams.name subDecoder)))


{-| -}
includeMany : (schema1 -> Relation HasMany uniq2) -> Limit -> Query uniq2 schema2 a -> Query uniq1 schema1 (List a -> b) -> Query uniq1 schema1 b
includeMany _ limit (Query _ (Parameters subParams) subDecoder) (Query schema (Parameters params) decoder) =
    Query schema
        (Parameters { params | embedded = Parameters { subParams | limit = limit } :: params.embedded })
        (apply decoder (Decode.field subParams.name (Decode.list subDecoder)))


{-| -}
select : (schema -> Field a) -> Query uniq schema (a -> b) -> Query uniq schema b
select getField (Query schema (Parameters params) queryDecoder) =
    case getField schema of
        Field fieldDecoder _ fieldName ->
            Query schema
                (Parameters { params | select = fieldName :: params.select })
                (apply queryDecoder (Decode.field fieldName fieldDecoder))


{-| -}
hardcoded : a -> Query uniq schema (a -> b) -> Query uniq schema b
hardcoded val (Query schema params queryDecoder) =
    Query schema
        params
        (apply queryDecoder (Decode.succeed val))


{-| -}
limitTo : Int -> Limit
limitTo limit =
    LimitTo limit


{-| -}
noLimit : Limit
noLimit =
    NoLimit


{-| -}
order : List (schema -> OrderBy) -> Query uniq schema a -> Query uniq schema a
order orders (Query schema (Parameters params) decoder) =
    Query schema
        (Parameters { params | order = params.order ++ List.map (\getOrder -> getOrder schema) orders })
        decoder


{-| Apply filters to a query
-}
filter : List (schema -> Filter) -> Query uniq schema a -> Query uniq schema a
filter filters (Query schema (Parameters params) decoder) =
    Query schema
        (Parameters { params | filter = params.filter ++ List.map (\getFilter -> getFilter schema) filters })
        decoder


{-| -}
singleValueFilterFn : (String -> Condition) -> a -> (schema -> Field a) -> schema -> Filter
singleValueFilterFn condCtor condArg getField schema =
    case getField schema of
        Field _ urlEncoder name ->
            Filter False (condCtor (urlEncoder condArg)) name


{-| Simple [pattern matching](https://www.postgresql.org/docs/9.5/static/functions-matching.html#FUNCTIONS-LIKE)
-}
like : String -> (schema -> Field String) -> schema -> Filter
like =
    singleValueFilterFn Like


{-| Case-insensitive `like`
-}
ilike : String -> (schema -> Field String) -> schema -> Filter
ilike =
    singleValueFilterFn ILike


{-| Equals
-}
eq : a -> (schema -> Field a) -> schema -> Filter
eq =
    singleValueFilterFn Eq


{-| Greater than or equal to
-}
gte : a -> (schema -> Field a) -> schema -> Filter
gte =
    singleValueFilterFn Gte


{-| Greater than
-}
gt : a -> (schema -> Field a) -> schema -> Filter
gt =
    singleValueFilterFn Gt


{-| Less than or equal to
-}
lte : a -> (schema -> Field a) -> schema -> Filter
lte =
    singleValueFilterFn Lte


{-| Less than
-}
lt : a -> (schema -> Field a) -> schema -> Filter
lt =
    singleValueFilterFn Lt


{-| In List
-}
inList : List a -> (schema -> Field a) -> schema -> Filter
inList condArgs getField schema =
    case getField schema of
        Field _ urlEncoder name ->
            Filter False (In (List.map urlEncoder condArgs)) name


{-| Is comparison
-}
is : a -> (schema -> Field a) -> schema -> Filter
is =
    singleValueFilterFn Is


{-| Negate a Filter
-}
not : (a -> (schema -> Field a) -> schema -> Filter) -> a -> (schema -> Field a) -> schema -> Filter
not filterCtor val getField schema =
    case filterCtor val getField schema of
        Filter negated cond fieldName ->
            Filter (Basics.not negated) cond fieldName


{-| Ascending
-}
asc : (schema -> Field a) -> schema -> OrderBy
asc getField schema =
    case getField schema of
        Field _ _ name ->
            Asc name


{-| Descending
-}
desc : (schema -> Field a) -> schema -> OrderBy
desc getField schema =
    case getField schema of
        Field _ _ name ->
            Desc name



-- REQUEST --
-- naming for these functions is based off of:
-- http://www.django-rest-framework.org/api-guide/generic-views/#retrieveupdateapiview


{-| Takes `limit`, `url` and a `query`, returns an Http.Request
-}
list : Limit -> String -> Maybe String -> Query uniq schema a -> Http.Request (List a)
list limit url maybeToken (Query _ (Parameters params) decoder) =
    Http.request
        { method = "GET"
        , headers = authorizationHeader maybeToken
        , url = getQueryUrl Nothing url params.name (Parameters { params | limit = limit })
        , body = Http.emptyBody
        , expect = Http.expectJson (Decode.list decoder)
        , timeout = Nothing
        , withCredentials = False
        }


{-| Takes `url` and a `query`, returns an Http.Request
-}
first : String -> Maybe String -> Query uniq schema a -> Http.Request (Maybe a)
first url maybeToken (Query _ (Parameters params) decoder) =
    Http.request
        { method = "GET"
        , headers = authorizationHeader maybeToken ++ singularHeader
        , url = getQueryUrl Nothing url params.name (Parameters params)
        , body = Http.emptyBody
        , expect = Http.expectJson (Decode.nullable decoder)
        , timeout = Nothing
        , withCredentials = False
        }


{-| -}
paginate : { pageNumber : Int, pageSize : Int } -> String -> Maybe String -> Query uniq schema a -> Http.Request (Page a)
paginate { pageNumber, pageSize } url maybeToken (Query _ (Parameters params) decoder) =
    let
        handleResponse response =
            let
                countResult =
                    Dict.get "Content-Range" response.headers
                        |> Result.fromMaybe "No Content-Range Header"
                        |> Result.andThen (Regex.replace Regex.All (Regex.regex ".+\\/") (always "") >> Ok)
                        |> Result.andThen String.toInt

                jsonResult =
                    Decode.decodeString (Decode.list decoder) response.body
            in
            Result.map2 Page jsonResult countResult
    in
    Http.request
        { method = "GET"
        , headers = authorizationHeader maybeToken ++ countExactHeader
        , url =
            getQueryUrl
                (Just <| (pageNumber - 1) * pageSize)
                url
                params.name
                (Parameters { params | limit = LimitTo pageSize })
        , body = Http.emptyBody
        , expect = Http.expectStringResponse handleResponse
        , timeout = Nothing
        , withCredentials = False
        }


getQueryUrl : Maybe Int -> String -> String -> Parameters -> String
getQueryUrl offset url name p =
    let
        trailingSlashUrl =
            if String.right 1 url == "/" then
                url
            else
                url ++ "/"

        ( labeledOrders, labeledFilters, labeledLimits ) =
            labelParams p
    in
    [ selectsToKeyValue p
    , labeledFiltersToKeyValues labeledFilters
    , labeledOrdersToKeyValue labeledOrders
    , labeledLimitsToKeyValue labeledLimits
    , offsetToKeyValue offset
    ]
        |> List.foldl (++) []
        |> queryParamsToUrl (trailingSlashUrl ++ name)


singularHeader : List Http.Header
singularHeader =
    [ Http.header "Accept" "application/vnd.pgrst.object+json" ]


countExactHeader : List Http.Header
countExactHeader =
    [ Http.header "Prefer" "count=exact" ]


authorizationHeader : Maybe String -> List Http.Header
authorizationHeader maybeToken =
    case maybeToken of
        Maybe.Nothing ->
            []

        Just token ->
            [ Http.header "Authorization" <| "Bearer " ++ token ]


selectsToKeyValueHelper : Parameters -> String
selectsToKeyValueHelper (Parameters params) =
    let
        embedded =
            List.map selectsToKeyValueHelper params.embedded

        selection =
            String.join "," (params.select ++ embedded)
    in
    params.name ++ "(" ++ selection ++ ")"


{-| -}
selectsToKeyValue : Parameters -> List ( String, String )
selectsToKeyValue (Parameters params) =
    let
        embedded =
            List.map selectsToKeyValueHelper params.embedded

        selection =
            String.join "," (params.select ++ embedded)
    in
    [ ( "select", selection ) ]


{-| -}
offsetToKeyValue : Maybe Int -> List ( String, String )
offsetToKeyValue maybeOffset =
    case maybeOffset of
        Nothing ->
            []

        Just offset ->
            [ ( "offset", toString offset ) ]


{-| -}
labelParamsHelper : String -> Parameters -> ( List ( String, OrderBy ), List ( String, Filter ), List ( String, Limit ) )
labelParamsHelper prefix (Parameters params) =
    let
        labelWithPrefix : a -> ( String, a )
        labelWithPrefix =
            (,) prefix

        labelNested : Parameters -> ( List ( String, OrderBy ), List ( String, Filter ), List ( String, Limit ) )
        labelNested (Parameters params) =
            labelParamsHelper (prefix ++ params.name ++ ".") (Parameters params)

        appendTriples :
            ( appendable1, appendable2, appendable3 )
            -> ( appendable1, appendable2, appendable3 )
            -> ( appendable1, appendable2, appendable3 )
        appendTriples ( os1, fs1, ls1 ) ( os2, fs2, ls2 ) =
            ( os1 ++ os2, fs1 ++ fs2, ls1 ++ ls2 )

        labeledOrders : List ( String, OrderBy )
        labeledOrders =
            List.map labelWithPrefix params.order

        labeledFilters : List ( String, Filter )
        labeledFilters =
            List.map labelWithPrefix params.filter

        labeledLimit : List ( String, Limit )
        labeledLimit =
            [ labelWithPrefix params.limit ]
    in
    params.embedded
        |> List.map labelNested
        |> List.foldl appendTriples ( labeledOrders, labeledFilters, labeledLimit )


{-| NOTE: What if we were to label when we add?
OrderBy, Filter, and Limit could have a List String which is populated by prefix info whenever
a query is included in another query. We would still need an operation to flatten
the QueryParams, but the logic would be much simpler (would no longer be a weird
concatMap) This may be a good idea / improve performance a smudge (prematureoptimzation much?)
-}
labelParams : Parameters -> ( List ( String, OrderBy ), List ( String, Filter ), List ( String, Limit ) )
labelParams =
    labelParamsHelper ""


{-| -}
labeledFiltersToKeyValues : List ( String, Filter ) -> List ( String, String )
labeledFiltersToKeyValues filters =
    let
        contToString : Condition -> String
        contToString cond =
            case cond of
                Like str ->
                    "like." ++ str

                Eq str ->
                    "eq." ++ str

                Gte str ->
                    "gte." ++ str

                Gt str ->
                    "gt." ++ str

                Lte str ->
                    "lte." ++ str

                Lt str ->
                    "lt." ++ str

                ILike str ->
                    "ilike." ++ str

                In list ->
                    "in." ++ String.join "," list

                Is str ->
                    "is." ++ str

        filterToKeyValue : ( String, Filter ) -> ( String, String )
        filterToKeyValue ( prefix, filter ) =
            case filter of
                Filter True cond key ->
                    ( prefix ++ key, "not." ++ contToString cond )

                Filter False cond key ->
                    ( prefix ++ key, contToString cond )
    in
    List.map filterToKeyValue filters


{-| -}
labeledOrdersToKeyValue : List ( String, OrderBy ) -> List ( String, String )
labeledOrdersToKeyValue orders =
    let
        orderToString : OrderBy -> String
        orderToString order =
            case order of
                Asc name ->
                    name ++ ".asc"

                Desc name ->
                    name ++ ".desc"

        labeledOrderToKeyValue : ( String, List OrderBy ) -> Maybe ( String, String )
        labeledOrderToKeyValue ( prefix, orders ) =
            case orders of
                [] ->
                    Nothing

                _ ->
                    Just
                        ( prefix ++ "order"
                        , orders
                            |> List.map orderToString
                            |> String.join ","
                        )
    in
    orders
        |> List.foldr
            (\( prefix, order ) dict ->
                Dict.update prefix
                    (\maybeOrders ->
                        case maybeOrders of
                            Nothing ->
                                Just [ order ]

                            Just os ->
                                Just (order :: os)
                    )
                    dict
            )
            Dict.empty
        |> Dict.toList
        |> List.filterMap labeledOrderToKeyValue


{-| -}
labeledLimitsToKeyValue : List ( String, Limit ) -> List ( String, String )
labeledLimitsToKeyValue limits =
    let
        toKeyValue : ( String, Limit ) -> Maybe ( String, String )
        toKeyValue labeledLimit =
            case labeledLimit of
                ( _, NoLimit ) ->
                    Nothing

                ( prefix, LimitTo limit ) ->
                    Just ( prefix ++ "limit", toString limit )
    in
    List.filterMap toKeyValue limits


{-| Copy pasta of the old Http.url
<https://github.com/evancz/elm-http/blob/3.0.1/src/Http.elm#L56>
-}
queryParamsToUrl : String -> List ( String, String ) -> String
queryParamsToUrl baseUrl args =
    let
        queryPair : ( String, String ) -> String
        queryPair ( key, value ) =
            queryEscape key ++ "=" ++ queryEscape value

        queryEscape : String -> String
        queryEscape string =
            String.join "+" (String.split "%20" (Http.encodeUri string))
    in
    case args of
        [] ->
            baseUrl

        _ ->
            baseUrl ++ "?" ++ String.join "&" (List.map queryPair args)


{-| Copy pasta of Json.Decode.Extra.apply
-}
apply : Decode.Decoder (a -> b) -> Decode.Decoder a -> Decode.Decoder b
apply =
    Decode.map2 (<|)



-- MY --


type Error
    = InvalidFormat
    | Decode
    | YetExists
    | InvalidPassword
    | UndefinedPostgrest
    | Undefined


type alias Rpc input output =
    { url : String
    , encode : input -> Value
    , decoder : Decode.Decoder output
    }


type alias Result output =
    Result.Result Error output


type alias Response output =
    Maybe (Result output)



-- INTERNAL --


type alias ErrorDescription =
    { hint : Maybe String
    , detail : Maybe String
    , code : Maybe String
    , message : Maybe String
    }


errorDescriptionDecoder : Decode.Decoder ErrorDescription
errorDescriptionDecoder =
    Decode.decode ErrorDescription
        |> Decode.required "hint" (Decode.nullable Decode.string)
        |> Decode.required "details" (Decode.nullable Decode.string)
        |> Decode.required "code" (Decode.nullable Decode.string)
        |> Decode.required "message" (Decode.nullable Decode.string)


fromErrorDescription : ErrorDescription -> Error
fromErrorDescription { hint, detail, code, message } =
    case code of
        -- unique_violation
        -- TODO extract table from message fk_ and value from detail
        Just "23505" ->
            YetExists

        Just "A0001" ->
            InvalidPassword

        _ ->
            UndefinedPostgrest


fromHttpError : Http.Error -> Error
fromHttpError err =
    let
        log =
            Debug.log (toString err)

        withLazyDefault d e =
            case e of
                Err _ ->
                    log d

                Ok err ->
                    err
    in
    case err of
        Http.BadPayload _ _ ->
            log InvalidFormat

        Http.BadStatus { url, status, headers, body } ->
            body
                |> Decode.decodeString errorDescriptionDecoder
                |> Result.map fromErrorDescription
                |> withLazyDefault Decode

        _ ->
            log Undefined



-- PUBLIC --


rpc : Rpc input output -> Maybe String -> input -> Http.Request output
rpc { url, encode, decoder } maybeToken input =
    Http.request
        { method = "POST"
        , headers = singularHeader ++ authorizationHeader maybeToken
        , url = url
        , body = Http.jsonBody (encode input)
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


rpcList : Rpc input output -> Maybe String -> input -> Http.Request (List output)
rpcList { url, encode, decoder } maybeToken input =
    Http.request
        { method = "POST"
        , headers = singularHeader ++ authorizationHeader maybeToken
        , url = url
        , body = Http.jsonBody (encode input)
        , expect = Http.expectJson (Decode.list decoder)
        , timeout = Nothing
        , withCredentials = False
        }


send : (Result output -> msg) -> Http.Request output -> Cmd msg
send onResult =
    Http.send (Result.mapError fromHttpError >> onResult)
