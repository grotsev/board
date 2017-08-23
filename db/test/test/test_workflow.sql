create function test_workflow
() returns setof text
  language plpgsql
  set role from current
as $function$
begin

  perform register('Surname', 'Name', date '1980-01-31', 'secret');

  return next is(authenticate('Surname', 'secretZ'), null, 'Wrong pasword');
  return next isnt(authenticate('Surname', 'secret'), null, 'Right pasword');

end;
$function$;
