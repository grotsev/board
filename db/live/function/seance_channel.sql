create or replace function seance_channel
( seance uuid
) returns text
  language sql
  stable
  strict
  security definer
as $function$

  select channel('seance/' || seance);

$function$;

comment on function seance_channel(uuid) is
  'JWT сеансового Web Socket канала';
