create function register
( surname  textfield
, name     textfield
, dob           date
, password textfield
) returns void
  language sql
  volatile
  security definer
as $function$
begin

  insert into staff
    ( surname
    , name
    , dob
    , password_hash
    )
  values
    ( register.surname
    , register.name
    , register.dob
    , crypt(register.password, gen_salt('bf'))
    );

end;
$function$;

comment on function register(textfield,textfield,date,textfield) is
  'Зарегистрировать нового сотрудника';
