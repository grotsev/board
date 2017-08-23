create table option
( voting          uuid not null
, option       uuid_pk not null
, title      textfield not null
, description textarea

, primary key (voting, option)
, foreign key (voting) references voting
);

comment on table option is
  'Вариант выбора';
comment on column option.title is
  'Название';
comment on column option.description is
  'Описание';
