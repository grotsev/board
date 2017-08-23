create function mock_login
( surname  textfield
, password textfield
) returns text
  language plpgsql
as $function$
declare
  token jwt_token;
begin
  select (authenticate(surname, password)).* into token;

  if (token is null) then
    raise 'Fail to authenticate(%, %)', surname, password;
  end if;

  execute $$set local request.jwt.claim.staff = '$$ || token.staff || $$'$$;
  execute $$set local request.jwt.claim.role  = '$$ || token.role  || $$'$$;
  execute $$set local request.jwt.claim.exp   = '$$ || token.exp   || $$'$$;
  execute $$set local role $$ || token.role;

  return login(surname, password);
end;
$function$;

comment on function mock_login(textfield,textfield) is
  'Тестовая версия проверяет, что пароль соответствует фамилии и возвращает JWT токен под ролью staff на день и инициализирует GUC';
