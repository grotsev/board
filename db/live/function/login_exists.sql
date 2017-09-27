create or replace function login_exists
( login   textfield
) returns boolean
  language sql
  volatile
  security definer
as $function$

  select exists
    ( select
      from staff
      where login = login_exists.login
    )

$function$;

comment on function login_exists(textfield) is
  'Проверить, есть ли уже такой логин';
