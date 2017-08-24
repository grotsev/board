create function new_vote
( voting uuid
, option uuid
) returns void
  language sql
  volatile
  strict
  security definer
as $function$

  insert into vote (voting, staff, option)
  values
    ( new_vote.voting
    , current_staff()
    , new_vote.option
    );

$function$;

comment on function new_vote(uuid,uuid) is
  'Проголосовать за вариант в голосовании от лица текущего сотрудника';
