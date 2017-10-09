create function test_workflow
() returns setof text
  language plpgsql
  set role from current
as $function$
<<function>>
declare
  voting uuid;
  option_flower uuid;
  option_cert uuid;
  option_mars uuid;
  option_snickers uuid;
begin

  perform register(uuid_generate_v1mc(), 'alice', 'secret', 'Лиса', 'Алиса', date '1980-01-31');
  perform register(uuid_generate_v1mc(), 'bob', 'secret', 'Губка', 'Боб', date '1980-02-01');
  perform register(uuid_generate_v1mc(), 'charlie', 'secret', 'Шоколадный', 'Чарли', date '1980-02-02');

  return next throws_ok($$select login(uuid_generate_v1mc(), 'alice', 'secreZ')$$, 'A0001', 'Invalid login and password', 'Wrong pasword');
  return next is((login(uuid_generate_v1mc(), 'alice', 'secret')).role, 'staff', 'Right pasword');

  -- Birthday of Alice
  perform mock_login(uuid_generate_v1mc(), 'bob', 'secret');
  select new_voting('День рождения 2017-01-31 Алиса') into voting;
  select new_option(voting, 'Цветы') into option_flower;
  select new_option(voting, 'Подарочный сертификат') into option_cert;
  perform new_vote(voting, option_flower);

  perform mock_login(uuid_generate_v1mc(), 'charlie', 'secret');
  perform new_vote(voting, option_flower);
  perform new_vote(voting, option_cert);

  -- Birthday of Charlie
  perform mock_login(uuid_generate_v1mc(), 'alice', 'secret');
  select new_voting('День рождения 2017-02-02 Чарли') into voting;
  select new_option(voting, 'Марс') into option_mars;
  select new_option(voting, 'Сникерс') into option_snickers;
  perform new_vote(voting, option_mars);

end;
$function$;
