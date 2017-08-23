create function login
( surname  textfield
, password textfield
) returns text
  language sql
  stable
  strict
  security definer
as $function$

  select sign(
    row_to_json(authenticate(surname, password))
  , current_setting('board.jwt_secret')
  );

$function$;

comment on function login(textfield,textfield) is
  'Проверяет, что пароль соответствует фамилии и возвращает JWT токен под ролью staff на день';
