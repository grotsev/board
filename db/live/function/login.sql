create or replace function login
( login       textfield
, password    textfield
) returns auth
  language plpgsql
  stable
  strict
  security definer
as $function$
declare
  auth auth;
begin

  select t.staff
       , t.role
       , t.exp
       , t.surname
       , t.name
       , sign
        ( row_to_json(row( t.staff, t.role, t.exp )::jwt_token)
        , current_setting('board.jwt_secret')
        ) as token
  from (
    select t.staff
         , 'staff'::name                                        as role
         , extract(epoch from (now() + interval '1 day'))::int4 as exp
         , t.surname
         , t.name
    from staff t
    where t.login = login.login
      and password_hash = crypt(login.password, password_hash)
    ) t
  into auth;

  if not found then
    raise sqlstate 'A0001' using
      message = 'Invalid login and password',
      detail = login,
      hint = 'Provide correct login and password';
  end if;

  return auth;

end;
$function$;

comment on function login(textfield,textfield) is
  'Проверяет, что пароль соответствует логину и генерирует JWT токен под ролью staff на день';
