create function test_workflow
() returns setof text
  language plpgsql
  set role from current
as $function$
begin

  perform register('Гроцев', 'Денис', date '1983-08-24', 'secret');
  return next pass('Ok');

end;
$function$;
