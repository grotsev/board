create or replace function current_seance
() returns uuid
  language sql
  stable
  security definer
as $function$

  select current_setting('request.jwt.claim.seance')::uuid;

$function$;

comment on function current_seance() is
  'Текущий сеанс, сессия';
