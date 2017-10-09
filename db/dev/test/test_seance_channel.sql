create function test_seance_channel
() returns setof text
  language plpgsql
  set role from current
as $function$
begin

  return next isnt(seance_channel(uuid_generate_v1mc()), null, 'Create seance channel');

end;
$function$;
