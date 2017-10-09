create function test_channel
() returns setof text
  language plpgsql
  set role from current
as $function$
begin

  return next isnt(channel('zzz'), null, 'Create channel');

end;
$function$;
