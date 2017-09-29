create or replace function register
( login       textfield
, password    textfield
, surname     textfield
, name        textfield
, dob           date
) returns auth
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

  select login(login, password);

$function$;

comment on function register(textfield,textfield,textfield,textfield,date) is
  'Зарегистрировать нового сотрудника';
