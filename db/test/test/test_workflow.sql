create function test_workflow
() returns setof text
  language plpgsql
  set role from current
as $function$
begin

  perform register('Surname', 'Name', date '1980-01-31', 'secret');
  return next pass('Ok');

  perform authenticate('Surname', 'secret');

end;
$function$;
