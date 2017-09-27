create or replace function register
( login       textfield
, password    textfield
, in out surname     textfield
, in out name        textfield
, dob           date
, out staff        uuid
, out role         name
, out exp          int4
, out token        text
) returns record
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

  select surname, name, staff, role, exp, token
  from login(login, password) t(staff, role, exp, surname, name, token);

$function$;

comment on function register(textfield,textfield,textfield,textfield,date) is
  'Зарегистрировать нового сотрудника';
