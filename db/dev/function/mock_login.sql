create function mock_login
( seance      uuid
, login    textfield
, password textfield
) returns auth
  language plpgsql
as $function$
declare
  auth auth;
begin
  select (login(seance, login, password)).* into auth;

  if not found then -- TODO check not found select login() or from login()
    raise 'Fail to authenticate(%, %)', login, password;
  end if;

  execute $$set local request.jwt.claim.staff = '$$ || auth.staff || $$'$$;
  execute $$set local request.jwt.claim.role  = '$$ || auth.role  || $$'$$;
  execute $$set local request.jwt.claim.exp   = '$$ || auth.exp   || $$'$$;
  execute $$set local role $$                       || auth.role;

  return auth;
end;
$function$;

comment on function mock_login(uuid,textfield,textfield) is
  'Тестовая версия проверяет, что пароль соответствует логину и генерирует JWT токен под ролью staff на день и инициализирует GUC';
