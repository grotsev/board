create function authenticate(
  surname textfield,
  password textfield
) returns jwt_token
  language sql
  stable
  strict
  security definer
as $function$

  select sign(
    row_to_json(r), current_setting('board.jwt_secret')
  ) as token
  from (
    select staff         as staff
         , 'staff'::text as role
         , extract(epoch from (now() + interval '1 day'))
                         as exp
    from staff
    where surname = authenticate.surname
      and password_hash = crypt(authenticate.password, password_hash)
  ) r;

$function$;

comment on function authenticate(textfield,textfield) is
  'Проверяет, что пароль соответствует фамилии и возвращает JWT токен под ролью staff на день';
