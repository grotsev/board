create function test_workflow
() returns setof text
  language plpgsql
  set role from current
as $function$
begin

  perform register('Surname', 'Name', date '1980-01-31', 'secret');

  return next is(authenticate('Surname', 'secretZ'), null, 'Wrong pasword');
  return next is((authenticate('Surname', 'secret')).role, 'staff', 'Right pasword');

  perform mock_login('Surname', 'secret');

end;
$function$;
