create table staff
( staff      uuid_pk not null
, surname  textfield not null
, name     textfield not null
, dob           date not null

, password_hash text not null

, primary key (staff)
, unique (surname, password_hash)
);

comment on table staff is
  'Сотрудник';
comment on column staff.surname is
  'Фамилия';
comment on column staff.name is
  'Имя';
comment on column staff.dob is
  'Дата рождения';
