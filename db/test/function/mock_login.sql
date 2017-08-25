create function mock_login
( login    textfield
, password textfield
, out staff        uuid
, out role         name
, out exp          int4
, out surname textfield
, out name    textfield
, out token        text
)
  language plpgsql
as $function$
begin
  select (login(login, password)).* into staff, role, exp, surname, name, token;

  if not found then -- TODO check not found select login() or from login()
    raise 'Fail to authenticate(%, %)', login, password;
  end if;

  execute $$set local request.jwt.claim.staff = '$$ || staff || $$'$$;
  execute $$set local request.jwt.claim.role  = '$$ || role  || $$'$$;
  execute $$set local request.jwt.claim.exp   = '$$ || exp   || $$'$$;
  execute $$set local role $$ || role;
end;
$function$;

comment on function mock_login(textfield,textfield) is
  'Тестовая версия проверяет, что пароль соответствует логину и генерирует JWT токен под ролью staff на день и инициализирует GUC';
