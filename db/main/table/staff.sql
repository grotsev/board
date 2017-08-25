create table staff
( staff      uuid_pk not null
, login    textfield not null
, surname  textfield not null
, name     textfield not null
, dob           date not null

, password_hash text not null

, primary key (staff)
, unique (login)
);

comment on table staff is
  'Сотрудник';
comment on column staff.login is
  'Уникальный логин';
comment on column staff.surname is
  'Фамилия';
comment on column staff.name is
  'Имя';
comment on column staff.dob is
  'Дата рождения';
comment on column staff.password_hash is
  'Хеш пароля';
