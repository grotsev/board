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
begin

  perform register('pet', 'Петров', 'Иван', date '1980-01-31', 'secret');
  perform register('nic', 'Николаева', 'Вера', date '1980-02-01', 'secret');

  return next is((login('pet', 'secreZ')).role, null, 'Wrong pasword');
  return next is((login('pet', 'secret')).role, 'staff', 'Right pasword');

  perform mock_login('pet', 'secret');

  select new_voting('День рождения Веры') into voting;

  select new_option(voting, 'Цветы') into option_flower;
  select new_option(voting, 'Подарочный сертификат') into option_cert;

  perform new_vote(voting, option_flower);

end;
$function$;
