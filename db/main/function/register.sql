create function register
( login    textfield
, surname  textfield
, name     textfield
, dob           date
, password textfield
) returns void
  language sql
  volatile
  security definer
as $function$

  -- TODO reject_insecure(register.password)
  -- TODO or check secure() and trigger on update, insert do crypt

  insert into staff
    ( login
    , surname
    , name
    , dob
    , password_hash
    )
  values
    ( register.login
    , register.surname
    , register.name
    , register.dob
    , crypt(register.password, gen_salt('bf'))
    );

$function$;

comment on function register(textfield,textfield,textfield,date,textfield) is
  'Зарегистрировать нового сотрудника';
