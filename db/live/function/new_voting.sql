create or replace function new_voting
( title textfield
) returns uuid
  language sql
  volatile
  strict
  security definer
as $function$

  insert into voting (title)
  values (new_voting.title)
  returning voting;

$function$;

comment on function new_voting(textfield) is
  'Создаёт новое голосование';
