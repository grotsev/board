create function test_staff_channel
() returns setof text
  language plpgsql
  set role from current
as $function$
begin

  perform register('alice', 'secret', 'Лиса', 'Алиса', date '1980-01-31');
  perform mock_login('alice', 'secret');
  return next isnt(staff_channel(), null, 'Filled staff_channel');

end;
$function$;
