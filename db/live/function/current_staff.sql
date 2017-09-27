create or replace function current_staff
() returns uuid
  language sql
  stable
  security definer
as $function$

  select current_setting('request.jwt.claim.staff')::uuid;

$function$;

comment on function current_staff() is
  'Текущий сотрудник';
