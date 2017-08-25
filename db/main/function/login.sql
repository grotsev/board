create function login
( login       textfield
, password    textfield
, out staff        uuid
, out role         name
, out exp          int4
, out surname textfield
, out name    textfield
, out token        text
)
  language sql
  stable
  strict
  security definer
as $function$

  select t.*
       , sign
        ( row_to_json(row( staff, role, exp )::jwt_token)
        , current_setting('board.jwt_secret')
        ) as token
  from (
    select staff
         , 'staff'::name                                        as role
         , extract(epoch from (now() + interval '1 day'))::int4 as exp
         , surname
         , name
    from staff
    where login = login.login
      and password_hash = crypt(login.password, password_hash)
    ) t

$function$;

comment on function login(textfield,textfield) is
  'Проверяет, что пароль соответствует логину и генерирует JWT токен под ролью staff на день';
