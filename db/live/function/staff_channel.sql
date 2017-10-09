create or replace function staff_channel
() returns text
  language sql
  stable
  strict
  security definer
as $function$

  select sign
    ( row_to_json(r)
    , current_setting('board.jwt_secret')
    )
  from (
    select 'staff/' || current_staff() as channel
         , 'r'                         as mode
  ) r;

$function$;

comment on function staff_channel() is
  'Возвращает JWT приватного Web Socket канала для сотрудника';
