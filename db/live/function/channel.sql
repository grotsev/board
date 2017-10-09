create or replace function channel
( name text
) returns text
  language sql
  stable
  strict
  security definer
as $function$

  with data(channel, mode) as (
    values (name   , 'r' )
  )
  select sign
    ( row_to_json(data)
    , current_setting('board.jwt_secret')
    )
  from data;

$function$;

comment on function channel(text) is
  'JWT именованного Web Socket канала';
