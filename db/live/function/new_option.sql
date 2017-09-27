create or replace function new_option
( voting uuid
, title textfield
) returns uuid
  language sql
  volatile
  strict
  security definer
as $function$

  insert into option
    ( voting
    , title
    )
  values
    ( new_option.voting
    , new_option.title
    )
  returning option;

$function$;

comment on function new_option(uuid,textfield) is
  'Создаёт новый вариант выбора';
