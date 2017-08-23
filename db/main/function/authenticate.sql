create function authenticate
( surname  textfield
, password textfield
) returns jwt_token
  language sql
  stable
  strict
  security definer
as $function$

  select (staff
       , 'staff'::name
       , extract(epoch from (now() + interval '1 day'))
      )::jwt_token
  from staff
  where surname = authenticate.surname
    and password_hash = crypt(authenticate.password, password_hash)

$function$;

comment on function authenticate(textfield,textfield) is
  'Проверяет, что пароль соответствует фамилии и возвращает JWT токен под ролью staff на день';
